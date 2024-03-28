ModUtil.Mod.Register( "PolycosmosItemManager" )


-- for the future for reference of filler items: MetaPoints are darkness, Gems is gemstones, SuperGems are diamonds, LockKeys are keys, SuperLockKeys are titan's blood, GiftPoints are nectar, SuperGiftPoints are ambrosia

--Sadly I need to put this buffer in case hades request some data before the Shared state is updated.
local bufferTime = 2

local ItemsDataArray=
{
    "Darkness",
    "Keys",
    "Gemstones",
    "Diamonds",
    "TitanBlood",
    "Nectar",
    "Ambrosia",
}

local KeysPackValue = 15
local DarknessPackValue = 500
local GemstonesPackValue = 100
local DiamondsPackValue = 15
local TitanBloodPackValue = 3
local NectarPackValue = 3
local AmbrosiaPackValue = 3

local valueLoaded = false


local KeyRequests = 0
local DarknessRequests = 0
local GemstonesRequests = 0
local DiamondsRequests = 0
local TitanBloodRequests = 0
local NectarRequests = 0
local AmbrosiaRequests = 0

-------------------- Auxiliary function for checking if a item is a filler item
function PolycosmosItemManager.IsFillerItem(string)
    return PolycosmosUtils.HasValue(ItemsDataArray, string)
end

--------------------

function PolycosmosItemManager.GiveFillerItem(item)
    if (item == "Keys") then
        KeyRequests = KeyRequests + 1
    end

    if (item == "Darkness") then
        DarknessRequests = DarknessRequests + 1
    end

    if (item == "Gemstones") then
        GemstonesRequests = GemstonesRequests + 1
    end

    if (item == "Diamonds") then
        DiamondsRequests = DiamondsRequests + 1
    end

    if (item == "TitanBlood") then
        TitanBloodRequests = TitanBloodRequests + 1
    end

    if (item == "Nectar") then
        NectarRequests = NectarRequests + 1
    end

    if (item == "Ambrosia") then
        AmbrosiaRequests = AmbrosiaRequests + 1
    end
end

--------------------

function PolycosmosItemManager.FlushAndProcessFillerItems()
    if (not valueLoaded) then
        if not StyxScribeShared.Root.FillerValues then
            wait( bufferTime )
            if not StyxScribeShared.Root.FillerValues then
                PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state for item manager. Enter and exit the save file again!")
                return
            end
        end

        DarknessPackValue = StyxScribeShared.Root.FillerValues['DarknessPackValue']
        KeysPackValue = StyxScribeShared.Root.FillerValues['KeysPackValue']
        GemstonesPackValue = StyxScribeShared.Root.FillerValues['GemstonesPackValue']
        DiamondsPackValue = StyxScribeShared.Root.FillerValues['DiamondsPackValue']
        TitanBloodPackValue = StyxScribeShared.Root.FillerValues['TitanBloodPackValue']
        NectarPackValue = StyxScribeShared.Root.FillerValues['NectarPackValue']
        AmbrosiaPackValue = StyxScribeShared.Root.FillerValues['AmbrosiaPackValue']

        valueLoaded = true
    end


    if (GameState.FillerItemLodger == nil) then
        GameState.FillerItemLodger = {}
        GameState.FillerItemLodger["Darkness"] = 0
        GameState.FillerItemLodger["Keys"] = 0
        GameState.FillerItemLodger["Gemstones"] = 0
        GameState.FillerItemLodger["Diamonds"] = 0
        GameState.FillerItemLodger["TitanBlood"] = 0
        GameState.FillerItemLodger["Nectar"] = 0
        GameState.FillerItemLodger["Ambrosia"] = 0
    end

    while (KeyRequests > GameState.FillerItemLodger["Keys"]) do
        PolycosmosItemManager.ProcessFillerItem("LockKeys", KeysPackValue, "Keys")
        GameState.FillerItemLodger["Keys"] = GameState.FillerItemLodger["Keys"] + 1
    end

    while (DarknessRequests > GameState.FillerItemLodger["Darkness"]) do
        PolycosmosItemManager.ProcessFillerItem("MetaPoints", DarknessPackValue, "Darkness")
        GameState.FillerItemLodger["Darkness"] = GameState.FillerItemLodger["Darkness"] + 1
    end

    while (GemstonesRequests > GameState.FillerItemLodger["Gemstones"]) do
        PolycosmosItemManager.ProcessFillerItem("Gems", GemstonesPackValue, "Gemstones")
        GameState.FillerItemLodger["Gemstones"] = GameState.FillerItemLodger["Gemstones"] + 1
    end

    while (DiamondsRequests > GameState.FillerItemLodger["Diamonds"]) do
        PolycosmosItemManager.ProcessFillerItem("SuperGems", DiamondsPackValue, "Diamonds")
        GameState.FillerItemLodger["Diamonds"] = GameState.FillerItemLodger["Diamonds"] + 1
    end
    
    while (TitanBloodRequests > GameState.FillerItemLodger["TitanBlood"]) do
        PolycosmosItemManager.ProcessFillerItem("SuperLockKeys", TitanBloodPackValue, "TitanBlood")
        GameState.FillerItemLodger["TitanBlood"] = GameState.FillerItemLodger["TitanBlood"] + 1
    end

    while (NectarRequests > GameState.FillerItemLodger["Nectar"]) do
        PolycosmosItemManager.ProcessFillerItem("GiftPoints", NectarPackValue, "Nectar")
        GameState.FillerItemLodger["Nectar"] = GameState.FillerItemLodger["Nectar"] + 1
    end

    while (AmbrosiaRequests > GameState.FillerItemLodger["Ambrosia"]) do
        PolycosmosItemManager.ProcessFillerItem("SuperGiftPoints", AmbrosiaPackValue, "Ambrosia")
        GameState.FillerItemLodger["Ambrosia"] = GameState.FillerItemLodger["Ambrosia"] + 1
    end

    KeyRequests = 0
    DarknessRequests = 0
    GemstonesRequests = 0
    DiamondsRequests = 0
    TitanBloodRequests = 0
    NectarRequests = 0
    AmbrosiaRequests = 0

    SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
    ValidateCheckpoint({ Valid = true })

    Save()
end

--------------------

function PolycosmosItemManager.ProcessFillerItem(internalItemName, packValue, name)
    AddResource(internalItemName, packValue)
    CurrentRun[internalItemName] = GameState.Resources[internalItemName]
    PolycosmosMessages.PrintToPlayer("Recieved a pack of "..packValue.." "..name)
end