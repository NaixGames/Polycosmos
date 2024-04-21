ModUtil.Mod.Register( "PolycosmosKeepsakeManager" )


local cacheNPCName=""

--------------------------------------

local KeepsakeDataTable =
{
    CerberusKeepsake = {
        ClientName = "CerberusKeepsake",
        HadesName = "NPC_Cerberus_01", 
        NPCName = "Cerberus"
    },
    AchillesKeepsake = {
        ClientName = "AchillesKeepsake",
        HadesName = "NPC_Achilles_01",
        NPCName = "Achilles"
    },
    NyxKeepsake = {
        ClientName = "NyxKeepsake",
        HadesName = "NPC_Nyx_01",
        NPCName = "Nyx"
    },
    ThanatosKeepsake = {
        ClientName = "ThanatosKeepsake",
        HadesName = "NPC_Thanatos_01",
        NPCName = "Thanatos"
    },
    CharonKeepsake = {
        ClientName = "CharonKeepsake",
        HadesName = "NPC_Charon_01",
        NPCName = "Charon"
    },
    HypnosKeepsake = {
        ClientName = "HypnosKeepsake",
        HadesName = "NPC_Hypnos_01",
        NPCName = "Hypnos"
    },
    MegaeraKeepsake = {
        ClientName = "MegaeraKeepsake",
        HadesName = "NPC_FurySister_01",
        NPCName = "Megaera"
    },
    OrpheusKeepsake = {
        ClientName = "OrpheusKeepsake",
        HadesName = "NPC_Orpheus_01",
        NPCName = "Orpheus"
    },
    DusaKeepsake = {
        ClientName = "DusaKeepsake",
        HadesName = "NPC_Dusa_01",
        NPCName = "Dusa"
    },
    SkellyKeepsake = {
        ClientName = "SkellyKeepsake",
        HadesName = "NPC_Skelly_01",
        NPCName = "Skelly"
    },
    ZeusKeepsake = {
        ClientName = "ZeusKeepsake",
        HadesName = "ZeusUpgrade",
        MeetLine = "ZeusFirstPickUp",
        NPCName = "Zeus"
    },
    PoseidonKeepsake = {
        ClientName = "PoseidonKeepsake",
        HadesName = "PoseidonUpgrade",
        MeetLine = "PoseidonFirstPickUp",
        NPCName = "Poseidon"
    },
    AthenaKeepsake = {
        ClientName = "AthenaKeepsake",
        HadesName = "AthenaUpgrade",
        MeetLine = "AthenaFirstPickUp",
        NPCName = "Athena"
    },
    AphroditeKeepsake = {
        ClientName = "AphroditeKeepsake",
        HadesName = "AphroditeUpgrade",
        MeetLine = "AphroditeFirstPickUp",
        NPCName = "Aphrodite"
    },
    AresKeepsake = {
        ClientName = "AresKeepsake",
        HadesName = "AresUpgrade",
        MeetLine = "AresFirstPickUp",
        NPCName = "Ares"
    },
    ArtemisKeepsake = {
        ClientName = "ArtemisKeepsake",
        HadesName = "ArtemisUpgrade",
        MeetLine = "ArtemisFirstPickUp",
        NPCName = "Artemis"
    },
    DionysusKeepsake = {
        ClientName = "DionysusKeepsake",
        HadesName = "DionysusUpgrade",
        MeetLine = "DionysusFirstPickUp",
        NPCName = "Dionysus"
    },
    HermesKeepsake = {
        ClientName = "HermesKeepsake",
        HadesName = "HermesUpgrade",
        NPCName = "Hermes"
    },
    DemeterKeepsake = {
        ClientName = "DemeterKeepsake",
        HadesName = "DemeterUpgrade",
        NPCName = "Demeter"
    },
    ChaosKeepsake = {
        ClientName = "ChaosKeepsake",
        HadesName = "TrialUpgrade",
        MeetLine = "ChaosFirstPickUp",
        NPCName = "Chaos"
    },
    SisyphusKeepsake = {
        ClientName = "SisyphusKeepsake",
        HadesName = "NPC_Sisyphus_01",
        NPCName = "Sisyphus"
    },
    EurydiceKeepsake = {
        ClientName = "EurydiceKeepsake",
        HadesName = "NPC_Eurydice_01",
        NPCName = "Eurydice"
    },
    PatroclusKeepsake = {
        ClientName = "PatroclusKeepsake",
        HadesName = "NPC_Patroclus_01",
        NPCName = "Patroclus"
    },
}

--------------------------------------



