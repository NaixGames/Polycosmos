ModUtil.Mod.Register( "PolycosmosEvents" )

loaded = false

local queuedCheck = "" --THIS IS USED TO HELP DESYNCS WITH CLIENT

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
next_score_to_complete = -1
limit_of_score = 1001
last_room_completed=0


--- variables for deathlink checks

is_greece_death = false

--variable for avoid racing problems

is_saving_client_data = false



------------ General function to process location checks

function PolycosmosEvents.UnlockLocationCheck(checkName)
    local checkToProcess = checkName
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
    table.insert(GameState.LocationsChecked, checkName)
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
    if ((not PolycosmosEvents.IsItemMappingInitiliazed()) or (not GameState.ClientDataIsLoaded)) then
        --In this case this would be the second location desynced, and I really believe at this point there is nothing I can do
        if (queuedCheck ~= "") then
            PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state. Enter and exit the save file again!")
        end
        queuedCheck = roomNumber
        return
    end

    if (GameState.ClientGameSettings["LocationMode"] ~= 1) then
        return
    end
    
    if (queuedCheck ~= "") then
        local bufferProcess = queuedCheck
        queuedCheck = ""
        PolycosmosEvents.GiveRoomCheck(bufferProcess)
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
    if ((not PolycosmosEvents.IsItemMappingInitiliazed()) or (not GameState.ClientDataIsLoaded)) then
        --In this case this would be the second location desynced, and I really believe at this point there is nothing I can do
        if (queuedCheck ~= "") then
            PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state. Enter and exit the save file again!")
        end
        queuedCheck = roomNumber
        return
    end

    if (GameState.ClientGameSettings["LocationMode"] ~= 2) then
        return
    end

    if (queuedCheck ~= "") then
        local bufferProcess = queuedCheck
        queuedCheck = ""
        PolycosmosEvents.GiveScore(bufferProcess)
    end

    -- initialize the variables we need in case we havent done that
    if (next_score_to_complete == -1) then
        if (GameState.ScoreSystem == nil) then
            GameState.ScoreSystem = {}
            GameState.ScoreSystem["actual_score"] = 0
            GameState.ScoreSystem["next_score_to_complete"] = 1
            GameState.ScoreSystem["last_room_completed"] = 0
        end
        actual_score = GameState.ScoreSystem["actual_score"]
        next_score_to_complete = GameState.ScoreSystem["next_score_to_complete"]
        last_room_completed = GameState.ScoreSystem["last_room_completed"]
    end

    -- if we already have all the possible checks, just return
    if (next_score_to_complete==limit_of_score) then
        return
    end

    -- This is to avoid counting the same room twice in a load/unload case. 
    if (last_room_completed == roomNumber) then
        return
    end
    
    actual_score = actual_score + roomNumber
    last_room_completed = roomNumber

    if (actual_score >= next_score_to_complete) then
        checkString = next_score_to_complete
        if (next_score_to_complete < 10) then
            checkString = "0"..checkString
        end
        PolycosmosEvents.UnlockLocationCheck("ClearScore"..checkString) --Need to make sure in this case we reset the score and the last completed room on the client
        actual_score = actual_score - next_score_to_complete
        PolycosmosMessages.PrintToPlayer("Cleared score "..next_score_to_complete.." you now got "..actual_score.." points")
        next_score_to_complete = next_score_to_complete+1
        GameState.ScoreSystem["next_score_to_complete"]  = next_score_to_complete
    else
        PolycosmosMessages.PrintToPlayer("You got "..actual_score.." points")
    end
    GameState.ScoreSystem["actual_score"] = actual_score
    GameState.ScoreSystem["last_room_completed"] = roomNumber
end

--Give weapon location check if needed

