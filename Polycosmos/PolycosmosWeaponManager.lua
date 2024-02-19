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
        return false
    end, PolycosmosWeaponManager)
end, PolycosmosWeaponManager)

------------

local InitialWeaponRequested = false

local WeaponDatabaseTrait = {
    SwordWeapon =
    {
        Name = "SwordWeapon",
        TraitName = "SwordBaseUpgradeTrait"
    },
    SpearWeapon = 
    {
        Name = "SpearWeapon",
        TraitName = "SpearBaseUpgradeTrait"
    },
    ShieldWeapon = 
    {
        Name = "ShieldWeapon",
        TraitName = "ShieldBaseUpgradeTrait"
    },
    BowWeapon = 
    {
        Name = "BowWeapon",
        TraitName = "BowBaseUpgradeTrait"
    },
    FistWeapon = 
    {
        Name = "FistWeapon",
        TraitName = "FistBaseUpgradeTrait"
    },
    GunWeapon = 
    {
        Name = "GunWeapon",
        TraitName = "GunBaseUpgradeTrait"
    }
}

local WeaponsUnlockCosmeticNames =
{
    SwordWeaponUnlock = {
        ClientNameItem = "SwordWeaponUnlockItem",
        ClientNameUnlock = "SwordWeaponUnlockLocation",
        HadesName = "SwordWeaponUnlock", 
    },
    BowWeaponUnlock = {
        ClientNameItem = "BowWeaponUnlockItem",
        ClientNameLocation = "BowWeaponUnlockLocation",
        HadesName = "BowWeaponUnlock", 
    },
    ShieldWeaponUnlock = {
        ClientNameItem = "ShieldWeaponUnlockItem",
        ClientNameLocation = "ShieldWeaponUnlockLocation",
        HadesName = "ShieldWeaponUnlock", 
    },
    SpearWeaponUnlock = {
        ClientNameItem = "SpearWeaponUnlockItem",
        ClientNameLocation = "SpearWeaponUnlockLocation",
        HadesName = "SpearWeaponUnlock", 
    },
    FistWeaponUnlock = {
        ClientNameItem = "FistWeaponUnlockItem",
        ClientNameLocation = "FistWeaponUnlockLocation",
        HadesName = "FistWeaponUnlock", 
    },
    GunWeaponUnlock = {
        ClientNameItem = "GunWeaponUnlockItem",
        ClientNameLocation = "GunWeaponUnlockLocation",
        HadesName = "GunWeaponUnlock", 
    },
}

------------ 

ModUtil.Path.Wrap("AddCosmetic", function (baseFunc, name, status)
    -- There should not be ANY scenario in which we call this before the data is loaded, so I will assume the datain Root is always updated
    if (not WeaponsUnlockCosmeticNames[name]) then
        return baseFunc(name, status)
    end
    
    if StyxScribeShared.Root.GameSettings["WeaponSanity"]==0 then
        AddCosmetic(WeaponsUnlockCosmeticNames[name].ClientNameItem)
        return baseFunc(name, status)
    end

    StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..name.."Location")
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
	GameState.Cosmetics[weaponHadesName] =true
	-- Record of it ever being added
	GameState.CosmeticsAdded[weaponHadesName] = true

    PolycosmosMessages.PrintToPlayer("Recieved weapon" .. weaponHadesName)
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

function PolycosmosWeaponManager.RequestInitialWeapon()
    if (StyxScribeShared.Root.GameSettings) then
        PolycosmosWeaponManager.EquipInitialWeapon()
    else
        InitialWeaponRequested = true
    end
end

------------ 

function PolycosmosWeaponManager.CheckRequestInitialWeapon( message )
    if (not InitialWeaponRequested) then
        return
    end
    PolycosmosWeaponManager.EquipInitialWeapon()
end

------------ 

function PolycosmosWeaponManager.EquipInitialWeapon()
    InitialWeaponRequested = false
    initialWeapon = StyxScribeShared.Root.GameSettings["InitialWeapon"]

    weaponString = ""
    weaponCosmetic = ""

    if (initialWeapon == 0) then
        weaponString = "SwordWeapon"
        weaponCosmetic = "SwordWeaponUnlock"
    elseif (initialWeapon == 1) then
        weaponString = "BowWeapon"
        weaponCosmetic = "BowWeaponUnlock"
    elseif (initialWeapon == 2) then
        weaponString = "SpearWeapon"
        weaponCosmetic = "SpearWeaponUnlock"
    elseif (initialWeapon == 3) then
        weaponString = "ShieldWeapon"
        weaponCosmetic = "ShieldWeaponUnlock"
    elseif (initialWeapon == 4) then
        weaponString = "FistWeapon"
        weaponCosmetic = "FistWeaponUnlock"
    else
        weaponString = "GunWeapon"
        weaponCosmetic = "GunWeaponUnlock"
    end

    -- Current ownership
	GameState.Cosmetics[weaponCosmetic] = true
	-- Record of it ever being added
	GameState.CosmeticsAdded[weaponCosmetic] = true
     -- Current ownership
	GameState.Cosmetics[weaponCosmetic.."Item"] = true
	-- Record of it ever being added
	GameState.CosmeticsAdded[weaponCosmetic.."Item"] = true


    print("trying to set hero weapon to "..weaponString)

    HeroData.DefaultHero.DefaultWeapon = weaponString
    CurrentRun.Hero.DefaultWeapon = weaponString
    

	EquipPlayerWeapon(WeaponDatabaseTrait[weaponString], { PreLoadBinks = true })
end

------------

ModUtil.Path.Wrap( "StartNewGame", function(baseFunc)
        PolycosmosWeaponManager.RequestInitialWeapon()
        return baseFunc()
end)

StyxScribe.AddHook( PolycosmosWeaponManager.CheckRequestInitialWeapon, styx_scribe_recieve_prefix.."Data finished", PolycosmosWeaponManager )