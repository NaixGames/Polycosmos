ModUtil.Mod.Register( "PolycosmosEvents" )

loaded = false

styx_scribe_send_prefix  = "Polycosmos to Client:"
styx_scribe_recieve_prefix = "Client to Polycosmos:"

------------ General function to process location checks

function PolycosmosEvents.ProcessLocationCheck(checkName)
    PolycosmosEvents.LoadData() 
    wait( 1 ) -- This is the wait to make sure all the elements we need area loaded in StyxScribe
    --if some weird shenanigan made StyxScribe not load (like exiting in the wrong moment), abort and send an error message
    if not StyxScribeShared.Root.LocationsUnlocked then
        PolycosmosMessages.PrintToPlayer("Exited while loading leaving StyxScribe in a corrupted state, exit save file and load again")
        return
    end
    --If the location is already visited, we ignore adding the check ... Although this if is not working sometimes and idkw!
    if PolycosmosEvents.HasValue(StyxScribeShared.Root.LocationsUnlocked, checkName) then
        return
    end
    if not StyxScribeShared.Root.LocationToItemMap[checkName] then --if nothing tangible is in this room, just return
        PolycosmosMessages.PrintToPlayer("Obtained Nothing")
        return
    end
    table.insert(StyxScribeShared.Root.LocationsUnlocked, checkName)
    StyxScribe.Send(styx_scribe_send_prefix.."Locations updated")
    itemObtained = StyxScribeShared.Root.LocationToItemMap[checkName]
    PolycosmosMessages.PrintToPlayer("Obtained "..itemObtained)
end

------------ On room completed, give Room check

function PolycosmosEvents.GiveRoomCheck(roomNumber)
    PolycosmosEvents.ProcessLocationCheck("Clear Room"..roomNumber)
end


--Here we should put other methods to process checks. Let it be boon/NPC related or whatever.

------------ On items updated, update run information

--When more features are added this is the function we need to extend!
function PolycosmosEvents.UpdateItemsRun( message )
    local itemList = StyxScribeShared.Root.ItemsUnlocked
    local pactList = {}
    for i=1,#itemList do
        local itemName = itemList[i]
        local parsedName = (itemName):gsub("PactLevel", "")
        if (PolycosmosHeatManager.IsHeatLevel(parsedName)) then
            table.insert(pactList, parsedName)
        end
    end
    PolycosmosHeatManager.SetUpHeatLevelFromPactList(pactList)
end

StyxScribe.AddHook( PolycosmosEvents.UpdateItemsRun, styx_scribe_recieve_prefix.."Items Updated", PolycosmosEvents )


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

function PolycosmosEvents.ConnectionError()
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
    PolycosmosEvents.GiveRoomCheck(run.RunDepthCache)
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


-- Auxiliary function to check if an array has a value
function PolycosmosEvents.HasValue (tab, val)
    for index, value in ipairs(tab) do
        print(value)
        if value == val then
            return true
        end
    end
    return false
end

