--[[
    ShowChamberNumber
    Authors:
        Museus (Discord: Museus#7777)
        Ellomenop (Discord: ellomenop#2254)

    Shows the current Chamber Number immediately upon starting a room. If that
    fails for some reason, fall back to showing the Depth during ShowCombatUI.
]]
ModUtil.Mod.Register("ShowChamberNumber")

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

-- Hiding Depth Counter doesn't actually do anything
ModUtil.Path.Wrap("HideDepthCounter", function ( baseFunc )
    return
end)
