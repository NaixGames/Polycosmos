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
    if (CurrentRun == nil) then
        return
    end

    while (MoneyPunishmentRequest > GameState.TrapLedger["MoneyPunishment"]) do
        if (CurrentRun.Money < 50) then
            break
        else
            CurrentRun.Money = mathf.max(CurrentRun.Money - 100,0)
		    ShowResourceUIs({ CombatOnly = false, UpdateIfShowing = true })
		    UpdateMoneyUI( CurrentRun.Money )

            PolycosmosMessages.PrintToPlayer("Someone sent you a Money punishment")

            GameState.TrapLedger["MoneyPunishment"] = GameState.TrapLedger["MoneyPunishment"] + 1
        end
    end

    while (HealthPunishmentRequest > GameState.TrapLedger["HealthPunishment"]) do
        damage = CurrentRun.Hero.MaxHealth/4
        CurrentRun.Hero.Health  = mathf.max(CurrentRun.Hero.Health  - damage,0)

        PolycosmosMessages.PrintToPlayer("Someone sent you a Health punishment")

        GameState.TrapLedger["HealthPunishment"] = GameState.TrapLedger["HealthPunishment"] + 1
    end

    MoneyPunishmentRequest = 0
    HealthPunishmentRequest = 0
end

--------------------
