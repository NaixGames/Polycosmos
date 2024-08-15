ModUtil.Mod.Register( "PolycosmosMessages" )

-- Change PrintStack height to take up less screen space
-- Default PrintStackHeight = 10
ModUtil.Table.Merge( ModUtil.Hades, {
	PrintStackHeight = 4
} )

local maxPrintBuffer = 4
local actualPrintBuffer = 0
local timeBuffer = 0.2
local fullBuffer = false
------------ Utils to uniformly change how we desplay messages

function PolycosmosMessages.PrintToPlayer(message)
    if (fullBuffer) then
        return
    end
    if (actualPrintBuffer == maxPrintBuffer) then
        ModUtil.Hades.PrintStack("Many other items obtained", 5, {1,0.9,0.1,1}, {0,0,0,1}, 20)
        fullBuffer = true
        return
    end
    ModUtil.Hades.PrintStack(message, 5, {1,0.9,0.1,1}, {0,0,0,1}, 20)
    actualPrintBuffer = actualPrintBuffer + 1
    wait( timeBuffer )
    actualPrintBuffer = actualPrintBuffer - 1
    if (actualPrintBuffer == 0 and fullBuffer) then
        fullBuffer = false
    end
end

function PolycosmosMessages.ClearBufferFlags()
    fullBuffer = false
    actualPrintBuffer = 0
end

function PolycosmosMessages.PrintInformationMessage(message)
    ModUtil.Hades.PrintStack(message, 5, {0.3,0.9,1,1}, {0,0,0,1}, 20)
end

function PolycosmosMessages.PrintErrorMessage(message, id)
    ModUtil.Hades.PrintStack("Error number "..id..": "..message, 5, {1,0,0,1}, {0,0,0,1}, 20)
end

-- for id Error

--id = 0x  is for Boon related errors
--id = 1x is for Heat related errors

--id = 9x is for AP related errors
