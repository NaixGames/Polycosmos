import typing

from BaseClasses import Item, ItemClassification
from typing import Dict

class ItemData(typing.NamedTuple):
    code: typing.Optional[int]
    progression: bool
    event: bool = False


hades_base_item_id = 666100
hades_event_base_item_id = hades_base_item_id+666

item_table_pacts: Dict[str, ItemData] = {  
    'HardLaborPactLevel': ItemData(hades_base_item_id, True),
    'LastingConsequencesPactLevel': ItemData(hades_base_item_id+1, True),
    'ConvenienceFeePactLevel': ItemData(hades_base_item_id+2, True),
    'JurySummonsPactLevel': ItemData(hades_base_item_id+3, True),
    'ExtremeMeasuresPactLevel': ItemData(hades_base_item_id+4, True),
    'CalisthenicsProgramPactLevel': ItemData(hades_base_item_id+5, True),
    'BenefitsPackagePactLevel': ItemData(hades_base_item_id+6, True),
    'MiddleManagementPactLevel': ItemData(hades_base_item_id+7, True),
    'UnderworldCustomsPactLevel': ItemData(hades_base_item_id+8, True),
    'ForcedOvertimePactLevel': ItemData(hades_base_item_id+9, True),
    'HeightenedSecurityPactLevel': ItemData(hades_base_item_id+10, True),
    'RoutineInspectionPactLevel': ItemData(hades_base_item_id+11, True),
    'DamageControlPactLevel': ItemData(hades_base_item_id+12, True),
    'ApprovalProcessPactLevel': ItemData(hades_base_item_id+13, True),
    'TightDeadlinePactLevel': ItemData(hades_base_item_id+14, True),
    'PersonalLiabilityPactLevel': ItemData(hades_base_item_id+15, True),  
}

items_table_event: Dict[str, ItemData] = {
    'MegVictory': ItemData(hades_event_base_item_id,True,True),
    'LernieVictory': ItemData(hades_event_base_item_id+1,True,True),
    'BrosVictory': ItemData(hades_event_base_item_id+2,True,True),
    'HadesVictory': ItemData(hades_event_base_item_id+3, True, True),
    "HadesVictorySwordWeapon": ItemData(hades_event_base_item_id+40, True, True),
    "MegVictorySwordWeapon": ItemData(hades_event_base_item_id+41, True, True),
    "LernieVictorySwordWeapon" : ItemData(hades_event_base_item_id+42, True, True),
    "BrosVictorySwordWeapon": ItemData(hades_event_base_item_id+43, True, True),
    "HadesVictoryBowWeapon": ItemData(hades_event_base_item_id+44, True, True),
    "MegVictoryBowWeapon": ItemData(hades_event_base_item_id+45, True, True),
    "LernieVictoryBowWeapon": ItemData(hades_event_base_item_id+46, True, True),
    "BrosVictoryBowWeapon" : ItemData(hades_event_base_item_id+47, True, True),
    "HadesVictorySpearWeapon" : ItemData(hades_event_base_item_id+48, True, True),
    "MegVictorySpearWeapon": ItemData(hades_event_base_item_id+49, True, True),
    "LernieVictorySpearWeapon": ItemData(hades_event_base_item_id+50, True, True),
    "BrosVictorySpearWeapon": ItemData(hades_event_base_item_id+51, True, True),
    "HadesVictoryShieldWeapon": ItemData(hades_event_base_item_id+52, True, True),
    "MegVictoryShieldWeapon": ItemData(hades_event_base_item_id+53, True, True),
    "LernieVictoryShieldWeapon": ItemData(hades_event_base_item_id+54, True, True),
    "BrosVictoryShieldWeapon": ItemData(hades_event_base_item_id+55, True, True),
    "HadesVictoryFistWeapon": ItemData(hades_event_base_item_id+56, True, True),
    "MegVictoryFistWeapon": ItemData(hades_event_base_item_id+57, True, True),
    "LernieVictoryFistWeapon": ItemData(hades_event_base_item_id+58, True, True),
    "BrosVictoryFistWeapon": ItemData(hades_event_base_item_id+59, True, True),
    "HadesVictoryGunWeapon": ItemData(hades_event_base_item_id+60, True, True),
    "MegVictoryGunWeapon": ItemData(hades_event_base_item_id+61, True, True),
    "LernieVictoryGunWeapon": ItemData(hades_event_base_item_id+62, True, True),
    "BrosVictoryGunWeapon": ItemData(hades_event_base_item_id+63, True, True),
}

