def create_regions(world, player: int, location_database):
    from . import create_region
    from .Locations import location_table_tartarus, location_table_asphodel, location_table_elyseum, location_table_styx

    #Technically this needs some items (beat Bosses). 
    #Need to add some event items for the Bosses so this looks more natural
    world.regions += [
        create_region(world, player, location_database, "Menu", None, ["Menu"]),
        create_region(world, player, location_database, "Underworld", None, ["Zags room"]), #should actually group rooms according to the part of the underworld they are in. That set up rools more easily
        create_region(world, player, location_database, "Tartarus", [location for location in location_table_tartarus], ["Exit Tartarus"]),
        create_region(world, player, location_database, "Asphodel", [location for location in location_table_asphodel], ["Exit Asphodel"]),
        create_region(world, player, location_database, "Elyseum", [location for location in location_table_elyseum], ["Exit Elyseum"]),
        create_region(world, player, location_database, "Styx", [location for location in location_table_styx]),
    ]

    # link up regions
    world.get_entrance("Menu", player).connect(world.get_region("Underworld", player))
    world.get_entrance("Zags room", player).connect(world.get_region("Tartarus", player))
    world.get_entrance("Exit Tartarus", player).connect(world.get_region("Asphodel", player))
    world.get_entrance("Exit Asphodel", player).connect(world.get_region("Elyseum", player))
    world.get_entrance("Exit Elyseum", player).connect(world.get_region("Styx", player))