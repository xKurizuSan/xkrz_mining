local ESX = exports['es_extended']:getSharedObject()
local ox_target = exports.ox_target

local IsAnimated = false
local smeltStarted = false
local smeltingInputOptions = {}
local smeltStartedClump = false
local smeltingInputOptionsClump = {}
local materialInput = false
local materialsOptions = {}

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
    SetEntityRotation(obj[1], 45.0, 1.0, 1.0, 0, 0)
    SetEntityRotation(obj[2], 150.0, 70.0, 80.0, 0, 0)
    SetEntityRotation(obj[3], 45.0, 50.0, 1.0, 0, 0)  
    SetEntityRotation(obj[4], 140.0, 1.0, 5.0, 0, 0)  
end) 

CreateThread(function()
	local modelHash2 = 'gr_prop_gr_bench_04b'

    if not HasModelLoaded(modelHash2) then 
        RequestModel(modelHash2)
        while not HasModelLoaded(modelHash2) do
            Citizen.Wait(1)
        end
    end

    local obj2 = CreateObject(modelHash2, vector3(1073.1964, -1988.7878, 29.9028), true)

    SetEntityRotation(obj2, 0.0, 0.0, 59.0, 0, 0)

end)

exports['qb-target']:AddTargetModel('cs_x_rubweea',  {
    options = {
      {
        type = 'client',
        event = 'xkrz_mining:smashrock',
        icon = "fa-solid fa-hammer",
        label = "Mining",
      },
    },
    distance = 1.5,
})

exports['qb-target']:AddTargetModel('cs_x_rubweea',  {
    options = {
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
    }, 
distance = 1.2
})

exports.qtarget:AddBoxZone("SmeltingClump", vector3(1086.27, -2003.67, 30.88), 4.2, 2.8, {
    name="SmeltingClump",
    heading=317,
    minZ=25,
    maxZ=27,
    }, {
   options = {
        {
            event = "xkrz_mining:smeltingclump",
            icon = "fa-brands fa-free-code-camp",
            label = "Schmelzen Klumpen",
        },
    }, 
distance = 1.2
})

exports.qtarget:AddBoxZone("Bench", vector3(1073.11, -1988.79, 30.88), 2.2, 1.0, {
    name="Bench",
    heading=328,
    minZ=25,
    maxZ=27,
    }, {
   options = {
        {
            event = "xkrz_mining:bench",
            icon = "fa-brands fa-free-code-camp",
            label = "Schleifen",
        },
    }, 
distance = 2.2
}) 

RegisterNetEvent('xkrz_mining:drillrock')
AddEventHandler('xkrz_mining:drillrock', function()
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
end)

RegisterNetEvent('xkrz_mining:smashrock')
AddEventHandler('xkrz_mining:smashrock', function()
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
end)

for k, v in pairs(Config.SmeltingOptions) do
    if v.smeltable then
        table.insert(smeltingInputOptions, {value = k, label = v.label})
    end
end 

RegisterNetEvent('xkrz_mining:smelting')
AddEventHandler('xkrz_mining:smelting', function()
    local smeltInput = lib.inputDialog('Material auswählen', {
        {type = 'select', label = 'Rohmaterial', description = 'Was willst du schmelzen?', icon = 'fa-solid fa-list', options = smeltingInputOptions},
        {type = 'number', label = 'Menge', description = 'Wieviel willst du schmelzen?', icon = 'hashtag', min = 1}
    })
    if smeltInput == nil then 
        smeltStarted = false
    else
        local hasItem = exports.ox_inventory:Search('count', smeltInput[1])
        if hasItem >= smeltInput[2] then
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
                    duration = duration * smeltInput[2],
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
                lib.callback('xkrz_mining:rewardSmeltItem', source, cb, removeItem, giveItem, smeltInput[2])
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
end)

for k, v in pairs(Config.SmeltingOptionsClump) do
    if v.smeltable then
        table.insert(smeltingInputOptionsClump, {value = k, label = v.label})
    end
end 

