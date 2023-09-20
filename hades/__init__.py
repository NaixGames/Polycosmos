import string

from BaseClasses import Entrance, Item, ItemClassification, Location, MultiWorld, Region, Tutorial
from .Items import item_table, item_table_pacts, item_pool_pacts, HadesItem, event_item_pairs
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
        # Fill out our pool with our items from item_pool, assuming 1 item if not present in item_pool
        pool = []
        #Fill pact items
        for name, data in item_table_pacts.items():
            for amount in range(item_pool_pacts.get(name, 1)):
                item = HadesItem(name, self.player)
                pool.append(item)

        self.multiworld.itempool += pool

        # Pair up our event locations with our event items
        for event, item in event_item_pairs.items():
            event_item = HadesItem(item, self.player)
            self.multiworld.get_location(event, self.player).place_locked_item(event_item)

    def set_rules(self):
        set_rules(self.multiworld, self.player)

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
        return self.multiworld.random.choice(["Darkness", "Keys"]) 


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

