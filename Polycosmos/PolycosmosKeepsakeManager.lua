ModUtil.Mod.Register( "PolycosmosKeepsakeManager" )


--------------------------------------

local KeepsakeDataTable =
{
    CerberusKeepsake = {
        ClientName = "Cerberus Keepsake",
        HadesName = "NPC_Cerberus_01", 
        NPCName = "Cerberus"
    },
    AchillesKeepsake = {
        ClientName = "Achilles Keepsake",
        HadesName = "NPC_Achilles_01",
        NPCName = "Achilles"
    },
    NyxKeepsake = {
        ClientName = "Nyx Keepsake",
        HadesName = "NPC_Nyx_01",
        NPCName = "Nyx"
    },
    ThanatosKeepsake = {
        ClientName = "Thanatos Keepsake",
        HadesName = "NPC_Thanatos_01",
        NPCName = "Thanatos"
    },
    CharonKeepsake = {
        ClientName = "Charon Keepsake",
        HadesName = "NPC_Charon_01",
        NPCName = "Charon"
    },
    HypnosKeepsake = {
        ClientName = "Hypnos Keepsake",
        HadesName = "NPC_Hypnos_01",
        NPCName = "Hypnos"
    },
    MegaeraKeepsake = {
        ClientName = "Megaera Keepsake",
        HadesName = "NPC_FurySister_01",
        NPCName = "Megaera"
    },
    OrpheusKeepsake = {
        ClientName = "Orpheus Keepsake",
        HadesName = "NPC_Orpheus_01",
        NPCName = "Orpheus"
    },
    DusaKeepsake = {
        ClientName = "Dusa Keepsake",
        HadesName = "NPC_Dusa_01",
        NPCName = "Dusa"
    },
    SkellyKeepsake = {
        ClientName = "Skelly Keepsake",
        HadesName = "NPC_Skelly_01",
        NPCName = "Skelly"
    },
    ZeusKeepsake = {
        ClientName = "Zeus Keepsake",
        HadesName = "ZeusUpgrade",
        MeetLine = "ZeusFirstPickUp",
        NPCName = "Zeus"
    },
    PoseidonKeepsake = {
        ClientName = "Poseidon Keepsake",
        HadesName = "PoseidonUpgrade",
        MeetLine = "PoseidonFirstPickUp",
        NPCName = "Poseidon"
    },
    AthenaKeepsake = {
        ClientName = "Athena Keepsake",
        HadesName = "AthenaUpgrade",
        MeetLine = "AthenaFirstPickUp",
        NPCName = "Athena"
    },
    AphroditeKeepsake = {
        ClientName = "Aphrodite Keepsake",
        HadesName = "AphroditeUpgrade",
        MeetLine = "AphroditeFirstPickUp",
        NPCName = "Aphrodite"
    },
    AresKeepsake = {
        ClientName = "Ares Keepsake",
        HadesName = "AresUpgrade",
        MeetLine = "AresFirstPickUp",
        NPCName = "Ares"
    },
    ArtemisKeepsake = {
        ClientName = "Artemis Keepsake",
        HadesName = "ArtemisUpgrade",
        MeetLine = "ArtemisFirstPickUp",
        NPCName = "Artemis"
    },
    DionysusKeepsake = {
        ClientName = "Dionysus Keepsake",
        HadesName = "DionysusUpgrade",
        MeetLine = "DionysusFirstPickUp",
        NPCName = "Dionysus"
    },
    HermesKeepsake = {
        ClientName = "Hermes Keepsake",
        HadesName = "HermesUpgrade",
        NPCName = "Hermes"
    },
    DemeterKeepsake = {
        ClientName = "Demeter Keepsake",
        HadesName = "DemeterUpgrade",
        NPCName = "Demeter"
    },
    ChaosKeepsake = {
        ClientName = "Chaos Keepsake",
        HadesName = "TrialUpgrade",
        MeetLine = "ChaosFirstPickUp",
        NPCName = "Chaos"
    },
    SisyphusKeepsake = {
        ClientName = "Sisyphus Keepsake",
        HadesName = "NPC_Sisyphus_01",
        NPCName = "Sisyphus"
    },
    EurydiceKeepsake = {
        ClientName = "Eurydice Keepsake",
        HadesName = "NPC_Eurydice_01",
        NPCName = "Eurydice"
    },
    PatroclusKeepsake = {
        ClientName = "Patroclus Keepsake",
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

    PolycosmosMessages.PrintToPlayer("Received keepsake "..item)
    
    if (CurrentRun ~= nil) then
        SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
        ValidateCheckpoint({ Valid = true })
    end

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
    -- Add dialogue line to avoid annoying issues with some gods
    if (PolycosmosKeepsakeManager.GetMeetlineFromHadesName(npcName)) then
        TextLinesRecord[PolycosmosKeepsakeManager.GetMeetlineFromHadesName(npcName)] = true
    end

    if GameState.ClientGameSettings["KeepsakeSanity"] == 0 then
        return baseFunc(npcName, amount)
    end
    
    local cacheNPCName = PolycosmosKeepsakeManager.GetClientNameFromHadesName(npcName)

    if not cacheNPCName then
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
            return npcData.ClientName
        end
    end
    return nil
end


function PolycosmosKeepsakeManager.GetNpcNameFromHadesName(npcName)
    for npcTag, npcData in pairs(KeepsakeDataTable) do
        if (npcData.HadesName == npcName) then
            return npcData.NPCName
        end
    end
    return ""
end

function PolycosmosKeepsakeManager.GetMeetlineFromHadesName(npcName)
    for npcTag, npcData in pairs(KeepsakeDataTable) do
        if (npcData.HadesName == npcName) then
            return npcData.MeetLine
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



