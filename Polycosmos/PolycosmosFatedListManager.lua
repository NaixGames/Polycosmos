ModUtil.Mod.Register( "PolycosmosFatedListManager" )


------------ 

local fatedListHints = ""

------------ 

local FatedListNames =
{
    FirstClear = {
        ClientNameLocation = "Is There No Escape?",
    },
	MeetOlympians = {
		ClientNameLocation = "Distant Relatives", 
	},
	MeetChthonicGods = {
		ClientNameLocation = "Chthonic Colleagues", 
	},
	OrpheusRelease = {
		ClientNameLocation = "The Reluctant Musician", 
	},
	AthenaUpgrades = {
		ClientNameLocation = "Goddess Of Wisdom", 
	},
	ZeusUpgrades = {
		ClientNameLocation = "God Of The Heavens", 
	},
	PoseidonUpgrades = {
		ClientNameLocation = "God Of The Sea", 
	},
	AphroditeUpgrades = {
		ClientNameLocation = "Goddess Of Love", 
	},
	AresUpgrades = {
		ClientNameLocation = "God Of War", 
	},
	ArtemisUpgrades = {
		ClientNameLocation = "Goddess Of The Hunt", 
	},
	DionysusUpgrades = {
		ClientNameLocation = "God Of Wine", 
	},
	HermesUpgrades = {
		ClientNameLocation = "God Of Swiftness", 
	},
	DemeterUpgrades = {
		ClientNameLocation = "Goddess Of Seasons", 
	},
	LegendaryUpgrades = {
		ClientNameLocation = "Power Without Equal", 
	},
	SynergyUpgrades = {
		ClientNameLocation = "Divine Pairings", 
	},
	ChaosBlessings = {
		ClientNameLocation = "Primordial Boons", 
	},
	ChaosCurses = {
		ClientNameLocation = "Primordial Banes", 
	},
	WeaponUnlocks = {
		ClientNameLocation = "Infernal Arms",
	},
	SwordHammerUpgrades = {
		ClientNameLocation = "The Stygian Blade", 
	},
	BowHammerUpgrades = {
		ClientNameLocation = "The Heart Seeking Bow", 
	},
	ShieldHammerUpgrades = {
		ClientNameLocation = "The Shield Of Chaos", 
	},
	SpearHammerUpgrades = {
		ClientNameLocation = "The Eternal Spear", 
	},
	FistHammerUpgrades = {
		ClientNameLocation = "The Twin Fists", 
	},
	GunHammerUpgrades = {
		ClientNameLocation = "The Adamant Rail", 
	},
	WeaponClears = {
		ClientNameLocation = "Master Of Arms", 
	},
	WeaponAspects = {
		ClientNameLocation = "A Violent Past", 
	},
	PactUpgrades = {
		ClientNameLocation = "Harsh Conditions", 
	},
	EliteAttributeKills = {
		ClientNameLocation = "Slashed Benefits", 
	},
	MiniBossKills = {
		ClientNameLocation = "Wanton Ransacking", 
	},
	CosmeticsSmall = {
		ClientNameLocation = "A Simple Job", 
	},
	CodexSmall = {
		ClientNameLocation = "Chthonic Knowledge", 
	},
	WellShopItems = {
		ClientNameLocation = "Customer Loyalty", 
	},
	MirrorUpgrades = {
		ClientNameLocation = "Dark Reflections", 
	},
	KeepsakesQuest = {
		ClientNameLocation = "Close At Heart", 
	},
	PoseidonFish = {
		ClientNameLocation = "Denizens Of The Deep", 
	},
	FirstSkellyStatue = {
		ClientNameLocation = "The Useless Trinket", 
	},
}

-------------------------------------------------------

function PolycosmosFatedListManager.GiveItemTitle(displayName)
	if (FatedListNames[displayName]) then
		if (GameState.ClientGameSettings["FateSanity"]==0) then
			return displayName
		else
			local nameFatedList =  PolycosmosEvents.GiveItemInLocation(FatedListNames[displayName].ClientNameLocation)
			if (nameFatedList == "") then
				return "UnknownAPFatedListReward"
			end
			return nameFatedList
		end
	else
		return displayName
	end
end

function PolycosmosFatedListManager.HasFateBeenChecked(displayName)
	if (FatedListNames[displayName]) then
		return PolycosmosEvents.HasLocationBeenChecked(FatedListNames[displayName].ClientNameLocation)
	end
	return false
end

-------------------------------------------------------


ModUtil.Path.Wrap( "OpenQuestLogScreen", function(baseFunc, args)
        return PolycosmosFatedListManager.OpenQuestLogScreenOverride(args)
end)

