ModUtil.Mod.Register("PolycosmosMirrorManager")
PolycosmosMirrorManager = {}
PolycosmosMirrorManager.MirrorUpgradeLocations = {}

local mirrorUpgradeData = {}
for _, pairData in pairs(MetaUpgradeOrder) do
    mirrorUpgradeData[pairData[1]] = {}
    mirrorUpgradeData[pairData[2]] = {}
end

for upgradeName, data in pairs(mirrorUpgradeData) do
    local maxLevels = MetaUpgradeData[upgradeName].MaxInvestment or #MetaUpgradeData[upgradeName].CostTable
    data.MaxLevel = maxLevels
    DebugPrint({ Text = MetaUpgradeData[upgradeName].Name })
    for level=1, maxLevels do
        PolycosmosMirrorManager.MirrorUpgradeLocations[upgradeName..level] = {
            UpgradeName = upgradeName,
            Level = level,
            ClientLocation = "Mirror "..MetaUpgradeData[upgradeName].Name.." - Level "..level
        }
    end
end


GameState.PolycosmosMirrorChecks = GameState.PolycosmosMirrorChecks or {}

function PolycosmosMirrorManager.GetChecksPurchased(upgradeName)
    return GameState.PolycosmosMirrorChecks[upgradeName] or 0
end

function PolycosmosMirrorManager.GetNextLocationData(upgradeName)

    local nextLevel =
        PolycosmosMirrorManager.GetChecksPurchased(upgradeName) + 1

    return PolycosmosMirrorManager.MirrorUpgradeLocations[
        upgradeName .. nextLevel
    ]
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


-- the main logic. when the player applies a mirror upgrade, sends a check and tracks checks sent separately from mirror upgrades
-- received to determine upgrade order
ModUtil.Path.Wrap("HandleMetaUpgradeInput", function(baseFunc, screen, button)

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
			DebugPrint({ Text = "    ApplyMetaUpgrade: "..upgradeData.Name })
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
			
			if upgradeData.DisablesMetaUpgrades then
                DebugPrint({ Text = "DisablesMetaUpgrades triggered" })
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

--in this context, refund really doesnt mean anything, so we'll remove the button entirely.
ModUtil.Path.Wrap("OpenMetaUpgradeMenu", function(baseFunc, args)

    baseFunc(args)

    local screen = ScreenAnchors.LevelUpScreen
    if not screen or not screen.Components then
        return
    end

    if screen.Components.RefundButton then
        Destroy({ Id = screen.Components.RefundButton.Id })
        screen.Components.RefundButton = nil
    end
end)

--we need to edit most of the UI for the upgrade menu to show the appropriate information
--the current levels and stat bonuses on the right will stay consistent, but the costs will be udpated to match
--sent locations and the name will update to reflect the next location to be sent, for legibility
ModUtil.Path.Wrap("CreateMetaUpgradeEntry", function(baseFunc, args)
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
		OffsetX = args.Screen.StatChangeX, OffsetY = -32,
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

    if PolycosmosMirrorManager.GetNextLocationData(upgradeName) then
        CreateTextBox({ Id = components[itemBackingKey].Id, Text = upgradeData.Name.." - Level "..nextMirrorLevel,
            FontSize = 21,
            OffsetX = LevelUpUI.TextInfoBaseX, OffsetY = -30,
            Color = componentColor,
            Font = "AlegreyaSansSCExtraBold",
            ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 1},
            LangDeScaleModifier = 0.8,
            LangFrScaleModifier = 0.9,
            LangItScaleModifier = 0.75,
            LangEsScaleModifier = 0.8,
            LangPtBrScaleModifier = 0.7,
            LangRuScaleModifier = 0.72,
            LangPlScaleModifier = 0.7,
            LangCnScaleModifier = 0.9,
            Justification = "Left" })
    else
        CreateTextBox({ Id = components[itemBackingKey].Id, Text = upgradeData.Name.." - All Checks Purchased",
            FontSize = 21,
            OffsetX = LevelUpUI.TextInfoBaseX, OffsetY = -30,
            Color = componentColor,
            Font = "AlegreyaSansSCExtraBold",
            ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 1},
            LangDeScaleModifier = 0.8,
            LangFrScaleModifier = 0.9,
            LangItScaleModifier = 0.75,
            LangEsScaleModifier = 0.8,
            LangPtBrScaleModifier = 0.7,
            LangRuScaleModifier = 0.72,
            LangPlScaleModifier = 0.7,
            LangCnScaleModifier = 0.9,
            Justification = "Left" })
    end
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
end)

