ModUtil.Mod.Register( "PolycosmosCosmeticsManager" )


------------ 

local StoreUnlockCosmeticNames =
{
    HealthFountainHeal1 = {
        ClientNameItem = "FountainUpgrade1Item", 
        ClientNameLocation = "Fountain Upgrade1 Location", --Requires TartarusReprieveItem
    },
    HealthFountainHeal2 = {
        ClientNameItem = "FountainUpgrade2Item", --IsProgressive
        ClientNameLocation = "Fountain Upgrade2 Location", --Requires HealthFountainHeal1
    },
    TartarusReprieve = {
        ClientNameItem = "FountainTartarusItem",
        ClientNameLocation = "Fountain Tartarus Location",
    },
    AsphodelReprieve = {
        ClientNameItem = "FountainAsphodelItem",
        ClientNameLocation = "Fountain Asphodel Location", --Requires TartarusReprieveItem, defeating Meg, requires PostBossGiftRack
    },
    ElysiumReprieve = {
        ClientNameItem = "FountainElysiumItem",
        ClientNameLocation = "Fountain Elysium Location", --Requires AsphodelReprieveItem, defeating Lernie, requires PostBossGiftRack
    },
    BreakableValue1 = {
        ClientNameItem = "UrnsOfWealth1Item",
        ClientNameLocation = "Urns Of Wealth1 Location", --Requires TartarusReprieveItem
    },
    BreakableValue2 = {
        ClientNameItem = "UrnsOfWealth2Item", --IsProgressive
        ClientNameLocation = "Urns Of Wealth2 Location", --Requires BreakableValue1Item
    },
    BreakableValue3 = {
        ClientNameItem = "UrnsOfWealth3Item", --IsProgressive
        ClientNameLocation = "Urns Of Wealth3 Location", --Requires BreakableValue2Item
    },
    ChallengeSwitches1 = {
        ClientNameItem = "InfernalTrove1Item", 
        ClientNameLocation = "Infernal Trove1 Location",
    },
    ChallengeSwitches2 = {
        ClientNameItem = "InfernalTrove2Item", --IsProgressive 
        ClientNameLocation = "Infernal Trove2 Location", --Requires defeating ElysiumReprieve, ChallengeSwitches1Item, PostBossGiftRack
    },
    ChallengeSwitches3 = {
        ClientNameItem = "InfernalTrove3Item", --IsProgressive 
        ClientNameLocation = "Infernal Trove3 Location", --Requires defeating ElysiumReprieve, ChallengeSwitches2Item, PostBossGiftRack, GhostAdminDesk
    },
	PostBossGiftRack = {
        ClientNameItem = "KeepsakeCollectionItem",
        ClientNameLocation = "Keepsake Collection Location", --Requires defeating Meg, TartarusReprieve
    },
    GhostAdminDesk = { --Everything here and below needs diamonds.
        ClientNameItem = "DeluxeContractorDeskItem",
        ClientNameLocation = "Deluxe Contractor Desk Location", --Requires ElysiumReprieve, CourtMusicianSentenceItem
    },
    BossAddGems = {
        ClientNameItem = "VanquishersKeepItem",
        ClientNameLocation = "Vanquishers Keep Location", -- Requires GhostAdminDesk
    },
    FishingUnlockItem = {
        ClientNameItem = "FishingRodItem",
        ClientNameLocation = "Fishing Rod Location", --Requires defeating Heros, TartartarusRepriveItem
    },
    OrpheusUnlockItem = {
        ClientNameItem = "CourtMusicianSentenceItem",
        ClientNameLocation = "Court Musician Sentence Location", --Requires defeating Meg, TartarusReprieveItem
    },
    Cosmetic_MusicPlayer = {
        ClientNameItem = "CourtMusicianStandItem",
        ClientNameLocation = "Court Musician Stand Location", --Requires OrpheusUnlockItem
    }, 
    RoomRewardMetaPointDropRunProgress = {
        ClientNameItem = "PitchBlackDarknessItem",
        ClientNameLocation = "Pitch Black Darkness Location", -- Requires DeluxeContractorDeskItem
    },
    LockKeyDropRunProgress = {
        ClientNameItem = "FatedKeysItem",
        ClientNameLocation = "Fated Keys Location", -- Requires DeluxeContractorDeskItem
    },
    GemDropRunProgress = {
        ClientNameItem = "BrilliantGemstonesItem",
        ClientNameLocation = "Brilliant Gemstones Location", -- Requires DeluxeContractorDeskItem
    },
    GiftDropRunProgress = {
        ClientNameItem = "VintageNectarItem", 
        ClientNameLocation = "Vintage Nectar Location", -- Requires DeluxeContractorDeskItem
    },
    UnusedWeaponBonusAddGems = {
        ClientNameItem = "DarkerThirstItem",
        ClientNameLocation = "Darker Thirst Location", -- Requires DeluxeContractorDeskItem
    },
}

--------------------------------------

