ModUtil.Mod.Register( "PolycosmosWeaponManager" )

------------ Setup of high level weapon system

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
end, PolycosmosWeaponManager)

-- Makes it impossible to buy from the Arsenal Room (required since only the Cosmetics unlock the weapons now, so buying them just wastes keys)
ModUtil.Path.Context.Wrap("ModUtil.Hades.Triggers.OnUsed.Interactables.1.Call", function()
    ModUtil.Path.Wrap("HasResource", function(baseFunc, name, amount)
        if (name == "LockKeys") then
            return false
        end
        return baseFunc(name, amount)
    end, PolycosmosWeaponManager)
end, PolycosmosWeaponManager)

------------

local WeaponDatabaseTrait = {
    SwordWeapon =
    {
        Name = "SwordWeapon",
        ClientName = "Sword Weapon",
        TraitName = "SwordBaseUpgradeTrait"
    },
    SpearWeapon = 
    {
        Name = "SpearWeapon",
        ClientName = "Spear Weapon",
        TraitName = "SpearBaseUpgradeTrait"
    },
    ShieldWeapon = 
    {
        Name = "ShieldWeapon",
        ClientName = "Shield Weapon",
        TraitName = "ShieldBaseUpgradeTrait"
    },
    BowWeapon = 
    {
        Name = "BowWeapon",
        ClientName = "Bow Weapon",
        TraitName = "BowBaseUpgradeTrait"
    },
    FistWeapon = 
    {
        Name = "FistWeapon",
        ClientName = "Fist Weapon",
        TraitName = "FistBaseUpgradeTrait"
    },
    GunWeapon = 
    {
        Name = "GunWeapon",
        ClientName = "Gun Weapon",
        TraitName = "GunBaseUpgradeTrait"
    }
}


function PolycosmosWeaponManager.GiveClientWeaponTraitName(weaponName)
    for name, data in pairs(WeaponDatabaseTrait) do
        if data.Name == weaponName then
            return data.ClientName
        end
    end
end


local WeaponsUnlockCosmeticNames =
{
    SwordWeaponUnlock = {
        ClientNameItem = "SwordWeaponUnlockItem",
        ClientNameLocation = "Sword Weapon Unlock Location",
        HadesName = "Sword Weapon Unlock", 
    },
    BowWeaponUnlock = {
        ClientNameItem = "BowWeaponUnlockItem",
        ClientNameLocation = "Bow Weapon Unlock Location",
        HadesName = "Bow Weapon Unlock", 
    },
    ShieldWeaponUnlock = {
        ClientNameItem = "ShieldWeaponUnlockItem",
        ClientNameLocation = "Shield Weapon Unlock Location",
        HadesName = "Shield Weapon Unlock", 
    },
    SpearWeaponUnlock = {
        ClientNameItem = "SpearWeaponUnlockItem",
        ClientNameLocation = "Spear Weapon Unlock Location",
        HadesName = "Spear Weapon Unlock", 
    },
    FistWeaponUnlock = {
        ClientNameItem = "FistWeaponUnlockItem",
        ClientNameLocation = "Fist Weapon Unlock Location",
        HadesName = "Fist Weapon Unlock", 
    },
    GunWeaponUnlock = {
        ClientNameItem = "GunWeaponUnlockItem",
        ClientNameLocation = "Gun Weapon Unlock Location",
        HadesName = "Gun Weapon Unlock", 
    },
}

------------ 

local cachedWeapons = {}

------------ 

ModUtil.Path.Wrap("AddCosmetic", function (baseFunc, name, status)
    -- There should not be ANY scenario in which we call this before the data is loaded, so I will assume the datain Root is always updated
    if (not PolycosmosWeaponManager.IsWeaponCosmetic(name)) then
        return baseFunc(name, status)
    end

    if (not GameState.ClientDataIsLoaded) then
        table.insert(cachedWeapons, name)
        return
    end
    
    if GameState.ClientGameSettings["WeaponSanity"] == 0 then
        AddCosmetic(WeaponsUnlockCosmeticNames[name].ClientNameItem)
        return baseFunc(name, status)
    end

    StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..name.." Location")
    return baseFunc(name, status)
