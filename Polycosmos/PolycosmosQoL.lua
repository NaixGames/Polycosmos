ModUtil.Mod.Register("PolycosmosQoL")

local config = {

	-- universal enable & disable of mod
    ModEnabled = true,
	
	-- allow Wretched broker to sell all items once lounge unlocked
	UnlockFullBroker = true,
	
	-- unlock the lounge from the start
	UnlockLounge = true,
	
	-- unlock the Fated List from the start
	-- may just change the cost to 0 Gemstones, going to try and have it already in your room after first death or start of new file
	UnlockFatedList = true,
	
}

PolycosmosQoL.config = config

if not config.ModEnabled then return end

if config.UnlockFullBroker then
	ModUtil.LoadOnce(function()

		-- Remove "GameStateRequirements" line for all applicable.
		BrokerData = 
		{
			-- Standard Trades
		
			{ 
				BuyName = "LockKeys", BuyAmount = 1,
				CostName = "Gems", CostAmount = 10, 
				Priority = true, 
				PurchaseSound = "/SFX/KeyPickup",
			},
		
			{ 
				BuyName = "GiftPoints", BuyAmount = 1,
				CostName = "LockKeys", CostAmount = 5, 
				Priority = true, 
				PurchaseSound = "/SFX/GiftAmbrosiaBottlePickup",
			},
		
			{ 
				BuyName = "SuperGems", BuyAmount = 1,
				CostName = "GiftPoints", CostAmount = 10, 
				Priority = true,
				PurchaseSound = "/SFX/SuperGemPickup",
				-- GameStateRequirements = { RequiredKills = { HydraHeadImmortal = 1 }, },
			},
		
			{ 
				BuyName = "SuperGiftPoints", BuyAmount = 1,
				CostName = "SuperGems", CostAmount = 2, 
				Priority = true,
				PurchaseSound = "/SFX/SuperGiftAmbrosiaBottlePickup",
				-- GameStateRequirements = { RequiredKills = { Theseus = 1 }, },
			},
		
			{ 
				BuyName = "SuperLockKeys", BuyAmount = 1,
				CostName = "SuperGiftPoints", CostAmount = 1, 
				Priority = true, 
				PurchaseSound = "/SFX/TitanBloodPickupSFX",
				-- GameStateRequirements = { RequiredKills = { Theseus = 1 }, },
			},
		
			-- Limited Time Trades
		
			{ 
				BuyName = "GiftPoints", BuyAmount = 1,
				CostName = "Gems", CostAmount = 10, 
				PurchaseSound = "/SFX/GiftAmbrosiaBottlePickup",
			},
		
			{ 
				BuyName = "LockKeys", BuyAmount = 3,
				CostName = "MetaPoints", CostAmount = 25, 
				PurchaseSound = "/SFX/KeyPickup",
			},
		
			{ 
				BuyName = "MetaPoints", BuyAmount = 50,
				CostName = "GiftPoints", CostAmount = 1, 
				PurchaseSound = "/SFX/Player Sounds/DarknessCollectionPickup",
			},
		
			{ 
				BuyName = "Gems", BuyAmount = 20,
				CostName = "LockKeys", CostAmount = 2, 
				PurchaseSound = "/SFX/GemPickup",
			},
		
			{ 
				BuyName = "SuperLockKeys", BuyAmount = 1,
				CostName = "LockKeys", CostAmount = 15, 
				PurchaseSound = "/SFX/TitanBloodPickupSFX",
				-- GameStateRequirements = { RequiredKills = { Harpy = 1 }, },
			},
		
			{ 
				BuyName = "Gems", BuyAmount = 200,
				CostName = "SuperLockKeys", CostAmount = 1, 
				PurchaseSound = "/SFX/GemPickup",
				-- GameStateRequirements = { RequiredKills = { Harpy = 1 }, },
			},
		
			{ 
				BuyName = "SuperGiftPoints", BuyAmount = 1,
				CostName = "GiftPoints", CostAmount = 10, 
				PurchaseSound = "/SFX/SuperGiftAmbrosiaBottlePickup",
				-- GameStateRequirements = { RequiredKills = { Theseus = 1 }, },
			},
		
			{ 
				BuyName = "SuperGiftPoints", BuyAmount = 1,
				CostName = "SuperLockKeys", CostAmount = 2, 
				PurchaseSound = "/SFX/SuperGiftAmbrosiaBottlePickup",
				-- GameStateRequirements = { RequiredKills = { Hades = 1 }, },
			},
		
			{ 
				BuyName = "SuperGems", BuyAmount = 1,
				CostName = "SuperLockKeys", CostAmount = 1, 
				PurchaseSound = "/SFX/SuperGemPickup",
				-- GameStateRequirements = { RequiredKills = { Hades = 1 }, },
			},
		
			{ 
				BuyName = "SuperGems", BuyAmount = 1,
				CostName = "Gems", CostAmount = 100, 
				PurchaseSound = "/SFX/SuperGemPickup",
				-- GameStateRequirements = { RequiredKills = { HydraHeadImmortal = 1 }, },
			},
		
			{ 
				BuyName = "MetaPoints", BuyAmount = 500,
				CostName = "SuperGiftPoints", CostAmount = 1, 
				PurchaseSound = "/SFX/Player Sounds/DarknessCollectionPickup",
				-- GameStateRequirements = { RequiredKills = { Theseus = 1 }, },
			},
		
			{ 
				BuyName = "Gems", BuyAmount = 50,
				CostName = "MetaPoints", CostAmount = 300, 
				PurchaseSound = "/SFX/GemPickup",
				-- GameStateRequirements = { RequiredMinShrinePointThresholdClear = 1 },
			},
		}
		
	end)
end

if config.UnlockLounge then

end

if config.UnlockFatedList then

end