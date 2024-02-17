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
            count = count + self.count(key, player)
        return count >= amount

    def _has_enough_of_item(self, player:int, amount: int, item:str) -> bool:
        return self.count(item, player)>=amount

    def _has_enough_routine_inspection(self, player: int, amount: int) -> int:
        return self._has_enough_of_item(player, amount, 'RoutineInspectionPactLevel')

def set_rules(world: MultiWorld, player: int, number_items: int, location_table, options):
    # Set up some logic in areas to avoid having all heats "stack up" as batch in other games.
    #set up that we can get all checks on Tartarus if we beat it
    for location in location_table_tartarus:
        if (location in location_table):
            set_rule(world.get_location(location,player), lambda state: True)

    total_routine_inspection = int(options.routine_inspection_pact_amount.value)

    set_rule(world.get_entrance('Exit Tartarus', player), lambda state: state.has("MegVictory", player) and state._total_heat_level(player, min(number_items/4,10)) and state._has_enough_routine_inspection(player,total_routine_inspection-2))
    set_rule(world.get_entrance('Exit Asphodel', player), lambda state: state.has("LernieVictory", player) and state._total_heat_level(player, min(number_items/2,20)) and state._has_enough_routine_inspection(player,total_routine_inspection-1))
    set_rule(world.get_entrance('Exit Elyseum', player), lambda state: state.has("BrosVictory", player)  and state._total_heat_level(player, min(number_items*3/4,30)) and state._has_enough_routine_inspection(player,total_routine_inspection))
    set_rule(world.get_location('Beat Hades', player), lambda state: state._total_heat_level(player, min(number_items,35)))

    if (options.keepsakesanity.value==1):
        set_rule(world.get_entrance('NPCS', player), lambda state: state._has_enough_of_item(player, 1, 'Nectar'))
    if (options.weaponsanity.value==1):
        set_rule(world.get_entrance('Weapon Cache', player), lambda state: state._has_enough_of_item(player, 1, 'Keys'))
    world.completion_condition[player] = lambda state: state.has('Victory', player)

