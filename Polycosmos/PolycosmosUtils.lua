ModUtil.Mod.Register( "PolycosmosUtils" )

-- Auxiliary function to check if an array has a value
function PolycosmosUtils.HasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end


------------------------------------------------------------------

--Auxiliary function parse an string of item list to an actual array

function PolycosmosUtils.ParseStringToArray( message )
    local resultTable = {}
    if (message == nil or message == "") then
        return resultTable
    end

    for word in string.gmatch(message, "([^,]+)") do
        table.insert(resultTable, word)
    end
    return resultTable
end

function PolycosmosUtils.NewParseStringToArray( message )
    local resultTable = {}
    if (message == nil or message == "") then
        return resultTable
    end

    for word in string.gmatch(message, "([^-]+)") do
        table.insert(resultTable, word)
    end
    return resultTable
end

function PolycosmosUtils.ParseSeparatingStringToArrayWithDash( message )
    local resultTable = {}
    if (message == nil or message == "") then
        return resultTable
    end

    for word in string.gmatch(message, "([^||]+)") do
        table.insert(resultTable, word)
    end
    return resultTable
end


function PolycosmosUtils.ParseStringToArrayWithDash( message )
    local resultTable = {}
    if (message == nil or message == "") then
        return resultTable
    end

    for word in string.gmatch(message, "([^--]+)") do
        table.insert(resultTable, word)
    end
    return resultTable
end


function PolycosmosUtils.ParseStringToArrayWithLenghts( message )
    local resultTable = {}

    if (message == nil or message == "") then
        return resultTable
    end


    local j = 1
    while j <= string.len(message) do
        --First get the length of next message
        local sepindex = 1
        for i=j, string.len(message) do
            local ichar = string.sub(message, i,i)
            if ichar == "|" then
                sepindex = i
                break
            end
        end

        local lenmessage = tonumber(string.sub(message, j, sepindex - 1))
        local word = string.sub(message, sepindex + 1 , sepindex + lenmessage)
        table.insert(resultTable, word)
        j = math.max(1, sepindex + lenmessage+1)

    end


    return resultTable
end


function PolycosmosUtils.PrintTableDebug( table )
    for key, data in pairs(table) do
        print(key .. " - " .. data)
    end
end