function PolycosmosEvents.GiveWeaponRoomCheck(roomNumber)
    if (roomNumber == nil) then
        return
    end
    --if some weird shenanigan made StyxScribe not load (like exiting in the wrong moment), try to load, if that fails abort and send an error message
    if ((not PolycosmosEvents.IsItemMappingInitiliazed()) or (not GameState.ClientDataIsLoaded)) then
        if (queuedCheck ~= "") then
            PolycosmosMessages.PrintToPlayer("Polycosmos in a desync state. Enter and exit the save file again!")
        end
        queuedCheck = roomNumber
        return
    end

    if (GameState.ClientGameSettings["LocationMode"] ~= 3) then
        return
    end

    if (queuedCheck ~= "") then
        local bufferProcess = queuedCheck
        queuedCheck = ""
        PolycosmosEvents.GiveWeaponRoomCheck(bufferProcess)
    end
    
    roomString = roomNumber
    if (roomNumber < 10) then
        roomString = "0"..roomNumber
    end

    roomString = roomString..GetEquippedWeapon()

    PolycosmosEvents.UnlockLocationCheck("ClearRoom"..roomString)
end


--Here we should put other methods to process checks. Let it be boon/NPC related or whatever.

------------ On items updated, update run information

--When more features are added this is the function we need to extend!
function PolycosmosEvents.UpdateItemsRun( message )
    if not (GameState.ClientDataIsLoaded == true) then
        --If data was not loaded for some reason, request the data again.
        --If this is not loaded then the player just started the game or did something really unexpected (start from a non fresh file?)
        --All items will be sent again eventually, so we ask the data and return 
        PolycosmosEvents.LoadData()
        return
    end
    local itemList = PolycosmosUtils.ParseStringToArray(message)
    local pactList = {}
    for i=1,#itemList do
        local itemName = itemList[i]
        local parsedName = (itemName):gsub("PactLevel", "")
        if (PolycosmosHeatManager.IsHeatLevel(parsedName)) then
            table.insert(pactList, parsedName)
        elseif (PolycosmosItemManager.IsFillerItem(parsedName)) then
            PolycosmosItemManager.GiveFillerItem(parsedName)
        elseif (PolycosmosKeepsakeManager.IsKeepsakeItem(parsedName)) then
            PolycosmosKeepsakeManager.GiveKeepsakeItem(parsedName)
        elseif (PolycosmosWeaponManager.IsWeaponItem(parsedName)) then
            PolycosmosWeaponManager.UnlockWeapon(parsedName)
        elseif (PolycosmosCosmeticsManager.IsCosmeticItem(parsedName)) then
            PolycosmosCosmeticsManager.UnlockCosmetics(parsedName)
        elseif (PolycosmosAspectsManager.IsHiddenAspect(parsedName)) then
            PolycosmosAspectsManager.UnlockHiddenAspect(parsedName, true)
        end
    end
    PolycosmosHeatManager.SetUpHeatLevelFromPactList(pactList)
    PolycosmosItemManager.FlushAndProcessFillerItems()
end

StyxScribe.AddHook( PolycosmosEvents.UpdateItemsRun, styx_scribe_recieve_prefix.."Items Updated:", PolycosmosEvents )


------------ On Hades killed, send victory signal to Client

function PolycosmosEvents.ProcessHadesDefeat()
    -- If needed, cache if the next death is going to be a deathlink or not
    if (GameState.ClientGameSettings["IgnoreGreeceDeaths"]==1) then
        is_greece_death = true
    end

    
    local numruns = GetNumRunsCleared()
    local weaponsWithVictory = 0
    for k, weaponName in ipairs( WeaponSets.HeroMeleeWeapons )  do
        if (GetNumRunsClearedWithWeapon(weaponName)>0 or GetEquippedWeapon() == weaponName) then
            weaponsWithVictory = weaponsWithVictory+1
        end
    end

    local numKeepsakes = PolycosmosKeepsakeManager.GiveNumberOfKeesakes()

    local numFates = 0

    for k, questName in ipairs( QuestOrderData ) do
		local questData = QuestData[questName]
		if GameState.QuestStatus[questData.Name] == "CashedOut" then
			numFates = numFates + 1
		end
	end

    StyxScribe.Send(styx_scribe_send_prefix.."Hades defeated"..numruns.."-"..weaponsWithVictory.."-"..numKeepsakes.."-"..numFates)
end

table.insert(EncounterData.BossHades.PostUnthreadedEvents, {FunctionName = "PolycosmosEvents.ProcessHadesDefeat"})

-- Also process victory on credit start, becase in this case Hades is technically not defeated.
ModUtil.Path.Wrap("StartCredits", function( baseFunc, args )
	PolycosmosEvents.ProcessHadesDefeat()
	return baseFunc(args)
end)

