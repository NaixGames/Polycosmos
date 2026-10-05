ModUtil.Mod.Register("PolycosmosInfernalTroveManager")

PolycosmosInfernalTroveManager = {}
PolycosmosInfernalTroveManager.TrovesChecked = {}

--The native trove handling just tracks decay cycles with varying time constraints, so we'll start our own tracker
ModUtil.Path.Wrap("StartChallengeEncounter", function(baseFunc, challengeSwitch)
    challengeSwitch.APStartTime = _worldTime
    return baseFunc(challengeSwitch)
end)

ModUtil.Path.Wrap("EndChallengeEncounter", function(baseFunc, challengeEncounter)
    if not GameState.ClientGameSettings["TroveSanity"] then
        return baseFunc(challengeEncounter)
    end
    local challengeSwitch = challengeEncounter.Switch
    --No rewards if you failed :/
    local failed = challengeSwitch.CurrentValue <= challengeEncounter.MinValue
    if failed then
        return baseFunc(challengeEncounter)
    end

    if challengeSwitch.APStartTime then
        local elapsedTime = _worldTime - challengeSwitch.APStartTime - challengeEncounter.DecayStartDelay

        if elapsedTime <= 15 then
            PolycosmosEvents.ProcessLocationCheck("Infernal Trove in 15 seconds", true)
        end
        if elapsedTime <= 30 then
            PolycosmosEvents.ProcessLocationCheck("Infernal Trove in 30 seconds", true)
        end
        if elapsedTime <= 45 then
            PolycosmosEvents.ProcessLocationCheck("Infernal Trove in 45 seconds", true)
        end
        if elapsedTime <= 60 then
            PolycosmosEvents.ProcessLocationCheck("Infernal Trove in 60 seconds", true)
        end
    end

    --Track how many troves have been opened in each region so we can send checks (easy to expand here for multiple troves in a region or more thresholds for total)
    local troveRegion = CurrentRun.CurrentRoom.ChallengeEncounterName
    local trovesChecked = PolycosmosInfernalTroveManager.TrovesChecked[troveRegion]
    local troveLocationName = troveRegion:gsub("TimeChallenge", "First Infernal Trove: ")
    local totalCount = 0

    if trovesChecked == nil then
        PolycosmosEvents.ProcessLocationCheck(troveLocationName, true)
    end
    trovesChecked = trovesChecked or 0
    PolycosmosInfernalTroveManager.TrovesChecked[troveRegion] = trovesChecked + 1

    for _, count in pairs(PolycosmosInfernalTroveManager.TrovesChecked) do
        totalCount = totalCount + count
    end
    if totalCount == 5 then
        PolycosmosEvents.ProcessLocationCheck("5 Infernal Troves", true)
    elseif totalCount == 10 then
        PolycosmosEvents.ProcessLocationCheck("10 Infernal Troves", true)
    end
    return baseFunc(challengeEncounter)

end)
