if(serverConfig.showLogos) then
    print(serverLogo)
end

local status = {
    eventsEnabled = false,
    coreLoaded = false,
    eventsAlreadyRunning = false,
    eventCurrentlyRunning = false,
}

local serverEvents = {
     {
        name = "chaosMod:GetStatus",
        callback = function()
            TriggerClientEvent('chaosMod:SendStatus', source, status)
        end
    },
    {
        name = "chaosMod:ToggleEvents",
        callback = function(arg)
            status.eventsEnabled = arg
        end
    }
}

local events = {
    {
        name = "Random Health Decrease",
        desc = "Decreases your health by a random amount",
        time = 5,
        func = function()
            TriggerClientEvent('chaosMod:RandomHealthDesc', -1)
        end
    },
    {
        name = "Random Health Increase",
        desc = "Increases your health by a random amount",
        time = 5,
        func = function()
            TriggerClientEvent('chaosMod:RandomHealthInc', -1)
        end
    },
    -- {
    --     name = "Spawn Random Vehicles",
    --     desc = "Spawns random vehicles around you",
    --    time = 60,
    --    func = function()
    --        TriggerClientEvent('chaosMod:SpawnRandomVehicles', -1)
    --    end
    -- }
    {
        name = "Random Explosions",
        desc = "Spawns random explosions around you",
        time = 60,
        func = function()
            TriggerClientEvent('chaosMod:RandomExplosions', -1)
        end
    }
}

print("^1[ChaosMod]^7: Initializing...")

-- Regsiter server events
for _, event in pairs(serverEvents) do
    print("^1[ChaosMod]^7: Registering server event: " .. event.name)
    RegisterServerEvent(event.name)
    AddEventHandler(event.name, event.callback)
end


print("^1[ChaosMod]^7: Server events registered. Initializing core thread...")

function eventMainHandler()
    -- Choose a random event
    local event = events[math.random(1, #events)]

    -- Chat that the event is starting
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"^1[ChaosMod]^7 ", "Starting event: " .. event.name}
    })

    -- Call the event
    event.func()

    -- Set that event is already running
    status.eventsAlreadyRunning = true
    status.eventCurrentlyRunning = true

    -- Wait for the event to finish
    Wait(event.time * 1000)

    -- Chat that the event is finished
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"^1[ChaosMod]^7 ", "Finished event: " .. event.name .. "! The next event will start in 30 seconds."}
    })

    -- Wait 30 seconds and then remove the already running status
    -- SetTimeout(30000, function()
    --    status.eventsAlreadyRunning = false
    -- end)

    status.eventsAlreadyRunning = false
end

-- Create a thread to handle events
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        if status.eventsEnabled and not status.eventsAlreadyRunning then
            eventMainHandler()
        end

        -- Push an update to status
        TriggerClientEvent('chaosMod:SendStatus', -1, status)
    end
end)

print("^1[ChaosMod]^7: Core thread initialized. Ready!")
status.coreLoaded = true