items_table_fates_completion: Dict[str,ItemData] = {
    'IsThereNoEscape?EventItem': ItemData(hades_event_base_item_id+4, True, True),
    'DistantRelativesEventItem': ItemData(hades_event_base_item_id+5, True, True),
    'ChthonicColleaguesEventItem': ItemData(hades_event_base_item_id+6, True, True),
    'TheReluctantMusicianEventItem': ItemData(hades_event_base_item_id+7, True, True),
    'GoddessOfWisdomEventItem': ItemData(hades_event_base_item_id+8, True, True),
    'GodOfTheHeavensEventItem': ItemData(hades_event_base_item_id+9, True, True),
    'GodOfTheSeaEventItem': ItemData(hades_event_base_item_id+10, True, True),
    'GoddessOfLoveEventItem': ItemData(hades_event_base_item_id+11, True, True),
    'GodOfWarEventItem': ItemData(hades_event_base_item_id+12, True, True),
    'GoddessOfTheHuntEventItem': ItemData(hades_event_base_item_id+13, True, True),
    'GodOfWineEventItem': ItemData(hades_event_base_item_id+14, True, True),
    'GodOfSwiftnessEventItem': ItemData(hades_event_base_item_id+15, True, True),
    'GoddessOfSeasonsEventItem': ItemData(hades_event_base_item_id+16, True, True),
    'PowerWithoutEqualEventItem': ItemData(hades_event_base_item_id+17, True, True),
    'DivinePairingsEventItem': ItemData(hades_event_base_item_id+18, True, True),
    'PrimordialBoonsEventItem': ItemData(hades_event_base_item_id+19, True, True),
    'PrimordialBanesEventItem': ItemData(hades_event_base_item_id+20, True, True),
    'InfernalArmsEventItem': ItemData(hades_event_base_item_id+21, True, True),
    'TheStygianBladeEventItem': ItemData(hades_event_base_item_id+22, True, True),
    'TheHeartSeekingBowEventItem': ItemData(hades_event_base_item_id+23, True, True),
    'TheShieldOfChaosEventItem': ItemData(hades_event_base_item_id+24, True, True),
    'TheEternalSpearEventItem': ItemData(hades_event_base_item_id+25, True, True),
    'TheTwinFistsEventItem': ItemData(hades_event_base_item_id+26, True, True),
    'TheAdamantRailEventItem': ItemData(hades_event_base_item_id+27, True, True),
    'MasterOfArmsEventItem': ItemData(hades_event_base_item_id+28, True, True),
    'AViolentPastEventItem': ItemData(hades_event_base_item_id+29, True, True),
    'HarshConditionsEventItem': ItemData(hades_event_base_item_id+30, True, True),
    'SlashedBenefitsEventItem': ItemData(hades_event_base_item_id+31, True, True),
    'WantonRansackingEventItem': ItemData(hades_event_base_item_id+32, True, True),
    'ASimpleJobEventItem': ItemData(hades_event_base_item_id+33, True, True),
    'ChthonicKnowledgeEventItem': ItemData(hades_event_base_item_id+34, True, True),
    'CustomerLoyaltyEventItem': ItemData(hades_event_base_item_id+35, True, True),
    'DarkReflectionsEventItem': ItemData(hades_event_base_item_id+36, True, True),
    'CloseAtHeartEventItem': ItemData(hades_event_base_item_id+37, True, True),
    'DenizensOfTheDeepEventItem': ItemData(hades_event_base_item_id+38, True, True),
    'TheUselessTrinketEventItem': ItemData(hades_event_base_item_id+39, True, True),
}

item_table_filler: Dict[str, ItemData] = {
    'Darkness': ItemData(hades_base_item_id+16, False),
    'Keys': ItemData(hades_base_item_id+17, False),
    'Gemstones': ItemData(hades_base_item_id+18, False),
    'Diamonds': ItemData(hades_base_item_id+19, False),
    'TitanBlood': ItemData(hades_base_item_id+20, False),
    'Nectar': ItemData(hades_base_item_id+21, False),
    'Ambrosia': ItemData(hades_base_item_id+22, False)
}

