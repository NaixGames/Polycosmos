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
    },
    PoseidonKeepsake = {
        ClientName = "PoseidonKeepsake",
        HadesName = "PoseidonUpgrade",
    },
    AthenaKeepsake = {
        ClientName = "AthenaKeepsake",
        HadesName = "AthenaUpgrade",
    },
    AphroditeKeepsake = {
        ClientName = "AphroditeKeepsake",
        HadesName = "AphroditeUpgrade",
    },
    AresKeepsake = {
        ClientName = "AresKeepsake",
        HadesName = "AresUpgrade",
    },
    ArtemisKeepsake = {
        ClientName = "ArtemisKeepsake",
        HadesName = "ArtemisUpgrade",
    },
    DionysusKeepsake = {
        ClientName = "DionysusKeepsake",
        HadesName = "DionysusUpgrade",
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
    if StyxScribeShared.Root.GameSettings["KeepsakeSanity"]==0 then
        return
    end

    gameNPCName = KeepsakeDataTable[item].HadesName

    if (GameState.Gift[gameNPCName].Value>0) then
        return
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
    if GiftData[npcName] and GiftData[npcName].InfiniteGifts and GameState.Gift[npcName].Value == GetMaxGiftLevel(name) then
		GameState.Gift[npcName].Value = 1
	end
end

---- wrapping for locations of keepsake

-- Wrapper for location checks
ModUtil.Path.Wrap("IncrementGiftMeter", function (baseFunc, npcName, amount)
    if StyxScribeShared.Root.GameSettings["KeepsakeSanity"]==0 then
        return baseFunc(npcName, amount)
    end
    -- only send the first level of friendship (ie, keepsake unlock). This should allow to upgrade friendship level after having the corresponding keepsake
    
    if not PolycosmosKeepsakeManager.GetClientNameFromHadesName(npcName) then
        return baseFunc(npcName, amount)
    end

    PolycosmosKeepsakeManager.HandleKeepsakeLocation(npcName)

    if (GameState.Gift[npcName].Value>0) then
        return baseFunc(npcName, amount)
    end
end)



function PolycosmosKeepsakeManager.HandleKeepsakeLocation(npcName)
    npcClientName = cacheNPCName
    if (PolycosmosEvents.HasLocationBeenChecked(npcClientName)) then
        return
    end
    StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..npcClientName)
    itemObtained =  PolycosmosEvents.GiveItemInLocation(npcClientName)
    PolycosmosMessages.PrintToPlayer("Obtained "..itemObtained)
end

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
        if (GameState.Gift[nameData].HadesName.Value>0) then
            numberKeepsakes = numberKeepsakes + 1
        end
    end
    return numberKeepsakes
end