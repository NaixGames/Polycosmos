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
}

#Here we have 39 items
item_pool_pacts: Dict[str, int] = {
    'HardLaborPactLevel': 5,
    'LastingConsequencesPactLevel': 4,
    'ConvenienceFeePactLevel': 2,
    'JurySummonsPactLevel': 3,
    'ExtremeMeasuresPactLevel': 4,
    'CalisthenicsProgramPactLevel': 2,
    'BenefitsPackagePactLevel': 2,
    'MiddleManagementPactLevel': 2,
    'UnderworldCustomsPactLevel': 1,
    'ForcedOvertimePactLevel': 2,
    'HeightenedSecurityPactLevel': 1,
    'RoutineInspectionPactLevel': 4,
    'DamageControlPactLevel': 2,
    'ApprovalProcessPactLevel': 2,
    'TightDeadlinePactLevel': 2,
    'PersonalLiabilityPactLevel': 1,
}

#Here we have 11 items
item_pool_fillers: Dict[str, int] = {
    'Darkness': 1,
    'Keys': 1,
}

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