item_table_keepsake: Dict[str, ItemData] ={
    'CerberusKeepsake': ItemData(hades_base_item_id+23, True),
    'AchillesKeepsake': ItemData(hades_base_item_id+24, True),
    'NyxKeepsake': ItemData(hades_base_item_id+25, True),
    'ThanatosKeepsake': ItemData(hades_base_item_id+26, True),
    'CharonKeepsake': ItemData(hades_base_item_id+27, True),
    'HypnosKeepsake': ItemData(hades_base_item_id+28, True),
    'MegaeraKeepsake': ItemData(hades_base_item_id+29, True),
    'OrpheusKeepsake': ItemData(hades_base_item_id+30, True),
    'DusaKeepsake': ItemData(hades_base_item_id+31, True),
    'SkellyKeepsake': ItemData(hades_base_item_id+32, True),
    'ZeusKeepsake': ItemData(hades_base_item_id+33, True),
    'PoseidonKeepsake': ItemData(hades_base_item_id+34, True),
    'AthenaKeepsake': ItemData(hades_base_item_id+35, True),
    'AphroditeKeepsake': ItemData(hades_base_item_id+36, True),
    'AresKeepsake': ItemData(hades_base_item_id+37, True),
    'ArtemisKeepsake': ItemData(hades_base_item_id+38, True),
    'DionysusKeepsake': ItemData(hades_base_item_id+39, True),
    'HermesKeepsake': ItemData(hades_base_item_id+40, True),
    'DemeterKeepsake': ItemData(hades_base_item_id+41, True),
    'ChaosKeepsake': ItemData(hades_base_item_id+42, True),
    'SisyphusKeepsake': ItemData(hades_base_item_id+43, True),
    'EurydiceKeepsake': ItemData(hades_base_item_id+44, True),
    'PatroclusKeepsake': ItemData(hades_base_item_id+45, True),
}

item_table_weapons: Dict[str, ItemData] ={
    'SwordWeaponUnlockItem': ItemData(hades_base_item_id+46, True),
    'BowWeaponUnlockItem': ItemData(hades_base_item_id+47, True),
    'SpearWeaponUnlockItem': ItemData(hades_base_item_id+48, True),
    'ShieldWeaponUnlockItem': ItemData(hades_base_item_id+49, True),
    'FistWeaponUnlockItem': ItemData(hades_base_item_id+50, True),
    'GunWeaponUnlockItem': ItemData(hades_base_item_id+51, True),
}

item_table_store: Dict[str, ItemData] ={
    'FountainUpgrade1Item': ItemData(hades_base_item_id+52, True),
    'FountainUpgrade2Item': ItemData(hades_base_item_id+53, True),
    'FountainTartarusItem': ItemData(hades_base_item_id+54, True),
    'FountainAsphodelItem': ItemData(hades_base_item_id+55, True),
    'FountainElysiumItem': ItemData(hades_base_item_id+56, True),
    'UrnsOfWealth1Item': ItemData(hades_base_item_id+57, True),
    'UrnsOfWealth2Item': ItemData(hades_base_item_id+58, True),
    'UrnsOfWealth3Item': ItemData(hades_base_item_id+59, True),
    'InfernalThrove1Item': ItemData(hades_base_item_id+60, True),
    'InfernalThrove2Item': ItemData(hades_base_item_id+61, True),
    'InfernalThrove3Item': ItemData(hades_base_item_id+62, True),
    'KeepsakeCollectionItem': ItemData(hades_base_item_id+63, True),
    'DeluxeContractorDeskItem': ItemData(hades_base_item_id+64, True),
    'VanquishersKeepItem': ItemData(hades_base_item_id+65, True),
    'FishingRodItem': ItemData(hades_base_item_id+66, True),
    'CourtMusicianSentenceItem': ItemData(hades_base_item_id+67, True),
    'CourtMusicianStandItem': ItemData(hades_base_item_id+68, True),
    'PitchBlackDarknessItem': ItemData(hades_base_item_id+69, True),
    'FatedKeysItem': ItemData(hades_base_item_id+70, True),
    'BrilliantGemstonesItem': ItemData(hades_base_item_id+71, True),
    'VintageNectarItem': ItemData(hades_base_item_id+72, True),
    'DarkerThirstItem': ItemData(hades_base_item_id+73, True),
}