local StoreUnlockProgressiveNames =
{
    "HealthFountainHeal1",
    "HealthFountainHeal2",
    "BreakableValue1",
    "BreakableValue2",
    "BreakableValue3",
    "ChallengeSwitches1",
    "ChallengeSwitches2",
    "ChallengeSwitches3",
}

local HealthFountainProgressive =
{
    "HealthFountainHeal1",
    "HealthFountainHeal2",
}

local BreakableValueProgressive =
{
    "BreakableValue1",
    "BreakableValue2",
    "BreakableValue3",
}

local ChallengeSwitchesProgressive =
{
    "ChallengeSwitches1",
    "ChallengeSwitches2",
    "ChallengeSwitches3",
}

--------------------------------------

local cachedCosmetics = {}

--------------------------------------


ModUtil.Path.Wrap("AddCosmetic", function (baseFunc, name, status)
    -- There should not be ANY scenario in which we call this before the data is loaded, so I will assume the datain Root is always updated
    if (not StoreUnlockCosmeticNames[name]) then
        return baseFunc(name, status)
    end

    local nameOverride = StoreUnlockCosmeticNames[name].ClientNameLocation --overriding this to split gaining the item from the location

    if (GameState.CosmeticsAdded[nameOverride] == true) then
        return
    end

    if (not GameState.ClientDataIsLoaded) then
        table.insert(cachedCosmetics, name)
        return
    end

    if GameState.ClientGameSettings["StoreSanity"]==0 then
         return baseFunc(name, status)
    end

    StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..nameOverride)
    return baseFunc(nameOverride, status)
end)


------------------------------------------

function PolycosmosCosmeticsManager.UnlockCosmetics(cosmeticClientName)
    cosmeticHadesName = ""
    for name, data in pairs(StoreUnlockCosmeticNames) do
        if data.ClientNameItem == cosmeticClientName then
            cosmeticHadesName = name
            break
        end
    end


    if (PolycosmosUtils.HasValue(StoreUnlockProgressiveNames, cosmeticHadesName)) then
        cosmeticHadesName = PolycosmosCosmeticsManager.GiveCorrespondingProgressiveName(cosmeticHadesName) 
    end

    if (cosmeticHadesName == nil) then
        return
    end

    -- Current ownership
	GameState.Cosmetics[cosmeticHadesName] = true

    if (GameState.CosmeticsAdded[cosmeticHadesName] == true) then
        return
    end 

	-- Record of it ever being added
	GameState.CosmeticsAdded[cosmeticHadesName] = true

    PolycosmosMessages.PrintToPlayer("Received cosmetic " .. cosmeticHadesName)
end

------------------------------------------

function PolycosmosCosmeticsManager.GiveCosmeticLocationData(cosmeticName)
    return StoreUnlockCosmeticNames[cosmeticName]
end

------------------------------------------

function PolycosmosCosmeticsManager.IsCosmeticItem(itemName)
    for name, data in pairs(StoreUnlockCosmeticNames) do
        if data.ClientNameItem == itemName then
            return true
        end
    end
    return false
end

function PolycosmosCosmeticsManager.IsCosmeticLocation(locationName)
    for name, data in pairs(StoreUnlockCosmeticNames) do
        if data.ClientNameLocation == locationName then
            return true
        end
    end
    return false
end


------------------------------------------

function PolycosmosCosmeticsManager.GiveCorrespondingProgressiveName(progressiveName)
    result = progressiveName

    if (GameState.CosmeticsAdded[progressiveName.."Progressive"] == true) then
        return
    end

    if (PolycosmosUtils.HasValue(HealthFountainProgressive, progressiveName)) then
        result = PolycosmosCosmeticsManager.GiveCorrespondingProgressiveNameFromTable(HealthFountainProgressive)
    elseif (PolycosmosUtils.HasValue(BreakableValueProgressive, progressiveName)) then
        result = PolycosmosCosmeticsManager.GiveCorrespondingProgressiveNameFromTable(BreakableValueProgressive)
    elseif (PolycosmosUtils.HasValue(ChallengeSwitchesProgressive, progressiveName)) then
        result = PolycosmosCosmeticsManager.GiveCorrespondingProgressiveNameFromTable(ChallengeSwitchesProgressive)
    end

    GameState.CosmeticsAdded[progressiveName.."Progressive"] = true

	return result
end


------------------------------------------

function PolycosmosCosmeticsManager.GiveCorrespondingProgressiveNameFromTable(progressiveTable)
    for index,value in ipairs(progressiveTable) do
        if (GameState.CosmeticsAdded[value] == false or GameState.CosmeticsAdded[value] == nil) then
            return value
        end
    end
    return progressiveTable[0]
end


--------------------------------------------

function PolycosmosCosmeticsManager.ResolveQueueCosmetics()
    if (not GameState.ClientDataIsLoaded) then
        return
    end
	for k, name in ipairs(cachedCosmetics) do
        AddCosmetic(name)
    end
    cachedCosmetics = {}
end