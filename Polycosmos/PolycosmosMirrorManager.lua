ModUtil.Mod.Register("PolycosmosMirrorManager")
PolycosmosMirrorManager = {}
PolycosmosMirrorManager.MirrorUpgradeLocations = {}

----------------------Item Handling and Mirror Upgrade List Management
local MirrorUpgradeTable = {
    ["Shadow Presence"] = {
        Name = "BackstabMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Chthonic Vitality"] = {
        Name = "DoorHealMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Death Defiance"] = {
        Name = "ExtraChanceMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Greater Reflex"] = {
        Name = "StaminaMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Boiling Blood"] = {
        Name = "StoredAmmoVulnerabilityMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Infernal Soul"] = {
        Name = "AmmoMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Deep Pockets"] = {
        Name = "MoneyMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Thick Skin"] = {
        Name = "HealthMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Privileged Status"] = {
        Name = "VulnerabilityEffectBonusMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Olympian Favor"] = {
        Name = "RareBoonDropMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Gods' Pride"] = {
        Name = "EpicBoonDropMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Fated Authority"] = {
        Name = "RerollMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Fiery Presence"] = {
        Name = "FirstStrikeMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Dark Regeneration"] = {
        Name = "DarknessHealMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Stubborn Defiance"] = {
        Name = "ExtraChanceReplenishMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Ruthless Reflex"] = {
        Name = "PerfectDashMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Abyssal Blood"] = {
        Name = "StoredAmmoSlowMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Stygian Soul"] = {
        Name = "ReloadAmmoMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Golden Touch"] = {
        Name = "InterestMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["High Confidence"] = {
        Name = "HighHealthDamageMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Family Favorite"] = {
        Name = "GodEnhancementMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Dark Foresight"] = {
        Name = "RunProgressRewardMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Gods' Legacy"] = {
        Name = "DuoRarityBoonDropMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
    ["Fated Persuasion"] = {
        Name = "RerollPanelMetaUpgrade",
        MaxLevel = nil,
        ObtainedMirrorUpgradeItems = 0,
    },
}

local mirrorHintsCache = ""
PolycosmosMirrorManager.ClientToInternal = {}
PolycosmosMirrorManager.InternalToClient = {}
for clientName, data in pairs(MirrorUpgradeTable) do
    PolycosmosMirrorManager.InternalToClient[data.Name] = clientName
    PolycosmosMirrorManager.ClientToInternal[clientName] = data.Name

	if MetaUpgradeData[data.Name].MaxInvestment or MetaUpgradeData[data.Name].CostTable then
		local upgradeName = data.Name
		local maxLevels = MetaUpgradeData[upgradeName].MaxInvestment or #MetaUpgradeData[upgradeName].CostTable
		data.MaxLevel = maxLevels
		for level=1, maxLevels do
			PolycosmosMirrorManager.MirrorUpgradeLocations[upgradeName..level] = {
				UpgradeName = upgradeName,
				Level = level,
				ClientLocation = "Mirror "..PolycosmosMirrorManager.InternalToClient[upgradeName].." - Level "..level
			}
		end
	end
end

function PolycosmosMirrorManager.RebuildMirrorStateFromUpgradeList(mirrorUpgradeList)
	
    if GameState.ClientGameSettings["MirrorSanity"] == 0 then
        return
    end

	local oldCounts = {}
	for clientName, data in pairs(MirrorUpgradeTable) do
		oldCounts[clientName] = data.ObtainedMirrorUpgradeItems
	end

    PolycosmosMirrorManager.ResetMirrorLevels()
    for i=1, #mirrorUpgradeList do
        local mirrorName = mirrorUpgradeList[i]
        MirrorUpgradeTable[mirrorName].ObtainedMirrorUpgradeItems = MirrorUpgradeTable[mirrorName].ObtainedMirrorUpgradeItems + 1
    end

	for clientName, data in pairs(MirrorUpgradeTable) do
		if data.ObtainedMirrorUpgradeItems > oldCounts[clientName] then
			PolycosmosMessages.PrintToPlayer("Obtained "..clientName.." mirror level item!")
			local level = math.min(data.ObtainedMirrorUpgradeItems, data.MaxLevel)
			PolycosmosMessages.PrintToPlayer(clientName.." level changed to "..level)
		end
	end
    PolycosmosMirrorManager.UpdateMirrorLevels()
    BuildMetaupgradeCache()
end
function PolycosmosMirrorManager.ResetMirrorLevels()
    for clientName, upgradeData in pairs(MirrorUpgradeTable) do
        upgradeData.ObtainedMirrorUpgradeItems = 0
    end
end
function PolycosmosMirrorManager.UpdateMirrorLevels()
	
    if GameState.ClientGameSettings["MirrorSanity"] == 0 then
        return
    end

    local mirrorSettingLoader = {}
    --sanity check on the upgrades we've received and print handling for the player
    for clientName, upgradeData in pairs(MirrorUpgradeTable) do
        local calculatedMirrorLevel = math.min(upgradeData.MaxLevel,upgradeData.ObtainedMirrorUpgradeItems)
        if upgradeData.ObtainedMirrorUpgradeItems > upgradeData.MaxLevel then
            PolycosmosMessages.PrintErrorMessage("Calculated mirror upgrade level over maximum, something went wrong with the item pool or item sync!",1)
        end
        mirrorSettingLoader[upgradeData.Name] = calculatedMirrorLevel
    end
    --check which side of the mirror is selected for that upgrade; if active, then apply the upgrade immediately. otherwise, just
    --store it until later
    for internalName, upgradeLevel in pairs(mirrorSettingLoader) do
        GameState.MetaUpgradeState = GameState.MetaUpgradeState or {}
        GameState.MetaUpgradesSelected = GameState.MetaUpgradesSelected or {}
		GameState.MetaUpgrades = GameState.MetaUpgrades or {}

        local mirrorIndex = nil
        --find the row in MetaUpgradeOrder for the upgrade, then check which side it is on
        for index, pair in pairs(MetaUpgradeOrder) do
            if pair[1] == internalName or pair[2] == internalName then
                mirrorIndex = index
                break
            end
        end
        local selectedUpgrade = GameState.MetaUpgradesSelected[mirrorIndex]
        if selectedUpgrade == nil then
            selectedUpgrade = internalName
            GameState.MetaUpgradesSelected[mirrorIndex] = internalName
        end
        if selectedUpgrade == internalName then
            GameState.MetaUpgrades[internalName] = upgradeLevel
            if CurrentRun ~= nil then
                CurrentRun.MetaUpgradeCache[internalName] = upgradeLevel
            end 
        else
            GameState.MetaUpgradeState[internalName] = upgradeLevel
        end
    end
    PolycosmosMirrorManager.UpdateHeroStatsFromMirror()
end

function PolycosmosMirrorManager.UpdateHeroStatsFromMirror()
	
    if GameState.ClientGameSettings["MirrorSanity"] == 0 then
        return
    end

    Heal( CurrentRun.Hero, { HealAmount = CurrentRun.Hero.MaxHealth, Silent = true } )
	thread( UpdateHealthUI )
	CurrentRun.NumRerolls = GetNumMetaUpgrades("RerollMetaUpgrade") + GetNumMetaUpgrades("RerollPanelMetaUpgrade")
	UpdateRerollUI( CurrentRun.NumRerolls )
end

--when the player switches which side of a mirror upgrade is active, apply it with the new logic
ModUtil.Path.Wrap("SwapMetaupgrade",function(baseFunc,screen, button)
	
    local mirrorLevelKey = "MirrorLevel"..button.Index

    if screen.Components[mirrorLevelKey] then
        Destroy({ Id = screen.Components[mirrorLevelKey].Id })
        screen.Components[mirrorLevelKey] = nil
    end

    baseFunc(screen,button)
	if GameState.ClientGameSettings["MirrorSanity"] ~= 0 then
    	PolycosmosMirrorManager.UpdateMirrorLevels()
	end
end)


----------------------Location Handling and UI Management

ModUtil.LoadOnce(function()
	if GameState then
		GameState.PolycosmosMirrorChecks = GameState.PolycosmosMirrorChecks or {}
	end
end)

function PolycosmosMirrorManager.GetChecksPurchased(upgradeName)
    return GameState.PolycosmosMirrorChecks[upgradeName] or 0
end

function PolycosmosMirrorManager.GetNextLocationData(upgradeName)
    local nextLevel = PolycosmosMirrorManager.GetChecksPurchased(upgradeName) + 1
    return PolycosmosMirrorManager.MirrorUpgradeLocations[upgradeName..nextLevel]
end

function PolycosmosMirrorManager.GetMirrorCost(upgradeName)
    local nextLevel = PolycosmosMirrorManager.GetChecksPurchased(upgradeName) + 1
    local upgradeData = MetaUpgradeData[upgradeName]

    if upgradeData.CostTable then
        return upgradeData.CostTable[nextLevel]
    end
    if upgradeData.Cost then
        return upgradeData.Cost
    end

    return nil
end

function PolycosmosMirrorManager.GetTotalMirrorInvestment()

    local total = 0

    for upgradeName, purchasedChecks in pairs(GameState.PolycosmosMirrorChecks) do

        local upgradeData = MetaUpgradeData[upgradeName]

        if upgradeData.CostTable then

            for level = 1, purchasedChecks do
                total = total + upgradeData.CostTable[level]
            end

        elseif upgradeData.Cost then

            total = total + (upgradeData.Cost * purchasedChecks)

        end
    end

    return total
end

function PolycosmosMirrorManager.IsMirrorItem(name)
	local itemName = (name):gsub(" Level","")
	return PolycosmosMirrorManager.ClientToInternal[itemName] ~= nil
end

function CacheMirrorHint(clientName)
	if GameState.ClientGameSettings["MirrorSanity"] ~= 0 then
		local wordLen = string.len(clientName)
		mirrorHintsCache = mirrorHintsCache..wordLen.."|"..clientName
	end
end
-- the main logic. when the player applies a mirror upgrade, sends a check and tracks checks sent separately from mirror upgrades
-- received to determine upgrade order
ModUtil.Path.Wrap("HandleMetaUpgradeInput", function(baseFunc, screen, button)
	if GameState.ClientGameSettings["MirrorSanity"] == 0 then
		return baseFunc(screen, button)
	end

	local buttonId = button.Id
	local upgradeData = button.Data
	local currentRun = CurrentRun
	local hasAction = false

	local capApplies = (GetNumMetaUpgrades( "MetaPointCapShrineUpgrade" ) > 0 and screen.ResourceName == "MetaPoints")
	local pointCap = 0
	local currentPoints = 0

    if screen.ResourceName == "ShrinePoints" then
		return baseFunc(screen, button)
    elseif screen.ResourceName == "MetaPoints" then
		pointCap = MetaUpgradeData.MetaPointCapShrineUpgrade.BaseValue + (GetNumMetaUpgrades( "MetaPointCapShrineUpgrade" ) * MetaUpgradeData.MetaPointCapShrineUpgrade.ChangeValue)
		currentPoints = PolycosmosMirrorManager.GetTotalMirrorInvestment()
	end
    upgradeData.NextCost = PolycosmosMirrorManager.GetMirrorCost(upgradeData.Name)

    if button.HandleType == "Add" then

		if upgradeData.GameStateRequirements and not IsGameStateEligible( CurrentRun, upgradeData.GameStateRequirements ) then
			thread( InCombatTextArgs, { Text = "ShrineGameStateIneglible", TargetId = CurrentRun.Hero.ObjectId, SkipRise = false, SkipFlash = false, Duration = 1.25, Group = "Combat_Menu_Overlay", Cooldown = 3 } )
			thread( CannotAffordMetaUpgradePresentation, button.NextCostId )
		elseif upgradeData.NextCost == nil then
			-- Maxed out
			thread( MetaUpgradeAtMaxPresentation, button.NextCostId )
		elseif capApplies and currentPoints + upgradeData.NextCost > pointCap then
			-- Shrine cap
			thread( MetaUpgradesAtGlobalCapPresentation, button.NextCostId )
		elseif not HasResource( button.ResourceName, upgradeData.NextCost ) and not screen.FreeSpend  then
			-- Not enough darkness
			thread( CannotAffordMetaUpgradePresentation, button.NextCostId )
		elseif upgradeData.RequiredTotalInvestment ~= nil and currentPoints < upgradeData.RequiredTotalInvestment then
			-- Needs more investment before it unlocks
			thread( InCombatTextArgs, { Text = "ShrineNeedsMoreInvestment", TargetId = CurrentRun.Hero.ObjectId, SkipRise = false, SkipFlash = false, Duration = 1.25, Group = "Combat_Menu_Overlay", LuaKey = "TempTextData", LuaValue = { Amount = upgradeData.RequiredTotalInvestment }} )

			thread( CannotAffordMetaUpgradePresentation, button.NextCostId )
		else
			PlaySound({ Name = "/SFX/Menu Sounds/MirrorMenuStatIncrease" })
			if not screen.FreeSpend then
				GameState.Resources[button.ResourceName] = GameState.Resources[button.ResourceName] - upgradeData.NextCost
				UpdateResourceUI( button.ResourceName, GameState.Resources[button.ResourceName] )
			end
			_G[screen.SpendPresentationName](upgradeData.NextCost, buttonId)

            local locationData = PolycosmosMirrorManager.GetNextLocationData(upgradeData.Name)
            if locationData == nil then
                thread( MetaUpgradeAtMaxPresentation, button.NextCostId )
                return
            end
            local purchasedChecks = PolycosmosMirrorManager.GetChecksPurchased(upgradeData.Name)
            GameState.PolycosmosMirrorChecks[upgradeData.Name] = purchasedChecks + 1
            PolycosmosEvents.ProcessLocationCheck(locationData.ClientLocation, true)

			local nextMirrorLevel = PolycosmosMirrorManager.GetChecksPurchased(upgradeData.Name) + 1
			local mirrorText = "- Level "..nextMirrorLevel

			if not PolycosmosMirrorManager.GetNextLocationData(upgradeData.Name) then
				mirrorText = "- MAX"
				FinalMetaUpgradePresentation(button, upgradeData.Name)
			end

			local mirrorLevelKey = "MirrorLevel"..button.ParentIndex

			if screen.Components[mirrorLevelKey] then
				ModifyTextBox({Id = screen.Components[mirrorLevelKey].Id, Text = mirrorText})
			end
			
			if upgradeData.DisablesMetaUpgrades then
				local startIndex = TableLength(MetaUpgradeOrder) - GetNulledMetaUpgradeCount() - upgradeData.ChangeValue
				for i = startIndex, startIndex + upgradeData.ChangeValue + 1, -1 do
					local metaUpgradeData = MetaUpgradeData[GameState.MetaUpgradesSelected[i]]
					if GameState.MetaUpgradeState[metaUpgradeData.Name] then
						for s = 1, GameState.MetaUpgradeState[metaUpgradeData.Name] do
							ApplyMetaUpgrade( metaUpgradeData, true, s == 1, true)
						end
					end
				end
			end
			screen.PointsAddedThisTime = screen.PointsAddedThisTime + 1
			hasAction = true
		end
    end
    if not hasAction then
		return
	end

	Heal( currentRun.Hero, { HealAmount = currentRun.Hero.MaxHealth, Silent = true } )
	thread( UpdateHealthUI )
	upgradeData.NextCost = PolycosmosMirrorManager.GetMirrorCost(upgradeData.Name)
	
	local numUpgrades = GetNumMetaUpgrades( upgradeData.Name )
	local totalStatChange = GetTotalStatChange( upgradeData )
	local text = GetMetaUpgradeShortTotalText( upgradeData )
	local color = Color.White
	if numUpgrades ~= 0 then
		color = screen.InvestedColor
	end

	ModifyTextBox({ Id = button.TextBoxId, Text = tostring( numUpgrades ) })
	ModifyTextBox({ Id = button.TotalTextBoxId, Text = text, LuaKey = "TempTextData", LuaValue = { Amount = totalStatChange }, ColorTarget = color, ColorDuration = 0.1 })

	UpdateButtonStates( screen )
	UpdateSubtitle( button )
	UpdateResourceUI( "MetaPoints", GameState.MetaPoints )
	-- Can be refilled at the mirror
	CurrentRun.NumRerolls = GetNumMetaUpgrades( "RerollMetaUpgrade" ) + GetNumMetaUpgrades("RerollPanelMetaUpgrade")
	if CurrentRun.NumRerolls > 0 then
		ShowResourceUIs({ CombatOnly = false })
	end
	UpdateRerollUI( CurrentRun.NumRerolls )

end)

--we need to edit most of the UI for the upgrade menu to show the appropriate information
--the current levels and stat bonuses on the right will stay consistent, but the costs will be updated to match
--sent locations and the name will update to reflect the next location to be sent, for legibility
ModUtil.Path.Wrap("CreateMetaUpgradeEntry", function(baseFunc, args)
	if GameState.ClientGameSettings["MirrorSanity"] == 0 then
		return baseFunc(args)
	end
    if args.Screen.ResourceName == "ShrinePoints" then
		return baseFunc(args)
    end
	local components = args.Components
	local upgradeData = args.Data
	local upgradeName = upgradeData.Name
	local k = args.Index
	local itemLocationY = args.OffsetY
	upgradeData.NextCost = PolycosmosMirrorManager.GetMirrorCost(upgradeName)
    local nextMirrorLevel = PolycosmosMirrorManager.GetChecksPurchased(upgradeName) + 1

	local numUpgrades = GetNumMetaUpgrades( upgradeName )
	local metaUpgradeNumKey = "UpgradeTotal"..k
	components[metaUpgradeNumKey] = CreateScreenComponent({ Name = "BlankObstacle", X = ScreenCenterX, Y = itemLocationY, Group = "Combat_Menu" })

	if upgradeData.Icon then
		components["Icon"..k] = CreateScreenComponent({ Name = "BlankObstacle", X = args.Screen.IconX, Y = itemLocationY - 33, Group = "Combat_Menu" })
		SetAnimation({ Name = upgradeData.Icon, DestinationId = components["Icon"..k].Id, Scale = 0.23 })
	end

	if not Contains( GameState.LastUnlockedMetaUpgrades, upgradeData.Name ) and not upgradeData.Starting and not args.Screen.ReadOnly then

		local itemBackingKey = "Backing"..k
		CreateTextBox({ Id = components[itemBackingKey].Id, Text = "MetaUpgrade_New",
			FontSize = 21,
			OffsetX = LevelUpUI.TextInfoBaseX - 115, OffsetY = -30,
			Color = Color.White,
			Font = "AlegreyaSansSCExtraBold",
			ShadowBlur = 0, ShadowColor = {0,0,0,0}, ShadowOffset={0, 1},
			Justification = "Left" })
	end

	local metaUpgradeTotalKey = "UpgradeValueTotal"..k
	local totalStatChange = GetTotalStatChange( upgradeData )
	components[metaUpgradeTotalKey] = CreateScreenComponent({ Name = "BlankObstacle", X = ScreenCenterX, Y = itemLocationY, Group = "Combat_Menu" })

	local text = GetMetaUpgradeShortTotalText( upgradeData )
	local color = Color.White
	if numUpgrades ~= 0 then
		color = args.Screen.InvestedColor
	elseif args.Locked then
		color = Color.MetaUpgradePointsInvalid
	end

	CreateTextBox({
		Id = components[metaUpgradeTotalKey].Id, Text = text,
		LuaKey = "TempTextData", LuaValue = { Amount = totalStatChange },
		TooltipKey = upgradeData.TotalTooltip, TooltipData = {Amount = totalStatChange },
		FontSize = 26,
		OffsetX = args.Screen.StatChangeX + 100, OffsetY = -32,
		Color = color,
		Font = "AlegreyaSansSCBold",
		ShadowBlur = 0, ShadowColor = {96,96,96,255}, ShadowOffset={0, 1},
		LangDeScaleModifier = 0.8,
		LangFrScaleModifier = 0.9,
		LangItScaleModifier = 0.75,
		LangEsScaleModifier = 0.8,
		LangPtBrScaleModifier = 0.7,
		LangRuScaleModifier = 0.68,
		LangPlScaleModifier = 0.7,
		LangCnScaleModifier = 0.9,
		Justification = "Left" })

	local metaUpgradeNextCostKey = "UpgradeCost"..k
	components[metaUpgradeNextCostKey] = CreateScreenComponent({ Name = "BlankObstacle", X = ScreenCenterX, Y = itemLocationY, Group = "Combat_Menu" })
	if not args.Screen.ReadOnly and not args.Locked then

		CreateTextBox({
			Id = components[metaUpgradeNextCostKey].Id, Text = tostring(upgradeData.NextCost),
			TooltipKey = upgradeData.TotalTooltip, TooltipData = {Amount = totalStatChange },
			FontSize = 26,
			OffsetX = args.Screen.UpgradeCostX, OffsetY = -30,
			Color = Color.DarknessPoint,
			Font = "AlegreyaSansSCMedium",
			ShadowBlur = 0, ShadowColor = {96,96,96,255}, ShadowOffset={0, 1},
			LangCnScaleModifier = 0.85,
			Justification = args.Screen.UpgradeCostJustification })
	end

	local itemBackingKey = "Backing"..k
	local componentColor = Color.ShrineAttribute
	if args.Swap and MetaUpgradeOrder[k] and MetaUpgradeOrder[k][2] == upgradeName then
		componentColor = Color.MirrorBAttribute
	end
	if ( upgradeData.GameStateRequirements ~= nil and not IsGameStateEligible( CurrentRun, upgradeData.GameStateRequirements )) then
		componentColor = Color.ShrineAttributeLocked
	elseif args.Locked then
		componentColor = Color.MetaUpgradePointsInvalid
	end

	CreateTextBox({
		Id = components[itemBackingKey].Id,
		Text = upgradeData.Name,
		FontSize = 21,
		OffsetX = LevelUpUI.TextInfoBaseX,
		OffsetY = -30,
		Color = componentColor,
		Font = "AlegreyaSansSCExtraBold",
		ShadowBlur = 0,
		ShadowColor = {0,0,0,1},
		ShadowOffset = {0, 1},
		LangDeScaleModifier = 0.8,
		LangFrScaleModifier = 0.9,
		LangItScaleModifier = 0.75,
		LangEsScaleModifier = 0.8,
		LangPtBrScaleModifier = 0.7,
		LangRuScaleModifier = 0.72,
		LangPlScaleModifier = 0.7,
		LangCnScaleModifier = 0.9,
		Justification = "Left"
	})

	local mirrorLevelKey = "MirrorLevel"..k

	components[mirrorLevelKey] = CreateScreenComponent({
		Name = "BlankObstacle",
		X = ScreenCenterX,
		Y = itemLocationY,
		Group = "Combat_Menu"
	})

	local mirrorText = "- Level "..nextMirrorLevel
	if not PolycosmosMirrorManager.GetNextLocationData(upgradeName) then
		mirrorText = "- MAX"
	end

	CreateTextBox({
		Id = components[mirrorLevelKey].Id,
		Text = mirrorText,
		FontSize = 21,
		OffsetX = LevelUpUI.TextInfoBaseX + 200,
		OffsetY = -30,
		Color = componentColor,
		Font = "AlegreyaSansSCExtraBold",
		ShadowBlur = 0,
		ShadowColor = {0,0,0,1},
		ShadowOffset = {0, 1},
		Justification = "Left"
	})

	if not args.Screen.ReadOnly then
		if args.Locked then
			local button = CreateArrowButton( k, { Screen = args.Screen, Data = upgradeData, IsIncrease = true, IsEnabled = false, Locked = true })
			CreateTooltipTarget( args.Screen, k, upgradeData, { Locked = true } )
		else
			local button = CreateArrowButton( k, { Screen = args.Screen, Data = upgradeData, IsIncrease = true, IsEnabled = true })
			button.ResourceName = args.Screen.ResourceName
			if args.Swap then
				components[itemBackingKey.."Swap"] = CreateScreenComponent({ Name = "ExchangeMetaupgrade", Scale = 1.0, Group = "Combat_Menu" })
				Attach({ Id = components[itemBackingKey.."Swap"].Id, DestinationId = components[itemBackingKey].Id, OffsetX = args.Screen.SwapButtonX, OffsetY = -29 })
				components[itemBackingKey.."Swap"].OnPressedFunctionName = "SwapMetaupgrade"
				components[itemBackingKey.."Swap"].OffsetY = itemLocationY
				components[itemBackingKey.."Swap"].Index = k
				components[itemBackingKey.."Swap"].Name = upgradeName

				-- hack: invisible textbox for autotooltips to trigger on the buttons
				local flipSideTooltip = "Blank"
				if MetaUpgradeOrder[k] then
					if MetaUpgradeOrder[k][1] == upgradeName then
						flipSideTooltip = MetaUpgradeOrder[k][2]
					else
						flipSideTooltip = MetaUpgradeOrder[k][1]
					end
				end
				local swapTooltipLuaValue =
				{
					BaseValue = GetMetaUpgradeStatDelta( upgradeData ),
					StartingValue = (upgradeData.BaseValue or 0),
					DisplayValue = (upgradeData.DisplayValue or 0),
					CurrentSide = upgradeName,
					FlipSide = flipSideTooltip,
				}
				SetInteractProperty({ DestinationId = components[itemBackingKey.."Swap"].Id, Property = "TooltipOffsetX", Value = 950 })
				CreateTextBox({ Id = components[itemBackingKey.."Swap"].Id, Text = upgradeName,
					FontSize = 1,
					OffsetX = 0, OffsetY = 0,
					Font = "AlegreyaSansSCExtraBold",
					Justification = "LEFT",
					Color = Color.Transparent,
					LuaKey = "TempTextData",
					LuaValue = swapTooltipLuaValue,
				})
				CreateTextBox({ Id = components[itemBackingKey.."Swap"].Id, Text = "MetaUpgradeSwapHint",
					FontSize = 1,
					OffsetX = 0, OffsetY = 0,
					Font = "AlegreyaSansSCExtraBold",
					Justification = "LEFT",
					Color = Color.Transparent,
					LuaKey = "TempTextData",
					LuaValue = swapTooltipLuaValue,
				})
				local hoverButton = CreateTooltipTarget( args.Screen, k, upgradeData )
				hoverButton.OnPressedFunctionName = "SwapMetaupgrade"
				hoverButton.OffsetY = itemLocationY
				hoverButton.Index = k
				hoverButton.Name = upgradeName
			else
				CreateTooltipTarget( args.Screen, k, upgradeData )
			end
		end
	end
	--after creating an entry, send a hint for the location
	local locationData = PolycosmosMirrorManager.GetNextLocationData(upgradeName)
	if locationData then
		CacheMirrorHint(locationData.ClientLocation)
		StyxScribe.Send(styx_scribe_send_prefix.."Locations hinted:"..mirrorHintsCache)
		mirrorHintsCache = ""
	end

	local screen = ScreenAnchors.LevelUpScreen
	if screen and screen.Components and screen.Components.RefundButton then
		Destroy({ Id = screen.Components.RefundButton.Id })
	end
end)

--in this context, refund really doesnt mean anything, so we'll remove the button entirely.


ModUtil.Path.Wrap("UpdateButtonStates", function(baseFunc, screen)
	if GameState.ClientGameSettings["MirrorSanity"] == 0 then
		return baseFunc(screen)
	end

    local components = screen.Components

	local capApplies = (GetNumMetaUpgrades( "MetaPointCapShrineUpgrade" ) > 0 and screen.ResourceName == "MetaPoints")
	local pointCap = 0
	local currentPoints = 0
    if screen.ResourceName == "ShrinePoints" then
		return baseFunc(screen)
    elseif screen.ResourceName == "MetaPoints" then
		pointCap = MetaUpgradeData.MetaPointCapShrineUpgrade.BaseValue + (GetNumMetaUpgrades( "MetaPointCapShrineUpgrade" ) * MetaUpgradeData.MetaPointCapShrineUpgrade.ChangeValue)
		currentPoints = PolycosmosMirrorManager.GetTotalMirrorInvestment()
	end

	for i, component in pairs( components ) do
		if component.HandleType == "Add" then
			local isEnabled = IsMetaUpgradeValid ( screen, component, currentPoints, capApplies, pointCap )
			if component.LastEnabled ~= isEnabled then
				local button = CreateArrowButton( component.ParentIndex, { Screen = screen, Data = component.Data, IsIncrease = true, IsEnabled = isEnabled } )
				button.ResourceName = screen.ResourceName
			end
			if not isEnabled then
				if component.Data.NextCost ~= nil then
					local text = "MetaUpgradeMenu_InvalidCost"
					local color = Color.MetaUpgradePointsInvalid
					if capApplies and ( currentPoints + component.Data.NextCost ) > pointCap then
						color = Color.MetaUpgradePointsCappedColor
					end

					ModifyTextBox({ Id = component.NextCostId, Text = text, LuaKey = "TempTextData", LuaValue = { Amount = component.Data.NextCost }, ColorTarget = color, ColorDuration = 0.0, ShadowAlpha = 0})
				else
					ModifyTextBox({ Id = component.NextCostId, Text = "MetaUpgradeMenu_Maxed", ColorTarget = Color.MetaUpgradePointsInvalid })
				end
			else
				local icon = "{!Icons.MetaPoint_Small}"
				ModifyTextBox({ Id = component.NextCostId, Text = component.Data.NextCost..icon, ColorTarget = Color.White, ColorDuration = 0.0, ShadowAlpha = 1})
			end
		elseif component.HandleType == "Unlock" then
			local isEnabled = HasResource( component.Data.ResourceName, component.Data.UnlockCost )
			if component.LastEnabled ~= isEnabled then
				local button = CreateUnlockButton( component.Data, { Screen = screen, OffsetX = component.OffsetX, OffsetY = component.OffsetY, Index = component.ParentIndex, IsEnabled = isEnabled, KeyCostKey = "UpgradeCost"..component.ParentIndex } )
				button.ResourceName = screen.ResourceName
			end

			if not isEnabled then
				ModifyTextBox({ Id = components[component.KeyCostKey].Id, Color = Color.MetaUpgradePointsInvalid })
			end
		end
	end
end)