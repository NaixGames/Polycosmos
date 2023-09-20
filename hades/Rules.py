from BaseClasses import MultiWorld
from .Items import item_table_pacts
from .Locations import location_table_tartarus
from ..AutoWorld import LogicMixin
from ..generic.Rules import set_rule


class HadesLogic(LogicMixin):
    #This is not working as expected
    def _total_heat_level(self, player:int, amount: int) -> int:
        count=0
        for key in item_table_pacts.keys():
            count = count + self.item_count(key, player)
        return count >= amount


def set_rules(world: MultiWorld, player: int):
    # Set up some logic in areas to avoid having all heats "stack up" as batch in other games.
    #set up that we can get all checks on Tartarus if we beat it
    for location in location_table_tartarus:
        set_rule(world.get_location(location,player), lambda state: True)

    set_rule(world.get_entrance('Exit Tartarus', player), lambda state: state.has("MegVictory", player) and state._total_heat_level(player, 10))
    set_rule(world.get_entrance('Exit Asphodel', player), lambda state: state.has("LernieVictory", player) and state._total_heat_level(player, 15))
    set_rule(world.get_entrance('Exit Elyseum', player), lambda state: state.has("BrosVictory", player)  and state._total_heat_level(player, 20))
    set_rule(world.get_location('Beat Hades', player), lambda state: state._total_heat_level(player, 35))

    world.completion_condition[player] = lambda state: state.has('Victory', player)
