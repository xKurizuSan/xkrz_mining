local ESX = exports['es_extended']:getSharedObject()
local ox_target = exports.ox_target
local ox_inventory = exports['ox_inventory']

local smeltStarted = false
local smeltingInputOptions = {}
local smeltStartedClump = false
local smeltingInputOptionsClump = {}
local materialInput = false
local materialsOptions = {}
local sellingInputOptions = {}

CreateThread(function()
	local modelHash = 'cs_x_rubweea'

    if not HasModelLoaded(modelHash) then 
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
        end
    end

    local obj = {
        CreateObject(modelHash, vector3(2969.5002, 2847.2454, 46.9747), true),
        CreateObject(modelHash, vector3(2970.5601, 2845.9080, 46.6155), true),
        CreateObject(modelHash, vector3(2971.1665, 2844.5430, 46.5892), true),
        CreateObject(modelHash, vector3(2971.6770, 2843.2639, 46.3458), true)
    }
    FreezeEntityPosition(obj[1], true)
    FreezeEntityPosition(obj[2], true)
    FreezeEntityPosition(obj[3], true)
    FreezeEntityPosition(obj[4], true)
    SetEntityRotation(obj[1], 45.0, 1.0, 1.0, 0, 0)
    SetEntityRotation(obj[2], 150.0, 70.0, 80.0, 0, 0)
    SetEntityRotation(obj[3], 45.0, 50.0, 1.0, 0, 0)  
    SetEntityRotation(obj[4], 140.0, 1.0, 5.0, 0, 0)  
end) 

exports['qb-target']:AddTargetModel('cs_x_rubweea',  {
    options = {
      {
        type = 'client',
        event = 'xkrz_mining:smashrock',
        icon = "fa-solid fa-hammer",
        label = "Mining",
      },
      {
        type = 'client',
        event = 'xkrz_mining:drillrock',
        icon = "fa-solid fa-life-ring",
        label = "Drill",
        item = 'mining_drill',
      },
    },
    distance = 1.5,
})

exports.qtarget:AddBoxZone("SmeltingRaw", vector3(1086.27, -2003.67, 30.88), 4.2, 2.8, {
    name="SmeltingRaw",
    heading=317,
    minZ=25,
    maxZ=27,
    }, {
   options = {
        {
            event = "xkrz_mining:smelting",
            icon = "fa-brands fa-free-code-camp",
            label = "Schmelzen Roh",
        },
        {
            event = "xkrz_mining:smeltingclump",
            icon = "fa-brands fa-free-code-camp",
            label = "Schmelzen Klumpen",
        },
    }, 
distance = 1.2
})

exports.qtarget:AddBoxZone("Bench", vector3(1070.39, -2004.94, 32.08), 0.8, 0.8, {
    name="Bench",
    heading=325,
    minZ=25,
    maxZ=27,
    }, {
   options = {
        {
            event = "xkrz_mining:bench",
            icon = "fa-solid fa-gem",
            label = "Schleifen",
        },
    }, 
distance = 2.2
}) 

exports.qtarget:AddBoxZone("Sell", vector3(797.65, -2988.69, 6.02), 0.6, 0.4, {
    name="Sell",
    heading=0,
    minZ=25,
    maxZ=27,
    }, {
   options = {
        {
            event = "xkrz_mining:sellMenu",
            icon = "fa-solid fa-gem",
            label = "Verkaufen",
        },
    }, 
distance = 2.2
}) 

