import typing

from BaseClasses import Item, ItemClassification
from typing import Dict

class ItemData(typing.NamedTuple):
    code: typing.Optional[int]
    progression: bool
    event: bool = False


hades_base_item_id = 666100

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
    'Victory': ItemData(hades_base_item_id+666, True, True),
    'MegVictory': ItemData(hades_base_item_id+667,True,True),
    'LernieVictory': ItemData(hades_base_item_id+668,True,True),
    'BrosVictory': ItemData(hades_base_item_id+669,True,True)
}

item_table_filler: Dict[str, ItemData] = {
    'Darkness': ItemData(hades_base_item_id+16, False),
    'Keys': ItemData(hades_base_item_id+17, False),
    'Gemstones': ItemData(hades_base_item_id+18, False),
    'Diamonds': ItemData(hades_base_item_id+19, False),
    'TitanBlood': ItemData(hades_base_item_id+20, False),
    'Nectar': ItemData(hades_base_item_id+21, True),
    'Ambrosia': ItemData(hades_base_item_id+22, False)
}

item_table_keepsake: Dict[str, ItemData] ={
    'CerberusKeepsake': ItemData(hades_base_item_id+23, False),
    'AchillesKeepsake': ItemData(hades_base_item_id+24, False),
    'NyxKeepsake': ItemData(hades_base_item_id+25, False),
    'ThanatosKeepsake': ItemData(hades_base_item_id+26, False),
    'CharonKeepsake': ItemData(hades_base_item_id+27, False),
    'HypnosKeepsake': ItemData(hades_base_item_id+28, False),
    'MegaeraKeepsake': ItemData(hades_base_item_id+29, False),
    'OrpheusKeepsake': ItemData(hades_base_item_id+30, False),
    'DusaKeepsake': ItemData(hades_base_item_id+31, False),
    'SkellyKeepsake': ItemData(hades_base_item_id+32, False),
    'ZeusKeepsake': ItemData(hades_base_item_id+33, False),
    'PoseidonKeepsake': ItemData(hades_base_item_id+34, False),
    'AthenaKeepsake': ItemData(hades_base_item_id+35, False),
    'AphroditeKeepsake': ItemData(hades_base_item_id+36, False),
    'AresKeepsake': ItemData(hades_base_item_id+37, False),
    'ArtemisKeepsake': ItemData(hades_base_item_id+38, False),
    'DionysusKeepsake': ItemData(hades_base_item_id+39, False),
    'HermesKeepsake': ItemData(hades_base_item_id+40, False),
    'DemeterKeepsake': ItemData(hades_base_item_id+41, False),
    'ChaosKeepsake': ItemData(hades_base_item_id+42, False),
    'SisyphusKeepsake': ItemData(hades_base_item_id+43, False),
    'EurydiceKeepsake': ItemData(hades_base_item_id+44, False),
    'PatroclusKeepsake': ItemData(hades_base_item_id+45, False),
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
    "Beat Hades": "Victory",
    "Beat Meg": "MegVictory",
    "Beat Lernie": "LernieVictory",
    "Beat Bros": "BrosVictory",
}

item_table = {
    **item_table_pacts,
    **items_table_event,
    **item_table_filler,
    **item_table_keepsake,
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
