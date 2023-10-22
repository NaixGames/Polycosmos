from __future__ import annotations
import atexit
import os
import sys
import asyncio
import random
import shutil
from typing import Tuple, List, Iterable, Dict
import threading

import ModuleUpdate
ModuleUpdate.update()

import websockets

import Utils
import json
import logging

if __name__ == "__main__":
    Utils.init_logging("HadesClient", exception_logger="Client")

from NetUtils import NetworkItem, ClientStatus
from CommonClient import gui_enabled, logger, get_base_parser, ClientCommandProcessor, \
    CommonContext, server_loop
import os
import ssl

from tkinter import Tk
from tkinter.filedialog import askdirectory
hadespath = askdirectory(title='Select Hades Folder')

logger = logging.getLogger("Hades")

sys.path.insert(1, hadespath)
os.chdir(hadespath)

from StyxScribe import StyxScribe

subsume = StyxScribe("Hades")
subsume.LoadPlugins()


styx_scribe_recieve_prefix = "Polycosmos to Client:"
styx_scribe_send_prefix = "Client to Polycosmos:"


#Test message and hook just to check styx scribe is working
def handleMessageTest(message):
    print(message)

#writting "Test:" + str con the styx console should trigger a print message
subsume.AddHook(handleMessageTest, "Test:", "HadesClient" )

def to_styx_scribe(message):
    subsume.Send(styx_scribe_send_prefix + " " + message)


#Here we implement methods for the client

class HadesClientCommandProcessor(ClientCommandProcessor):
    def _cmd_resync(self):
        """Manually trigger a resync."""
        self.output(f"Syncing items.")
        self.ctx.syncing = True