------------ On deathlink, kill Zag

function PolycosmosEvents.KillPlayer( message )
    PolycosmosMessages.PrintToPlayer("Deathlink recieved!")
    wait( 2 )
	KillHero(CurrentRun.Hero,  { }, { })
end

StyxScribe.AddHook( PolycosmosEvents.KillPlayer, styx_scribe_recieve_prefix.."Deathlink recieved", PolycosmosEvents )

------------ On death, send deathlink to players

function PolycosmosEvents.SendDeathlink()
    if (is_greece_death == true) then
        is_greece_death = false
    else
        StyxScribe.Send(styx_scribe_send_prefix.."Zag died")
    end
end


ModUtil.Path.Wrap("HandleDeath", function( baseFunc, currentRun, killer, killingUnitWeapon )
	PolycosmosEvents.SendDeathlink()
	return baseFunc(currentRun, killer, killingUnitWeapon)
end)

------------ On connection error, send warning to player to reconnect

function PolycosmosEvents.ConnectionError( message )
    PolycosmosMessages.PrintErrorMessage("Connection error detected.", 9)
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
        PolycosmosEvents.GiveWeaponRoomCheck(run.RunDepthCache)
    end
    return baseFunc(run, room)
end)

-- Wrapper for room loading
ModUtil.LoadOnce(function ()
    if (GameState.ClientDataIsLoaded == nil) then
        GameState.ClientDataIsLoaded = false
    end
    PolycosmosEvents.LoadData()
    PolycosmosMessages.PrintInformationMessage("Mod loaded")
end)



-------------- Checked if a location has been checked
function PolycosmosEvents.HasLocationBeenChecked( location )
   return PolycosmosUtils.HasValue(GameState.LocationsChecked, location)
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

function PolycosmosEvents.ReceiveLocationToItemMap(message)
    local LocationToItemMap = PolycosmosUtils.ParseSeparatingStringToArrayWithDash(message)
    for i=1,#LocationToItemMap do
        local map = LocationToItemMap[i]
        PolycosmosEvents.ReceiveLocationToItem(map)
    end
end

function PolycosmosEvents.ReceiveLocationToItem(message)
    local MessageAsTable = PolycosmosUtils.ParseStringToArrayWithDash(message)
    local key = MessageAsTable[1]
    local value = MessageAsTable[2].."-"..MessageAsTable[3]
    locationToItemMapping[key] = value
end

StyxScribe.AddHook( PolycosmosEvents.ReceiveLocationToItemMap, styx_scribe_recieve_prefix.."Location to Item Map:", PolycosmosEvents )

-------------- method to reconstruct the mapping of checked Location

function PolycosmosEvents.AddCheckedLocation( location )
    table.insert(GameState.LocationsChecked, location)
end


-------------- Method to store Client info on save file. Avoid desyncs and problems with exiting and reintering.

