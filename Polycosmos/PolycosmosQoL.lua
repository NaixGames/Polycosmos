ModUtil.Mod.Register("PolycosmosQoL")

local config = {

	-- universal enable & disable of mod
    ModEnabled = true,
	
	-- allow Wretched broker to sell all items once lounge unlocked
	UnlockFullBroker = true,
	
	-- unlock the House Contractor and Lounge from the start
	-- (the House Contractor unlocks from one specific line of code, but the Broker, Lounge, etc. all unlock based on 5 minimum escape attempts.)
	-- (may also be a good idea to remove the ability for Hypnos to comment on the number of escape attempts you've completed, he's the only one that really does it.)
	UnlockHouse = true,
	
	-- unlock the Fated List from the start, and remove ability to purchase it
	UnlockFatedList = true,

	-- remove ability to purchase EM4
	NoExtremerMeasures = true,

	-- allow Demeter to appear at the same time as other gods
	UnlockDemeterEarly = true,

	-- speed up keepsake upgrades to reasonably level them within an archipelago session
	FasterKeepsakeLevels = true,

	-- turn on a chamber number display in the top corner during runs (credits to Museus and Ellomenop for initial script)
	ShowChamberNumber = true,

	-- allow quick resets by pressing assist+use+shout+reload (credits to Museus and Ellomenop for initial script)
	QuickRestart = true,
	
}

PolycosmosQoL.config = config

if not config.ModEnabled then return end

if config.UnlockFullBroker then
	-- unlocks all possible entries, assumes no use of Wretched Broker mods
	-- (this could likely just be a loop checking for if GameStateRequirements ~= nil, then make it nil on each table)
	ModUtil.Table.NilMerge( BrokerData, {
		[3] = {
			GameStateRequirements = true
		},
		[4] = {
			GameStateRequirements = true
		},
		[5] = {
			GameStateRequirements = true
		},
		[10] = {
			GameStateRequirements = true
		},
		[11] = {
			GameStateRequirements = true
		},
		[12] = {
			GameStateRequirements = true
		},
		[13] = {
			GameStateRequirements = true
		},
		[14] = {
			GameStateRequirements = true
		},
		[15] = {
			GameStateRequirements = true
		},
		[16] = {
			GameStateRequirements = true
		},
		[17] = {
			GameStateRequirements = true
		},
	})
end

if config.UnlockHouse then
	-- remove requirement for House Contractor
	ModUtil.Table.NilMerge( DeathLoopData, {
		DeathArea = {
			-- remove min run requirement for House Contractor
			ObstacleData = {
				[210158] = {
					SetupGameStateRequirements = {
						RequiredMinCompletedRuns = true
					}
				},
			-- remove min run requirement for Wretched Broker
				[423390] = {
					SetupGameStateRequirements = {
						RequiredMinCompletedRuns = true
					}
				}
			},
			-- remove min run requirements to unlock the lounge
			DistanceTriggers = {
				[2] = {
					RequiredMinCompletedRuns = true
				},
				[3] = {
					RequiredMinCompletedRuns = true
				},
				[7] = {
					RequiredMinCompletedRuns = true
				},
				[8] = {
					RequiredMinCompletedRuns = true
				},
			},
			-- remove min run requirement for Dusa to show up with the lounge being unlocked
			StartUnthreadedEvents = {
				[19] = {
					GameStateRequirements = {
						RequiredMinCompletedRuns = true
					}
				},
				[20] = {
					GameStateRequirements = {
						RequiredMinCompletedRuns = true
					}
				}
			}
		}
	})
end

if config.UnlockFatedList then
	ModUtil.Path.Wrap("StartNewGame", function(baseFunc)
		baseFunc()
		-- Adds the Fated List ("QuestLog") on the start of a new save file only.
		-- This does not unlock the QuestLog on an already-started file, but most people shouldn't be using Polycosmos in this way.
		AddCosmetic( "QuestLog" )
	end, PolycosmosQoL)
end

if config.NoExtremerMeasures then
	ModUtil.Path.Wrap("StartNewGame", function(baseFunc)
		baseFunc()
		-- Adds the ability to select EM4 when Extreme Measures is unlocked on the start of a new save file only.
		-- (this just makes EM4 cleaner in the shop)
		-- This does not unlock EM4 on an already-started file, but most people shouldn't be using Polycosmos in this way.
		AddCosmetic( "HadesEMFight" )
	end, PolycosmosQoL)
end

if config.UnlockDemeterEarly then
	ModUtil.Table.NilMerge( LootData, {
		DemeterUpgrade = {
			RequiredSeenRooms = "DeathArea"
		}
	})
end

if config.FasterKeepsakeLevels then
	ModUtil.Path.Wrap("AdvanceKeepsake", function(baseFunc)
		for i=1,3 do
			--level up 3x as fast (around 13 encounters)
			baseFunc()
		end
	end)
end

-- QoL so that unlocking new levels of the mirror is compatible with routine inspection unlocks
ModUtil.Path.Wrap("UnlockNextMetaUpgradePanel", function(baseFunc, screen, button)
  baseFunc(screen, button)
  CloseMetaUpgradeScreen(screen, button)
  OpenMetaUpgradeMenu()
end, PolycosmosQoL)