RegisterNetEvent('xkrz_mining:smeltingclump')
AddEventHandler('xkrz_mining:smeltingclump', function()
    local smeltInputClump = lib.inputDialog('Material auswählen', {
        {type = 'select', label = 'Rohmaterial', description = 'Was willst du schmelzen?', icon = 'fa-solid fa-list', options = smeltingInputOptionsClump},
        {type = 'number', label = 'Menge', description = 'Wieviel willst du schmelzen?', icon = 'hashtag', min = 1}
    })
    if smeltInputClump == nil then 
        smeltStartedClump = false
    else
        local hasItem = exports.ox_inventory:Search('count', smeltInputClump[1])
        if hasItem >= smeltInputClump[2] then
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
                    duration = duration * smeltInputClump[2],
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
                lib.callback('xkrz_mining:rewardSmeltItemClump', source, cb, removeItem, giveItem, smeltInputClump[2])
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
end)

for k, v in pairs(Config.materialsOptions) do
    if v.smeltable then
        table.insert(materialsOptions, {value = k, label = v.label})
    end
end 

RegisterNetEvent('xkrz_mining:bench')
AddEventHandler('xkrz_mining:bench', function()
    local materialInput = lib.inputDialog('Material auswählen', {
        {type = 'select', label = 'Rohmaterial', description = 'Was willst du schmelzen?', icon = 'fa-solid fa-list', options = materialsOptions},
        {type = 'number', label = 'Menge', description = 'Wieviel willst du schmelzen?', icon = 'hashtag', min = 1}
    })
    if materialInput == nil then 
        materialInput = false
    else
        local hasItem = exports.ox_inventory:Search('count', materialInput[1])
        if hasItem >= materialInput[2] then
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
                    duration = duration * materialInput[2],
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
                lib.callback('xkrz_mining:rewardMaterial', source, cb, removeItem, giveItem, materialInput[2])
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
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function GetPed() return PlayerPedId() end

RegisterNetEvent('xkrz_mining:checkwater')
AddEventHandler('xkrz_mining:checkwater', function()
    if not IsAnimated then
        if not IsPedInAnyVehicle(GetPed(), false) then
	    	if IsEntityInWater(GetPed()) then
                LoadAnimDict('anim@heists@narcotics@funding@gang_idle')
                TaskPlayAnim(GetPed(), 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01', 8.0, 8.0, -1, 33, 0, 0, 0, 0)
                IsAnimated = true
                lib.progressCircle({
                    duration = 5000,
                    label = 'Wasche Stein..',
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
                Wait(timer)
                ClearPedTasks(GetPed())
                IsAnimated = false
	    		TriggerServerEvent('xkrz_mining:washedStone')
                lib.notify({
                    title = 'Erfolg',
                    description = 'Du hast einen Stein gewaschen.',
                    position = 'top',
                    type = 'success'
                }) 
	    	else
                lib.notify({
                    title = 'Error',
                    description = 'Gehe näher ans Wasser',
                    position = 'top',
                    type = 'error'
                }) 
	    	end
        else
            lib.notify({
                title = 'Error',
                description = 'Du bist in einem Fahrzeug',
                position = 'top',
                type = 'error'
            }) 
	    end
    else
        lib.notify({
            title = 'Error',
            description = 'Animation?',
            position = 'top',
            type = 'error'
        })
    end
end)

local smeltBlip = AddBlipForCoord(1086.3845, -2003.6810, 30.9738)
SetBlipSprite(smeltBlip, 648)
SetBlipColour(smeltBlip, 17)
SetBlipScale(smeltBlip, 0.80)
SetBlipAsShortRange(smeltBlip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString('Schmelze')
EndTextCommandSetBlipName(smeltBlip)

local miningBlip = AddBlipForCoord(2971.1665, 2844.5430, 46.5892)
SetBlipSprite(miningBlip, 622)
SetBlipColour(miningBlip, 64)
SetBlipScale(miningBlip, 1.1)
SetBlipAsShortRange(miningBlip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString('Mining')
EndTextCommandSetBlipName(miningBlip)