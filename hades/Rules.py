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

    def _has_enough_routine_inspection(self, player: int, ammount: int) -> int:
        return self.item_count('RoutineInspectionPactLevel',player) >= ammount


def set_rules(world: MultiWorld, player: int, number_items: int):
    # Set up some logic in areas to avoid having all heats "stack up" as batch in other games.
    #set up that we can get all checks on Tartarus if we beat it
    for location in location_table_tartarus:
        set_rule(world.get_location(location,player), lambda state: True)

    total_routine_inspection = int(world.routine_inspection_pact_ammount[player].value)

    set_rule(world.get_entrance('Exit Tartarus', player), lambda state: state.has("MegVictory", player) and state._total_heat_level(player, min(number_items/4,10)) and state._has_enough_routine_inspection(player,2-total_routine_inspection))
    set_rule(world.get_entrance('Exit Asphodel', player), lambda state: state.has("LernieVictory", player) and state._total_heat_level(player, min(number_items/2,20)) and state._has_enough_routine_inspection(player,3-total_routine_inspection))
    set_rule(world.get_entrance('Exit Elyseum', player), lambda state: state.has("BrosVictory", player)  and state._total_heat_level(player, min(number_items*3/4,30)) and state._has_enough_routine_inspection(player,4-total_routine_inspection))
    set_rule(world.get_location('Beat Hades', player), lambda state: state._total_heat_level(player, min(number_items,35)))

    world.completion_condition[player] = lambda state: state.has('Victory', player)
