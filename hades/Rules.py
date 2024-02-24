from BaseClasses import MultiWorld
from .Items import item_table_pacts, item_table_weapons
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
    
    def _has_enough_urns(self, player: int, amount: int) -> int:
        return self.count('UrnsOfWealth1Item', player) + self.count('UrnsOfWealth2Item', player) + self.count('UrnsOfWealth3Item', player) >=amount
    
    def _has_enough_throve(self, player: int, amount: int) -> int:
        return self.count('InfernalThrove1Item', player) + self.count('InfernalThrove2Item', player) + self.count('InfernalThrove3Item', player) >=amount
    
    def _has_enough_weapons(self, player: int, options, amount: int) -> int:
        if (options.weaponsanity.value==0):
            return True
        return self.count('SwordWeaponUnlockItem', player) + self.count('BowWeaponUnlockItem', player) + self.count('SpearWeaponUnlockItem', player) + self.count('ShieldWeaponUnlockItem', player) + self.count('FistWeaponUnlockItem', player) + self.count('GunWeaponUnlockItem', player) >=amount
    

def set_rules(world: MultiWorld, player: int, number_items: int, location_table, options):
    # Set up some logic in areas to avoid having all heats "stack up" as batch in other games.
    #set up that we can get all checks on Tartarus if we beat it
    for location in location_table_tartarus:
        if (location in location_table):
            set_rule(world.get_location(location,player), lambda state: True)

    total_routine_inspection = int(options.routine_inspection_pact_amount.value)

    set_rule(world.get_entrance('Exit Tartarus', player), lambda state: state.has("MegVictory", player) and state._total_heat_level(player, min(number_items/4,10)) and state._has_enough_routine_inspection(player,total_routine_inspection-2) and state._has_enough_weapons(player, options, 2))
    set_rule(world.get_entrance('Exit Asphodel', player), lambda state: state.has("LernieVictory", player) and state._total_heat_level(player, min(number_items/2,20)) and state._has_enough_routine_inspection(player,total_routine_inspection-1) and state._has_enough_weapons(player, options, 3))
    set_rule(world.get_entrance('Exit Elyseum', player), lambda state: state.has("BrosVictory", player)  and state._total_heat_level(player, min(number_items*3/4,30)) and state._has_enough_routine_inspection(player,total_routine_inspection) and state._has_enough_weapons(player, options, 4))
    set_rule(world.get_location('Beat Hades', player), lambda state: state._total_heat_level(player, min(number_items,35)) and state._has_enough_weapons(player, options, 5))

    if (options.keepsakesanity.value==1 and options.nectar_pack_value.value > 0):
        set_rule(world.get_entrance('NPCS', player), lambda state: state._has_enough_of_item(player, 1, 'Nectar'))
    if (options.weaponsanity.value==1 and options.keys_pack_value.value >0):
        set_rule(world.get_entrance('Weapon Cache', player), lambda state: state._has_enough_of_item(player, 1, 'Keys'))
    if (options.storesanity.value==1):
        set_store_rules(world, player, number_items, location_table, options)
    world.completion_condition[player] = lambda state: state.has('Victory', player)



def set_store_rules(world: MultiWorld, player: int, number_items: int, location_table, options):
    #set up rules related to locations on the store

    #we set the currency we need for each type of store
    if (options.gemstones_pack_value.value>0):
        set_rule(world.get_entrance('Store Gemstones Entrance', player), lambda state: state._has_enough_of_item(player, 1, 'Gemstones') ) 
    if (options.diamonds_pack_value.value>0):
        set_rule(world.get_entrance('Store Diamonds Entrance', player), lambda state: state._has_enough_of_item(player, 1, 'Diamonds') )

    #Fountains
    set_rule(world.get_location('FountainUpgrade1Location', player), lambda state: state.has('FountainTartarusItem', player))
    set_rule(world.get_location('FountainUpgrade2Location', player), lambda state: state.has('FountainUpgrade1Item', player) or state.has('FountainUpgrade2Item', player))
    set_rule(world.get_location('FountainAsphodelLocation', player), lambda state: state.has('FountainTartarusItem', player) and state.has('KeepsakeCollectionItem', player) and state.has("MegVictory", player))
    set_rule(world.get_location('FountainElysiumLocation', player), lambda state: state.has('FountainAsphodelItem', player) and state.has('KeepsakeCollectionItem', player) and state.has("LernieVictory", player))
    
    #Urns
    set_rule(world.get_location('UrnsOfWealth1Location', player), lambda state: state.has('FountainTartarusItem', player))
    set_rule(world.get_location('UrnsOfWealth2Location', player), lambda state: state._has_enough_urns(player,1))
    set_rule(world.get_location('UrnsOfWealth3Location', player), lambda state: state._has_enough_urns(player,2))
    
    #Infernal Throve
    set_rule(world.get_location('UrnsOfWealth2Location', player), lambda state: state._has_enough_throve(player,1) and state.has('FountainElysiumItem',player) and state.has('KeepsakeCollectionItem', player))
    set_rule(world.get_location('UrnsOfWealth3Location', player), lambda state: state._has_enough_throve(player,2) and state.has('FountainElysiumItem',player) and state.has('KeepsakeCollectionItem', player) and state.has('DeluxeContractorDeskItem', player))
    
    #Keepsake storage
    set_rule(world.get_location('KeepsakeCollectionLocation', player), lambda state: state.has('MegVictory', player) and state.has('FountainTartarusItem', player))
    
    #Deluxe contractor desk
    set_rule(world.get_location('DeluxeContractorDeskLocation', player), lambda state: state.has('FountainElysiumItem', player) and state.has('CourtMusicianSentenceItem', player))
    
    #Other random stuff
    set_rule(world.get_location('VanquishersKeepLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('FishingRodLocation', player), lambda state: state.has('BrosVictory', player) and state.has('FountainTartarusItem', player))
    set_rule(world.get_location('CourtMusicianSentenceLocation', player), lambda state: state.has('MegVictory', player) and state.has('FountainTartarusItem', player))
    set_rule(world.get_location('CourtMusicianStandLocation', player), lambda state: state.has('CourtMusicianSentenceItem', player))
    
    #Upgrades of runs with gems locations
    set_rule(world.get_location('PitchBlackDarknessLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('FatedKeysLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('BrilliantGemstonesLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('VintageNectarLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('DarkerThirstLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))