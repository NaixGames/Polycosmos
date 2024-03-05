from enum import KEEP
from BaseClasses import MultiWorld
from .Items import item_table_pacts, item_table_weapons, item_table_keepsake, items_table_fates_completion
from .Locations import location_weapons_subfixes, location_table_tartarus
from ..AutoWorld import LogicMixin
from ..generic.Rules import set_rule


class HadesLogic(LogicMixin):
    #This is not working as expected
    def _total_heat_level(self, player:int, amount: int, options) -> bool:
        if not options.heat_system.value == 1:
            return True
        count=0
        for key in item_table_pacts.keys():
            count = count + self.count(key, player)
        return count >= amount

    def _has_enough_of_item(self, player:int, amount: int, item:str) -> bool:
        return self.count(item, player)>=amount

    def _has_enough_routine_inspection(self, player: int, amount: int, options) -> bool:
        if not options.heat_system.value == 1:
            return True
        return self._has_enough_of_item(player, amount, 'RoutineInspectionPactLevel')
    
    def _has_enough_urns(self, player: int, amount: int) -> bool:
        return self.count('UrnsOfWealth1Item', player) + self.count('UrnsOfWealth2Item', player) + self.count('UrnsOfWealth3Item', player) >=amount
    
    def _has_enough_throve(self, player: int, amount: int) -> bool:
        return self.count('InfernalThrove1Item', player) + self.count('InfernalThrove2Item', player) + self.count('InfernalThrove3Item', player) >=amount
    
    def _has_enough_weapons(self, player: int, options, amount: int) -> bool:
        if (options.weaponsanity.value==0):
            return True
        return self.count('SwordWeaponUnlockItem', player) + self.count('BowWeaponUnlockItem', player) + self.count('SpearWeaponUnlockItem', player) + self.count('ShieldWeaponUnlockItem', player) + self.count('FistWeaponUnlockItem', player) + self.count('GunWeaponUnlockItem', player) >=amount
    
    def _has_enough_keepsakes(self, player:int, amount:int, options) -> bool:
        amount_keepsakes = 0
        for keepsake_name in item_table_keepsake:
            amount_keepsakes += self.count(keepsake_name, player)
        return amount_keepsakes >= amount

    def _has_enough_fates_done(self, player:int, amount:int, options) -> bool:
        amount_fates = 0 
        for fates_names in items_table_fates_completion:
            amount_fates += self.count(fates_names, player)
        return amount_fates >= amount
    
    def _has_weapon(self, weaponSubfix, player:int, option) -> bool:
        if (option.weaponsanity.value==0):
            return True
        if (weaponSubfix == "SwordWeapon"):
            return (option.initial_weapon.value == 0) or (self.count('SwordWeaponUnlockItem', player)>0)
        if (weaponSubfix == "BowWeapon"):
            return (option.initial_weapon.value == 1) or (self.count('BowWeaponUnlockItem', player)>0)
        if (weaponSubfix == "SpearWeapon"):
            return (option.initial_weapon.value == 2) or (self.count('SpearWeaponUnlockItem', player)>0)
        if (weaponSubfix == "ShieldWeapon"):
            return (option.initial_weapon.value == 3) or (self.count('ShieldWeaponUnlockItem', player)>0)
        if (weaponSubfix == "FistWeapon"):
            return (option.initial_weapon.value == 4) or (self.count('FistWeaponUnlockItem', player)>0)
        if (weaponSubfix == "GunWeapon"):
            return (option.initial_weapon.value == 5) or (self.count('GunWeaponUnlockItem', player)>0)
        return True

    def _can_get_victory(self, player: int, options) -> bool:
        can_win = self._has_defeated_boss('HadesVictory', player, options)
        if (options.weaponsanity.value == 1):
            weapons = options.weapons_clears_needed.value
            can_win = (can_win) and (self._has_enough_weapons(player,options,weapons))
        if (options.keepsakesanity.value == 1):
            keepsakes = options.keepsakes_needed.value
            can_win = (can_win) and (self._has_enough_keepsakes(player,keepsakes,options))
        fates = options.fates_needed.value
        can_win = (can_win) and (self._has_enough_fates_done(player,fates,options))
        return can_win
    
    def _has_defeated_boss(self,bossVictory,player:int, options) -> bool:
        if (options.location_system.value == 3):
            counter=0
            for weaponSubfix in location_weapons_subfixes:
                counter += self.count(bossVictory+weaponSubfix, player)
            return counter > 0
        else:
           return self.count(bossVictory, player) == 1

