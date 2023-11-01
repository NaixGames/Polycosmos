import string

from BaseClasses import Entrance, Item, ItemClassification, Location, MultiWorld, Region, Tutorial
from .Items import item_table, item_table_pacts, HadesItem, event_item_pairs, create_pact_pool_ammount, create_filler_pool_options
from .Locations import setup_location_table, HadesLocation
from .Options import hades_options
from .Regions import create_regions
from .Rules import set_rules
from ..AutoWorld import WebWorld, World


class HadesWeb(WebWorld):
    tutorials = [Tutorial(
        "Multiworld Setup Guide",
        "A guide to setting up Hades for Archipelago. "
        "This guide covers single-player, multiworld, and related software.",
        "English",
        "Hades.md",
        "Hades/en",
        ["Naix"]
    )]


class HadesWorld(World):
    """
    Hades is a rogue-like dungeon crawler in which you defy the god of the dead as you hack and slash your way out of the Underworld of Greek myth.
    """

    option_definitions = hades_options
    game = "Hades"
    topology_present = False
    data_version = 1
    web = HadesWeb()
    required_client_version = (0, 4, 1)

    location_table = setup_location_table()
    item_name_to_id = {name: data.code for name, data in item_table.items()}
    location_name_to_id = location_table

    def create_items(self):
        pool = []

        #Fill pact items
        item_pool_pacts = create_pact_pool_ammount(hades_options, self.multiworld, self.player)

        #Fill pact items
        for name, data in item_table_pacts.items():
            for amount in range(item_pool_pacts.get(name, 1)):
                item = HadesItem(name, self.player)
                pool.append(item)

        #create the pack of filler options
        filler_options = create_filler_pool_options(hades_options, self.multiworld, self.player)

        #Fill filler items uniformly. Maybe later we can tweak this.
        index = 0
        for amount in range(0, len(self.location_name_to_id)-len(pool)):
            item_name = filler_options[index]
            item = HadesItem(item_name, self.player)
            pool.append(item)
            index = (index+1)%len(filler_options)
        
        self.multiworld.itempool += pool


        # Pair up our event locations with our event items
        for event, item in event_item_pairs.items():
            event_item = HadesItem(item, self.player)
            self.multiworld.get_location(event, self.player).place_locked_item(event_item)

    def set_rules(self):
        set_rules(self.multiworld, self.player, self.calculate_number_of_important_items())

    def calculate_number_of_important_items(self):
        #Go thorugh every option and count what is the chosen level
        total = int(self.multiworld.hard_labor_pact_ammount[self.player].value)
        total += int(self.multiworld.lasting_consequences_pact_ammount[self.player].value)
        total += int(self.multiworld.convenience_fee_pact_ammount[self.player].value)
        total += int(self.multiworld.jury_summons_pact_ammount[self.player].value)
        total += int(self.multiworld.extreme_measures_pact_ammount[self.player].value)
        total += int(self.multiworld.calisthenics_program_pact_ammount[self.player].value)
        total += int(self.multiworld.benefits_package_pact_ammount[self.player].value)
        total += int(self.multiworld.middle_management_pact_ammount[self.player].value)
        total += int(self.multiworld.underworld_customs_pact_ammount[self.player].value)
        total += int(self.multiworld.forced_overtime_pact_ammount[self.player].value)
        total += int(self.multiworld.heightened_security_pact_ammount[self.player].value)
        total += int(self.multiworld.routine_inspection_pact_ammount[self.player].value)
        total += int(self.multiworld.damage_control_pact_ammount[self.player].value)
        total += int(self.multiworld.approval_process_pact_ammount[self.player].value)
        total += int(self.multiworld.tight_deadline_pact_ammount[self.player].value)
        total += int(self.multiworld.personal_liability_pact_ammount[self.player].value)
        return total

    def create_item(self, name: str) -> Item:
        return HadesItem(name, self.player)

    def create_regions(self):
        location_table = setup_location_table()
        create_regions(self.multiworld, self.player)

    def fill_slot_data(self) -> dict:
        slot_data = {
            'seed': "".join(self.multiworld.per_slot_randoms[self.player].choice(string.ascii_letters) for i in range(16))
        }
        for option_name in hades_options:
            option = getattr(self.multiworld, option_name)[self.player]
            slot_data[option_name] = option.value
        return slot_data

    def get_filler_item_name(self) -> str:
        return "Darkness"


def create_region(world: MultiWorld, player: int, name: str, locations=None, exits=None):
    ret = Region(name, player, world)
    location_table = setup_location_table()
    if locations:
        for location in locations:
            loc_id = location_table.get(location, 0)
            location = HadesLocation(player, location, loc_id, ret)
            ret.locations.append(location)
    if exits:
        for exit in exits:
            ret.exits.append(Entrance(player, exit, ret))

    return ret

