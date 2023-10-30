ModUtil.Mod.Register( "PolycosmosItemManager" )


-- for the future for reference of filler items: MetaPoints are darkness, Gems is gemstones, SuperGems are diamonds, LockKeys are keys, SuperLockKeys are titan's blood, GiftPoints are nectar, SuperGiftPoints are ambrosia

--Sadly I need to put this buffer in case hades request some data before the Shared state is updated.
local bufferTime = 2

local ItemsDataArray=
{
    "Darkness",
    "Keys",
}

local KeysPackValue = 15

local DarknessPackValue = 500

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
        valueLoaded = true
    end

    if (item == "Keys") then
        AddResource("LockKeys", KeysPackValue)
        CurrentRun.LockKeys = GameState.Resources.LockKeys
        print("Keys obtained. Now have "..GameState.Resources.LockKeys.." keys")
    end

    if (item == "Darkness") then
        AddResource("MetaPoints", DarknessPackValue)
        CurrentRun.MetaPoints = GameState.Resources.MetaPoints
        print("Keys obtained. Now have "..GameState.Resources.MetaPoints.." keys")
    end
    
    -- This is not saving the increase in the resource for some reason if I do this on the same run :/. Need to research how to do this better.
    SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
    ValidateCheckpoint({ Valid = true })

    Save()
end