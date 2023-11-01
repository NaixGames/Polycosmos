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

class HardLaborPactAmmount(Range):
    """Choose the ammount of Hard Labor pacts in the pool."""
    display_name = "Hard Labor Pact Ammount"
    range_start = 0
    range_end = 5
    default = 3
    internal_name = "HardLaborPactLevel"

class LastingConsequencesPactAmmount(Range):
    """Choose the ammount of Lasting Consequences pacts in the pool. """
    display_name = "Lasting Consequences Pact Ammount"
    range_start = 0
    range_end = 4
    default = 2
    internal_name = "LastingConsequencesPactLevel"

class ConvenienceFeePactAmmount(Range):
    """Choose the ammount of Convenience Fee pacts in the pool."""
    display_name = "Convenience Fee Pact Ammount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "ConvenienceFeePactLevel"

class JurySummonsPactAmmount(Range):
    """Choose the ammount of Jury Summons pacts in the pool."""
    display_name = "Jury Summons Pact Ammount"
    range_start = 0
    range_end = 3
    default = 2
    internal_name = "JurySummonsPactLevel"

class ExtremeMeasuresPactAmmount(Range):
    """Choose the ammount of Extreme Measures pacts in the pool. """
    display_name = "Extreme Measures Pact Ammount"
    range_start = 0
    range_end = 4
    default = 2
    internal_name = "ExtremeMeasuresPactLevel"

class CalisthenicsProgramPactAmmount(Range):
    """Choose the ammount of Calisthenics Program pacts in the pool."""
    display_name = "Calisthenics Program Pact Ammount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "CalisthenicsProgramPactLevel"

class BenefitsPackagePactAmmount(Range):
    """Choose the ammount of Benefits Package pacts in the pool."""
    display_name = "Benefits Package Pact Ammount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "BenefitsPackagePactLevel"

class MiddleManagementPactAmmount(Range):
    """Choose the ammount of Middle Management pacts in the pool."""
    display_name = "Middle Management Pact Ammount"
    range_start = 0
    range_end = 1
    default = 1
    internal_name = "MiddleManagementPactLevel"

class UnderworldCustomsPactAmmount(Range):
    """Choose the ammount of Underworld Customs pacts in the pool."""
    display_name = "Underworld Customs Pact Ammount"
    range_start = 0
    range_end = 1
    default = 1
    internal_name = "UnderworldCustomsPactLevel"

class ForcedOvertimePactAmmount(Range):
    """Choose the ammount of Forced Overtime pacts in the pool."""
    display_name = "Forced Overtime Pact Ammount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "ForcedOvertimePactLevel"

class HeightenedSecurityPactAmmount(Range):
    """Choose the ammount of Heightened Security pacts in the pool."""
    display_name = "Heightened Security Pact Ammount"
    range_start = 0
    range_end = 1
    default = 1
    internal_name = "HeightenedSecurityPactLevel"

class RoutineInspectionPactAmmount(Range):
    """Choose the ammount of Routine Inspection pacts in the pool."""
    display_name = "Routine Inspection Pact Ammount"
    range_start = 0
    range_end = 4
    default = 3
    internal_name = "RoutineInspectionPactLevel"

class DamageControlPactAmmount(Range):
    """Choose the ammount of Damage Control pacts in the pool."""
    display_name = "Damage Control Pact Ammount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "DamageControlPactLevel"

class ApprovalProcessPactAmmount(Range):
    """Choose the ammount of Approval Process pacts in the pool."""
    display_name = "Approval Process Pact Ammount"
    range_start = 0
    range_end = 2
    default = 1
    internal_name = "ApprovalProcessPactLevel"

class TightDeadlinePactAmmount(Range):
    """Choose the ammount of Tight Deadline pacts in the pool."""
    display_name = "Tight Deadline Pact Ammount"
    range_start = 0
    range_end = 3
    default = 2
    internal_name = "TightDeadlinePactLevel"

class PersonalLiabilityPactAmmount(Range):
    """Choose the ammount of Personal Liability pacts in the pool."""
    display_name = "Personal Liability Pact Ammount"
    range_start = 0
    range_end = 1
    default = 0
    internal_name = "PersonalLiabilityPactLevel"