item_table_hidden_aspects : Dict[str, ItemData] ={
    "SwordHiddenAspect" : ItemData(hades_base_item_id+74, True),
	"BowHiddenAspect": ItemData(hades_base_item_id+75, True),
	"SpearHiddenAspect": ItemData(hades_base_item_id+76, True),
	"ShieldHiddenAspect": ItemData(hades_base_item_id+77, True),
	"FistHiddenAspect": ItemData(hades_base_item_id+78, True),
	"GunHiddenAspect": ItemData(hades_base_item_id+79, True)
}



def create_filler_pool_options(options):
    item_filler_options = []
    if (options.darkness_pack_value.value > 0):
        item_filler_options.append('Darkness')
    if (options.keys_pack_value.value > 0):
        item_filler_options.append('Keys')
    if (options.gemstones_pack_value.value > 0):
        item_filler_options.append('Gemstones')
    if (options.diamonds_pack_value.value > 0):
        item_filler_options.append('Diamonds')
    if (options.titan_blood_pack_value.value > 0):
        item_filler_options.append('TitanBlood')
    if (options.nectar_pack_value.value > 0):
        item_filler_options.append('Nectar')
    if (options.ambrosia_pack_value.value > 0):
        item_filler_options.append('Ambrosia')
    if (len(item_filler_options)==0):
        item_filler_options.append('Darkness')
    return item_filler_options

#Here we have 39 items
#This should be replace with a method that construct the dictionary from the settings.
item_pool_pacts: Dict[str, int] = {
    'HardLaborPactLevel': 5,
    'LastingConsequencesPactLevel': 4,
    'ConvenienceFeePactLevel': 2,
    'JurySummonsPactLevel': 3,
    'ExtremeMeasuresPactLevel': 4,
    'CalisthenicsProgramPactLevel': 2,
    'BenefitsPackagePactLevel': 2,
    'MiddleManagementPactLevel': 1,
    'UnderworldCustomsPactLevel': 1,
    'ForcedOvertimePactLevel': 2,
    'HeightenedSecurityPactLevel': 1,
    'RoutineInspectionPactLevel': 4,
    'DamageControlPactLevel': 2,
    'ApprovalProcessPactLevel': 2,
    'TightDeadlinePactLevel': 2,
    'PersonalLiabilityPactLevel': 1,
}

def create_pact_pool_amount(options) -> Dict[str, int]:
    item_pool_pacts = {
        'HardLaborPactLevel': int(options.hard_labor_pact_amount.value),
        'LastingConsequencesPactLevel': int(options.lasting_consequences_pact_amount.value),
        'ConvenienceFeePactLevel': int(options.convenience_fee_pact_amount.value),
        'JurySummonsPactLevel': int(options.jury_summons_pact_amount.value),
        'ExtremeMeasuresPactLevel': int(options.extreme_measures_pact_amount.value),
        'CalisthenicsProgramPactLevel': int(options.calisthenics_program_pact_amount.value),
        'BenefitsPackagePactLevel': int(options.benefits_package_pact_amount.value),
        'MiddleManagementPactLevel': int(options.middle_management_pact_amount.value),
        'UnderworldCustomsPactLevel': int(options.underworld_customs_pact_amount.value),
        'ForcedOvertimePactLevel': int(options.forced_overtime_pact_amount.value),
        'HeightenedSecurityPactLevel': int(options.heightened_security_pact_amount.value),
        'RoutineInspectionPactLevel': int(options.routine_inspection_pact_amount.value),
        'DamageControlPactLevel': int(options.damage_control_pact_amount.value),
        'ApprovalProcessPactLevel': int(options.approval_process_pact_amount.value),
        'TightDeadlinePactLevel': int(options.tight_deadline_pact_amount.value),
        'PersonalLiabilityPactLevel': int(options.personal_liability_pact_amount.value),
    }
    return item_pool_pacts




