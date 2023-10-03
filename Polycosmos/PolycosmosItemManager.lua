ModUtil.Mod.Register( "PolycosmosItemManager" )


local ItemsDataArray=
{
    "Darkness",
    "Keys",
}

-------------------- Auxiliary function for checking if a item is a filler item
function PolycosmosItemManager.IsFillerItem(string)
    return PolycosmosEvents.HasValue(ItemsDataArray, string)
end

--------------------

function PolycosmosItemManager.GiveFillerItem(item)
    --Give item
    --Tell Client that we dont need those items anymore! To avoid gaining them multiple times
    print("this should give "..item.." :)")
    --We should also, somehow avoid getting the item multiple times.
end