class DarknessPackValue(Range):
    """Choose the value(ammount of darkness) of each darkness pack in the pool. If set to 0 Darkness will not appear in the pool."""
    display_name = "Darkness Pack Value"
    range_start = 0
    range_end = 10000
    default = 1000
    internal_name = "DarknessPackValue"

class KeysPackValue(Range):
    """Choose the value(ammount of Keys) of each Keys pack in the pool. If set to 0 Keys will not appear in the pool"""
    display_name = "Keys Pack Value"
    range_start = 0
    range_end = 500
    default = 20
    internal_name = "KeysPackValue"

class GemstonesPackValue(Range):
    """Choose the value(ammount of Gemstones) of each Gemstone pack in the pool. If set to 0 Gems will not appear in the pool"""
    display_name = "Gemstone Pack Value"
    range_start = 0
    range_end = 2500
    default = 100
    internal_name = "GemstonePackValue"

class DiamondsPackValue(Range):
    """Choose the value(ammount of diamonds) of each diamonds pack in the pool. If set to 0 Diamonds will not appear in the pool"""
    display_name = "Diamonds Pack Value"
    range_start = 0
    range_end = 100
    default = 15
    internal_name = "DiamondsPackValue"

class TitanBloodPackValue(Range):
    """Choose the value(ammount of Titan blood) of each Titan blood pack in the pool. If set to 0 Titan blood will not appear in the pool"""
    display_name = "Titan Blood Pack Value"
    range_start = 0
    range_end = 50
    default = 3
    internal_name = "TitanBloodPackValue"

class NectarPackValue(Range):
    """Choose the value(ammount of Nectar) of each Nectar pack in the pool. If set to 0 Nectar will not appear in the pool"""
    display_name = "Nectar Pack Value"
    range_start = 0
    range_end = 50
    default = 3
    internal_name = "NectarPackValue"

class AmbrosiaPackValue(Range):
    """Choose the value(ammount of Ambrosia) of each Ambrosia pack in the pool. If set to 0 Ambrosia will not appear in the pool"""
    display_name = "Ambrosia Pack Value"
    range_start = 0
    range_end = 50
    default = 3
    internal_name = "AmbrosiaPackValue"


# ------------------------------ Building dictionary ------------------------


hades_options: typing.Dict[str, type(Option)] = {
    "weapon": InitialWeapon,
    "death_link": DeathLink,
    "hard_labor_pact_ammount": HardLaborPactAmmount,
    "lasting_consequences_pact_ammount": LastingConsequencesPactAmmount,
    "convenience_fee_pact_ammount": ConvenienceFeePactAmmount,
    "jury_summons_pact_ammount": JurySummonsPactAmmount,
    "extreme_measures_pact_ammount": ExtremeMeasuresPactAmmount,
    "calisthenics_program_pact_ammount": CalisthenicsProgramPactAmmount,
    "benefits_package_pact_ammount": BenefitsPackagePactAmmount,
    "middle_management_pact_ammount": MiddleManagementPactAmmount,
    "underworld_customs_pact_ammount": UnderworldCustomsPactAmmount,
    "forced_overtime_pact_ammount": ForcedOvertimePactAmmount,
    "heightened_security_pact_ammount": HeightenedSecurityPactAmmount,
    "routine_inspection_pact_ammount": RoutineInspectionPactAmmount,
    "damage_control_pact_ammount": DamageControlPactAmmount,
    "approval_process_pact_ammount": ApprovalProcessPactAmmount,
    "tight_deadline_pact_ammount": TightDeadlinePactAmmount,
    "personal_liability_pact_ammount": PersonalLiabilityPactAmmount,
    "darkness_pack_value": DarknessPackValue,
    "keys_pack_value": KeysPackValue,
    "gemstones_pack_value": GemstonesPackValue,
    "diamonds_pack_value": DiamondsPackValue,
    "titan_blood_pack_value": TitanBloodPackValue,
    "nectar_pack_value": NectarPackValue,
    "ambrosia_pack_value": AmbrosiaPackValue,
}
