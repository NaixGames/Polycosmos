ModUtil.Mod.Register( "PolycosmosHelperManager" )


local HelpersDataArray=
{
    "MaxHealthHelper",
	"BoonBoostHelper",
}


local valueLoaded = false

local MaxHealthRequests = 0
local BoonBoostRequests = 0


-------------------- Auxiliary function for checking if a item is a filler item
function PolycosmosHelperManager.IsHelperItem(string)
    return PolycosmosUtils.HasValue(HelpersDataArray, string)
end

--------------------

function PolycosmosHelperManager.GiveHelperItem(item)
    if (item == "MaxHealthHelper") then
        MaxHealthRequests = MaxHealthRequests + 1
    elseif (item == "BoonBoostHelper") then
        BoonBoostRequests = BoonBoostRequests + 1
    end
end

--------------------

function PolycosmosHelperManager.FlushAndProcessHelperItems()
    if (GameState.HelperItemLodger == nil) then
        GameState.HelperItemLodger = {}
        GameState.HelperItemLodger["MaxHealthHelper"] = 0
        GameState.HelperItemLodger["BoonBoostHelper"] = 0
    end

    while (MaxHealthRequests > GameState.HelperItemLodger["MaxHealthHelper"]) do
        CurrentRun.Hero.MaxHealth = CurrentRun.Hero.MaxHealth + 25
		HeroData.DefaultHero.MaxHealth = HeroData.DefaultHero.MaxHealth + 25
        GameState.HelperItemLodger["MaxHealthHelper"] = GameState.HelperItemLodger["MaxHealthHelper"] + 1
        PolycosmosMessages.PrintToPlayer("Received a Max Health boost!")
    end

    while (BoonBoostRequests > GameState.HelperItemLodger["BoonBoostHelper"]) do
        GameState.HelperItemLodger["BoonBoostHelper"] = GameState.HelperItemLodger["BoonBoostHelper"] + 1
        PolycosmosMessages.PrintToPlayer("Received a Boon Rarity boost!")
    end

    MaxHealthRequests = 0
    BoonBoostRequests = 0

    SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
    ValidateCheckpoint({ Valid = true })

    Save()
end

--------------------

function GetRarityChancesOverride( args )
	if (GameState.HelperItemLodger == nil) then
        GameState.HelperItemLodger = {}
        GameState.HelperItemLodger["MaxHealthHelper"] = 0
        GameState.HelperItemLodger["BoonBoostHelper"] = 0
    end

	local name = args.Name
	local ignoreTempRarityBonus = args.IgnoreTempRarityBonus
	local referencedTable = "BoonData"
	if name == "StackUpgrade" then
		referencedTable = "StackData"
	elseif name == "WeaponUpgrade" then
		referencedTable = "WeaponData"
	elseif name == "HermesUpgrade" then
		referencedTable = "HermesData"
	end

	local legendaryRoll = CurrentRun.Hero[referencedTable].LegendaryChance or 0
	local heroicRoll = CurrentRun.Hero[referencedTable].HeroicChance or 0
	local epicRoll = CurrentRun.Hero[referencedTable].EpicChance or 0
	local rareRoll = CurrentRun.Hero[referencedTable].RareChance or 0

	if CurrentRun.CurrentRoom.BoonRaritiesOverride then
		legendaryRoll = CurrentRun.CurrentRoom.BoonRaritiesOverride.LegendaryChance or legendaryRoll
		heroicRoll = CurrentRun.CurrentRoom.BoonRaritiesOverride.HeroicChance or heroicRoll
		epicRoll = CurrentRun.CurrentRoom.BoonRaritiesOverride.EpicChance or epicRoll
		rareRoll =  CurrentRun.CurrentRoom.BoonRaritiesOverride.RareChance or rareRoll
	elseif args.BoonRaritiesOverride then
		legendaryRoll = args.BoonRaritiesOverride.LegendaryChance or legendaryRoll
		heroicRoll = args.BoonRaritiesOverride.HeroicChance or heroicRoll
		epicRoll = args.BoonRaritiesOverride.EpicChance or epicRoll
		rareRoll =  args.BoonRaritiesOverride.RareChance or rareRoll
	end

	local metaupgradeRareBoost = GetNumMetaUpgrades( "RareBoonDropMetaUpgrade" ) * ( MetaUpgradeData.RareBoonDropMetaUpgrade.ChangeValue - 1 )
	local metaupgradeEpicBoost = GetNumMetaUpgrades( "EpicBoonDropMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 ) + GetNumMetaUpgrades( "EpicHeroicBoonMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
	local metaupgradeLegendaryBoost = GetNumMetaUpgrades( "DuoRarityBoonDropMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
	local metaupgradeHeroicBoost = GetNumMetaUpgrades( "EpicHeroicBoonMetaUpgrade" ) * ( MetaUpgradeData.EpicBoonDropMetaUpgrade.ChangeValue - 1 )
	legendaryRoll = legendaryRoll + metaupgradeLegendaryBoost + (GameState.HelperItemLodger["BoonBoostHelper"]*0.01)
	heroicRoll = heroicRoll + metaupgradeHeroicBoost + (GameState.HelperItemLodger["BoonBoostHelper"]*0.01)
	rareRoll = rareRoll + metaupgradeRareBoost + (GameState.HelperItemLodger["BoonBoostHelper"]*0.01)
	epicRoll = epicRoll + metaupgradeEpicBoost + (GameState.HelperItemLodger["BoonBoostHelper"]*0.01)

	local rarityTraits = GetHeroTraitValues("RarityBonus", { UnlimitedOnly = ignoreTempRarityBonus })
	for i, rarityTraitData in pairs(rarityTraits) do
		if rarityTraitData.RequiredGod == nil or rarityTraitData.RequiredGod == name then
			if rarityTraitData.RareBonus then
				rareRoll = rareRoll + rarityTraitData.RareBonus
			end
			if rarityTraitData.EpicBonus then
				epicRoll = epicRoll + rarityTraitData.EpicBonus
			end
			if rarityTraitData.HeroicBonus then
				heroicRoll = heroicRoll + rarityTraitData.HeroicBonus
			end
			if rarityTraitData.LegendaryBonus then
				legendaryRoll = legendaryRoll + rarityTraitData.LegendaryBonus
			end
		end
	end
	return
	{
		Rare = rareRoll,
		Epic = epicRoll,
		Heroic = heroicRoll,
		Legendary = legendaryRoll,
	}
end


ModUtil.Path.Wrap("GetRarityChances", function(baseFunc, args)
    return GetRarityChancesOverride( args )
end, PolycosmosHelperManager)