import typing
from Options import TextChoice, Option, Range, Toggle, DeathLink


class InitialWeapon(TextChoice):
    """Chose your initial weapon. Although this does not do anything now.
     """
    display_name = "weapon"
    option_Sword = 0
    option_Bow = 1
    internal_name = "Weapon"

# -----------------------Settings for Pact levels ---------------

class HardLaborPactAmount(Range):
    """Choose the amount of Hard Labor pacts in the pool."""
    display_name = "Hard Labor Pact Amount"
    range_start = 0
    range_end = 5
    default = 3
    internal_name = "HardLaborPactLevel"

class LastingConsequencesPactAmount(Range):
    """Choose the amount of Lasting Consequences pacts in the pool. """
    display_name = "Lasting Consequences Pact Amount"
    range_start = 0
    range_end = 4
    default = 2
    internal_name = "LastingConsequencesPactLevel"

class ConvenienceFeePactAmount(Range):
    """Choose the amount of Convenience Fee pacts in the pool."""
    display_name = "Convenience Fee Pact Amount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "ConvenienceFeePactLevel"

class JurySummonsPactAmount(Range):
    """Choose the amount of Jury Summons pacts in the pool."""
    display_name = "Jury Summons Pact Amount"
    range_start = 0
    range_end = 3
    default = 2
    internal_name = "JurySummonsPactLevel"

class ExtremeMeasuresPactAmount(Range):
    """Choose the amount of Extreme Measures pacts in the pool. """
    display_name = "Extreme Measures Pact Amount"
    range_start = 0
    range_end = 4
    default = 2
    internal_name = "ExtremeMeasuresPactLevel"

class CalisthenicsProgramPactAmount(Range):
    """Choose the amount of Calisthenics Program pacts in the pool."""
    display_name = "Calisthenics Program Pact Amount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "CalisthenicsProgramPactLevel"

class BenefitsPackagePactAmount(Range):
    """Choose the amount of Benefits Package pacts in the pool."""
    display_name = "Benefits Package Pact Amount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "BenefitsPackagePactLevel"

class MiddleManagementPactAmount(Range):
    """Choose the amount of Middle Management pacts in the pool."""
    display_name = "Middle Management Pact Amount"
    range_start = 0
    range_end = 1
    default = 1
    internal_name = "MiddleManagementPactLevel"

class UnderworldCustomsPactAmount(Range):
    """Choose the amount of Underworld Customs pacts in the pool."""
    display_name = "Underworld Customs Pact Amount"
    range_start = 0
    range_end = 1
    default = 1
    internal_name = "UnderworldCustomsPactLevel"

class ForcedOvertimePactAmount(Range):
    """Choose the amount of Forced Overtime pacts in the pool."""
    display_name = "Forced Overtime Pact Amount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "ForcedOvertimePactLevel"

class HeightenedSecurityPactAmount(Range):
    """Choose the amount of Heightened Security pacts in the pool."""
    display_name = "Heightened Security Pact Amount"
    range_start = 0
    range_end = 1
    default = 1
    internal_name = "HeightenedSecurityPactLevel"

class RoutineInspectionPactAmount(Range):
    """Choose the amount of Routine Inspection pacts in the pool."""
    display_name = "Routine Inspection Pact Amount"
    range_start = 0
    range_end = 4
    default = 3
    internal_name = "RoutineInspectionPactLevel"

class DamageControlPactAmount(Range):
    """Choose the amount of Damage Control pacts in the pool."""
    display_name = "Damage Control Pact Amount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "DamageControlPactLevel"

class ApprovalProcessPactAmount(Range):
    """Choose the amount of Approval Process pacts in the pool."""
    display_name = "Approval Process Pact Amount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "ApprovalProcessPactLevel"

class TightDeadlinePactAmount(Range):
    """Choose the amount of Tight Deadline pacts in the pool."""
    display_name = "Tight Deadline Pact Amount"
    range_start = 0
    range_end = 3
    default = 2
    internal_name = "TightDeadlinePactLevel"