RegisterNetEvent('xkrz_mining:drillrock')
AddEventHandler('xkrz_mining:drillrock', function()
    local PlayerWeight = exports.ox_inventory:GetPlayerWeight()
    local MaxWeight = exports.ox_inventory:GetPlayerMaxWeight()
    if PlayerWeight <= MaxWeight then
        local hasItem = exports.ox_inventory:Search('count', 'mining_drill_bit')
        if hasItem >= 1 then
            local propModel = GetHashKey("hei_prop_heist_drill")
            RequestAnimDict("anim@heists@fleeca_bank@drilling")
                while not HasAnimDictLoaded("anim@heists@fleeca_bank@drilling") do
                    Citizen.Wait(0)
                end
            RequestModel(propModel)
                while not HasModelLoaded(propModel) do
                    Citizen.Wait(0)
                end
            local ped = PlayerPedId()
            local prop = CreateObject(propModel, 0, 0, 0, true, true, true)
            AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.16, 0.0, 0.0, 90.0, 270.0, 180.0, true, true, false, true, 1, true)
            TaskPlayAnim(ped, "anim@heists@fleeca_bank@drilling", "drill_straight_start", 8.0, 1.0, -1, 1, 0, false, false, false)
            local success = lib.skillCheck(Config.DrillSkillDifficulty, Config.SkillCheckKeys)
	        if success then
                lib.progressCircle({
                duration = 5000,
                label = '',
                useWhileDead = false,
                canCancel = false,
                position = "bottom",
                disable = {
                    move = true,
                    car = true,
                    combat = true,
                    mouse = false
                },
                })
                DetachEntity(prop, true, true)
                DeleteEntity(prop)
                ClearPedTasks(ped)
                lib.notify({
                    title = 'Erfolg',
                    description = 'Du warst erfolgreich.',
                    position = 'top',
                    type = 'success'
                })
                TriggerServerEvent('xkrz_mining:drillReward')
            else 
                DetachEntity(prop, true, true)
                DeleteEntity(prop)
                ClearPedTasks(ped)
                lib.notify({
                    title = 'Error',
                    description = 'Dein Steinbohrer ist abgebrochen.',
                    position = 'top',
                    type = 'error'
                })
                if Config.RemoveDrillBit then
                    TriggerServerEvent('xkrz_mining:removeDrillBit')
                end
            end
        else 
            lib.notify({
                title = 'Error',
                description = 'Du brauchst einen Steinbohrer',
                position = 'top',
                type = 'error'
            })
        end 
    else 
    lib.notify({
        title = 'Error',
        description = 'Du kannst nicht mehr tragen!!',
        position = 'top',
        type = 'error'
    })
    end
end)

RegisterNetEvent('xkrz_mining:smashrock')
AddEventHandler('xkrz_mining:smashrock', function()
    local PlayerWeight = exports.ox_inventory:GetPlayerWeight()
    local MaxWeight = exports.ox_inventory:GetPlayerMaxWeight()
    if PlayerWeight <= MaxWeight then
        local hasItem = exports.ox_inventory:Search('count', 'mining_pickaxe')
        if hasItem >= 1 then
            local success = lib.skillCheck(Config.PickAxeSkillDifficulty, Config.SkillCheckKeys)
            if success then
                lib.progressCircle({
                duration = 5000,
                label = '',
                useWhileDead = false,
                canCancel = false,
                position = "bottom",
                disable = {
                    move = true,
                    car = true,
                    combat = true,
                    mouse = false
                },
                anim = {dict = 'amb@world_human_hammering@male@base', clip = 'base'},
                prop = {bone = 57005, model = 'prop_tool_pickaxe', pos = vec3(0.09, -0.53, -0.22), rot = vec3(252.0, 180.0, 0.0)}    
                })
                lib.notify({
                    title = 'Erfolg',
                    description = 'Du warst erfolgreich.',
                    position = 'top',
                    type = 'success'
                })
                lib.callback('xkrz_mining:Reward', source, cb, input)
            else
                lib.notify({
                    title = 'Error',
                    description = 'Versuch es nochmal.',
                    position = 'top',
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = 'Error',
                description = 'Du hast keine Spitzhacke.',
                position = 'top',
                type = 'error'
            })
        end
    else 
        lib.notify({
            title = 'Error',
            description = 'Du kannst nicht mehr tragen!!',
            position = 'top',
            type = 'error'
        })
    end
end)

for k, v in pairs(Config.SmeltingOptions) do
    table.insert(smeltingInputOptions, {value = k, label = v.label})
end 