-------------------- Auxiliary function for checking if a item is a keepsake
function PolycosmosKeepsakeManager.IsKeepsakeItem(string)
    if (KeepsakeDataTable[string]==nil) then
        return false
    end
    return true
end

-----------------------


function PolycosmosKeepsakeManager.GiveKeepsakeItem(item)
    -- There should not be ANY scenario in which we call this before the data is loaded, so I will assume the datain Root is always updated
    if GameState.ClientGameSettings["KeepsakeSanity"] == 0 then
        return
    end

    gameNPCName = KeepsakeDataTable[item].HadesName

    if (GameState.Gift[gameNPCName].Value>0) then
        return
    end

    --Give first line of text to avoid blocking fated list. This can take a LONG while if you dont do this.
    if (KeepsakeDataTable[item].MeetLine) then
        TextLinesRecord[KeepsakeDataTable[item].MeetLine] = true
    end

    PolycosmosKeepsakeManager.IncrementGift(gameNPCName)

    PolycosmosMessages.PrintToPlayer("Recieved keepsake "..item)
    
    SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
    ValidateCheckpoint({ Valid = true })

    Save()
end

function PolycosmosKeepsakeManager.IncrementGift(npcName)
    -- Recreating this function to avoid a loop when wrapping.
    GameState.Gift[npcName].Value = 1

    --- this is some testing to see if we can fix codex
    SelectCodexEntry( npcName )
	IncrementTableValue( GameState.NPCInteractions, npcName )
	CheckCodexUnlock( "OlympianGods", npcName )
	CheckCodexUnlock( "ChthonicGods", npcName )
	CheckCodexUnlock( "OtherDenizens", npcName )

    if HasCodexEntry( name ) then
        thread( ShowCodexUpdate, { Animation = "CodexHeartUpdateIn" })
    end
end

---- wrapping for locations of keepsake

-- Wrapper for location checks
ModUtil.Path.Wrap("IncrementGiftMeter", function (baseFunc, npcName, amount)
    if GameState.ClientGameSettings["KeepsakeSanity"] == 0 then
        return baseFunc(npcName, amount)
    end
    
    if not PolycosmosKeepsakeManager.GetClientNameFromHadesName(npcName) then
        return baseFunc(npcName, amount)
    end

    PolycosmosEvents.ProcessLocationCheck(cacheNPCName, true)

    -- only send the first level of friendship (ie, keepsake unlock). This should allow to upgrade friendship level after having the corresponding keepsake
    if (GameState.Gift[npcName].Value>0) then
        return baseFunc(npcName, amount)
    end
end)

function PolycosmosKeepsakeManager.GetClientNameFromHadesName(npcName)
    for npcTag, npcData in pairs(KeepsakeDataTable) do
        if (npcData.HadesName == npcName) then
            cacheNPCName = npcData.ClientName
            return true
        end
    end
    return false
end


function PolycosmosKeepsakeManager.GetNpcNameFromHadesName(npcName)
    for npcTag, npcData in pairs(KeepsakeDataTable) do
        if (npcData.HadesName == npcName) then
            return npcData.NPCName
        end
    end
    return ""
end

function PolycosmosKeepsakeManager.GiveNumberOfKeesakes()
    numberKeepsakes = 0
    for nameKey, nameData in pairs(KeepsakeDataTable) do
        if (GameState.Gift[nameData.HadesName].Value>0) then
            numberKeepsakes = numberKeepsakes + 1
        end
    end
    return numberKeepsakes
end

-- What follows is to make codex tell you if a particular npc still needs their nectar for a check or not.

ModUtil.Path.Wrap("CodexOpenEntry", function (baseFunc, screen, button)
    if GameState.ClientGameSettings["KeepsakeSanity"] == 0 then
        return baseFunc(screen, button)
    end

    return CodexOpenEntryOverride(screen, button)
end)


function PolycosmosKeepsakeManager.GiveCorrectedCodexName(codexEntry)
    if (not PolycosmosKeepsakeManager.GetClientNameFromHadesName(codexEntry)) then
        return codexEntry
    end

    local npcLocationName = cacheNPCName

    if (PolycosmosEvents.HasLocationBeenChecked( npcLocationName )) then
        return codexEntry
    end

    return PolycosmosKeepsakeManager.GetNpcNameFromHadesName(codexEntry).."(Missing Nectar Check)"
end


function CodexOpenEntryOverride( screen, button )
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

    local fixedText = PolycosmosKeepsakeManager.GiveCorrectedCodexName(button.EntryName)

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
