ModUtil.Mod.Register( "PolycosmosCodexHelper" )



-- What follows is to make codex tell you if a particular npc still needs their nectar for a check or not.

ModUtil.Path.Wrap("CodexOpenEntry", function (baseFunc, screen, button)
	if not GameState.ClientDataIsLoaded then:
		return baseFunc(screen, button)

    if GameState.ClientGameSettings["KeepsakeSanity"] == 0 then
        return baseFunc(screen, button)
    end

    return PolycosmosCodexHelper.CodexOpenEntryOverride(screen, button)
end)



function PolycosmosCodexHelper.CodexOpenEntryOverride( screen, button )
	if not IsScreenOpen( "Codex" ) or IsScreenOpen("BoonInfoScreen") then
		return
	end

	if button.EntryName == CodexStatus.SelectedEntryNames[button.ChapterName] and screen.Components.EntryText ~= nil or not CodexStatus[button.ChapterName] or not CodexStatus[button.ChapterName][button.EntryName] then
		-- Already open
		return
	end
	CodexCloseEntry( screen, CodexStatus.SelectedEntryNames[button.ChapterName] )
	CodexStatus.SelectedEntryNames[button.ChapterName] = button.EntryName

	local chapterStatus = CodexStatus[button.ChapterName]
	chapterStatus[button.EntryName].New = false
	Destroy({ Id = screen.Components[button.EntryName].UnreadStarId })
	screen.Components[button.EntryName].UnreadStarId = nil

	ModifyTextBox({ Id = screen.Components[button.EntryName].Id, Color = selectedColor, Font = selectedFont })

	local entryTextOffsetY = 60
	if GameState.Gift[button.EntryName] == nil then
		-- no relationship bar for this entry
		entryTextOffsetY = 0
	end

	screen.Components.Image = CreateScreenComponent({ Name = "BlankObstacle", X = 670, Y = 616 + entryTextOffsetY, Scale = 1.0, Group = "Combat_Menu_Overlay" })
	SetAlpha({ Id = screen.Components.Image.Id, Fraction = 1 })
	if button.EntryData.Image ~= nil then
		SetAnimation({ DestinationId = screen.Components.Image.Id, Name = button.EntryData.Image })
	end

	screen.Components.EntryTitle = CreateScreenComponent({ Name = "BlankObstacle", X = 600, Y = 285, Group = "Combat_Menu_Overlay" })
	screen.Components.EntryText = CreateScreenComponent({ Name = "BlankObstacle", X = 770, Y = 370 + entryTextOffsetY, Group = "Combat_Menu_Overlay" })
	screen.Components.BoonInfoHint = CreateScreenComponent({ Name = "BlankObstacle", X = 770 + 800, Y = 930, Group = "Combat_Menu_Overlay" })
	CreateRelationshipBar( screen, button.EntryName )
	HandleRelationshipChanged( screen, button.ChapterName, button.EntryName )

	local text = ""
	local complete = true
	local threshold = 0
	local uniqueThresholdText = nil
	local currentUnlockAmount = GetCodexEntryAmount( button.ChapterName, button.EntryName ) or 0
	for index, unlockPortion in ipairs(button.EntryData.Entries) do
		if chapterStatus ~= nil and
			chapterStatus[button.EntryName] ~= nil and
			chapterStatus[button.EntryName][index] ~= nil then
				if chapterStatus[button.EntryName][index].Unlocked then
					text = GetDisplayName({ Text = unlockPortion.HelpTextId or unlockPortion.Text }) .. " "
					if Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockThreshold then
						currentUnlockAmount = currentUnlockAmount - Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockThreshold
					end
				elseif Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockGameStateRequirements and
					IsGameStateEligible( CurrentRun, Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockGameStateRequirements) then
						text = GetDisplayName({ Text = unlockPortion.HelpTextId or unlockPortion.Text }) .. " "
				end

		else
			-- displays next unlock threshold rather than final unlock threshold
			if Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockThreshold then
				threshold = Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockThreshold - currentUnlockAmount
				complete = false
				break
			elseif complete and Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockGameStateRequirements and not IsGameStateEligible( CurrentRun, Codex[button.ChapterName].Entries[button.EntryName].Entries[index].UnlockGameStateRequirements ) then
				uniqueThresholdText = Codex[button.ChapterName].Entries[button.EntryName].Entries[index].CustomUnlockText
				complete = false
			end
		end
	end

	local lang = GetLanguage({})
	if complete then
		if Contains(LocalizationData.CodexScripts.EntryCompleteSkipNewLines, lang) then
			text = text .. " " .. GetDisplayName({Text = "Codex_Complete"})
		else
			text = text .. " \\n " .. GetDisplayName({Text = "Codex_Complete"})
		end
	else
		if uniqueThresholdText then
			text = text .. " \\n " .. GetDisplayName({Text = uniqueThresholdText})
		else
			local unlockType = Codex[button.ChapterName].Entries[button.EntryName].UnlockType
			if unlockType == nil then
				unlockType = Codex[button.ChapterName].UnlockType
			end
			text = text .. " \\n " .. GetDisplayName({Text = "Codex_"..tostring(unlockType).."_Locked"})
		end
	end
	if threshold <= 0 then
		threshold = 1
	end

	CreateTextBox(MergeTables({
		Id = screen.Components.EntryText.Id,
		Text = text,
		Color = Color.CodexText,
		Font = "AlegreyaSansRegular",
		FontSize = 20,
		LuaKey = "TempTextData",
		LuaValue = { Amount = threshold, Name = button.EntryName},
		ShadowBlur = 0,
		ShadowColor = {0,0,0,1},
		ShadowOffset = {0, 2},
		Justification = "Left",
		VerticalJustification = "Top",
		Width = 820,
		LineSpacingBottom = 10,
	}, LocalizationData.CodexScripts.EntryText ))

	local codexNamePlateFont = "AlegreyaSansSCRegular"
	if lang == "ja" then
		codexNamePlateFont = "CaesarDressing" -- Maps to "Utsukushi" in Japanese
	end

    --THIS IS TO MAKE IT CODEX TELL YOU IF THE NPC NEEDS NECTAR

    local fixedText = PolycosmosCodexHelper.GiveCorrectedCodexName(button.EntryName)

	CreateTextBox({
		Id = screen.Components.EntryTitle.Id,
		Text = fixedText,
		FontSize = 38,
		Color = Color.Black,
		Font = codexNamePlateFont,
		ShadowColor = {0,0,0,0},
		Justification = "LEFT",
	})

	if  GameState.CosmeticsAdded.CodexBoonList and BoonInfoScreenData.SortedTraitIndex[button.EntryName] then

		screen.Components.BoonInfoTextBacking = CreateScreenComponent({ Name = "CodexBoonInfoTextBacking", X = 1450, Y = 930, Group = "Combat_Menu_Overlay" })

		CreateTextBox({
			Id = screen.Components.BoonInfoHint.Id,
			OffsetX = -125,
			Text = "Codex_BoonInfo",
			FontSize = 20,
			Color = Color.CodexText,
			Font = "AlegreyaSansSCRegular",
			ShadowColor = {0,0,0,0},
			Justification = "CENTER",
		})
	end

	TeleportCursor({ OffsetX = button.EntryXLocation, OffsetY = button.EntryYLocation, ForceUseCheck = true })
	SetConfigOption({ Name = "FreeFormSelecSearchFromId", Value = button.Id })

	UpdateChapterEntryArrows( screen )

	if button.EntryData.EntryReadVoiceLines ~= nil then
		thread( PlayVoiceLines, button.EntryData.EntryReadVoiceLines )
	end
end


function PolycosmosCodexHelper.GiveCorrectedCodexName(codexEntry)
	if (PolycosmosWeaponManager.IsWeaponItem(codexEntry.."UnlockItem")) then
		if (GetNumRunsClearedWithWeapon(codexEntry)>0) then
			return codexEntry.."(used for Hades defeat)"
		end
		return codexEntry.."(Hades defeat missing)"
	end

	local cacheNPCName = PolycosmosKeepsakeManager.GetClientNameFromHadesName(codexEntry)

	if (PolycosmosEvents.HasLocationBeenChecked( cacheNPCName )) then
        return codexEntry
    end

	if (cacheNPCName) then
		return PolycosmosKeepsakeManager.GetNpcNameFromHadesName(codexEntry).."(Missing Nectar Check)"
	end

	return codexEntry
end
