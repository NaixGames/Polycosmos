ModUtil.Mod.Register( "PolycosmosCosmeticsManager" )


local StoreUnlockCosmeticNamesGemstones =
{
    HealthFountainHeal1 = {
        ClientNameItem = "FountainUpgrade1Item", 
        ClientNameLocation = "FountainUpgrade1Location", --Requires TartarusReprieveItem
    },
    HealthFountainHeal2 = {
        ClientNameItem = "FountainUpgrade2Item", --IsProgressive
        ClientNameLocation = "FountainUpgrade2Location", --Requires HealthFountainHeal2
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
    }
}

local StoreUnlockCosmeticNamesDiamonds =
{
    GhostAdminDesk = {
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
