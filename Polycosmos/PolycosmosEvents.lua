ModUtil.Mod.Register( "PolycosmosEvents" )

loaded = false

local checkToProcess = "" --TODO: Change this for array and process the whole array. This could help with desyncs.

locationsCheckedThisPlay = {} --This is basically a local copy of the locations checked to avoid writting on StyxScribeShared.Root at runtime

locationToItemMapping = {} --This is used to have the location to item mapping.
--When having too many locations StyxScribe.Root wouldnt work. The writting speed was too slow. Having the dictionary being handled by strings works much better.

-- since eventually the number of locations checked is long enough, I also moved this to work with strings.

--[[

Important note:

To avoid inconsistency during play the Root object should ONLY be used at the start to set data such at settings,
locations already checked in server and to build the location to item mapping. Any other communication
between hades and client should be done by sending messages by the StyxScribe hook message.

This is far more nuanced, but should be more stable during runtime for any user that does not run a SSD.
In fact, after testing this seems to fix a big bunch of crashes that would be a pain to fix otherwise. 

]]--


--Sadly I need to put this buffer in case hades request some data before the Shared state is updated. This could happen
--in the case a location check is requested as soon as the game boots up.
local bufferTime = 2

styx_scribe_send_prefix  = "Polycosmos to Client:"
styx_scribe_recieve_prefix = "Client to Polycosmos:"

--- variables for score based system

actual_score = 0
last_score_completed = -1
limit_of_score = 1001
last_room_completed=0

------------ General function to process location checks

function PolycosmosEvents.UnlockLocationCheck(checkName)
    checkToProcess = checkName
    if (checkToProcess == "") then
        return
    end
    PolycosmosEvents.ProcessLocationCheck(checkToProcess, true)
    checkToProcess = ""
end

-----

function PolycosmosEvents.ProcessLocationCheck(checkName, printToPlayer)
    --If the location is already visited, we ignore adding the check
    if (PolycosmosEvents.HasLocationBeenChecked( checkName )) then
        return
    end
    itemObtained = PolycosmosEvents.GiveItemInLocation(checkName)
    if not itemObtained then --if nothing tangible is in this room, just return
        return
    end
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
    --if some weird shenanigan made StyxScribe not load (like exiting in the wrong moment), try to load, if that fails abort and send an error message
    if ((not PolycosmosEvents.IsItemMappingInitiliazed()) or (not StyxScribeShared.Root.GameSettings)) then
        PolycosmosEvents.LoadData()
        wait( bufferTime )
        if not PolycosmosEvents.IsItemMappingInitiliazed() then
            PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state. Enter and exit the save file again!")
            return
        end
    end

    if (StyxScribeShared.Root.GameSettings['LocationMode'] ~= 1) then
        return
    end
    
    roomString = roomNumber
    if (roomNumber < 10) then
        roomString = "0"..roomNumber
    end

    PolycosmosEvents.UnlockLocationCheck("ClearRoom"..roomString)
end

----------- When using score based checks, we use this function instead of give room check


