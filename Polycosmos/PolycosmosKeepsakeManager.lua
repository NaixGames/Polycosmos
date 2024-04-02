ModUtil.Mod.Register( "PolycosmosKeepsakeManager" )


local cacheNPCName=""

--------------------------------------

local KeepsakeDataTable =
{
    CerberusKeepsake = {
        ClientName = "CerberusKeepsake",
        HadesName = "NPC_Cerberus_01", 
    },
    AchillesKeepsake = {
        ClientName = "AchillesKeepsake",
        HadesName = "NPC_Achilles_01",
    },
    NyxKeepsake = {
        ClientName = "NyxKeepsake",
        HadesName = "NPC_Nyx_01",
    },
    ThanatosKeepsake = {
        ClientName = "ThanatosKeepsake",
        HadesName = "NPC_Thanatos_01",
    },
    CharonKeepsake = {
        ClientName = "CharonKeepsake",
        HadesName = "NPC_Charon_01",
    },
    HypnosKeepsake = {
        ClientName = "HypnosKeepsake",
        HadesName = "NPC_Hypnos_01",
    },
    MegaeraKeepsake = {
        ClientName = "MegaeraKeepsake",
        HadesName = "NPC_FurySister_01",
    },
    OrpheusKeepsake = {
        ClientName = "OrpheusKeepsake",
        HadesName = "NPC_Orpheus_01",
    },
    DusaKeepsake = {
        ClientName = "DusaKeepsake",
        HadesName = "NPC_Dusa_01",
    },
    SkellyKeepsake = {
        ClientName = "SkellyKeepsake",
        HadesName = "NPC_Skelly_01",
    },
    ZeusKeepsake = {
        ClientName = "ZeusKeepsake",
        HadesName = "ZeusUpgrade",
        MeetLine = "ZeusFirstPickUp",
    },
    PoseidonKeepsake = {
        ClientName = "PoseidonKeepsake",
        HadesName = "PoseidonUpgrade",
        MeetLine = "PoseidonFirstPickUp",
    },
    AthenaKeepsake = {
        ClientName = "AthenaKeepsake",
        HadesName = "AthenaUpgrade",
        MeetLine = "AthenaFirstPickUp",
    },
    AphroditeKeepsake = {
        ClientName = "AphroditeKeepsake",
        HadesName = "AphroditeUpgrade",
        MeetLine = "AphroditeFirstPickUp",
    },
    AresKeepsake = {
        ClientName = "AresKeepsake",
        HadesName = "AresUpgrade",
        MeetLine = "AresFirstPickUp",
    },
    ArtemisKeepsake = {
        ClientName = "ArtemisKeepsake",
        HadesName = "ArtemisUpgrade",
        MeetLine = "ArtemisFirstPickUp",
    },
    DionysusKeepsake = {
        ClientName = "DionysusKeepsake",
        HadesName = "DionysusUpgrade",
        MeetLine = "DionysusFirstPickUp",
    },
    HermesKeepsake = {
        ClientName = "HermesKeepsake",
        HadesName = "HermesUpgrade",
    },
    DemeterKeepsake = {
        ClientName = "DemeterKeepsake",
        HadesName = "DemeterUpgrade",
    },
    ChaosKeepsake = {
        ClientName = "ChaosKeepsake",
        HadesName = "TrialUpgrade",
        MeetLine = "ChaosFirstPickUp",
    },
    SisyphusKeepsake = {
        ClientName = "SisyphusKeepsake",
        HadesName = "NPC_Sisyphus_01",
    },
    EurydiceKeepsake = {
        ClientName = "EurydiceKeepsake",
        HadesName = "NPC_Eurydice_01",
    },
    PatroclusKeepsake = {
        ClientName = "PatroclusKeepsake",
        HadesName = "NPC_Patroclus_01",
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


function PolycosmosKeepsakeManager.GiveNumberOfKeesakes()
    numberKeepsakes = 0
    for nameKey, nameData in pairs(KeepsakeDataTable) do
        if (GameState.Gift[nameData.HadesName].Value>0) then
            numberKeepsakes = numberKeepsakes + 1
        end
    end
    return numberKeepsakes
end