class HadesContext(CommonContext):

    # ----------------- Client start up and ending section starts  --------------------------------
    command_processor = HadesClientCommandProcessor
    game = "Hades"
    items_handling = 0b111  # full remote
    cache_items_received_names = [] 
    hades_slot_data = None
    players_id_to_name = None
    creating_location_to_item_mapping = False
    missing_locations_cache = []
    checked_locations_cache = []
    location_name_to_id = None
    locations_received_names = []
    location_to_item_map_created = False
    deathlink_pending = False
    deathlink_enabled = False
    is_connected = False
    is_receiving_items_from_connect_package = False

    dictionary_filler_items = {
        "Darkness": 0,
        "Keys": 0,
    }

    def __init__(self, server_address, password):
        super(HadesContext, self).__init__(server_address, password)
        self.send_index: int = 0
        self.syncing = False
        self.awaiting_bridge = False
        #Load here any data you might need the client to know about

        #Add hook to comunicate with StyxScribe
        subsume.AddHook(self.send_location_check_to_server, styx_scribe_recieve_prefix + "Locations updated:", "HadesClient" )
        subsume.AddHook(self.on_game_completion, styx_scribe_recieve_prefix + "Hades defeated", "HadesClient" )
        subsume.AddHook(self.check_connection_and_send_items_and_request_location_dictionary, styx_scribe_recieve_prefix + "Data requested", "HadesClient" )
        #Add hook to delete filler items once obtained so they are not triggered more than once
        subsume.AddHook(self.on_filler_item_recieved_signal, styx_scribe_recieve_prefix + "Got filler item:", "HadesClient")
        #hook to send deathlink to other player when Zag dies
        subsume.AddHook(self.send_death, styx_scribe_recieve_prefix + "Zag died", "HadesClient" )

    async def server_auth(self, password_requested: bool = False):
        #This is called to autentificate with the server.
        if password_requested and not self.password:
            await super(HadesContext, self).server_auth(password_requested)
        await self.get_username()
        await self.send_connect()

    async def connection_closed(self):
        #This is called when the connection is closed (duh!)
        #This will send the message always, but only process by Styx scribe if actually in game
        subsume.Send(styx_scribe_send_prefix+"Connection Error")
        self.is_connected=False
        self.is_receiving_items_from_connect_package=False
        await super(HadesContext, self).connection_closed()
        

    #Do not touch this
    @property
    def endpoints(self):
        if self.server:
            return [self.server]
        else:
            return []

    async def shutdown(self):
        #What is called when the app gets shutdown
        subsume.close()
        await super(HadesContext, self).shutdown()
    
    # ----------------- Client start up and ending section end  --------------------------------


    ## TODO: IMPLEMENT OPTIONS. NOTE THOSE ARE ALL CONTAINED IN hades_slot_data AS PART OF THE DICTIONARY DATA


    # ----------------- Package Management section starts --------------------------------
    
    def on_package(self, cmd: str, args: dict):
        #This is what is done when a package arrives. 
        if cmd in {"Connected"}:
            #What should be done in a connection package
            self.missing_locations_cache = args['missing_locations']
            self.checked_locations_cache = args['checked_locations']
            self.hades_slot_data = args['slot_data']  
            self.location_name_to_id = {name: idnumber for idnumber, name, in self.location_names.items()}
            if 'death_link' in self.hades_slot_data and self.hades_slot_data['death_link']:
                self.set_deathlink = True
                self.deathlink_enabled = True
            self.is_connected=True
            self.is_receiving_items_from_connect_package=True
            asyncio.create_task(self.send_msgs([{"cmd": "Get", "keys": ["hades:"+str(self.slot)+":filler:Darkness",
                                                     "hades:"+str(self.slot)+":filler:Keys"]}]))

        if cmd in {"RoomInfo"}:
            #What should be done when room info is sent. 
            self.seed_name = args['seed_name']

        if cmd in {"ReceivedItems"}:
            #What should be done when an Item is recieved.
            #NOTE THIS GETS ALL ITEMS THAT HAVE BEEN RECIEVED! WE USE THIS FOR RESYNCS!
            for item in args['items']:
                self.cache_items_received_names += [self.item_names[item.item]]
            msg = f"Received {', '.join([self.item_names[item.item] for item in args['items']])}"
            #We ignore sending the package to hades if just connected, since the game it not ready for it (and will request it itself later)
            if (self.is_receiving_items_from_connect_package):
                return;
            self.send_items()

        if cmd in {"LocationInfo"}:
            if self.creating_location_to_item_mapping:
                self.creating_location_to_item_mapping=False
                self.create_location_to_item_dictionary(args['locations'])
                return
            super().on_package(cmd, args)

        if cmd in {"Retrieved"}:
            if "hades:"+str(self.slot)+":filler:Darkness" in args["keys"]:
                if args["keys"]["hades:"+str(self.slot)+":filler:Darkness"] is not None:
                    self.dictionary_filler_items["Darkness"] = args["keys"]["hades:"+str(self.slot)+":filler:Darkness"]
            if "hades:"+str(self.slot)+":filler:Keys" in args["keys"]:
                if args["keys"]["hades:"+str(self.slot)+":filler:Keys"] is not None:
                    self.dictionary_filler_items["Keys"] = args["keys"]["hades:"+str(self.slot)+":filler:Keys"]
    

    def send_items(self):
        #we filter the filler items according to how many we have recieved
        self.filter_filler_items_from_cache()

        payload_message = self.parse_array_to_string(self.cache_items_received_names)
        subsume.Send(styx_scribe_send_prefix+"Items Updated:" + payload_message)


    def parse_array_to_string(self, array_of_items):
        message = ""
        for itemname in array_of_items:
            message += itemname
            message += ","
        return message

    async def send_location_check_to_server(self, message):
       #First we wait to avoid desync from happening
       sendingLocationsId = []
    
       #TODO: make this support an array and not only one location
       sendingLocationsName = message
       sendingLocationsId += [self.location_name_to_id[sendingLocationsName]]

       payload_message = [{"cmd": 'LocationChecks', "locations": sendingLocationsId}]
       await self.send_msgs(payload_message)

    async def check_connection_and_send_items_and_request_location_dictionary(self, message):
        if (self.check_for_connection()):
            self.is_receiving_items_from_connect_package=False
            await self.send_items_and_request_location_dictionary(message)

    async def send_items_and_request_location_dictionary(self, message):
        #send items that were already cached in connect
        self.send_items()
        #Construct location to item mapping
        self.locations_received_names = []
        for location in self.checked_locations_cache:
           self.locations_received_names += [self.location_names[location]]
        subsume.Modules.StyxScribeShared.Root["LocationsUnlocked"] = self.locations_received_names
        self.request_location_to_item_dictionary()

    def request_location_to_item_dictionary(self):
        self.creating_location_to_item_mapping = True
        request = self.missing_locations_cache + self.checked_locations_cache
        asyncio.create_task(self.send_msgs([{"cmd": "LocationScouts", "locations": request, "create_as_hint": 0}]))

    def create_location_to_item_dictionary(self, itemsdict):
        itemmap = {}
        for networkitem in itemsdict:
            itemmap[self.location_names[networkitem.location]] =  self.player_names[networkitem.player] + "-" + self.item_names[networkitem.item]
        subsume.Modules.StyxScribeShared.Root["LocationToItemMap"] = itemmap
        self.creating_location_to_item_dictionary = False
        subsume.Send(styx_scribe_send_prefix + "Data package finished")

    # ----------------- Package Management section ends --------------------------------

    # ------------------ Section for dealing with filler items not getting obtianed more than once ------------

    async def on_filler_item_recieved_signal(self, message):
        self.dictionary_filler_items[message] = self.dictionary_filler_items[message]+1
        await self.send_msgs([{"cmd": "Set", "key": "hades:"+str(self.slot)+":filler:"+message,"want_reply": False, "default": 1, "operations": [{"operation": "add","value": 1}]}])

    def filter_filler_items_from_cache(self):
        for key in self.dictionary_filler_items:
            for i in range(0,self.dictionary_filler_items[key]):
                if key in self.cache_items_received_names:
                    self.cache_items_received_names.remove(key)
                
    # ----------------- Filler items section ended --------------------------------
    

    #-------------deathlink section started --------------------------------
    def on_deathlink(self, data: dict):
        #What should be done when a deathlink message is recieved
        self.deathlink_pending = True
        super().on_deathlink(data)
        to_styx_scribe(styx_scribe_send_prefix + ":Deathlink recieved")
        asyncio.create_task(self.wait_and_lower_deathlink_flag())

    def send_death(self, death_text: str = ""):
        #What should be done to send a death link
        #Avoid sending death if we died from a deathlink
        if (self.deathlink_enabled==False or self.deathlink_pending==True):
            return
        asyncio.create_task(super().send_death(death_text))

    async def wait_and_lower_deathlink_flag(self):
        await asyncio.sleep(3)     
        self.deathlink_pending = False

    #-------------deathlink section ended


    #-------------game completion section starts
    #this is to detect game completion. Note that on futher updates this will need --------------------------------
    #to be changed to adapt to new game completion conditions
    def on_game_completion(self, message):
        asyncio.create_task(self.send_msgs([{"cmd": "StatusUpdate", "status": ClientStatus.CLIENT_GOAL}]))
        self.finished_game = True
    #-------------game completion section ended --------------------------------


    #------------ game connection QoL handling
    def check_for_connection(self):
        if (self.is_connected == False):
            subsume.Send(styx_scribe_send_prefix+"Connection Error")
            return False
        return True

    #------------

def print_error_and_close(msg):
    logger.error("Error: " + msg)
    Utils.messagebox("Error", msg, error=True)
    sys.exit(1)


#  ------------ Methods to start the client + Hades + StyxScribe ------------

def launch_hades():
    subsume.Launch()


if __name__ == '__main__':
    async def main(args):
            ctx = HadesContext(args.connect, args.password)
            ctx.server_task = asyncio.create_task(server_loop(ctx), name="server loop")
            if gui_enabled:
                ctx.run_gui()
            ctx.run_cli()

            await ctx.exit_event.wait()
            ctx.server_address = None

            await ctx.shutdown()

    import colorama
    
    thr = threading.Thread(target=launch_hades, args=(), kwargs={})
    thr.start()
    parser = get_base_parser()
    args = parser.parse_args()
    colorama.init()
    asyncio.run(main(args))
    colorama.deinit()
