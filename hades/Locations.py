import typing

from BaseClasses import Location


hades_base_location_id = 5093427000

#This is basically location + score checks. Keeping this as a variable to have easier time keeping
max_number_room_checks = 1072

#Making global tables that can be used for unit testing.

global location_table_tartarus 
location_table_tartarus = {
    'Beat Meg': None,
}

global location_table_asphodel
location_table_asphodel = {
    'Beat Lernie': None,
}

global location_table_elyseum
location_table_elyseum = {
    'Beat Bros': None,
}

global location_table_styx
location_table_styx = {
    'Beat Hades': None,
}

location_keepsakes ={
    'CerberusKeepsake': max_number_room_checks+1,
    'AchillesKeepsake': max_number_room_checks+2,
    'NyxKeepsake': max_number_room_checks+3,
    'ThanatosKeepsake': max_number_room_checks+4,
    'CharonKeepsake': max_number_room_checks+5,
    'HypnosKeepsake': max_number_room_checks+6,
    'MegaeraKeepsake': max_number_room_checks+7,
    'OrpheusKeepsake': max_number_room_checks+8,
    'DusaKeepsake': max_number_room_checks+9,
    'SkellyKeepsake': max_number_room_checks+10,
    'ZeusKeepsake': max_number_room_checks+11,
    'PoseidonKeepsake': max_number_room_checks+12,
    'AthenaKeepsake': max_number_room_checks+13,
    'AphorditeKeepsake': max_number_room_checks+14,
    'AresKeepsake': max_number_room_checks+15,
    'ArtemisKeepsake': max_number_room_checks+16,
    'DionysusKeepsake': max_number_room_checks+17,
    'HermesKeepsake': max_number_room_checks+18,
    'DemeterKeepsake': max_number_room_checks+19,
    'ChaosKeepsake': max_number_room_checks+20,
    'SisyphusKeepsake': max_number_room_checks+21,
    'EurydiceKeepsake': max_number_room_checks+22,
    'PatroclusKeepsake': max_number_room_checks+23,
    'DemeterKeepsake': max_number_room_checks+24,
}

def give_all_locations_table():
    table_rooms = give_default_location_table()
    table_score = give_score_location_table(1000)
    
    return {
        **table_rooms,
        **table_score,
        **location_keepsakes,
    }

def clear_tables():
    global location_table_tartarus 
    location_table_tartarus = {
        'Beat Meg': None,
    }

    global location_table_asphodel
    location_table_asphodel = {
        'Beat Lernie': None,
    }

    global location_table_elyseum
    location_table_elyseum = {
        'Beat Bros': None,
    }

    global location_table_styx
    location_table_styx = {
        'Beat Hades': None,
    }
    

#Change parameters so they include the settings of the player
#Chose between old and new system. And for the new system we want to be able
#to choose how many "locations" we have.
def setup_location_table_with_settings(options):
    clear_tables()
    total_table = {}
    
    if (options.keepsakesanity.value == 1):
        total_table.update(location_keepsakes)
   
    match (options.location_system.value):
        case 1: 
            result = give_default_location_table()
            total_table.update(result)
        
        case 2:
            levels = options.score_rewards_amount.value
            total_table.update(give_score_location_table(levels))
    
    return total_table
            
#-----------------------------------------------

def give_default_location_table():
    #Repopulate tartarus table; rooms from 1 to 14.
    global location_table_tartarus 
    for i in range(14):
        stringInt=i+1;
        if (stringInt<10):
            stringInt = "0"+str(stringInt);
        location_table_tartarus["ClearRoom"+str(stringInt)] = hades_base_location_id+i
        
    #Repopulate asphodel table, rooms from 15 to 28
    global location_table_asphodel
    for i in range(14,28):
        location_table_asphodel["ClearRoom"+str(i+1)]=hades_base_location_id+i
    
    #Repopulate elyseum table, rooms from 29 to 42
    global location_table_elyseum
    for i in range(28,42):
        location_table_elyseum["ClearRoom"+str(i+1)]=hades_base_location_id+i
    
    #Repopulate elyseum table, rooms from 43 to 72 
    global location_table_styx 
    for i in range(42,72):
        location_table_elyseum["ClearRoom"+str(i+1)]=hades_base_location_id+i
    
    location_table = {
        **location_table_tartarus, 
        **location_table_asphodel,
        **location_table_elyseum,
        **location_table_styx,
    }
    return location_table

def give_score_location_table(locations):
    fraction_location = int(locations/8)
    locations_first_region = locations-7*fraction_location

    global location_table_tartarus 
    ##Recall to add a offset for the location to avoid sharing ids if two players play with different settings
    for i in range(locations_first_region):
        stringInt=i+1;
        if (stringInt<10):
            stringInt = "0"+str(stringInt);
        location_table_tartarus["ClearScore"+str(stringInt)]=hades_base_location_id+i+72 

    global location_table_asphodel
    for i in range(locations_first_region, locations_first_region+2*fraction_location):
        location_table_asphodel["ClearScore"+str(i+1)]=hades_base_location_id+i+72 
        
    global location_table_elyseum
    for i in range(locations_first_region+2*fraction_location, locations_first_region+4*fraction_location):
        location_table_elyseum["ClearScore"+str(i+1)]=hades_base_location_id+i+72 
    
    global location_table_styx
    for i in range(locations_first_region+4*fraction_location, locations):
        location_table_styx["ClearScore"+str(i+1)]=hades_base_location_id+i+72 

    location_table = {
        **location_table_tartarus, 
        **location_table_asphodel,
        **location_table_elyseum,
        **location_table_styx,
    }
    
    return location_table
    

#-----------------------------------------------

class HadesLocation(Location):
    game: str = "Hades"

    def __init__(self, player: int, name: str, address=None, parent=None):
        super(HadesLocation, self).__init__(player, name, address, parent)
        if address is None:
            self.event = True
            self.locked = True