event_item_pairs: Dict[str, str] = {
    "Beat Hades": "HadesVictory",
    "Beat Meg": "MegVictory",
    "Beat Lernie": "LernieVictory",
    "Beat Bros": "BrosVictory",
    'IsThereNoEscape?Event': 'IsThereNoEscape?EventItem',
    'DistantRelativesEvent': 'DistantRelativesEventItem',
    'ChthonicColleaguesEvent': 'ChthonicColleaguesEventItem',
    'TheReluctantMusicianEvent': 'TheReluctantMusicianEventItem',
    'GoddessOfWisdomEvent': 'GoddessOfWisdomEventItem',
    'GodOfTheHeavensEvent': 'GodOfTheHeavensEventItem',
    'GodOfTheSeaEvent': 'GodOfTheSeaEventItem',
    'GoddessOfLoveEvent': 'GoddessOfLoveEventItem',
    'GodOfWarEvent': 'GodOfWarEventItem',
    'GoddessOfTheHuntEvent': 'GoddessOfTheHuntEventItem',
    'GodOfWineEvent': 'GodOfWineEventItem',
    'GodOfSwiftnessEvent': 'GodOfSwiftnessEventItem',
    'GoddessOfSeasonsEvent': 'GoddessOfSeasonsEventItem',
    'PowerWithoutEqualEvent': 'PowerWithoutEqualEventItem',
    'DivinePairingsEvent': 'DivinePairingsEventItem',
    'PrimordialBoonsEvent': 'PrimordialBoonsEventItem',
    'PrimordialBanesEvent': 'PrimordialBanesEventItem',
    'InfernalArmsEvent': 'InfernalArmsEventItem',
    'TheStygianBladeEvent': 'TheStygianBladeEventItem',
    'TheHeartSeekingBowEvent': 'TheHeartSeekingBowEventItem',
    'TheShieldOfChaosEvent': 'TheShieldOfChaosEventItem',
    'TheEternalSpearEvent': 'TheEternalSpearEventItem',
    'TheTwinFistsEvent': 'TheTwinFistsEventItem',
    'TheAdamantRailEvent': 'TheAdamantRailEventItem',
    'MasterOfArmsEvent': 'MasterOfArmsEventItem',
    'AViolentPastEvent': 'AViolentPastEventItem',
    'HarshConditionsEvent': 'HarshConditionsEventItem',
    'SlashedBenefitsEvent': 'SlashedBenefitsEventItem',
    'WantonRansackingEvent': 'WantonRansackingEventItem',
    'ASimpleJobEvent': 'ASimpleJobEventItem',
    'ChthonicKnowledgeEvent': 'ChthonicKnowledgeEventItem',
    'CustomerLoyaltyEvent': 'CustomerLoyaltyEventItem',
    'DarkReflectionsEvent': 'DarkReflectionsEventItem',
    'CloseAtHeartEvent': 'CloseAtHeartEventItem',
    'DenizensOfTheDeepEvent': 'DenizensOfTheDeepEventItem',
    'TheUselessTrinketEvent': 'TheUselessTrinketEventItem', 
}