function PolycosmosEvents.SaveClientData( message )
    if (GameState.ClientDataIsLoaded == true) then
        PolycosmosEvents.SetUpGameWithData()
    end
    
    if (is_saving_client_data) then
        return
    end

    is_saving_client_data = true

    local codified_settings = StyxScribeShared.Root.Settings

    local array_settings = PolycosmosUtils.ParseStringToArray(codified_settings)


    GameState.HeatSettings = {}
    GameState.ClientGameSettings["HeatMode"] = array_settings[1]
    GameState.HeatSettings["HardLaborPactLevel"] = array_settings[2]
    GameState.HeatSettings["LastingConsequencesPactLevel"] = array_settings[3]
    GameState.HeatSettings["ConvenienceFeePactLevel"] = array_settings[4]
    GameState.HeatSettings["JurySummonsPactLevel"] = array_settings[5]
    GameState.HeatSettings["ExtremeMeasuresPactLevel"] = array_settings[6]
    GameState.HeatSettings["CalisthenicsProgramPactLevel"] = array_settings[7]
    GameState.HeatSettings["BenefitsPackagePactLevel"] = array_settings[8]
    GameState.HeatSettings["MiddleManagementPactLevel"] = array_settings[9]
    GameState.HeatSettings["UnderworldCustomsPactLevel"] = array_settings[10]
    GameState.HeatSettings["ForcedOvertimePactLevel"] = array_settings[11]
    GameState.HeatSettings["HeightenedSecurityPactLevel"] = array_settings[12]
    GameState.HeatSettings["RoutineInspectionPactLevel"] = array_settings[13]
    GameState.HeatSettings["DamageControlPactLevel"] = array_settings[14]
    GameState.HeatSettings["ApprovalProcessPactLevel"] = array_settings[15]
    GameState.HeatSettings["TightDeadlinePactLevel"] = array_settings[16]
    GameState.HeatSettings["PersonalLiabilityPactLevel"] = array_settings[17]

    GameState.ClientFillerValues = {}
    GameState.ClientFillerValues["DarknessPackValue"] = array_settings[18]
    GameState.ClientFillerValues["KeysPackValue"] = array_settings[19]
    GameState.ClientFillerValues["GemstonesPackValue"] = array_settings[20]
    GameState.ClientFillerValues["DiamondsPackValue"] = array_settings[21]
    GameState.ClientFillerValues["TitanBloodPackValue"] = array_settings[22]
    GameState.ClientFillerValues["NectarPackValue"] = array_settings[23]
    GameState.ClientFillerValues["AmbrosiaPackValue"] = array_settings[24]

    GameState.ClientGameSettings = {}
    GameState.ClientGameSettings["LocationMode"] = array_settings[25]
    GameState.ClientGameSettings["ReverseOrderEM"] = array_settings[26]
    GameState.ClientGameSettings["KeepsakeSanity"] = array_settings[27]
    GameState.ClientGameSettings["WeaponSanity"] = array_settings[28]
    GameState.ClientGameSettings["StoreSanity"] = array_settings[29]
    GameState.ClientGameSettings["InitialWeapon"] = array_settings[30]
    GameState.ClientGameSettings["IgnoreGreeceDeaths"] = array_settings[31]
    GameState.ClientGameSettings["FateSanity"] = array_settings[32]
    GameState.ClientGameSettings["HiddenAspectSanity"] = array_settings[33]
    GameState.ClientGameSettings["PolycosmosVersion"] = array_settings[34]

    GameState.LocationsChecked = {}

    GameState.ClientDataIsLoaded = true

    PolycosmosROEM.LoadBossData()

    SaveCheckpoint({ SaveName = "_Temp", DevSaveName = CreateDevSaveName( CurrentRun, { PostReward = true } ) })
    ValidateCheckpoint({ Valid = true })

    Save()

    is_saving_client_data = false

    PolycosmosEvents.SetUpGameWithData()
end

function PolycosmosEvents.SetUpGameWithData()
    PolycosmosROEM.LoadBossData()
    PolycosmosWeaponManager.CheckRequestInitialWeapon()
    PolycosmosCosmeticsManager.ResolveQueueCosmetics()
    PolycosmosHeatManager.UpdateMaxLevelFunctionFromData()
    PolycosmosHeatManager.SaveUserIntededHeat()
    PolycosmosHeatManager.CheckMinimalHeatSetting()
    PolycosmosHeatManager.UpdatePactsLevelWithoutMetaCache()

    --Send all locations to server to resync
    for i,value in ipairs(GameState.LocationsChecked) do
        StyxScribe.Send(styx_scribe_send_prefix.."Locations updated:"..value)
    end

    if (GameState.MetaUpgrades["BiomeSpeedShrineUpgrade"] == 0 and CurrentRun ~= nil) then
        CurrentRun.ActiveBiomeTimer = false
        return
    end
    --if having some heat for TightDeadline, force the timer.
    if (CurrentRun ~= nil) then
        CurrentRun.ActiveBiomeTimer = true
    end
end

--Set hook to load Boss data once informacion of setting is loaded
StyxScribe.AddHook( PolycosmosEvents.SaveClientData, styx_scribe_recieve_prefix.."Data finished", PolycosmosEvents )


ModUtil.WrapBaseFunction("StartNewRun", 
    function ( baseFunc, prevRun, args )
        run = baseFunc( prevRun, args )
        if (GameState ~= nil and GameState.ClientDataIsLoaded) then
            PolycosmosEvents.SetUpGameWithData()
        end
        --Avoid doing things to the run here, since it can create racing conditions.
        return run
    end, PolycosmosEvents)