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

-------------------- Auxiliary function for checking if a item is a filler item
function PolycosmosItemManager.IsFillerItem(string)
    return PolycosmosUtils.HasValue(ItemsDataArray, string)
end

--------------------

function PolycosmosItemManager.GiveFillerItem(item)
    if (not valueLoaded) then
        if not StyxScribeShared.Root.FillerValues then
            PolycosmosEvents.LoadData()
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

    print(item)

    if (item == "Keys") then
        print("1")
        AddResource("LockKeys", KeysPackValue)
        CurrentRun.LockKeys = GameState.Resources.LockKeys
        PolycosmosMessages.PrintToPlayer("Recieved a pack of "..KeysPackValue.." Keys")
    end

    if (item == "Darkness") then
        print("2")
        AddResource("MetaPoints", DarknessPackValue)
        CurrentRun.MetaPoints = GameState.Resources.MetaPoints
        PolycosmosMessages.PrintToPlayer("Recieved a pack of "..DarknessPackValue.." Darkness")
    end

    if (item == "Gemstones") then
        print("3")
        AddResource("Gems", GemstonesPackValue)
        CurrentRun.Gems = GameState.Resources.Gems
        PolycosmosMessages.PrintToPlayer("Recieved a pack of "..GemstonesPackValue.." Gems")
    end

    if (item == "Diamonds") then
        print("4")
        AddResource("SuperGems", DiamondsPackValue)
        CurrentRun.SuperGems = GameState.Resources.SuperGems
        PolycosmosMessages.PrintToPlayer("Recieved a pack of "..DiamondsPackValue.." Diamonds")
    end

    if (item == "TitanBlood") then
        print("5")
        AddResource("SuperLockKeys", TitanBloodPackValue)
        CurrentRun.SuperLockKeys = GameState.Resources.SuperLockKeys
        PolycosmosMessages.PrintToPlayer("Recieved a pack of "..TitanBloodPackValue.." Titan Blood")
    end

    if (item == "Nectar") then
        print("6")
        AddResource("GiftPoints", NectarPackValue)
        CurrentRun.GiftPoints = GameState.Resources.GiftPoints
        PolycosmosMessages.PrintToPlayer("Recieved a pack of "..NectarPackValue.." Nectar")
    end

    if (item == "Ambrosia") then
        print("7")
        AddResource("SuperGiftPoints", AmbrosiaPackValue)
        CurrentRun.SuperGiftPoints = GameState.Resources.SuperGiftPoints
        PolycosmosMessages.PrintToPlayer("Recieved a pack of "..AmbrosiaPackValue.." Ambrosia")
    end
    
    SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
    ValidateCheckpoint({ Valid = true })

    Save()
end