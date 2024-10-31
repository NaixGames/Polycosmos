ModUtil.Mod.Register( "PolycosmosTrapManager" )

local TrapDataArray=
{
    "MoneyPunishment", --Takes some money away
    "HealthPunishment", --Takes some health away
}

local MoneyPunishmentRequest = 0
local HealthPunishmentRequest = 0

-------------------- Auxiliary function for checking if a item is a filler item
function PolycosmosTrapManager.IsTrapItem(string)
    return PolycosmosUtils.HasValue(TrapDataArray, string)
end

--------------------

function PolycosmosTrapManager.GiveTrapItem(item)
    if (item == "MoneyPunishment") then
        MoneyPunishmentRequest = MoneyPunishmentRequest + 1
    end
    if (item == "HealthPunishment") then
        HealthPunishmentRequest = HealthPunishmentRequest + 1
    end
end

function PolycosmosTrapManager.FlushTrapItems()
    MoneyPunishmentRequest = 0
    HealthPunishmentRequest = 0
end

--------------------

ModUtil.Path.Wrap("SetupEnemyObject", function( baseFunc, newEnemy, currentRun, args )
	PolycosmosTrapManager.ProcessTrapItems()
	return baseFunc(newEnemy, currentRun, args)
end)

function PolycosmosTrapManager.ProcessTrapItems()
    if (GameState.TrapLedger == nil) then
        GameState.TrapLedger = {}
        GameState.TrapLedger["MoneyPunishment"] = 0
        GameState.TrapLedger["HealthPunishment"] = 0
    end

    --I swear to god idk how we can get to this state which a null run but enemies, but this
    --game's architecture never cease to surprise me lol
    if (CurrentRun == nil) or (CurrentRun.RunDepthCache == nil) or (CurrentRun.RunDepthCache == 0) then
        return
    end

    if (MoneyPunishmentRequest > GameState.TrapLedger["MoneyPunishment"]) then
        local difLedger = MoneyPunishmentRequest - GameState.TrapLedger["MoneyPunishment"]
        local maxNumberPunishment = math.floor(CurrentRun.Money/100)
        local numberOfPunishments = math.min(maxNumberPunishment, difLedger)

        if (numberOfPunishments > 0) then
            CurrentRun.Money = math.max(CurrentRun.Money - 100*numberOfPunishments, 1)
		    ShowResourceUIs({ CombatOnly = false, UpdateIfShowing = true })
		    UpdateMoneyUI( CurrentRun.Money )

            PolycosmosMessages.PrintToPlayer("You got a Money punishment")

            GameState.TrapLedger["MoneyPunishment"] = GameState.TrapLedger["MoneyPunishment"] + numberOfPunishments
        end
    end

    if (HealthPunishmentRequest > GameState.TrapLedger["HealthPunishment"]) then
        local difLedger = HealthPunishmentRequest - GameState.TrapLedger["HealthPunishment"]
        local damage = CurrentRun.Hero.MaxHealth/4
        local maxNumberPunishment = math.floor(CurrentRun.Hero.MaxHealth/damage)
        local numberOfPunishments = math.min(maxNumberPunishment, difLedger)

        CurrentRun.Hero.Health  = math.max(CurrentRun.Hero.Health  - damage*numberOfPunishments,1)

        PolycosmosMessages.PrintToPlayer("You got a Health punishment")

        GameState.TrapLedger["HealthPunishment"] = GameState.TrapLedger["HealthPunishment"] + numberOfPunishments
    end

    MoneyPunishmentRequest = 0
    HealthPunishmentRequest = 0
end

--------------------