function PolycosmosEvents.GiveScore(roomNumber)
    if (roomNumber == nil) then
        return
    end
    --if some weird shenanigan made StyxScribe not load (like exiting in the wrong moment), try to load, if that fails abort and send an error message
    if not PolycosmosEvents.IsItemMappingInitiliazed() then
        PolycosmosEvents.LoadData()
        wait( bufferTime )
        if not PolycosmosEvents.IsItemMappingInitiliazed() then
            PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state. Enter and exit the save file again!")
            return
        end
    end

    if (StyxScribeShared.Root.GameSettings['LocationMode']~= 2) then
        return
    end

    -- initialize the variables we need in case we havent done that
    if (last_score_completed == -1) then
        actual_score = StyxScribeShared.Root.Score
        last_score_completed = StyxScribeShared.Root.LastScoreCheck
        last_room_completed = StyxScribeShared.Root.LastRoomComplete
    end

    -- if we already have all the possible checks, just return
    if (last_score_completed==limit_of_score) then
        return
    end

    -- This is to avoid counting the same room twice in a load/unload case. 
    if (roomNumber ~=1 and last_room_completed == roomNumber) then
        return
    end
    
    actual_score = actual_score + roomNumber
    last_room_completed = roomNumber

    if (actual_score >= last_score_completed) then
        checkString = last_score_completed
        if (last_score_completed < 10) then
            checkString = "0"..checkString
        end
        PolycosmosEvents.UnlockLocationCheck("ClearScore"..checkString) --Need to make sure in this case we reset the score and the last completed room on the client
        actual_score = actual_score - last_score_completed
        PolycosmosMessages.PrintToPlayer("Cleared score "..last_score_completed.." you now got "..actual_score.." points")
        last_score_completed = last_score_completed+1
    else
        PolycosmosMessages.PrintToPlayer("You got "..actual_score.." points")
    end
    StyxScribe.Send(styx_scribe_send_prefix.."ScoreUpdate:"..actual_score.."-"..roomNumber) --make sure we can save the score and recover in case of a reload    
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
        elseif (PolycosmosKeepsakeManager.IsKeepsakeItem(parsedName)) then
            PolycosmosKeepsakeManager.GiveKeepsakeItem(parsedName)
        end
    end
    PolycosmosHeatManager.SetUpHeatLevelFromPactList(pactList)
end

StyxScribe.AddHook( PolycosmosEvents.UpdateItemsRun, styx_scribe_recieve_prefix.."Items Updated:", PolycosmosEvents )


------------ On Hades killed, send victory signal to Client

function PolycosmosEvents.ProcessHadesDefeat()
    -- Adding a plus on the number of runs and the number of weapons because this does not account our most recent victory
    numruns = GetNumRunsCleared()
    weaponsWithVictory = 0
    for k, weaponName in ipairs( WeaponSets.HeroMeleeWeapons )  do
        if (GetNumRunsClearedWithWeapon(weaponName)>0 or GetEquippedWeapon() == weaponName) then
            weaponsWithVictory = weaponsWithVictory+1
        end
    end
    StyxScribe.Send(styx_scribe_send_prefix.."Hades defeated"..numruns.."-"..weaponsWithVictory)
end

table.insert(EncounterData.BossHades.PostUnthreadedEvents, {FunctionName = "PolycosmosEvents.ProcessHadesDefeat"})


------------ On deathlink, kill Zag

function PolycosmosEvents.KillPlayer( message )
    PolycosmosMessages.PrintToPlayer("Deathlink recieved!")
    wait( 2 )
	KillHero(CurrentRun.Hero,  { }, { })
end

StyxScribe.AddHook( PolycosmosEvents.KillPlayer, styx_scribe_recieve_prefix.."Deathlink recieved", PolycosmosEvents )

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
        PolycosmosEvents.GiveScore(run.RunDepthCache)
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

-------------- Checked if a location has been checked
function PolycosmosEvents.HasLocationBeenChecked( location )
   return PolycosmosUtils.HasValue(locationsCheckedThisPlay, location)
end


-------------------Auxiliar functions to handle location to item mapping

function PolycosmosEvents.IsItemMappingInitiliazed()
    local key,val = next(locationToItemMapping)
    return (key ~= nil)
end

function PolycosmosEvents.GiveItemInLocation(location)
    return locationToItemMapping[location]
end

--------------- method to reconstruct location to item mapping

function PolycosmosEvents.RecieveLocationToItem(message)
    local MessageAsTable = PolycosmosUtils.ParseStringToArrayWithDash(message)
    local key = MessageAsTable[1]
    local value = MessageAsTable[2].."-"..MessageAsTable[3]
    locationToItemMapping[key] = value
end

StyxScribe.AddHook( PolycosmosEvents.RecieveLocationToItem, styx_scribe_recieve_prefix.."Location to Item Map:", PolycosmosEvents )

-------------- method to reconstruct the mapping of checked Location

function PolycosmosEvents.AddCheckedLocation( message )
    table.insert(locationsCheckedThisPlay, message)
end

StyxScribe.AddHook( PolycosmosEvents.AddCheckedLocation, styx_scribe_recieve_prefix.."Location checked reminder:", PolycosmosEvents )