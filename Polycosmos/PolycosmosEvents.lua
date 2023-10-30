ModUtil.Mod.Register( "PolycosmosEvents" )

loaded = false

local checkToProcess = "" --TODO: Change this for array and process the whole array. This could help with desyncs.

local locationsCheckedThisPlay = {} --This is basically a local copy of the locations checked to avoid writting on StyxScribeShared.Root at runtime


--[[

Important note:

To avoid inconsistency during play the Root object should ONLY be used at the start to set data such at settings,
locations already checked in server and to build the location to item mapping. Any other communication
between hades and client should be done by sending messages by the StyxScribe hook message.

This is far more nuanced, but should be more stable during runtime for any user that does not run a SSD.

]]--


--Sadly I need to put this buffer in case hades request some data before the Shared state is updated.
local bufferTime = 2

styx_scribe_send_prefix  = "Polycosmos to Client:"
styx_scribe_recieve_prefix = "Client to Polycosmos:"

------------ General function to process location checks

function PolycosmosEvents.UnlockLocationCheck(checkName)
    checkToProcess = checkName
    if (checkToProcess == "") then
        return
    end
    --if some weird shenanigan made StyxScribe not load (like exiting in the wrong moment), try to load, if that fails abort and send an error message
    if not StyxScribeShared.Root.LocationToItemMap then
        PolycosmosEvents.LoadData()
        wait( bufferTime )
        if not StyxScribeShared.Root.LocationToItemMap then
            PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state. Enter and exit the save file again!")
            return
        end
    end
    PolycosmosEvents.ProcessLocationCheck(checkToProcess, true)
    checkToProcess = ""
end

-----

function PolycosmosEvents.ProcessLocationCheck(checkName, printToPlayer)
    --If the location is already visited, we ignore adding the check
    if (PolycosmosUtils.HasValue(StyxScribeShared.Root.LocationsUnlocked, checkName) or PolycosmosUtils.HasValue(locationsCheckedThisPlay, checkName)) then
        return
    end
    if not StyxScribeShared.Root.LocationToItemMap[checkName] then --if nothing tangible is in this room, just return
        return
    end
    itemObtained = StyxScribeShared.Root.LocationToItemMap[checkName]
    table.insert(locationsCheckedThisPlay, checkName)
    StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..checkName)
    if  printToPlayer then  --This is to avoid overflowing the print stack if by any chance we print a set of locations in the future
        PolycosmosMessages.PrintToPlayer("Obtained "..itemObtained)
    end
end

------------ On room completed, request processing the Room check

function PolycosmosEvents.GiveRoomCheck(roomNumber)
    if (roomNumber == nil) then
        return
    end
    PolycosmosEvents.UnlockLocationCheck("Clear Room"..roomNumber)
end

--Here we should put other methods to process checks. Let it be boon/NPC related or whatever.

------------ On items updated, update run information

--When more features are added this is the function we need to extend!
function PolycosmosEvents.UpdateItemsRun( message )
    local itemList = PolycosmosUtils.ParseStringToArray(message)
    local pactList = {}
    for i=1,#itemList do
        local itemName = itemList[i]
        local parsedName = (itemName):gsub("PactLevel", "")
        if (PolycosmosHeatManager.IsHeatLevel(parsedName)) then
            table.insert(pactList, parsedName)
        elseif (PolycosmosItemManager.IsFillerItem(parsedName)) then
            PolycosmosItemManager.GiveFillerItem(parsedName)
            StyxScribe.Send(styx_scribe_send_prefix.."Got filler item:"..parsedName)
        end
    end
    PolycosmosHeatManager.SetUpHeatLevelFromPactList(pactList)
end

StyxScribe.AddHook( PolycosmosEvents.UpdateItemsRun, styx_scribe_recieve_prefix.."Items Updated:", PolycosmosEvents )


------------ On Hades killed, send victory signal to Client

function PolycosmosEvents.ProcessHadesDefeat()
    StyxScribe.Send(styx_scribe_send_prefix.."Hades defeated")
end

table.insert(EncounterData.BossHades.PostUnthreadedEvents, {FunctionName = "PolycosmosEvents.ProcessHadesDefeat"})


------------ On deathlink, kill Zag

function PolycosmosEvents.KillPlayer( message )
    PolycosmosMessages.PrintToPlayer("Deathlink recieved!")
    wait( 2 )
	KillHero(CurrentRun.Hero,  { }, { })
end

StyxScribe.AddHook( PolycosmosEvents.KillPlayer, styx_scribe_recieve_prefix..":Deathlink recieved", PolycosmosEvents )

------------ On death, send deathlink to players

function PolycosmosEvents.SendDeathlink()
    StyxScribe.Send(styx_scribe_send_prefix.."Zag died")
end


ModUtil.Path.Wrap("HandleDeath", function( baseFunc, currentRun, killer, killingUnitWeapon )
	PolycosmosEvents.SendDeathlink()
	return baseFunc(currentRun, killer, killingUnitWeapon)
end)

------------ On connection error, send warning to player to reconnect

function PolycosmosEvents.ConnectionError( message )
    PolycosmosMessages.PrintErrorMessage("Connection error detected. Go back to menu and reconnect the Client!", 9)
    PolycosmosMessages.PrintErrorMessage("Connection error detected. Go back to menu and reconnect the Client!", 9)
    PolycosmosMessages.PrintErrorMessage("Connection error detected. Go back to menu and reconnect the Client!", 9)
end

StyxScribe.AddHook( PolycosmosEvents.ConnectionError, styx_scribe_recieve_prefix.."Connection Error", PolycosmosEvents )

------------ Load rando basic data

function PolycosmosEvents.LoadData()
    if not loaded then
        loaded=true
    end
    StyxScribe.Send(styx_scribe_send_prefix.."Data requested")
end


------------ Wrappers to send checks

-- Wrapper for room completion
ModUtil.Path.Wrap("DoUnlockRoomExits", function (baseFunc, run, room)
    if (run and run.RunDepthCache) then
        PolycosmosEvents.GiveRoomCheck(run.RunDepthCache)
    end
    return baseFunc(run, room)
end)

-- Wrapper for room loading
ModUtil.LoadOnce(function ()
    PolycosmosEvents.LoadData()
    PolycosmosMessages.PrintInformationMessage("Mod loaded")
end)


-------------- On new run make sure to load the Heat Levels again
ModUtil.Path.Wrap("StartNewRun", function (baseFunc, prevRun, args)
            PolycosmosHeatManager.UpdatePactsLevelWithoutMetaCache()
            return baseFunc(prevRun, args)
        end)