event_item_pairs_weapon_mode: Dict[str, str] = {
    'IsThereNoEscape?Event': 'IsThereNoEscape?EventItem',
    'DistantRelativesEvent': 'DistantRelativesEventItem',
    'ChthonicColleaguesEvent': 'ChthonicColleaguesEventItem',
    'TheReluctantMusicianEvent': 'TheReluctantMusicianEventItem',
    'GoddessOfWisdomEvent': 'GoddessOfWisdomEventItem',
    'GodOfTheHeavensEvent': 'GodOfTheHeavensEventItem',
    'GodOfTheSeaEvent': 'GodOfTheSeaEventItem',
    'GoddessOfLoveEvent': 'GoddessOfLoveEventItem',
    'GodOfWarEvent': 'GodOfWarEventItem',
    'GoddessOfTheHuntEvent': 'GoddessOfTheHuntEventItem',
    'GodOfWineEvent': 'GodOfWineEventItem',
    'GodOfSwiftnessEvent': 'GodOfSwiftnessEventItem',
    'GoddessOfSeasonsEvent': 'GoddessOfSeasonsEventItem',
    'PowerWithoutEqualEvent': 'PowerWithoutEqualEventItem',
    'DivinePairingsEvent': 'DivinePairingsEventItem',
    'PrimordialBoonsEvent': 'PrimordialBoonsEventItem',
    'PrimordialBanesEvent': 'PrimordialBanesEventItem',
    'InfernalArmsEvent': 'InfernalArmsEventItem',
    'TheStygianBladeEvent': 'TheStygianBladeEventItem',
    'TheHeartSeekingBowEvent': 'TheHeartSeekingBowEventItem',
    'TheShieldOfChaosEvent': 'TheShieldOfChaosEventItem',
    'TheEternalSpearEvent': 'TheEternalSpearEventItem',
    'TheTwinFistsEvent': 'TheTwinFistsEventItem',
    'TheAdamantRailEvent': 'TheAdamantRailEventItem',
    'MasterOfArmsEvent': 'MasterOfArmsEventItem',
    'AViolentPastEvent': 'AViolentPastEventItem',
    'HarshConditionsEvent': 'HarshConditionsEventItem',
    'SlashedBenefitsEvent': 'SlashedBenefitsEventItem',
    'WantonRansackingEvent': 'WantonRansackingEventItem',
    'ASimpleJobEvent': 'ASimpleJobEventItem',
    'ChthonicKnowledgeEvent': 'ChthonicKnowledgeEventItem',
    'CustomerLoyaltyEvent': 'CustomerLoyaltyEventItem',
    'DarkReflectionsEvent': 'DarkReflectionsEventItem',
    'CloseAtHeartEvent': 'CloseAtHeartEventItem',
    'DenizensOfTheDeepEvent': 'DenizensOfTheDeepEventItem',
    'TheUselessTrinketEvent': 'TheUselessTrinketEventItem', 
    "Beat HadesSwordWeapon": "HadesVictorySwordWeapon",
    "Beat MegSwordWeapon": "MegVictorySwordWeapon",
    "Beat LernieSwordWeapon": "LernieVictorySwordWeapon",
    "Beat BrosSwordWeapon": "BrosVictorySwordWeapon",
    "Beat HadesBowWeapon": "HadesVictoryBowWeapon",
    "Beat MegBowWeapon": "MegVictoryBowWeapon",
    "Beat LernieBowWeapon": "LernieVictoryBowWeapon",
    "Beat BrosBowWeapon": "BrosVictoryBowWeapon",
    "Beat HadesSpearWeapon": "HadesVictorySpearWeapon",
    "Beat MegSpearWeapon": "MegVictorySpearWeapon",
    "Beat LernieSpearWeapon": "LernieVictorySpearWeapon",
    "Beat BrosSpearWeapon": "BrosVictorySpearWeapon",
    "Beat HadesShieldWeapon": "HadesVictoryShieldWeapon",
    "Beat MegShieldWeapon": "MegVictoryShieldWeapon",
    "Beat LernieShieldWeapon": "LernieVictoryShieldWeapon",
    "Beat BrosShieldWeapon": "BrosVictoryShieldWeapon",
    "Beat HadesFistWeapon": "HadesVictoryFistWeapon",
    "Beat MegFistWeapon": "MegVictoryFistWeapon",
    "Beat LernieFistWeapon": "LernieVictoryFistWeapon",
    "Beat BrosFistWeapon": "BrosVictoryFistWeapon",
    "Beat HadesGunWeapon": "HadesVictoryGunWeapon",
    "Beat MegGunWeapon": "MegVictoryGunWeapon",
    "Beat LernieGunWeapon": "LernieVictoryGunWeapon",
    "Beat BrosGunWeapon": "BrosVictoryGunWeapon",
}



item_table = {
    **item_table_pacts,
    **items_table_event,
    **items_table_fates_completion,
    **item_table_filler,
    **item_table_keepsake,
    **item_table_weapons,
    **item_table_store,
    **item_table_hidden_aspects,
}

class HadesItem(Item):
    game = "Hades"

    def __init__(self, name, player: int = None):
        item_data = item_table[name]
        super(HadesItem, self).__init__(
            name,
            ItemClassification.progression if item_data.progression else ItemClassification.filler,
            item_data.code, player
        )
