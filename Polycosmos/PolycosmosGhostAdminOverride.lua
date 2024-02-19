ModUtil.Mod.Register( "PolycosmosGhostAdminOverride" )

------------ Setup of high level weapon system

ModUtil.Path.Wrap( "DisplayCosmetics", function(baseFunc, screen, slotName)
        return PolycosmosGhostAdminOverride.DisplayCosmeticsOverride(screen, slotName)
end)


function PolycosmosGhostAdminOverride.GiveAPItemAtLocation(locationName)
    return PolycosmosEvents.GiveItemInLocation(locationName)
end



function PolycosmosGhostAdminOverride.DisplayCosmeticsOverride( screen, slotName )

	local components = screen.Components

	ModifyTextBox({ Id = components["Category"..slotName].Id, Color = Color.White })
	DestroyTextBox({ Id = components.ShopBackgroundDim.Id })

	local newButtonKey = "NewIcon"..slotName
	if components[newButtonKey] ~= nil then
		SetAlpha({ Id = components[newButtonKey].Id, Fraction = 0.0 })
	end

	screen.ActiveCategory = slotName

	local itemLocationX = screen.ItemStartX
	local itemLocationY = screen.ItemStartY

	local availableItems = {}
	local purchasedItems = {}

	for cosmeticName, cosmeticData in pairs( ConditionalItemData ) do
		if not cosmeticData.DebugOnly and cosmeticData.ResourceCost ~= nil and not cosmeticData.Disabled then
			if cosmeticData.GameStateRequirements == nil or IsGameStateEligible( CurrentRun, cosmeticData, cosmeticData.GameStateRequirements ) then
				if GameState.CosmeticsAdded[cosmeticName] then
					purchasedItems[cosmeticData.Slot] = purchasedItems[cosmeticData.Slot] or {}
					table.insert( purchasedItems[cosmeticData.Slot], cosmeticData )
				else

					availableItems[cosmeticData.Slot] = availableItems[cosmeticData.Slot] or {}
					table.insert( availableItems[cosmeticData.Slot], cosmeticData )
				end
			end
		end
	end
	for trackName, trackData in pairs( MusicPlayerTrackData ) do
		if not trackData.DebugOnly and trackData.ResourceCost ~= nil then
			if GameState.CosmeticsAdded[trackData.Name] then
				purchasedItems.Music = purchasedItems.Music or {}
				table.insert( purchasedItems.Music, trackData )
			else
				if trackData.GameStateRequirements == nil or IsGameStateEligible( CurrentRun, trackData, trackData.GameStateRequirements ) then
					availableItems.Music = availableItems.Music or {}
					table.insert( availableItems.Music, trackData )
				end
			end
		end
	end

	screen.NumItems = 0
	screen.NumItemsPurchaseable = 0
	screen.NumItemsAffordable = 0

	local firstUseable = false

	-- Available
	local itemsToDisplay = availableItems[slotName] or {}
	table.sort( itemsToDisplay, CosmeticItemSort )
	for k, cosmetic in ipairs( itemsToDisplay ) do

		screen.NumItems = screen.NumItems + 1
		screen.NumItemsPurchaseable = screen.NumItemsPurchaseable + 1
		if HasResource( cosmetic.ResourceName, cosmetic.ResourceCost ) then
			screen.NumItemsAffordable = screen.NumItemsAffordable + 1
		end

		screen.OfferedVoiceLines = screen.OfferedVoiceLines or cosmetic.OfferedVoiceLines

		local purchaseButtonKey = "PurchaseButton"..screen.NumItems
		components[purchaseButtonKey] = CreateScreenComponent({ Name = "ButtonGhostAdminItem", Group = "Combat_Menu", Scale = 1, X = itemLocationX, Y = itemLocationY })
		components[purchaseButtonKey].OnMouseOverFunctionName = "MouseOverGhostAdminItem"
		AttachLua({ Id = components[purchaseButtonKey].Id, Table = components[purchaseButtonKey] })
		SetInteractProperty({ DestinationId = components[purchaseButtonKey].Id, Property = "TooltipOffsetX", Value = 665 })

		local purchaseButtonTitleKey = "PurchaseButtonTitle"..screen.NumItems
		components[purchaseButtonTitleKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu", Scale = 1, X = itemLocationX, Y = itemLocationY })

		if cosmetic.Icon ~= nil then
			local iconKey = "Icon"..screen.NumItems
			components[iconKey] = CreateScreenComponent({ Name = "BlankObstacle", X = itemLocationX, Y = itemLocationY, Scale = 0.5, Group = "Combat_Menu" })
			SetAnimation({ DestinationId = components[iconKey].Id , Name = cosmetic.Icon })
		end

		local name = cosmetic.Name
		for trackName, trackData in pairs( MusicPlayerTrackData ) do
			if trackData.Name == name then
				name = GetMusicTrackTitle( name )
				break
			end
		end

		local displayName = name

		local resourceData = ResourceData[cosmetic.ResourceName]
		local costString = resourceData.IconPath
		costString = cosmetic.ResourceCost.." @"..costString
		local costColor = Color.CostAffordableShop
		if not HasResource( cosmetic.ResourceName, cosmetic.ResourceCost ) then
			costColor = Color.CostUnaffordable
		end

		-------------------------------------------------
		-------------------THIS IS THE NEW BIT TO SHOW DIFFERENT ITEMS FOR AP
		-------------------------------------------------

		if (PolycosmosWeaponManager.IsWeaponLocation(displayName.."Location") == true ) then
			Title = PolycosmosGhostAdminOverride.GiveAPItemAtLocation(displayName.."Location")
		else
			Title = displayName
		end

		print(Title)

		-------------------------------------------------
		-------------------THIS ENDS THE NEW BIT TO SHOW DIFFERENT ITEMS FOR AP
		-------------------------------------------------

		-- Title
		CreateTextBox(MergeTables({ Id = components[purchaseButtonTitleKey].Id,
			Text = Title, --We can override the title here to show another item!
			OffsetX = -355,
			OffsetY = -20,
			FontSize = 24,
			Width = 720,
			Color = costColor,
			Font = "AlegreyaSansSCBold",
			ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
			Justification = "Left",
			DataProperties =
			{
				OpacityWithOwner = true,
			},
		}, LocalizationData.GhostAdminScreen.CosmeticTitle ))

		-- Cost
		CreateTextBox(MergeTables({ Id = components[purchaseButtonTitleKey].Id, Text = costString,
			OffsetX = 430,
			OffsetY = 0,
			FontSize = 28,
			Color = costColor,
			Font = "AlegreyaSansSCBold",
			Justification = "Right",
			DataProperties =
			{
				OpacityWithOwner = true,
			},
		}, LocalizationData.GhostAdminScreen.CosmeticCost ))

		-- Description
		CreateTextBoxWithFormat(MergeTables({ Id = components[purchaseButtonKey].Id,
			Text = displayName,
			OffsetX = -355,
			OffsetY = -4,
			Format = "BaseFormat",
			UseDescription = true,
			VariableAutoFormat = "BoldFormatGraft",
			LuaKey = "TooltipData",
			LuaValue = cosmetic,
			Justification = "Left",
			VerticalJustification = "Top",
			LineSpacingBottom = 0,
			Width = 615,
			FontSize = 16,
			DataProperties =
			{
				OpacityWithOwner = true,
			},
		}, LocalizationData.GhostAdminScreen.CosmeticDescription))

		components[purchaseButtonKey].OnPressedFunctionName = "HandleGhostAdminPurchase"
		if not firstUseable then
			TeleportCursor({ OffsetX = itemLocationX, OffsetY = itemLocationY, ForceUseCheck = true })
			firstUseable = true
		end

		components[purchaseButtonKey].Data = cosmetic
		components[purchaseButtonKey].Index = screen.NumItems
		components[purchaseButtonKey].TitleId = components[purchaseButtonTitleKey].Id
		components[purchaseButtonKey].DisplayName = name

		if not GameState.CosmeticsViewed[cosmetic.Name] then
			-- New icon
			local newButtonKey = "NewIcon"..screen.NumItems
			components[newButtonKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu" })
			SetAnimation({ DestinationId = components[newButtonKey].Id , Name = "MusicPlayerNewTrack" })
			Attach({ Id = components[newButtonKey].Id, DestinationId = components[purchaseButtonKey].Id, OffsetX = -430, OffsetY = 0 })
			components[purchaseButtonKey].NewButtonId = components[newButtonKey].Id
		end

		itemLocationY = itemLocationY + screen.EntryYSpacer

	end

	-- Purchased
	local itemsToDisplay = purchasedItems[slotName] or {}
	table.sort( itemsToDisplay, CosmeticItemSort )
	for k, cosmetic in ipairs( itemsToDisplay ) do

		screen.NumItems = screen.NumItems + 1

		local buttonName = "ButtonGhostAdminItem"
		if not cosmetic.Removable or ( cosmetic.RotateOnly and GameState.Cosmetics[cosmetic.Name] ) then
			buttonName = "ButtonGhostAdminItemDisabled"
		end

		local purchaseButtonKey = "PurchaseButton"..screen.NumItems
		components[purchaseButtonKey] = CreateScreenComponent({ Name = buttonName, Group = "Combat_Menu", Scale = 1.0, X = itemLocationX, Y = itemLocationY })
		SetInteractProperty({ DestinationId = components[purchaseButtonKey].Id, Property = "TooltipOffsetX", Value = 665 })

		local purchaseButtonTitleKey = "PurchaseButtonTitle"..screen.NumItems
		components[purchaseButtonTitleKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu", Scale = 1, X = itemLocationX, Y = itemLocationY })

		if cosmetic.Icon ~= nil then
			local iconKey = "Icon"..screen.NumItems
			components[iconKey] = CreateScreenComponent({ Name = "BlankObstacle", X = itemLocationX, Y = itemLocationY, Scale = 0.4, Group = "Combat_Menu" })
			SetAnimation({ DestinationId = components[iconKey].Id , Name = cosmetic.Icon })
		end

		local name = cosmetic.Name
		for trackName, trackData in pairs( MusicPlayerTrackData ) do
			if trackData.Name == name then
				name = GetMusicTrackTitle( name )
				break
			end
		end

		local titleColor = {0.5, 0.5, 0.5, 1.0}
		local displayName = cosmetic.RePurchaseName or name
		local costText = "Shop_Purchased"
		if cosmetic.Removable then
			if GameState.Cosmetics[name] then
				if not cosmetic.RotateOnly then
					components[purchaseButtonKey].OnPressedFunctionName = "HandleGhostAdminRemoval"
					--titleColor = Color.CostAffordableShop
					costText = "Shop_Removable"
				end
			else
				components[purchaseButtonKey].Free = true
				components[purchaseButtonKey].OnPressedFunctionName = "HandleGhostAdminPurchase"
				--titleColor = Color.CostAffordableShop
				costText = "Shop_ReAdd"
			end
		end

		-- Title
		CreateTextBox(MergeTables({ Id = components[purchaseButtonTitleKey].Id,
			Text = displayName,
			OffsetX = -355,
			OffsetY = -22,
			FontSize = 24,
			Width = 720,
			Color = titleColor,
			Font = "AlegreyaSansSCRegular",
			ShadowBlur = 0, ShadowColor = {0,0,0,0}, ShadowOffset={0, 2},
			Justification = "Left",
			DataProperties =
			{
				OpacityWithOwner = true,
			},
		}, LocalizationData.GhostAdminScreen.CosmeticTitle ))

		-- Cost
		CreateTextBox(MergeTables({ Id = components[purchaseButtonTitleKey].Id,
			Text = costText,
			OffsetX = 430,
			OffsetY = 0,
			FontSize = 28,
			Color = Color.White,
			Font = "AlegreyaSansSCBold",
			Justification = "Right",
			DataProperties =
			{
				OpacityWithOwner = true,
			},
		}, LocalizationData.GhostAdminScreen.CosmeticCost ))

		-- Description
		CreateTextBoxWithFormat(MergeTables({ Id = components[purchaseButtonKey].Id,
			Text = displayName,
			OffsetX = -355,
			OffsetY = -4,
			Format = "BaseFormat",
			UseDescription = true,
			VariableAutoFormat = "BoldFormatGraft",
			LuaKey = "TooltipData",
			LuaValue = cosmetic,
			Justification = "Left",
			VerticalJustification = "Top",
			LineSpacingBottom = 0,
			Width = 615,
			FontSize = 16,
			DataProperties =
			{
				OpacityWithOwner = true,
			},
		}, LocalizationData.GhostAdminScreen.CosmeticDescription))

		if not firstUseable then
			TeleportCursor({ OffsetX = itemLocationX, OffsetY = itemLocationY, ForceUseCheck = true })
			firstUseable = true
		end

		components[purchaseButtonKey].Data = cosmetic
		components[purchaseButtonKey].Index = screen.NumItems
		components[purchaseButtonKey].TitleId = components[purchaseButtonTitleKey].Id
		components[purchaseButtonKey].DisplayName = name

		itemLocationY = itemLocationY + screen.EntryYSpacer

	end

	GhostAdminPostDisplayCategoryPresentation( screen )
end