local ESX = exports['es_extended']:getSharedObject()
ox_inventory = exports['ox_inventory']

Citizen.CreateThread(function()
	local collectors = 'mining_washedstone'
	ESX.RegisterUsableItem('mining_stone', function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('xkrz_mining:checkwater', source, ESX.GetItemLabel('mining_stone'), 10000)
	end)
end)

lib.callback.register('xkrz_mining:washedStone', function(source, itemsAll)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local items = {}
    
    local convertedItems = ConvertItems(itemsAll)

    for _, convertedItem in pairs(convertedItems) do
        local randItem = convertedItem.name
        local amount = convertedItem.amount
        xPlayer.removeInventoryItem('mining_stone', convertedItem.amount)
        xPlayer.addInventoryItem(randItem, amount)
    end
end)

function ConvertItems(itemsAll)
    local convertedItems = {}

    local remainingItems = itemsAll
    while remainingItems > 0 do
        local randIndex = math.random(1, #Config.Reward.ItemList)
        local randItem = Config.Reward.ItemList[randIndex]
        local amount = math.min(math.floor(itemsAll / #Config.Reward.ItemList), remainingItems)
        
        table.insert(convertedItems, {name = randItem, amount = amount})
        remainingItems = remainingItems - amount
    end

    return convertedItems
end

RegisterServerEvent('xkrz_mining:removeDrillBit')
AddEventHandler('xkrz_mining:removeDrillBit', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    local random = math.random(1, 2)
    if random == 1 then 
	    xPlayer.removeInventoryItem('mining_drill_bit', 1)
    end
end)

RegisterServerEvent('xkrz_mining:drillReward')
AddEventHandler('xkrz_mining:drillReward', function()
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	local count = math.random(Config.DrillMinAmount, Config.DrillMaxAmount)
    local items = {}

    for i = 1, math.random(1, 1) do  
        local item = Config.DrillReward.ItemList[math.random(1, #Config.DrillReward.ItemList)]
        items[#items + 1] = item
    end
	for k,v in pairs(items) do
		xPlayer.addInventoryItem('mining_stone', count)
		xPlayer.addInventoryItem(v, i)
	end
end)

lib.callback.register('xkrz_mining:Reward', function(source, input)
    local src = source
	local ped = ESX.GetPlayerFromId(src)
	local count = math.random(1, 3)
		ped.addInventoryItem('mining_stone', count)
end)

lib.callback.register('xkrz_mining:hasItem', function(source, item)
    local hasItem = ox_inventory:Search(source, 'count', item)
    return hasItem
end)

lib.callback.register('xkrz_mining:rewardSmeltItem', function(source, item, giveItem, quantity)
    local src = source
    local ped = ESX.GetPlayerFromId(src)
    ped.removeInventoryItem(item, quantity)
    ped.addInventoryItem(giveItem, quantity)
end)

lib.callback.register('xkrz_mining:rewardSmeltItemClump', function(source, item, giveItem, quantity)
    local src = source
    local ped = ESX.GetPlayerFromId(src)
	local count = math.random(quantity * 3,quantity * 5)
    ped.removeInventoryItem(item, quantity)
    ped.addInventoryItem(giveItem, count)
end)

lib.callback.register('xkrz_mining:rewardMaterial', function(source, item, giveItem, quantity)
    local src = source
    local ped = ESX.GetPlayerFromId(src)
    ped.removeInventoryItem(item, quantity)
    ped.addInventoryItem(giveItem, quantity)
end)

lib.callback.register('xkrz_mining:sellItem', function(source, item, quantity, price)
    local src = source
    local ped = ESX.GetPlayerFromId(src)
    ped.removeInventoryItem(item, quantity)
    ped.addInventoryItem('money', price)
end)
