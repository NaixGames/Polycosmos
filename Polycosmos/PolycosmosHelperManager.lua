ModUtil.Mod.Register( "PolycosmosHelperManager" )


local HelpersDataArray=
{
    "MaxHealthHelper",
	"BoonBoostHelper",
	"InitialMoneyHelper",
}


local MaxHealthRequests = 0
local InitialMoneyRequests = 0
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
	elseif (item == "InitialMoneyHelper") then
		InitialMoneyRequests = InitialMoneyRequests + 1
    end
end

function PolycosmosHelperManager.MaxHealthSyncUpdate()
	if (GameState.HelperItemLodger["MaxHealthReminder"] < HeroData.DefaultHero.MaxHealth) then
		GameState.HelperItemLodger["MaxHealthReminder"] = HeroData.DefaultHero.MaxHealth
	else
		HeroData.DefaultHero.MaxHealth = GameState.HelperItemLodger["MaxHealthReminder"]
	end
end

function PolycosmosHelperManager.GetExtraInitialMoney()
	PolycosmosHelperManager.InitializeHelperItemLodger()
	CurrentRun.Money = CurrentRun.Money + GameState.HelperItemLodger["InitialMoneyHelper"]*25
	ShowResourceUIs({ CombatOnly = false, UpdateIfShowing = true })
	UpdateMoneyUI( CurrentRun.Money )
end

--------------------

function PolycosmosHelperManager.InitializeHelperItemLodger()
	if (GameState.HelperItemLodger == nil) then
        GameState.HelperItemLodger = {}
        GameState.HelperItemLodger["MaxHealthHelper"] = 0
		GameState.HelperItemLodger["MaxHealthReminder"] = HeroData.DefaultHero.MaxHealth
        GameState.HelperItemLodger["BoonBoostHelper"] = 0
		GameState.HelperItemLodger["InitialMoneyHelper"] = 0
    end
end

function PolycosmosHelperManager.FlushAndProcessHelperItems()
    PolycosmosHelperManager.InitializeHelperItemLodger()

	-- if player has upgraded their max health, record this
	PolycosmosHelperManager.MaxHealthSyncUpdate()

	local MaxHealthDeltaWithDefault = math.max(CurrentRun.Hero.MaxHealth-HeroData.DefaultHero.MaxHealth,0)

    if (MaxHealthRequests > GameState.HelperItemLodger["MaxHealthHelper"]) then
        local healthIncrease = 25*(MaxHealthRequests - GameState.HelperItemLodger["MaxHealthHelper"])
		if (CurrentRun ~= nil) then
			CurrentRun.Hero.MaxHealth = CurrentRun.Hero.MaxHealth + healthIncrease
			CurrentRun.Hero.Health = CurrentRun.Hero.Health + healthIncrease		
		end
		HeroData.DefaultHero.MaxHealth = HeroData.DefaultHero.MaxHealth + healthIncrease
        GameState.HelperItemLodger["MaxHealthHelper"] = MaxHealthRequests
        PolycosmosMessages.PrintToPlayer("Received a Max Health boost!")

		ShowHealthUI()
    end

	GameState.HelperItemLodger["MaxHealthReminder"] = HeroData.DefaultHero.MaxHealth

	PolycosmosHelperManager.SetupMaxHealth(MaxHealthDeltaWithDefault)

    if (BoonBoostRequests > GameState.HelperItemLodger["BoonBoostHelper"]) then
        GameState.HelperItemLodger["BoonBoostHelper"] = BoonBoostRequests
        PolycosmosMessages.PrintToPlayer("Received a Boon Rarity boost!")
    end

	if (InitialMoneyRequests > GameState.HelperItemLodger["InitialMoneyHelper"]) then
        GameState.HelperItemLodger["InitialMoneyHelper"] = GameState.HelperItemLodger["InitialMoneyHelper"] + InitialMoneyRequests
        PolycosmosMessages.PrintToPlayer("Received more initial Money!")
    end


    MaxHealthRequests = 0
    BoonBoostRequests = 0
	InitialMoneyRequests = 0

    if (CurrentRun ~= nil) then
        SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
        ValidateCheckpoint({ Valid = true })

        Save()
    end
end

--------------------

function GetRarityChancesOverride( args )
	PolycosmosHelperManager.InitializeHelperItemLodger()

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


function PolycosmosHelperManager.SetupMaxHealth(MaxHealthDeltaWithDefault)
    if (GameState.HelperItemLodger ~= nil and GameState.HelperItemLodger["MaxHealthHelper"] > 0) then
		-- if player has upgraded their max health, record this
		PolycosmosHelperManager.MaxHealthSyncUpdate()
		
		HeroData.DefaultHero.MaxHealth = GameState.HelperItemLodger["MaxHealthReminder"]

		if (CurrentRun ~= nil) then
			local delta = CurrentRun.Hero.MaxHealth - CurrentRun.Hero.Health
			CurrentRun.Hero.MaxHealth = HeroData.DefaultHero.MaxHealth + MaxHealthDeltaWithDefault
			CurrentRun.Hero.Health = CurrentRun.Hero.MaxHealth - delta

			SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
			ValidateCheckpoint({ Valid = true })

			Save()
		end

		ShowHealthUI()
		
	end
end