ModUtil.Path.Wrap( "CashOutQuest", function(baseFunc, screen, button)
		if (not FatedListNames[button.Data.Name]) then
			return baseFunc(screen, button)
		end

		if GameState.ClientGameSettings["FateSanity"] == 0 then
			return baseFunc(screen, button)
		end

		local fateNameLocation = FatedListNames[button.Data.Name].ClientNameLocation

		StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..fateNameLocation)
        return PolycosmosFatedListManager.CashOutQuestOverride(screen, button)
end)

-------------------------------------------------------

function PolycosmosFatedListManager.SendCacheHints()
	if (GameState.ClientGameSettings["FateSanity"]==0) then
			return
	end

	StyxScribe.Send(styx_scribe_send_prefix.."Locations hinted:"..fatedListHints)
	fatedListHints = ""
end

function PolycosmosFatedListManager.CacheFateHint(questName)
	if (GameState.ClientGameSettings["FateSanity"]==0) then
			return
	end

	if (FatedListNames[questName]) then
		fatedListHints = fatedListHints..FatedListNames[questName].ClientNameLocation.."-"
	end
end

-------------------------------------------------------

function PolycosmosFatedListManager.OpenQuestLogScreenOverride( args )
	ResetKeywords()
	local screen = DeepCopyTable( ScreenData.QuestLog )
	screen.Components = {}
	ScreenAnchors.QuestLogScreen = screen
	local components = screen.Components
	screen.CloseAnimation = "QuestLogOut"

	OnScreenOpened({ Flag = screen.Name, PersistCombatUI = true })
	FreezePlayerUnit()
	EnableShopGamepadCursor()
	SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
	SetConfigOption({ Name = "FreeFormSelectStepDistance", Value = 8 })
	SetConfigOption({ Name = "FreeFormSelectSuccessDistanceStep", Value = 8 })
	SetConfigOption({ Name = "FreeFormSelectRepeatDelay", Value = 0.6 })
	SetConfigOption({ Name = "FreeFormSelectRepeatInterval", Value = 0.1 })

	components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu" })
	components.ShopBackgroundSplatter = CreateScreenComponent({ Name = "LevelUpBackground", Group = "Combat_Menu" })
	components.ShopBackground = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu" })

	SetAnimation({ DestinationId = components.ShopBackground.Id, Name = "QuestLogIn", OffsetY = 0 })

	SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4 })
	SetColor({ Id = components.ShopBackgroundDim.Id, Color = {0.090, 0.055, 0.157, 0.8} })

	PlaySound({ Name = "/SFX/Menu Sounds/FatedListOpen" })

	wait(0.2)

	-- Title
	CreateTextBox(MergeTables({ Id = components.ShopBackground.Id, Text = "QuestLogScreen_Title", FontSize = 34, OffsetX = 0, OffsetY = -460, Color = Color.White, Font = "SpectralSCLightTitling", ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2}, Justification = "Center" }, LocalizationData.QuestLogScreen.TitleText))
	CreateTextBox({ Id = components.ShopBackground.Id, Text = "QuestLogScreen_Flavor", FontSize = 15, OffsetX = 0, OffsetY = -410, Width = 840, Color = {120, 120, 120, 255}, Font = "CrimsonTextItalic", ShadowBlur = 0, ShadowColor = {0,0,0,0}, ShadowOffset={0, 2}, Justification = "Center" })

	-- Description Box
	components.DescriptionBox = CreateScreenComponent({ Name = "BlankObstacle", X = 795, Y = 300, Group = "Combat_Menu" })

	-- Close button
	components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Scale = 0.7, Group = "Combat_Menu" })
	Attach({ Id = components.CloseButton.Id, DestinationId = components.ShopBackground.Id, OffsetX = -6, OffsetY = 456 })
	components.CloseButton.OnPressedFunctionName = "CloseQuestLogScreen"
	components.CloseButton.ControlHotkey = "Cancel"

	local itemLocationX = screen.ItemStartX
	local itemLocationY = screen.ItemStartY

	screen.Components.ScrollUp = CreateScreenComponent({ Name = "ButtonCodexUp", X = 430, Y = screen.ItemStartY - screen.EntryYSpacer + 1, Scale = 1.0, Sound = "/SFX/Menu Sounds/GeneralWhooshMENU", Group = "Combat_Menu" })
	screen.Components.ScrollUp.OnPressedFunctionName = "QuestLogScrollUp"
	screen.Components.ScrollUp.ControlHotkey = "MenuLeft"

	screen.Components.ScrollDown = CreateScreenComponent({ Name = "ButtonCodexDown", X = 430, Y = screen.ItemStartY + ( (screen.EntryYSpacer - 1) * screen.ItemsPerPage + 10), Scale = 1.0, Sound = "/SFX/Menu Sounds/GeneralWhooshMENU", Group = "Combat_Menu" })
	screen.Components.ScrollDown.OnPressedFunctionName = "QuestLogScrollDown"
	screen.Components.ScrollDown.ControlHotkey = "MenuRight"

	local readyToCashOutQuests = {}
	local incompleteQuests = {}
	local cashedOutQuests = {}

	for k, questName in ipairs( QuestOrderData ) do
		local questData = QuestData[questName]
		if (GameState.QuestStatus[questData.Name] == "CashedOut" or PolycosmosFatedListManager.HasFateBeenChecked(questData.Name) ) then
			table.insert( cashedOutQuests, questData )
		elseif IsGameStateEligible( CurrentRun, questData, questData.UnlockGameStateRequirements ) then
			if IsGameStateEligible( CurrentRun, questData, questData.CompleteGameStateRequirements ) then
				table.insert( readyToCashOutQuests, questData )
			else
				table.insert( incompleteQuests, questData )
			end
		end
	end

	screen.NumItems = 0
	local anyNew = false
	local anyToCashOut = 0

	for k, questData in ipairs( readyToCashOutQuests ) do

		-- QuestButton
		screen.NumItems = screen.NumItems + 1
		local questButtonKey = "QuestButton"..screen.NumItems
		components[questButtonKey] = CreateScreenComponent({ Name = "ButtonQuestLogEntry", Scale = 1, X = itemLocationX, Y = itemLocationY, Group = "Combat_Menu" })
		components[questButtonKey].OnPressedFunctionName = "CashOutQuest"
		components[questButtonKey].OnMouseOverFunctionName = "MouseOverQuest"
		components[questButtonKey].OnMouseOffFunctionName = "MouseOffQuest"
		components[questButtonKey].Data = questData
		components[questButtonKey].Index = screen.NumItems
		AttachLua({ Id = components[questButtonKey].Id, Table = components[questButtonKey] })

		local newButtonKey = "NewIcon"..screen.NumItems
		if not GameState.QuestsViewed[questData.Name] then
			-- New icon
			anyNew = true
			components[newButtonKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu" })
			SetAnimation({ DestinationId = components[newButtonKey].Id , Name = "QuestLogNewQuest" })
			Attach({ Id = components[newButtonKey].Id, DestinationId = components[questButtonKey].Id, OffsetX = 0, OffsetY = 0 })
		end

		PolycosmosFatedListManager.CacheFateHint(questData.Name)

		CreateTextBox(MergeTables({ Id = components[questButtonKey].Id,
			Text = PolycosmosFatedListManager.GiveItemTitle(questData.Name), --THIS IS THE NEW BIT FOR OVERRIDING TITLES
			Color = {245, 200, 47, 255},
			FontSize = 22,
			OffsetX = -10, OffsetY = 0,
			Width = 330,
			Font = "AlegreyaSansSCBold",
			OutlineThickness = 0,
			OutlineColor = {255, 205, 52, 255},
			ShadowBlur = 0, ShadowColor = {0,0,0,0}, ShadowOffset={0, 2},
			Justification = "Right",
			DataProperties =
			{
				OpacityWithOwner = true,
			},
			}, LocalizationData.QuestLogScreen.QuestName))
		Flash({ Id = components[questButtonKey].Id, Speed = 0.8, MinFraction = 0.0, MaxFraction = 0.7, Color = Color.White })

		itemLocationY = itemLocationY + screen.EntryYSpacer

		anyToCashOut = anyToCashOut + 1

	end

	for k, questData in ipairs( incompleteQuests ) do

		-- QuestButton
		screen.NumItems = screen.NumItems + 1
		local questButtonKey = "QuestButton"..screen.NumItems
		components[questButtonKey] = CreateScreenComponent({ Name = "ButtonQuestLogEntry", Scale = 1, X = itemLocationX, Y = itemLocationY, Group = "Combat_Menu" })
		components[questButtonKey].OnMouseOverFunctionName = "MouseOverQuest"
		components[questButtonKey].OnMouseOffFunctionName = "MouseOffQuest"
		components[questButtonKey].Data = questData
		components[questButtonKey].Index = screen.NumItems
		AttachLua({ Id = components[questButtonKey].Id, Table = components[questButtonKey] })

		local newButtonKey = "NewIcon"..screen.NumItems
		if not GameState.QuestsViewed[questData.Name] then
			-- New icon
			anyNew = true
			components[newButtonKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu" })
			SetAnimation({ DestinationId = components[newButtonKey].Id , Name = "QuestLogNewQuest" })
			Attach({ Id = components[newButtonKey].Id, DestinationId = components[questButtonKey].Id, OffsetX = 0, OffsetY = 0 })
		end

		PolycosmosFatedListManager.CacheFateHint(questData.Name)

		CreateTextBox(MergeTables({ Id = components[questButtonKey].Id,
			Text = PolycosmosFatedListManager.GiveItemTitle(questData.Name), --THIS IS THE NEW BIT FOR OVERRIDING TITLES
			Color = {215, 215, 215, 255},
			FontSize = 22,
			OffsetX = -10, OffsetY = 0,
			Font = "AlegreyaSansSCBold",
			OutlineThickness = 0,
			OutlineColor = {0,0,0,0.5},
			ShadowBlur = 0, ShadowColor = {0,0,0,0.7}, ShadowOffset={0, 2},
			Justification = "Right",
			DataProperties =
			{
				OpacityWithOwner = true,
			},
			}, LocalizationData.QuestLogScreen.QuestName))

		itemLocationY = itemLocationY + screen.EntryYSpacer
	end

	PolycosmosFatedListManager.SendCacheHints()

	for k, questData in ipairs( cashedOutQuests ) do

		-- QuestButton
		screen.NumItems = screen.NumItems + 1
		local questButtonKey = "QuestButton"..screen.NumItems
		components[questButtonKey] = CreateScreenComponent({ Name = "ButtonQuestLogEntry", Scale = 1, X = itemLocationX, Y = itemLocationY, Group = "Combat_Menu" })
		components[questButtonKey].OnMouseOverFunctionName = "MouseOverQuest"
		components[questButtonKey].OnMouseOffFunctionName = "MouseOffQuest"
		components[questButtonKey].Data = questData
		components[questButtonKey].Index = screen.NumItems
		AttachLua({ Id = components[questButtonKey].Id, Table = components[questButtonKey] })

		CreateTextBox(MergeTables({ Id = components[questButtonKey].Id,
			Text = PolycosmosFatedListManager.GiveItemTitle(questData.Name), --THIS IS THE NEW BIT FOR OVERRIDING TITLES
			Color = Color.Black,
			FontSize = 22,
			OffsetX = -10, OffsetY = 0,
			Font = "AlegreyaSansSCRegular",
			ShadowBlur = 0, ShadowColor = {0,0,0,0}, ShadowOffset={0, 2},
			Justification = "Right",
			DataProperties =
			{
				OpacityWithOwner = true,
			},
			}, LocalizationData.QuestLogScreen.QuestName))

		itemLocationY = itemLocationY + screen.EntryYSpacer

	end

	if anyToCashOut == 1 then
		thread( PlayVoiceLines, HeroVoiceLines.OpenedQuestLogSingleQuestCompleteVoiceLines, true )
	elseif anyToCashOut > 1 then
		thread( PlayVoiceLines, HeroVoiceLines.OpenedQuestLogMultiQuestsCompleteVoiceLines, true )
	elseif anyNew then
		thread( PlayVoiceLines, HeroVoiceLines.OpenedQuestLogNewQuestsAddedVoiceLines, true )
	else
		thread( PlayVoiceLines, HeroVoiceLines.OpenedQuestLogVoiceLines, true )
	end

	QuestLogUpdateVisibility( screen )
	MouseOffQuest()

	wait(0.1)
	TeleportCursor({ OffsetX = screen.ItemStartX - 30, OffsetY = screen.ItemStartY, ForceUseCheck = true })

	screen.KeepOpen = true
	thread( HandleWASDInput, screen )
	HandleScreenInput( screen )

end

function PolycosmosFatedListManager.CashOutQuestOverride( screen, button )

	local questData = button.Data
	if questData.CompleteGameStateRequirements ~= nil and not IsGameStateEligible( CurrentRun, questData, questData.CompleteGameStateRequirements ) then
		QuestIncompletePresentation( button )
		return
	end

	if GameState.QuestStatus[button.Data.Name] ~= "CashedOut" then
		GameState.QuestStatus[button.Data.Name] = "CashedOut"
		QuestCashedOutPresentation( screen, button )
	end

	StopFlashing({ Id = button.Id })
	ModifyTextBox({ Id = button.Id, Color = Color.Black })
	ModifyTextBox({ Id = ScreenAnchors.QuestLogScreen.Components.DescriptionBox.Id, AffectText = "QuestLogReward", Color = Color.Gray })
	ModifyTextBox({ Id = ScreenAnchors.QuestLogScreen.Components.DescriptionBox.Id, AffectText = "QuestLog_CashOutHint", FadeTarget = 0 })

end

