def create_regions(ctx, location_database):
    from . import create_region
    from .Locations import location_table_tartarus, location_table_asphodel, location_table_elyseum, location_table_styx, location_table_styx_late, location_keepsakes, location_weapons

    #create correct underworld exit
    underworldExits = ["Zags room"]
    if (ctx.options.keepsakesanity.value==1):
        underworldExits += ["NPCS"]
        
    if (ctx.options.weaponsanity.value==1):
        underworldExits += ["Weapon Cache"]

    #Technically this needs some items (beat Bosses). 
    #Need to add some event items for the Bosses so this looks more natural
    ctx.multiworld.regions += [
        create_region(ctx.multiworld, ctx.player, location_database, "Menu", None, ["Menu"]),
        create_region(ctx.multiworld, ctx.player, location_database, "Underworld", None, underworldExits), #should actually group rooms according to the part of the underworld they are in. That set up rools more easily
        create_region(ctx.multiworld, ctx.player, location_database, "Tartarus", [location for location in location_table_tartarus], ["Exit Tartarus", "DieT"]),
        create_region(ctx.multiworld, ctx.player, location_database, "Asphodel", [location for location in location_table_asphodel], ["Exit Asphodel", "DieA"]),
        create_region(ctx.multiworld, ctx.player, location_database, "Elyseum", [location for location in location_table_elyseum], ["Exit Elyseum", "DieE"]),
        create_region(ctx.multiworld, ctx.player, location_database, "Styx", [location for location in location_table_styx], ["DieS", "Late Chambers"]),
        create_region(ctx.multiworld, ctx.player, location_database, "StyxLate", [location for location in location_table_styx_late], ["DieSL"]),
    ]

    #here we set locations that depend on options
    if (ctx.options.keepsakesanity.value==1):
        ctx.multiworld.regions += [create_region(ctx.multiworld, ctx.player, location_database, "KeepsakesLocations", [location for location in location_keepsakes], ["ExitNPCS"])] 
    
    if (ctx.options.weaponsanity.value==1):
        ctx.multiworld.regions += [create_region(ctx.multiworld, ctx.player, location_database, "WeaponsLocations", [location for location in location_weapons], ["ExitWeaponCache"])]
        
    # link up regions
    ctx.multiworld.get_entrance("Menu", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))
    ctx.multiworld.get_entrance("Zags room", ctx.player).connect(ctx.multiworld.get_region("Tartarus", ctx.player))
    ctx.multiworld.get_entrance("Exit Tartarus", ctx.player).connect(ctx.multiworld.get_region("Asphodel", ctx.player))
    ctx.multiworld.get_entrance("Exit Asphodel", ctx.player).connect(ctx.multiworld.get_region("Elyseum", ctx.player))
    ctx.multiworld.get_entrance("Exit Elyseum", ctx.player).connect(ctx.multiworld.get_region("Styx", ctx.player))
    ctx.multiworld.get_entrance("Late Chambers", ctx.player).connect(ctx.multiworld.get_region("StyxLate", ctx.player))
    ctx.multiworld.get_entrance("DieT", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))
    ctx.multiworld.get_entrance("DieA", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))    
    ctx.multiworld.get_entrance("DieE", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))
    ctx.multiworld.get_entrance("DieS", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))
    ctx.multiworld.get_entrance("DieSL", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))

    #here we connect locations that depend on options
    if (ctx.options.keepsakesanity.value==1):
        ctx.multiworld.get_entrance("NPCS", ctx.player).connect(ctx.multiworld.get_region("KeepsakesLocations", ctx.player))
        ctx.multiworld.get_entrance("ExitNPCS", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))
        
    if (ctx.options.weaponsanity.value==1):
        ctx.multiworld.get_entrance("Weapon Cache", ctx.player).connect(ctx.multiworld.get_region("WeaponsLocations", ctx.player))
        ctx.multiworld.get_entrance("ExitWeaponCache", ctx.player).connect(ctx.multiworld.get_region("Underworld", ctx.player))
        