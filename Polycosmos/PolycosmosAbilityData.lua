ModUtil.Mod.Register("PolycosmosAbilityData")

PolycosmosAbilityData = {}

--This file contains reference tables and trait data for use in PolycosmosAbilityManager.lua


PolycosmosAbilityData.AbilityMap = {

    ["Dash"] = "NoDashTrait",

    ["Sword Attack"] = "NoAttackSwordTrait",
    ["Spear Attack"] = "NoAttackSpearTrait",
    ["Shield Attack"] = "NoAttackShieldTrait",
    ["Bow Attack"] = "NoAttackBowTrait",
    ["Fist Attack"] = "NoAttackFistTrait",
    ["Gun Attack"] = "NoAttackGunTrait",

    ["Sword Special"] = "NoSpecialSwordTrait",
    ["Spear Special"] = "NoSpecialSpearTrait",
    ["Shield Special"] = "NoSpecialShieldTrait",
    ["Bow Special"] = "NoSpecialBowTrait",
    ["Fist Special"] = "NoSpecialFistTrait",
    ["Gun Special"] = "NoSpecialGunTrait",

    ["Cast"] = "NoCastTrait",
    ["Call"] = "NoCallTrait",
}

PolycosmosAbilityData.WeaponTraits =
{
    SwordWeapon =
    {
        Attack = "NoAttackSwordTrait",
        Special = "NoSpecialSwordTrait",
    },
    SpearWeapon =
    {
        Attack = "NoAttackSpearTrait",
        Special = "NoSpecialSpearTrait",
    },
    ShieldWeapon =
    {
        Attack = "NoAttackShieldTrait",
        Special = "NoSpecialShieldTrait",
    },
    BowWeapon =
    {
        Attack = "NoAttackBowTrait",
        Special = "NoSpecialBowTrait",
    },
    FistWeapon =
    {
        Attack = "NoAttackFistTrait",
        Special = "NoSpecialFistTrait",
    },
    GunWeapon =
    {
        Attack = "NoAttackGunTrait",
        Special = "NoSpecialGunTrait",
    },
}

--when we filter boons and upgrades later, not all daedalus hammer upgrades or chaos effects follow a consistent scheme. 
--sadly, this means we have to blacklist them manually, so we'll use these tables to map the trait to its ability
PolycosmosAbilityData.OtherAttackEffects = {
    SwordHealthBufferDamageTrait = true,
    SwordCriticalTrait = true,
    SwordCursedLifeStealTrait = true,
    SwordDoubleDashAttackTrait = true,
    SwordTwoComboTrait = true,
    SwordGoldDamageTrait = true,
    SwordThrustWaveTrait = true,
    SwordBackstabTrait = true,
    SwordHeavySecondStrikeTrait = true,

    SpearReachAttack = true,
    SpearSpinDamageRadius = true,
    SpearSpinChargeLevelTime = true,
    SpearAutoAttack = true,
    SpearDashMultiStrike = true,
    SpearSpinChargeAreaDamageTrait = true,
    SpearAttackPhalanxTrait = true,
    SpearSpinTravelDurationTrait = true,

    BowDoubleShotTrait = true,
    BowLongRangeDamageTrait = true,
    BowSlowChargeDamageTrait = true,
    BowTapFireTrait = true,
    BowPowerShotTrait = true,
    BowTripleShotTrait = true,
    BowChainShotTrait = true,
    BowCloseAttackTrait = true,

    ShieldChargeSpeedTrait = true,
    ShieldBashDamageTrait = true,
    ShieldDashAOETrait = true,
    ShieldPerfectRushTrait = true,
    ShieldChargeHealthBufferTrait = true,
    ShieldRushProjectileTrait = true,
    ShieldThrowEmpowerTrait = true,

    FistDashAttackHealthBufferTrait = true,
    FistAttackFinisherTrait = true,
    FistReachAttackTrait = true,
    FistConsecutiveAttackTrait = true,
    FistHeavyAttackTrait = true,

    GunMinigunTrait = true,
    GunChainShotTrait = true,
    GunShotgunTrait = true,
    GunHeavyBulletTrait = true,
    GunInfiniteAmmoTrait = true,
    GunArmorPenerationTrait = true,
    GunHomingBulletTrait = true,
    GunLoadedGrenadeLaserTrait = true,
    GunLoadedGrenadeSpeedTrait = true,
    GunLoadedGrenadeWideTrait = true,
    GunLoadedGrenadeInfiniteAmmoTrait = true,

    ChaosBlessingDashAttackTrait = true,
    ChaosBlessingMeleeTrait = true,
    ChaosCursePrimaryAttackTrait = true,
}

