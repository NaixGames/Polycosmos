ModUtil.Mod.Register( "PolycosmosKeepsakeManager" )


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
    print("Giving keepsake item with "..item)

    if not StyxScribeShared.Root.GameSettings["KeepsakeSanity"] then
        print("Keepsakenity is off!")
        print(StyxScribeShared.Root.GameSettings["KeepsakeSanity"])
        return
    end

    gameNPCName = KeepsakeDataTable[item].HadesName

    if (GameState.Gift[gameNPCName].Value>0) then
        print("Already friend of npc, ignoring")
        return
    end

    print("STARTING GIVING ROUTINE")

    PolycosmosKeepsakeManager.IncrementGift(gameNPCName)

    PolycosmosMessages.PrintToPlayer("Recieved keepsake "..item)
    
    SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
    ValidateCheckpoint({ Valid = true })

    Save()
end

function PolycosmosKeepsakeManager.IncrementGift(npcName)
    -- Recreating this function to avoid a loop when wrapping.
    GameState.Gift[npcName].Value = GameState.Gift[npcName].Value + 1
	if GiftData[npcName] and GiftData[npcName].InfiniteGifts and GameState.Gift[npcName].Value == GetMaxGiftLevel(name) then
		GameState.Gift[npcName].Value = 1
	end
end

---- wrapping for locations of keepsake

-- Wrapper for room completion
ModUtil.Path.Wrap("IncrementGiftMeter", function (baseFunc, npcName, amount)
    if not StyxScribeShared.Root.GameSettings["KeepsakeSanity"] then
        return baseFunc(npcName, amount)
    end
    -- only send the first level of friendship (ie, keepsake unlock). This should allow to upgrade friendship level after having the corresponding keepsake
    if (GameState.Gift[npcName].Value>0) then
        return baseFunc(npcName, amount)
    end
    PolycosmosKeepsakeManager.HandleKeepsakeLocation(npcName)
end)

function PolycosmosKeepsakeManager.HandleKeepsakeLocation(npcName)
    npcClientName = PolycosmosKeepsakeManager.GetClientNameFromHadesName(npcName)
    StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..npcClientName)
    itemObtained = StyxScribeShared.Root.LocationToItemMap[npcClientName]
    PolycosmosMessages.PrintToPlayer("Obtained "..itemObtained)
end

function PolycosmosKeepsakeManager.GetClientNameFromHadesName(npcName)
    for npcTag, npcData in pairs(KeepsakeDataTable) do
        if (npcData.HadesName == npcName) then
            return npcData.ClientName
        end
    end
end