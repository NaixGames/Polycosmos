ModUtil.Mod.Register( "PolycosmosWeaponStoreSystem" )

-- Checks the weapon being unlocked only if the cosmetics are available.
ModUtil.Path.Wrap("IsWeaponUnlocked", function(baseFunc, weaponName)
    if weaponName == "SwordWeapon" and GameState.Cosmetics.SwordWeaponUnlockItem then
        return true
    elseif weaponName == "SpearWeapon" and GameState.Cosmetics.SpearWeaponUnlockItem then
        return true
    elseif weaponName == "ShieldWeapon" and GameState.Cosmetics.ShieldWeaponUnlockItem then
        return true
    elseif weaponName == "BowWeapon" and GameState.Cosmetics.BowWeaponUnlockItem then
        return true
    elseif weaponName == "FistWeapon" and GameState.Cosmetics.FistWeaponUnlockItem then
        return true
    elseif weaponName == "GunWeapon" and GameState.Cosmetics.GunWeaponUnlockItem then
        return true    
    end
    return false
end, PolycosmosWeaponStoreSystem)

-- Makes it impossible to buy from the Arsenal Room (required since only the Cosmetics unlock the weapons now, so buying them just wastes keys)
ModUtil.Path.Context.Wrap("ModUtil.Hades.Triggers.OnUsed.Interactables.1.Call", function()
    ModUtil.Path.Wrap("HasResource", function(baseFunc, name, amount)
        return false
    end, PolycosmosWeaponStoreSystem)
end, PolycosmosWeaponStoreSystem)
