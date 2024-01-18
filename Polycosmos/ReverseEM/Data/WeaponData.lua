-- I couldn't get MapSetTable to work properly for some reason.
-- These are some outlier variables that cause instances of "local requiredShrineLevel" to not work with the new GetNumMetaUpgrades function.

-- Change "WeaponData -> HarpyLightning -> ShrineMetaUpgradeRequiredLevel" from "= 1" to "= 4"

ModUtil.MapSetTable( WeaponData, {
    HarpyLightning = {
        ShrineMetaUpgradeRequiredLevel = 4,
    }
})