-- Show the chamber depth you've reached in the top-right of your screen
if config.ShowChamberNumber then
	-- Scripts/RoomManager.lua : 1874
	ModUtil.Path.Wrap("StartRoom", function ( baseFunc, currentRun, currentRoom )
		ShowDepthCounter()
		baseFunc(currentRun, currentRoom)
	end)

	-- Scripts/UIScripts.lua : 145
	ModUtil.Path.Wrap("ShowCombatUI", function ( baseFunc, flag )
		ShowDepthCounter()
		baseFunc(flag)
	end)

	-- Make sure Hiding Depth Counter doesn't actually do anything
	ModUtil.Path.Wrap("HideDepthCounter", function ( baseFunc )
		return
	end)
end

-- QuickRestart setup below here
function PolycosmosQoL.CanReset()
    -- QuickRestart must be Enabled
    if not config.QuickRestart then return false end

    -- Short delay to handle edge cases
    wait(0.1)

    -- Zag must not be in the House
    if ModUtil.Path.Get("CurrentDeathAreaRoom") then return false end

    -- Zag must not be frozen
    if not IsEmpty( CurrentRun.Hero.FreezeInputKeys ) then return false end

    -- Combat UI must be visible
    if not (ShowingCombatUI or false) then return false end

    -- We can't be LastStand-ing
    if PolycosmosQoL.LastStanding then return false end

    -- We can't be QuickRestart-ing
    if PolycosmosQoL.UsedQuickRestart then return false end

    -- We can't be mid-trial god selection
    if PolycosmosQoL.MidDevotion then return false end

    -- If we're in a Thanatos Room, enemies must have already spawned
    if (CurrentRun ~= nil and CurrentRun.CurrentRoom ~= nil and
            CurrentRun.CurrentRoom.Encounter ~= nil and
            CurrentRun.CurrentRoom.Encounter.ThanatosId ~= nil
            and GetActiveEnemyCount() == 0) then
        return false
    end

    return true
end

function PolycosmosQoL.ResetRun(triggerArgs)
    if not PolycosmosQoL.CanReset() then
        ModUtil.Hades.PrintOverhead("Can't reset now!", 2)
        return
    end

    PolycosmosQoL.UsedQuickRestart = true
    AddInputBlock({ Name = "QuickRestart" })

    wait(0.1)

    Kill( CurrentRun.Hero, triggerArgs )
end

OnControlPressed{ "Assist Use Shout Reload",
    function(triggerArgs)
        if config.QuickRestart then
            if IsControlDown({ Name = "Assist" })
                    and IsControlDown({ Name = "Use" })
                    and IsControlDown({ Name = "Shout" })
                    and IsControlDown({ Name = "Reload" }) then
                PolycosmosQoL.ResetRun(triggerArgs)
            end
        end
    end
}

OnAnyLoad{ "RoomPreRun",
    function ( triggerArgs )
        if PolycosmosQoL.UsedQuickRestart then
            thread( PlayVoiceLines, GlobalVoiceLines.EnteredDeathAreaVoiceLines )
            PolycosmosQoL.UsedQuickRestart = false

            RemoveLastAwardTrait()
            UnequipWeaponUpgrade()
            RemoveLastAssistTrait()

            -- Reset Starting Keepsake
            GameState.LastAwardTrait = GameState.QuickRestartStartingKeepsake or GameState.LastAwardTrait
        end
    end
}

ModUtil.Path.Wrap("HandleDeath", function(baseFunc, currentRun, killer, killingUnitWeapon)
    if PolycosmosQoL.UsedQuickRestart then
        RemoveInputBlock({ Name = "QuickRestart" })
    end
    
    return baseFunc(currentRun, killer, killingUnitWeapon)
end)

ModUtil.Path.Context.Wrap("HandleDeath", function ()
    ModUtil.Path.Wrap("LoadMap", function(baseFunc, argTable)
        if PolycosmosQoL.UsedQuickRestart then
            argTable.Name = "RoomPreRun"

            if GameState.QuickRestartStartingKeepsake then
              GameState.LastAwardTrait = GameState.QuickRestartStartingKeepsake
            end
        end

        baseFunc(argTable)
        
        --In some cases IsDead will be set to false by DoPatches() causing the "mirror bug"
        CurrentRun.Hero.IsDead = true
    end)
end)

ModUtil.Path.Wrap("WindowDropEntrance", function( baseFunc, ... )
    local val = baseFunc(...)
    -- Get starting keepsake
    GameState.QuickRestartStartingKeepsake = GameState.LastAwardTrait
    return val
end)

ModUtil.Path.Wrap("PlayerLastStandPresentationStart", function( baseFunc, ... )
    PolycosmosQoL.LastStanding = true
    return baseFunc( ... )
end)

ModUtil.Path.Wrap("PlayerLastStandPresentationEnd", function( baseFunc, ... )
    local val = baseFunc( ... )
    PolycosmosQoL.LastStanding = false
    return val
end)

ModUtil.Path.Wrap("StartDevotionTestPresentation", function( baseFunc, ... )
    PolycosmosQoL.MidDevotion = true
    baseFunc(...)
    PolycosmosQoL.MidDevotion = false
end)

-- Remove starting cutscene on a restart
ModUtil.Path.Wrap("ShowRunIntro", function( baseFunc )

    if PolycosmosQoL and PolycosmosQoL.UsedQuickRestart then
        return
    end

    baseFunc()
end)