RegisterNetEvent('xkrz_mining:smelting')
AddEventHandler('xkrz_mining:smelting', function()
    local smeltInput = lib.inputDialog('Material auswählen', {
        {type = 'select', label = 'Rohmaterial', description = 'Was willst du schmelzen?', icon = 'fa-solid fa-list', options = smeltingInputOptions},
        {type = 'checkbox', label = 'Alles schmelzen?'},
        {type = 'number', label = 'Anzahl', description = 'Wie viel möchtest du schmelzen?', icon = 'hashtag', min = 1}
    })
    if smeltInput == nil then 
        smeltStarted = false
    else
        if smeltInput[2] then 
            local hasItem = exports.ox_inventory:Search('count', smeltInput[1])
            if hasItem >= 1 then
                local removeItem = nil
                local giveItem = nil
                local duration = nil
                for k, v in pairs(Config.SmeltingOptions) do 
                    if k == smeltInput[1] then 
                        removeItem = k
                        giveItem = k
                        duration = v.duration
                    end
                end
                if duration == nil then 
                    smeltStarted = false
                    return 
                else
                    lib.progressCircle({
                        duration = duration * hasItem,
                        label = 'Schmelze ein...',
                        useWhileDead = false,
                        canCancel = false,
                        position = "bottom",
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        anim = {dict = 'amb@world_human_stand_fire@male@idle_a', clip = 'idle_a'},
                    })
                    giveItem = giveItem:gsub("raw_", "")
                    lib.callback('xkrz_mining:rewardSmeltItem', source, cb, removeItem, giveItem, hasItem)
                    smeltStarted = false
                end
            else
                lib.notify({
                    title = 'Error',
                    description = 'Du hast nicht genug Items.',
                    position = 'top',
                    type = 'error'
                })
                smeltStarted = false
            end
        else
            local hasItem = exports.ox_inventory:Search('count', smeltInput[1])
            if hasItem >= smeltInput[3] then
                local removeItem = nil
                local giveItem = nil
                local duration = nil
                for k, v in pairs(Config.SmeltingOptions) do 
                    if k == smeltInput[1] then 
                        removeItem = k
                        giveItem = k
                        duration = v.duration
                    end
                end
                if duration == nil then 
                    smeltStarted = false
                    return 
                else
                    lib.progressCircle({
                        duration = duration * smeltInput[3],
                        label = 'Schmelze ein...',
                        useWhileDead = false,
                        canCancel = false,
                        position = "bottom",
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        anim = {dict = 'amb@world_human_stand_fire@male@idle_a', clip = 'idle_a'},
                    })
                    giveItem = giveItem:gsub("raw_", "")
                    lib.callback('xkrz_mining:rewardSmeltItem', source, cb, removeItem, giveItem, smeltInput[3])
                    smeltStarted = false
                end
            else
                lib.notify({
                    title = 'Error',
                    description = 'Du hast nicht genug Items.',
                    position = 'top',
                    type = 'error'
                })
                smeltStarted = false
            end
        end
    end 
end)

for k, v in pairs(Config.SmeltingOptionsClump) do
    table.insert(smeltingInputOptionsClump, {value = k, label = v.label})
end 