class PersonalLiabilityPactAmount(Range):
    """Choose the amount of Personal Liability pacts in the pool."""
    display_name = "Personal Liability Pact Amount"
    range_start = 0
    range_end = 1
    default = 0
    internal_name = "PersonalLiabilityPactLevel"

class DarknessPackValue(Range):
    """Choose the value(amount of darkness) of each darkness pack in the pool. If set to 0 Darkness will not appear in the pool."""
    display_name = "Darkness Pack Value"
    range_start = 0
    range_end = 10000
    default = 1000
    internal_name = "DarknessPackValue"

class KeysPackValue(Range):
    """Choose the value(amount of Keys) of each Keys pack in the pool. If set to 0 Keys will not appear in the pool"""
    display_name = "Keys Pack Value"
    range_start = 0
    range_end = 500
    default = 20
    internal_name = "KeysPackValue"

class GemstonesPackValue(Range):
    """Choose the value(amount of Gemstones) of each Gemstone pack in the pool. If set to 0 Gems will not appear in the pool"""
    display_name = "Gemstone Pack Value"
    range_start = 0
    range_end = 2500
    default = 100
    internal_name = "GemstonePackValue"

class DiamondsPackValue(Range):
    """Choose the value(amount of diamonds) of each diamonds pack in the pool. If set to 0 Diamonds will not appear in the pool"""
    display_name = "Diamonds Pack Value"
    range_start = 0
    range_end = 100
    default = 15
    internal_name = "DiamondsPackValue"

class TitanBloodPackValue(Range):
    """Choose the value(amount of Titan blood) of each Titan blood pack in the pool. If set to 0 Titan blood will not appear in the pool"""
    display_name = "Titan Blood Pack Value"
    range_start = 0
    range_end = 50
    default = 3
    internal_name = "TitanBloodPackValue"

class NectarPackValue(Range):
    """Choose the value(amount of Nectar) of each Nectar pack in the pool. If set to 0 Nectar will not appear in the pool"""
    display_name = "Nectar Pack Value"
    range_start = 0
    range_end = 50
    default = 3
    internal_name = "NectarPackValue"

class AmbrosiaPackValue(Range):
    """Choose the value(amount of Ambrosia) of each Ambrosia pack in the pool. If set to 0 Ambrosia will not appear in the pool"""
    display_name = "Ambrosia Pack Value"
    range_start = 0
    range_end = 50
    default = 3
    internal_name = "AmbrosiaPackValue"


# ------------------------------ Building dictionary ------------------------


hades_options: typing.Dict[str, type(Option)] = {
    "weapon": InitialWeapon,
    "death_link": DeathLink,
    "hard_labor_pact_amount": HardLaborPactAmount,
    "lasting_consequences_pact_amount": LastingConsequencesPactAmount,
    "convenience_fee_pact_amount": ConvenienceFeePactAmount,
    "jury_summons_pact_amount": JurySummonsPactAmount,
    "extreme_measures_pact_amount": ExtremeMeasuresPactAmount,
    "calisthenics_program_pact_amount": CalisthenicsProgramPactAmount,
    "benefits_package_pact_amount": BenefitsPackagePactAmount,
    "middle_management_pact_amount": MiddleManagementPactAmount,
    "underworld_customs_pact_amount": UnderworldCustomsPactAmount,
    "forced_overtime_pact_amount": ForcedOvertimePactAmount,
    "heightened_security_pact_amount": HeightenedSecurityPactAmount,
    "routine_inspection_pact_amount": RoutineInspectionPactAmount,
    "damage_control_pact_amount": DamageControlPactAmount,
    "approval_process_pact_amount": ApprovalProcessPactAmount,
    "tight_deadline_pact_amount": TightDeadlinePactAmount,
    "personal_liability_pact_amount": PersonalLiabilityPactAmount,
    "darkness_pack_value": DarknessPackValue,
    "keys_pack_value": KeysPackValue,
    "gemstones_pack_value": GemstonesPackValue,
    "diamonds_pack_value": DiamondsPackValue,
    "titan_blood_pack_value": TitanBloodPackValue,
    "nectar_pack_value": NectarPackValue,
    "ambrosia_pack_value": AmbrosiaPackValue,
}
