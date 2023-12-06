local ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
	local collectors = 'mining_washedstone'
	ESX.RegisterUsableItem('mining_stone', function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('xkrz_mining:checkwater', source, ESX.GetItemLabel('mining_stone'), 10000)
	end)
end)

RegisterServerEvent('xkrz_mining:washedStone')
AddEventHandler('xkrz_mining:washedStone', function()
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
    local items = {}

    for i = 1, math.random(1, 1) do  
        local item = Config.Reward.ItemList[math.random(1, #Config.Reward.ItemList)]
        items[#items + 1] = item
    end
	for k,v in pairs(items) do
		xPlayer.removeInventoryItem('mining_stone', 1)
		xPlayer.addInventoryItem(v, i)
	end
end)

RegisterServerEvent('xkrz_mining:removeDrillBit')
AddEventHandler('xkrz_mining:removeDrillBit', function()
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem('mining_drill_bit', 1)
end)

RegisterServerEvent('xkrz_mining:drillReward')
AddEventHandler('xkrz_mining:drillReward', function()
	local _source = source
	xPlayer = ESX.GetPlayerFromId(_source)
	local count = math.random(3, 5)
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