RegisterNetEvent('xkrz_mining:smeltingclump')
AddEventHandler('xkrz_mining:smeltingclump', function()
    local smeltInputClump = lib.inputDialog('Material auswählen', {
        {type = 'select', label = 'Rohmaterial', description = 'Was willst du schmelzen?', icon = 'fa-solid fa-list', options = smeltingInputOptionsClump},
        {type = 'checkbox', label = 'Alles schmelzen?'},
        {type = 'number', label = 'Anzahl', description = 'Wie viel möchtest du schmelzen?', icon = 'hashtag', min = 1}
    })
    if smeltInputClump == nil then 
        smeltStartedClump = false
    else
        if smeltInputClump[2] then 
            local hasItem = exports.ox_inventory:Search('count', smeltInputClump[1])
            if hasItem >= 1 then
                local removeItem = nil
                local giveItem = nil
                local duration = nil
                for k, v in pairs(Config.SmeltingOptionsClump) do 
                    if k == smeltInputClump[1] then 
                        removeItem = k
                        giveItem = k
                        duration = v.duration
                    end
                end
                if duration == nil then 
                    smeltStartedClump = false
                    return 
                else
                    lib.progressCircle({
                        duration = duration * hasItem,
                        label = 'Schmelze ein...',
                        useWhileDead = false,
                        canCancel = false,
                        position = "bottom",
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        anim = {dict = 'amb@world_human_stand_fire@male@idle_a', clip = 'idle_a'},
                    })
                    giveItem = giveItem:gsub("clump_", "")
                    lib.callback('xkrz_mining:rewardSmeltItemClump', source, cb, removeItem, giveItem, hasItem)
                    smeltStartedClump = false
                end
            else
                lib.notify({
                    title = 'Error',
                    description = 'Du hast nicht genug Items.',
                    position = 'top',
                    type = 'error'
                })
                smeltStartedClump = false
            end
        else 
            local hasItem = exports.ox_inventory:Search('count', smeltInputClump[1])
            if hasItem >= smeltInputClump[3] then
                local removeItem = nil
                local giveItem = nil
                local duration = nil
                for k, v in pairs(Config.SmeltingOptionsClump) do 
                    if k == smeltInputClump[1] then 
                        removeItem = k
                        giveItem = k
                        duration = v.duration
                    end
                end
                if duration == nil then 
                    smeltStartedClump = false
                    return 
                else
                    lib.progressCircle({
                        duration = duration * smeltInputClump[3],
                        label = 'Schmelze ein...',
                        useWhileDead = false,
                        canCancel = false,
                        position = "bottom",
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        anim = {dict = 'amb@world_human_stand_fire@male@idle_a', clip = 'idle_a'},
                    })
                    giveItem = giveItem:gsub("clump_", "")
                    lib.callback('xkrz_mining:rewardSmeltItemClump', source, cb, removeItem, giveItem, smeltInputClump[3])
                    smeltStartedClump = false  
                end 
            else
                lib.notify({
                    title = 'Error',
                    description = 'Du hast nicht genug Items.',
                    position = 'top',
                    type = 'error'
                })
                smeltStartedClump = false
            end
        end
    end
end)

for k, v in pairs(Config.materialsOptions) do
    table.insert(materialsOptions, {value = k, label = v.label})
end 

