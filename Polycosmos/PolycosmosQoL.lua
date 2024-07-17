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
	ModUtil.Path.Wrap("HandleDeath", function(baseFunc)
		baseFunc()
		-- remove seeing the surface requirement, but hide behind second run to avoid demeter taking Athenea space
		-- on first run. When that happens a bunch of artifacts happen, and best to avoid it.
		ModUtil.Table.NilMerge( LootData, {
			DemeterUpgrade = {
				RequiredSeenRooms = true
			}
		})
	end, PolycosmosQoL)
end


-- QoL so that unlocking new levels of the mirror is compatible with routine inspection unlocks
ModUtil.Path.Wrap("UnlockNextMetaUpgradePanel", function(baseFunc, screen, button)
  baseFunc(screen, button)
  CloseMetaUpgradeScreen(screen, button)
  OpenMetaUpgradeMenu()
end, PolycosmosQoL)