def set_rules(world: MultiWorld, player: int, number_items: int, location_table, options):
    # Set up some logic in areas to avoid having all heats "stack up" as batch in other games.
    total_routine_inspection = int(options.routine_inspection_pact_amount.value)


    if (options.location_system.value == 3):
        for weaponSubfix in location_weapons_subfixes:
            set_rule(world.get_entrance('Zags room'+weaponSubfix, player), lambda state: state._has_weapon(weaponSubfix, player, options))
            set_rule(world.get_entrance('Exit Tartarus'+weaponSubfix, player), lambda state: state.has("MegVictory"+weaponSubfix, player) and state._total_heat_level(player, min(number_items/4,10), options) and state._has_enough_routine_inspection(player,total_routine_inspection-2, options) and state._has_enough_weapons(player, options, 2))
            set_rule(world.get_entrance('Exit Asphodel'+weaponSubfix, player), lambda state: state.has("LernieVictory"+weaponSubfix, player) and state._total_heat_level(player, min(number_items/2,20), options) and state._has_enough_routine_inspection(player,total_routine_inspection-1, options) and state._has_enough_weapons(player, options, 3))
            set_rule(world.get_entrance('Exit Elyseum'+weaponSubfix, player), lambda state: state.has("BrosVictory"+weaponSubfix, player)  and state._total_heat_level(player, min(number_items*3/4,30), options) and state._has_enough_routine_inspection(player,total_routine_inspection, options) and state._has_enough_weapons(player, options, 4))
            set_rule(world.get_location('Beat Hades'+weaponSubfix, player), lambda state: state._total_heat_level(player, min(number_items,35), options) and state._has_enough_weapons(player, options, 5))
    else:
        for location in location_table_tartarus:
            if (location in location_table):
               set_rule(world.get_location(location,player), lambda state: True)
        set_rule(world.get_entrance('Exit Tartarus', player), lambda state: state.has("MegVictory", player) and state._total_heat_level(player, min(number_items/4,10), options) and state._has_enough_routine_inspection(player,total_routine_inspection-2, options) and state._has_enough_weapons(player, options, 2))
        set_rule(world.get_entrance('Exit Asphodel', player), lambda state: state.has("LernieVictory", player) and state._total_heat_level(player, min(number_items/2,20), options) and state._has_enough_routine_inspection(player,total_routine_inspection-1, options) and state._has_enough_weapons(player, options, 3))
        set_rule(world.get_entrance('Exit Elyseum', player), lambda state: state.has("BrosVictory", player)  and state._total_heat_level(player, min(number_items*3/4,30), options) and state._has_enough_routine_inspection(player,total_routine_inspection, options) and state._has_enough_weapons(player, options, 4))
        set_rule(world.get_location('Beat Hades', player), lambda state: state._total_heat_level(player, min(number_items,35), options) and state._has_enough_weapons(player, options, 5))
    
    world.completion_condition[player] = lambda state: state._can_get_victory(player, options)
    
    if (options.keepsakesanity.value==1 and options.nectar_pack_value.value > 0):
        set_rule(world.get_entrance('NPCS', player), lambda state: True)
    if (options.weaponsanity.value==1 and options.keys_pack_value.value >0):
        set_rule(world.get_entrance('Weapon Cache', player), lambda state: True)
    if (options.storesanity.value==1):
        set_store_rules(world, player, number_items, location_table, options)
    if (options.fatesanity.value==1):
        set_fates_rules(world,player,number_items,location_table,options, "")
    set_fates_rules(world,player,number_items,location_table,options, "Event")


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
    set_rule(world.get_location('FountainAsphodelLocation', player), lambda state: state.has('FountainTartarusItem', player) and state.has('KeepsakeCollectionItem', player) and state._has_defeated_boss('MegVictory', player, options))
    set_rule(world.get_location('FountainElysiumLocation', player), lambda state: state.has('FountainAsphodelItem', player) and state.has('KeepsakeCollectionItem', player) and state._has_defeated_boss('LernieVictory', player, options))
    
    #Urns
    set_rule(world.get_location('UrnsOfWealth1Location', player), lambda state: state.has('FountainTartarusItem', player))
    set_rule(world.get_location('UrnsOfWealth2Location', player), lambda state: state._has_enough_urns(player,1))
    set_rule(world.get_location('UrnsOfWealth3Location', player), lambda state: state._has_enough_urns(player,2))
    
    #Infernal Throve
    set_rule(world.get_location('UrnsOfWealth2Location', player), lambda state: state._has_enough_throve(player,1) and state.has('FountainElysiumItem',player) and state.has('KeepsakeCollectionItem', player))
    set_rule(world.get_location('UrnsOfWealth3Location', player), lambda state: state._has_enough_throve(player,2) and state.has('FountainElysiumItem',player) and state.has('KeepsakeCollectionItem', player) and state.has('DeluxeContractorDeskItem', player))
    
    #Keepsake storage
    set_rule(world.get_location('KeepsakeCollectionLocation', player), lambda state: state._has_defeated_boss('MegVictory', player, options) and state.has('FountainTartarusItem', player))
    
    #Deluxe contractor desk
    set_rule(world.get_location('DeluxeContractorDeskLocation', player), lambda state: state.has('FountainElysiumItem', player) and state.has('CourtMusicianSentenceItem', player))
    
    #Other random stuff
    set_rule(world.get_location('VanquishersKeepLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('FishingRodLocation', player), lambda state: state._has_defeated_boss('BrosVictory', player, options) and state.has('FountainTartarusItem', player))
    set_rule(world.get_location('CourtMusicianSentenceLocation', player), lambda state: state._has_defeated_boss('MegVictory', player, options) and state.has('FountainTartarusItem', player))
    set_rule(world.get_location('CourtMusicianStandLocation', player), lambda state: state.has('CourtMusicianSentenceItem', player))
    
    #Upgrades of runs with gems locations
    set_rule(world.get_location('PitchBlackDarknessLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('FatedKeysLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('BrilliantGemstonesLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('VintageNectarLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    set_rule(world.get_location('DarkerThirstLocation', player), lambda state: state.has('DeluxeContractorDeskItem', player))
    

def set_fates_rules(world: MultiWorld, player: int, number_items: int, location_table, options, subfix: str):
    #Rules that dont depend on other settings
    set_rule(world.get_location('IsThereNoEscape?'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options))
    set_rule(world.get_location('HarshConditions'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options)) #requires heat
    set_rule(world.get_location('SlashedBenefits'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options)) #requires heat
    set_rule(world.get_location('TheUselessTrinket'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options)) #requires heat
    set_rule(world.get_location('WantonRansacking'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options))
    set_rule(world.get_location('DarkReflections'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options))

    #Rules that depend on storesanity
    if (options.storesanity.value==1):
        set_rule(world.get_location('TheReluctantMusician'+subfix, player), lambda state: state.has('CourtMusicianSentenceItem', player))
        set_rule(world.get_location('ASimpleJob'+subfix, player), lambda state: state.has('CodexIndexItem', player))
        set_rule(world.get_location('DenizensOfTheDeep'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options) and state.has('FishingRodItem',player))
    else:
        set_rule(world.get_location('TheReluctantMusician'+subfix, player), lambda state: state._has_defeated_boss('MegVictory', player, options))
        set_rule(world.get_location('DenizensOfTheDeep'+subfix, player), lambda state: state._has_defeated_boss('HadesVictory', player, options))
    
    #This part depends on weaponsanity, but the false option is handled on has_enough_weapons
    set_rule(world.get_location('InfernalArms'+subfix, player), lambda state: state._has_enough_weapons(player, options, 5))
    set_rule(world.get_location('AViolentPast'+subfix, player), lambda state: state._has_enough_weapons(player, options, 5))
    set_rule(world.get_location('MasterOfArms'+subfix, player), lambda state: state._has_enough_weapons(player, options, 5) and state._has_defeated_boss('HadesVictory', player, options))
   
    #rules that depend on weaponsanity:
    if (options.weaponsanity.value==1):
        set_rule(world.get_location('TheStygianBlade'+subfix, player), lambda state: state.has('SwordWeaponUnlockItem', player) or options.initial_weapon.value==0)
        set_rule(world.get_location('TheHeartSeekingBow'+subfix, player), lambda state: state.has('BowWeaponUnlockItem', player) or options.initial_weapon.value==1)
        set_rule(world.get_location('TheEternalSpear'+subfix, player), lambda state: state.has('SpearWeaponUnlockItem', player) or options.initial_weapon.value==2)
        set_rule(world.get_location('TheShieldOfChaos'+subfix, player), lambda state: state.has('ShieldWeaponUnlockItem', player) or options.initial_weapon.value==3)
        set_rule(world.get_location('TheTwinFists'+subfix, player), lambda state: state.has('FistWeaponUnlockItem', player) or options.initial_weapon.value==4)
        set_rule(world.get_location('TheAdamantRail'+subfix, player), lambda state: state.has('GunWeaponUnlockItem', player) or options.initial_weapon.value==5)
        
    if (options.keepsakesanity.value==1):
        set_rule(world.get_location('CloseAtHeart'+subfix, player), lambda state: state._has_enough_keepsakes(player, 23, options))