RegisterNetEvent('xkrz_mining:bench')
AddEventHandler('xkrz_mining:bench', function()
    local materialInput = lib.inputDialog('Material auswählen', {
        {type = 'select', label = 'Rohmaterial', description = 'Was möchtest du schleifen?', icon = 'fa-solid fa-list', options = materialsOptions},
        {type = 'checkbox', label = 'Alles schleifen?'},
        {type = 'number', label = 'Anzahl', description = 'Wie viel möchtest du schleifen?', icon = 'hashtag', min = 1}
    })
    if materialInput == nil then 
        materialInput = false
    else
        if materialInput[2] then 
            local hasItem2 = exports.ox_inventory:Search('count', materialInput[1])
            if hasItem2 >= 1 then
                local removeItem = nil
                local giveItem = nil
                local duration = nil
                for k, v in pairs(Config.materialsOptions) do 
                    if k == materialInput[1] then 
                        removeItem = k
                        giveItem = k
                        duration = v.duration
                    end
                end
                if duration == nil then 
                    materialInput = false
                    return 
                else
                    lib.progressCircle({
                        duration = duration * hasItem2,
                        label = 'Schleifen...',
                        useWhileDead = false,
                        canCancel = false,
                        position = "bottom",
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        anim = {dict = 'amb@world_human_stand_fire@male@idle_a', clip = 'idle_a'},
                    })
                    giveItem = giveItem:gsub("raw_", "")
                    lib.callback('xkrz_mining:rewardMaterial', source, cb, removeItem, giveItem, hasItem2)
                    materialInput = false
                end
            else
                lib.notify({
                    title = 'Error',
                    description = 'Du hast nicht genug Items.',
                    position = 'top',
                    type = 'error'
                })
                materialInput = false 
            end 
        else
            local hasItem3 = exports.ox_inventory:Search('count', materialInput[1])
            if hasItem3 >= materialInput[3] then
                print(hasItem3)
                local removeItem = nil
                local giveItem = nil
                local duration = nil
                for k, v in pairs(Config.materialsOptions) do 
                    if k == materialInput[1] then 
                        removeItem = k
                        giveItem = k
                        duration = v.duration
                    end
                end
                if duration == nil then 
                    materialInput = false
                    return 
                else
                    print('test')
                    lib.progressCircle({
                        duration = duration * materialInput[3],
                        label = 'Schleifen...',
                        useWhileDead = false,
                        canCancel = false,
                        position = "bottom",
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        anim = {dict = 'amb@world_human_stand_fire@male@idle_a', clip = 'idle_a'},
                        })
                    giveItem = giveItem:gsub("raw_", "")
                    lib.callback('xkrz_mining:rewardMaterial', source, cb, removeItem, giveItem, materialInput[3])
                    materialInput = false 
                end 
            else
                lib.notify({
                    title = 'Error',
                    description = 'Du hast nicht genug Items.',
                    position = 'top',
                    type = 'error'
                })
                materialInput = false
            end
        end
    end 
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function GetPed() return PlayerPedId() end

local IsAnimated = false

RegisterNetEvent('xkrz_mining:checkwater')
AddEventHandler('xkrz_mining:checkwater', function()
    if not IsAnimated then
        if not IsPedInAnyVehicle(GetPed(), false) then
            if IsEntityInWater(GetPed()) then
                local itemsAll = exports.ox_inventory:Search('count', 'mining_stone')
                
                if itemsAll >= 10 then
                    LoadAnimDict('anim@heists@narcotics@funding@gang_idle')
                    TaskPlayAnim(GetPed(), 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
                    IsAnimated = true
                    lib.progressCircle({
                        duration = 1000 * itemsAll / 2,
                        label = 'Wasche Stein..',
                        useWhileDead = false,
                        canCancel = false, -- Wenn "true" werden sofort alle Items gegeben bei Animationsabbruch. (Testmodus)
                        position = "bottom",
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        },
                        onCancel = function()
                            ClearPedTasks(GetPed())
                            IsAnimated = false
                            lib.notify({
                                title = 'Abgebrochen',
                                description = 'Das Waschen der Steine wurde abgebrochen.',
                                position = 'top',
                                type = 'error'
                            })
                        end
                    })
                    Wait(100)
                    if IsAnimated then
                        ClearPedTasks(GetPed())
                        IsAnimated = false
                        lib.callback('xkrz_mining:washedStone', source, cb, itemsAll)
                        lib.notify({
                            title = 'Erfolg',
                            description = 'Du hast deine Steine gewaschen.',
                            position = 'top',
                            type = 'success'
                        })
                    end
                else
                    lib.notify({
                        title = 'Fehler',
                        description = 'Du benötigst mindestens 10 Steine, um sie zu waschen.',
                        position = 'top',
                        type = 'error'
                    })
                end
            else
                lib.notify({
                    title = 'Fehler',
                    description = 'Gehe näher ans Wasser',
                    position = 'top',
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = 'Fehler',
                description = 'Du bist in einem Fahrzeug',
                position = 'top',
                type = 'error'
            })
        end
    end
end)


-- THX to McKl1992 for the Stonewash Fix

Citizen.CreateThread(function()
    if Config.Sell then  
        local NPCPosition = {x = 797.6882, y = -2988.6956, z = 6.0209, rot = 89.5012} 
        local pedModel = GetHashKey("csb_trafficwarden")   
	    RequestModel(pedModel)
	    while not HasModelLoaded(pedModel) do 
	    	Wait(10)
	    end
	    local npc = CreatePed(4, pedModel,  NPCPosition.x, NPCPosition.y, NPCPosition.z - 1.0, NPCPosition.rot, false, false)
	    FreezeEntityPosition(npc, true)
	    SetEntityHeading(npc, NPCPosition.rot)
	    SetEntityInvincible(npc, true)
	    SetBlockingOfNonTemporaryEvents(npc, true)
    end
end)

function ShowNotification(text)
 	SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
 	DrawNotification(false, true)
end

function showInfobar(msg)
 	CurrentActionMsg  = msg
 	SetTextComponentFormat('STRING')
	AddTextComponentString(CurrentActionMsg)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

for k, v in pairs(Config.sellingInputOptions) do
    table.insert(sellingInputOptions, {value = k, label = v.label})
end 

RegisterNetEvent('xkrz_mining:sellMenu')
AddEventHandler('xkrz_mining:sellMenu', function()
    if Config.Sell then     
        local sellInput = lib.inputDialog('Material auswählen', {
            {type = 'select', label = 'Material', description = 'Was willst du verkaufen?', icon = 'recycle', options = sellingInputOptions},
            {type = 'checkbox', label = 'Alles verkaufen?'},
            {type = 'number', label = 'Menge', description = 'Wieviel willst du verkaufen?', icon = 'hashtag', min = 1}
        })
        if sellInput == nil then 
            sellInput = false
        else
            if sellInput[2] then 
                local checkItem = sellInput[1]
                local hasItem = exports.ox_inventory:Search('count', sellInput[1])
                if hasItem >= 1 then
                    local removeItem = nil
                    local price = nil
                    for k, v in pairs(Config.sellingInputOptions) do 
                        if k == sellInput[1] then 
                            removeItem = k
                            price = v.price 
                        end
                    end
                    price = price * hasItem
                    local sellItem = checkItem
                    if lib.progressCircle({
                        duration = math.random(1500, 2500),
                        label = 'verkaufe...',
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        anim = {dict = 'mp_common', clip = 'givetake1_a'},
                        disable = {move = true, car = true, combat = true}
                    }) then
                        lib.callback('xkrz_mining:sellItem', source, cb, removeItem, hasItem, price)
                    end
                else
                    lib.notify({
                        title = 'Error',
                        description = 'Du hast nicht genug zum verkaufen.',
                        position = 'top',
                        type = 'error'
                    })
                end
            else             
                if sellInput == nil then 
                    return 
                else
                    local checkItem = sellInput[1]
                    local hasItem = exports.ox_inventory:Search('count', sellInput[1])
                    if hasItem >= sellInput[3] then
                        local removeItem = nil
                        local price = nil
                        for k, v in pairs(Config.sellingInputOptions) do 
                            if k == sellInput[1] then 
                                removeItem = k
                                price = v.price 
                            end
                        end
                        price = price * sellInput[3]
                        local sellItem = checkItem
                        if lib.progressCircle({
                            duration = math.random(1500, 2500),
                            label = 'Verkaufe...',
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            anim = {dict = 'mp_common', clip = 'givetake1_a'},
                            disable = {move = true, car = true, combat = true}
                        }) then
                            lib.callback('xkrz_mining:sellItem', source, cb, removeItem, sellInput[3], price)
                        end
                    else 
                        lib.notify({
                            title = 'Error',
                            description = 'Du hast nicht genug zum verkaufen.',
                            position = 'top',
                            type = 'error'
                        })
                    end
                end
            end
        end
    end
end)

if Config.BlipSmelt then 
    local smeltBlip = AddBlipForCoord(1086.3845, -2003.6810, 30.9738)
    SetBlipSprite(smeltBlip, 648)
    SetBlipColour(smeltBlip, 17)
    SetBlipScale(smeltBlip, 0.80)
    SetBlipAsShortRange(smeltBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Schmelze')
    EndTextCommandSetBlipName(smeltBlip)
end

if Config.BlipMining then
    local miningBlip = AddBlipForCoord(2971.1665, 2844.5430, 46.5892)
    SetBlipSprite(miningBlip, 622)
    SetBlipColour(miningBlip, 64)
    SetBlipScale(miningBlip, 1.1)
    SetBlipAsShortRange(miningBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Mining')
    EndTextCommandSetBlipName(miningBlip)
end 

if Config.BlipGrind then
    local grindBlip = AddBlipForCoord(1070.39, -2004.94, 32.08)
    SetBlipSprite(grindBlip, 617)
    SetBlipColour(grindBlip, 64)
    SetBlipScale(grindBlip, 0.80)
    SetBlipAsShortRange(grindBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Schleifen')
    EndTextCommandSetBlipName(grindBlip)
end  

if Config.Sell and Config.BlipSell then
    local sellBlip = AddBlipForCoord(797.6882, -2988.6956, 6.0209)
    SetBlipSprite(sellBlip, 108)
    SetBlipColour(sellBlip, 64)
    SetBlipScale(sellBlip, 0.80)
    SetBlipAsShortRange(sellBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Verkäufer')
    EndTextCommandSetBlipName(sellBlip)
end  