ModUtil.Path.Wrap("UpdateButtonStates", function(baseFunc, screen)

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
--OpenMetaUpgradeMenu creates the initial UI
--CreateMetaUpgradeEntry
--HandleMetaUpgradeInput
--AttemptUnlock
--ApplyMetaUpgrade


-- OVERALL
-- in openmetaupgrademenu, can disable refund button
--          also, uses GameState.MetaUpgradesSelected to distinguish which side is selected
-- in CreateMetaUpgradeEntry, most of UI adjustments occur
--          calls GetMetaUpgradePurchasePrice() and GetMetaUpgradeRefundPrice() for costs, 
--          GetNumMetaUpgrades(upgradeName) for what's owned, displays UpgradeValueTotal for tooltip of current stat bonus,
--          can edit CreateTextBox({Text = upgradeData.Name}) to make it show the level of the location
-- in CreateArrowButton' createtextbox, can update tooltip. most things go to HandleMetaUpgradeInput for processing
-- could maybe use CreateTooltipTarget instead, look and see
-- ====== MOST IMPORTANT ======
-- in HandleMetaUpgradeInput , reads upgradeName, checks requirements, darkness, investment, cap, max rank
--          adds upgrades on + through IncrementTableValue(GameState.MetaUpgrades,upgradeData.Name) and ApplyMetaUpgrade(...)
--          after purchase, runs ModifyTextBox(), UpdateButtonStates(), UpdateSubtitle(), UpdateRerollUI() to refresh screen
-- in UpdateButtonStates, handles the "can I click this" -- do i have the cost, is it maxed, is it unavailable
-- SwapMetaupgrade handles which side is enabled using MetaUpgradeOrder, removes Traits from opposite side, adds new ones,
--          and rebuilds UI with CreateMetaUpgradeEntry

-- PLAN
-- I want to move all of the "add the upgrade to the saved list" to the styx unlock
-- Then replace the functionality in the mirror with a new styx location send
-- Each click of "+" should go through cost logic, update as it would normally do, and instead of adding a level immediately,
-- Send a location and update to the next level/tooltip.
-- the righthand side listing # of current levels and stat bonus should stay affected by the saved actual mirror levels, not checks
-- meaning it will update when the player received a check
-- So in createmetaupgradeentry, we may be able to leave the cost checks but swap GetNumMetaUpgrades with some 
-- "getprocessedchecks" or similar, and use the processed check to add the current level to the display name
-- In handlemetaupgradeinput, we need to check requirements and darkness, but replace investment with our own checks to compare with
-- a new max rank verification (i think). we need to check what the refresh script does in detail to see if it needs updates.
-- In updatebuttonstates, we can do the same swaps as handlemetaupgradeinput
-- maybe check UpdateSubtitle and UpdateResourceUI
-- SwapMetaupgrade will hopefully be mostly the same?
-- Depending on where the current unlocked ranks are stored, we can increment that table with the styx item receipt and
-- use it for theside flip

-- STEPS
-- In handlemetaupgradeinput, nix these lines
--IncrementTableValue(
--    GameState.MetaUpgrades,
--    upgradeData.Name
--)
--
--ApplyMetaUpgrade(...)
-- And replace with incrementing our GameState.PolycosmosMirrorChecks/styx send
-- Eg. GameState.PolycosmosMirrorChecks[upgradeName] += 1 or something like that
-- For cost calculations, we need to replace GetMetaUpgradePurchasePrice() with some 
-- new GetMirrorPurchasePrice(upgradeName), using GameState.PolyCosmosMirrorChecks instead of GameState.MetaUpgrades
-- In UpdateButtonStates, replace upgradeData.NextCost with our own calculations (and probably the other things)
-- In CreateMetaUpgradeEntry, we will KEEP GetNumMetaUpgrades for Current Rank counter, stat display, and effect strength
-- But upgradeData.Name will be replaced with some name based on a thing like
--local purchasedChecks =
--    GetMirrorCheckCount(upgradeName)
--
--local nextLevel =
--    purchasedChecks + 1
-- For display, and the tooltip will have both the original displayed and a new one based on the map from the
-- purchased checks for the AP item it grants, and the GetMetaUpgradePurchasePrice in there will also be replaced with a new cost check