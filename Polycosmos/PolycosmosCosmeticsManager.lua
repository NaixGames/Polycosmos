ModUtil.Mod.Register( "PolycosmosCosmeticsManager" )


local StoreUnlockCosmeticNames =
{
    HealthFountainHeal1 = {
        ClientNameItem = "FountainUpgrade1Item", 
        ClientNameLocation = "FountainUpgrade1Location", --Requires TartarusReprieveItem
    },
    HealthFountainHeal2 = {
        ClientNameItem = "FountainUpgrade2Item", --IsProgressive
        ClientNameLocation = "FountainUpgrade2Location", --Requires HealthFountainHeal1
    },
    TartarusReprieve = {
        ClientNameItem = "FountainTartarusItem",
        ClientNameLocation = "FountainTartarusLocation",
    },
    AsphodelReprieve = {
        ClientNameItem = "FountainAsphodelItem",
        ClientNameLocation = "FountainAsphodelLocation", --Requires TartarusReprieveItem, defeating Meg, requires PostBossGiftRack
    },
    ElysiumReprieve = {
        ClientNameItem = "FountainElysiumItem",
        ClientNameLocation = "FountainElysiumLocation", --Requires AsphodelReprieveItem, defeating Lernie, requires PostBossGiftRack
    },
    BreakableValue1 = {
        ClientNameItem = "UrnsOfWealth1Item",
        ClientNameLocation = "UrnsOfWealth1Location", --Requires TartarusReprieveItem
    },
    BreakableValue2 = {
        ClientNameItem = "UrnsOfWealth2Item", --IsProgressive
        ClientNameLocation = "UrnsOfWealth2Location", --Requires BreakableValue1Item
    },
    BreakableValue3 = {
        ClientNameItem = "UrnsOfWealth3Item", --IsProgressive
        ClientNameLocation = "UrnsOfWealth3Location", --Requires BreakableValue2Item
    },
    ChallengeSwitches1 = {
        ClientNameItem = "InfernalThrove1Item", 
        ClientNameLocation = "InfernalThrove1Location",
    },
    ChallengeSwitches2 = {
        ClientNameItem = "InfernalThrove2Item", --IsProgressive 
        ClientNameLocation = "InfernalThrove2Location", --Requires defeating ElysiumReprieve, ChallengeSwitches1Item, PostBossGiftRack
    },
    ChallengeSwitches3 = {
        ClientNameItem = "InfernalThrove3Item", --IsProgressive 
        ClientNameLocation = "InfernalThrove3Location", --Requires defeating ElysiumReprieve, ChallengeSwitches2Item, PostBossGiftRack, GhostAdminDesk
    },
	PostBossGiftRack = {
        ClientNameItem = "KeepsakeCollectionItem",
        ClientNameLocation = "KeepsakeCollectionLocation", --Requires defeating Meg, TartarusReprieve
    },
    CodexBoonList = {
        ClientNameItem = "CodexIndexItem",
        ClientNameLocation = "CodexIndexLocation",
    }, 
    GhostAdminDesk = { --Everything here and below needs diamonds.
        ClientNameItem = "DeluxeContractorDeskItem",
        ClientNameLocation = "DeluxeContractorDeskLocation", --Requires ElysiumReprieve, CourtMusicianSentenceItem
    },
    BossAddGems = {
        ClientNameItem = "VanquishersKeepItem",
        ClientNameLocation = "VanquishersKeepLocation", -- Requires GhostAdminDesk
    },
    FishingUnlockItem = {
        ClientNameItem = "FishingRodItem",
        ClientNameLocation = "FishingRodLocation", --Requires defeating Heros, TartartarusRepriveItem
    },
    OrpheusUnlockItem = {
        ClientNameItem = "CourtMusicianSentenceItem",
        ClientNameLocation = "CourtMusicianSentenceLocation", --Requires defeating Meg, TartarusReprieveItem
    },
    Cosmetic_MusicPlayer = {
        ClientNameItem = "CourtMusicianStandItem",
        ClientNameLocation = "CourtMusicianStandLocation", --Requires OrpheusUnlockItem
    }, 
    RoomRewardMetaPointDropRunProgress = {
        ClientNameItem = "PitchBlackDarknessItem",
        ClientNameLocation = "PitchBlackDarknessLocation", -- Requires DeluxeContractorDeskItem
    },
    LockKeyDropRunProgress = {
        ClientNameItem = "FatedKeysItem",
        ClientNameLocation = "FatedKeysLocation", -- Requires DeluxeContractorDeskItem
    },
    GemDropRunProgress = {
        ClientNameItem = "BrilliantGemstonesItem",
        ClientNameLocation = "BrilliantGemstonesLocation", -- Requires DeluxeContractorDeskItem
    },
    GiftDropRunProgress = {
        ClientNameItem = "VintageNectarItem", 
        ClientNameLocation = "VintageNectarLocation", -- Requires DeluxeContractorDeskItem
    },
    UnusedWeaponBonusAddGems = {
        ClientNameItem = "DarkerThirstItem",
        ClientNameLocation = "DarkerThirstLocation", -- Requires DeluxeContractorDeskItem
    },
}

--------------------------------------


ModUtil.Path.Wrap("AddCosmetic", function (baseFunc, name, status)
    -- There should not be ANY scenario in which we call this before the data is loaded, so I will assume the datain Root is always updated
    if (not StoreUnlockCosmeticNames[name]) then
        return baseFunc(name, status)
    end
    
    if StyxScribeShared.Root.GameSettings["StoreSanity"]==0 then
         return baseFunc(name, status)
    end

    nameOverride = StoreUnlockCosmeticNames[name].ClientNameLocation --overriding this to split gaining the item from the location
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

    if (GameState.CosmeticsAdded[cosmeticHadesName] == true) then
        return
    end 

    -- Current ownership
	GameState.Cosmetics[cosmeticHadesName] = true
	-- Record of it ever being added
	GameState.CosmeticsAdded[cosmeticHadesName] = true

    PolycosmosMessages.PrintToPlayer("Recieved cosmetic" .. cosmeticHadesName)
end

------------------------------------------

function PolycosmosCosmeticsManager.GiveCosmeticLocationData(cosmeticName)
    return StoreUnlockCosmeticNames[cosmeticName]
end

------------------------------------------