end)

------------ 

function PolycosmosWeaponManager.UnlockWeapon(weaponClientName)
    weaponHadesName = ""
    for name, data in pairs(WeaponsUnlockCosmeticNames) do
        if data.ClientNameItem == weaponClientName then
            weaponHadesName = data.ClientNameItem
            break
        end
    end

    -- Current ownership
	GameState.Cosmetics[weaponHadesName] = true
	
    if (GameState.CosmeticsAdded[weaponHadesName] == true) then
        return
    end 

    -- Record of it ever being added
	GameState.CosmeticsAdded[weaponHadesName] = true

    PolycosmosMessages.PrintToPlayer("Received weapon" .. weaponHadesName)
end

------------ 

function PolycosmosWeaponManager.IsWeaponItem(itemName)
    for name, data in pairs(WeaponsUnlockCosmeticNames) do
        if data.ClientNameItem == itemName then
            return true
        end
    end
    return false
end

------------ 

function PolycosmosWeaponManager.IsWeaponLocation(locationName)
    for name, data in pairs(WeaponsUnlockCosmeticNames) do
        if data.ClientNameLocation == locationName then
            return true
        end
    end
    return false
end

------------ 

function PolycosmosWeaponManager.IsWeaponCosmetic(locationName)
    for name, data in pairs(WeaponsUnlockCosmeticNames) do
        if data.HadesName == locationName then
            return true
        end
    end
    return false
end

------------ 

function PolycosmosWeaponManager.CheckRequestInitialWeapon()
    PolycosmosWeaponManager.ResolveQueueWeapons()
    PolycosmosWeaponManager.EquipInitialWeapon()
end

------------ 

function PolycosmosWeaponManager.EquipInitialWeapon()
    initialWeapon = GameState.ClientGameSettings["InitialWeapon"]

    if (GameState.WeaponsUnlocked and GameState.WeaponsUnlocked["SwordWeapon"]) then
        GameState.WeaponsUnlocked["SwordWeapon"] = false
    end

    weaponString = ""
    weaponCosmetic = ""

    if (initialWeapon == 0) then
        weaponString = "SwordWeapon"
        weaponCosmetic = "SwordWeaponUnlock"
        weaponClientString = "Sword Weapon Unlock"
    elseif (initialWeapon == 1) then
        weaponString = "BowWeapon"
        weaponCosmetic = "BowWeaponUnlock"
        weaponClientString = "Bow Weapon Unlock"
    elseif (initialWeapon == 2) then
        weaponString = "SpearWeapon"
        weaponCosmetic = "SpearWeaponUnlock"
        weaponClientString = "Spear Weapon Unlock"
    elseif (initialWeapon == 3) then
        weaponString = "ShieldWeapon"
        weaponCosmetic = "ShieldWeaponUnlock"
        weaponClientString = "Shield Weapon Unlock"
    elseif (initialWeapon == 4) then
        weaponString = "FistWeapon"
        weaponCosmetic = "FistWeaponUnlock"
        weaponClientString = "Fist Weapon Unlock"
    else
        weaponString = "GunWeapon"
        weaponCosmetic = "GunWeaponUnlock"
        weaponClientString = "Gun Weapon Unlock"
    end

    -- Current ownership
	GameState.Cosmetics[weaponClientString] = true
	-- Record of it ever being added
	GameState.CosmeticsAdded[weaponClientString] = true
     -- Current ownership
	GameState.Cosmetics[weaponCosmetic.."Item"] = true
	-- Record of it ever being added
	GameState.CosmeticsAdded[weaponCosmetic.."Item"] = true

    HeroData.DefaultHero.DefaultWeapon = weaponString
    CurrentRun.Hero.DefaultWeapon = weaponString
    

	EquipPlayerWeapon(WeaponDatabaseTrait[weaponString], { PreLoadBinks = true })
end



------------

function PolycosmosWeaponManager.ResolveQueueWeapons()
	for k, name in ipairs(cachedWeapons) do
        AddCosmetic(name)
    end
    cachedCosmetics = {}
end