PolycosmosAbilityData.OtherSpecialEffects = {
    GunGrenadeFastTrait = true,
    GunExplodingSecondaryTrait = true,
    GunSlowGrenade = true,
    GunGrenadeDropTrait = true,
    GunGrenadeClusterTrait = true,
    GunLoadedGrenadeBoostTrait = true,

    FistKillTrait = true,
    FistDoubleDashSpecialTrait = true,
    FistChargeSpecialTrait = true,
    FistTeleportSpecialTrait = true,
    FistSpecialLandTrait = true,
    FistSpecialFireballTrait = true,

    ShieldThrowFastTrait = true,
    ShieldThrowCatchExplode = true,
    ShieldThrowElectiveCharge = true,
    ShieldThrowEmpowerTrait = true,
    ShieldThrowRushTrait = true,

    BowPenetrationTrait = true,
    BowSecondaryBarrageTrait = true,
    BowSecondaryFocusedFireTrait = true,
    BowConsecutiveBarrageTrait = true,

    SpearThrowBounce = true,
    SpearThrowPenetrate = true,
    SpearThrowCritical = true,
    SpearThrowExplode = true,
    SpearThrowElectiveCharge = true,

    SwordBlinkTrait = true,
    SwordSecondaryDoubleAttackTrait = true,
    SwordSecondaryAreaDamageTrait = true,
    SwordConsecrationBoostTrait = true,
}



--These are the traits that disable each primary ability
TraitData.NoDashTrait =
{
    Hidden = true,
	Name = "NoDashTrait",
    PropertyChanges =
    {
		{
            WeaponNames = WeaponSets.HeroRushWeapons,
            WeaponProperty = "Control",
            ChangeValue = "null",
            ChangeType = "Absolute",
        },
	},
}

TraitData.NoCastTrait =
{
    Hidden = true,
	Name = "NoCastTrait",
    PropertyChanges =
    {
        {
            WeaponNames = WeaponSets.HeroNonPhysicalWeapons,
            WeaponProperty = "Control",
            ChangeValue = "null",
            ChangeType = "Absolute",
        },
	},
}

TraitData.NoCallTrait =
{
    Hidden = true,
	Name = "NoCallTrait",
	SuperGainMultiplier =
	{
		BaseMin = 0,
		BaseMax = 0,
		SourceIsMultiplier = true,
	},
}

-- and because the attack/special traits for each weapon are so long and repetitive, we'll just let this function set them all up for us
-- disabling controls for the main attack causes a litany of crashes, so we have to find a workaround by making it do nothing and almost never be usable
local function CreateNoAttackTrait(traitName, weaponName)

    TraitData[traitName] = 
    {
        Hidden = true,
        Name = traitName,
        
        PropertyChanges =
        {
            {
                WeaponNames = { weaponName },
                WeaponProperty = "Projectile",
                ChangeValue = "1_BaseProjectile",
                ChangeType = "Absolute",
            },
            {
                WeaponNames = { weaponName },
                WeaponProperty = "SwapOnFire",
                ChangeValue = "null",
                ChangeType = "Absolute",
            },
            {
                WeaponNames = { weaponName },
                WeaponProperty = "MaxAmmo",
                ChangeValue = 0,
                ChangeType = "Absolute",
            },
            {
                WeaponNames = { weaponName },
                WeaponProperty = "ChargeStartAnimation",
                ChangeValue = "null",
                ChangeType = "Absolute",
            },
            {
                WeaponNames = { weaponName },
                WeaponProperty = "FireGraphic",
                ChangeValue = "null",
                ChangeType = "Absolute",
            },
            {
                WeaponNames = { weaponName },
                WeaponProperty = "FireFx",
                ChangeValue = "null",
                ChangeType = "Absolute",
            },
            {
                WeaponNames = { weaponName },
                WeaponProperty = "ChargeFx",
                ChangeValue = "null",
                ChangeType = "Absolute",
            },
            {
                WeaponNames = { weaponName },
                WeaponProperty = "FireOnRelease",
                ChangeValue = false,
                ChangeType = "Boolean",
            },
        },

        WeaponDataOverride =
        {
            [weaponName] =
            {
                Sounds =
                {
                    FireSounds = {},
                    ChargeSounds = {},
                    ImpactSounds = {},
                },
            },
        },
    }
end

local function CreateNoSpecialTrait(traitName, weaponName)
    
    TraitData[traitName] = 
    {
        Hidden = true,
        Name = traitName,

        PropertyChanges =
        {
            {
                WeaponNames = { weaponName },
                WeaponProperty = "Control",
                ChangeValue = "null",
                ChangeType = "Absolute",
            },
        },
    }
end

CreateNoAttackTrait("NoAttackSwordTrait", "SwordWeapon")
CreateNoAttackTrait("NoAttackSpearTrait", "SpearWeapon")
CreateNoAttackTrait("NoAttackBowTrait", "BowWeapon")
CreateNoAttackTrait("NoAttackShieldTrait", "ShieldWeapon")
CreateNoAttackTrait("NoAttackGunTrait", "GunWeapon")
CreateNoAttackTrait("NoAttackFistTrait", "FistWeapon")

CreateNoSpecialTrait("NoSpecialSwordTrait", "SwordParry")
CreateNoSpecialTrait("NoSpecialBowTrait", "BowSplitShot")
CreateNoSpecialTrait("NoSpecialSpearTrait", "SpearWeaponThrow")
CreateNoSpecialTrait("NoSpecialShieldTrait", "ShieldThrow")
CreateNoSpecialTrait("NoSpecialFistTrait", "FistWeaponSpecial")
CreateNoSpecialTrait("NoSpecialGunTrait", "GunGrenadeToss")