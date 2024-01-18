-- I couldn't get MapSetTable to work properly for some reason.
-- These are some outlier variables that cause instances of "local requiredShrineLevel" to not work with the new GetNumMetaUpgrades function.

-- Change "HydraHeadImmortal -> ShrineMetaUpgradeRequiredLevel" from "= 2" to "= 3"

ModUtil.MapSetTable( UnitSetData.Enemies, {
    HydraHeadImmortal = {
        ShrineMetaUpgradeRequiredLevel = 3,
    }
})


-- Change "HadesAmmo -> ShrineMetaUpgradeRequiredLevel" from "= 4" to "= 1"

ModUtil.MapSetTable( UnitSetData.Enemies, {
    HadesAmmo = {
        ShrineMetaUpgradeRequiredLevel = 1,
    }
})


-- Change "Hades -> ShrineMetaUpgradeRequiredLevel" from "= 4" to "= 1"

ModUtil.MapSetTable( UnitSetData.Enemies, {
    Hades = {
        ShrineMetaUpgradeRequiredLevel = 1,
    }
})

