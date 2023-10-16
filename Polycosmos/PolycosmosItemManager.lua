ModUtil.Mod.Register( "PolycosmosItemManager" )


local ItemsDataArray=
{
    "Darkness",
    "Keys",
}

-------------------- Auxiliary function for checking if a item is a filler item
function PolycosmosItemManager.IsFillerItem(string)
    return PolycosmosUtils.HasValue(ItemsDataArray, string)
end

--------------------

function PolycosmosItemManager.GiveFillerItem(item)
    if (item == "Keys") then
        if (GameState.Resources.LockKeys) then
            GameState.Resources.LockKeys = GameState.Resources.LockKeys + 15
        else
            GameState.Resources.LockKeys = 15
        end
    end
    if (item == "Darkness") then
        if (GameState.Resources.MetaPoints) then
            GameState.Resources.MetaPoints = GameState.Resources.MetaPoints + 500
        else
            GameState.Resources.MetaPoints = 500
        end
    end
end