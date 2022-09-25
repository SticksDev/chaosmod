if (clientConfig.showLogos) then
    print(clientLogo)
end

local status = {
    coreLoaded = false,
    eventsEnabled = false,
    eventCurrentlyRunning = false
}

local vehs = {"adder", "banshee", "bullet", "cheetah", "cyclone", "entityxf", "fmj", "gp1", "infernus", "italigtb",
              "italigtb2", "nero", "nero2", "osiris", "penetrator", "pfister811", "reaper", "sc1", "sultanrs", "t20",
              "tempesta", "turismor", "tyrus", "vacca", "vagner", "visione", "voltic", "xa21", "zentorno", "zorrusso"}

local clientEvents = {{
    name = "chaosMod:SendStatus",
    callback = function(data)
        if (data.eventsEnabled ~= status.eventsEnabled) then
            if (data.eventsEnabled) then
                print("^1[ChaosMod Server ]^7: Events enabled")
            else
                print("^1[ChaosMod Server]^7: Events disabled")
            end
        end

        if (data.eventCurrentlyRunning ~= status.eventCurrentlyRunning) then
            if (data.eventCurrentlyRunning) then
                print("^1[ChaosMod Server]^7: Event started")
            else
                print("^1[ChaosMod Server]^7: Event ended")
            end
        end

        status.coreLoaded = data.coreLoaded
        status.eventsEnabled = data.eventsEnabled
        status.eventCurrentlyRunning = data.eventCurrentlyRunning
    end
}, {
    name = "chaosMod:RandomHealthDesc",
    callback = function()
        -- Descreese health by a random amount
        local health = GetEntityHealth(PlayerPedId())

        -- Make sure random health does not kill the player, so we set the minimum to 1
        local randomHealth = math.random(1, health)

        -- Set the new health
        SetEntityHealth(PlayerPedId(), randomHealth)
    end
}, {
    name = "chaosMod:RandomHealthInc",
    callback = function()
        -- Increase health by a random amount
        local health = GetEntityHealth(PlayerPedId())
        local randomHealth = math.random(1, health)

        -- Set the new health
        SetEntityHealth(PlayerPedId(), randomHealth)
    end
}, {
    name = "chaosMod:SpawnRandomVehicles",
    callback = function()
        -- Check if the event is still running
        if not status.eventCurrentlyRunning then
            return
        end

        -- Get a random vehicle
        local veh = vehs[math.random(1, #vehs)]
        local ped = GetPlayerPed(source)
        local playerCoords = GetEntityCoords(ped)
        local playerHeading = GetEntityHeading(ped)

        print(("^1[ChaosMod]^7: Spawning vehicle: %s (playerCords: %s)"):format(veh, playerCoords))

        -- Spawn the vehicle
        local veh = CreateVehicle(GetHashKey(veh), playerCoords.x, playerCoords.y, 50, playerHeading, true, false)

        -- Set the vehicle to be invincible
        SetEntityInvincible(veh, true)

        SetTimeout(1000, function()
            -- Delete 
            DeleteEntity(veh)
        end)

        Wait(500)
    end
}}
local commands = {{
    name = "eventtoggle",
    desc = "Toggles the chaos events.",
    func = function(source, args)
        local enabled = args[1] == "true" and true or false
        if args[1] == "true" or args[1] == "false" then
            TriggerServerEvent('chaosMod:ToggleEvents', enabled)

            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"^1[ChaosMod]^7 ", ("Toggled events to be %s"):format(enabled and "^2enabled" or "^2disabled")}
            })
        else
            -- Chat incorrect usage
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"^1[ChaosMod]^7 Incorrect usage. Usage: /eventtoggle <true/false>"}
            })
        end
    end
}}

-- Register client events
for _, event in pairs(clientEvents) do
    print("^1[ChaosMod Client]^7: Registering client event: " .. event.name)
    RegisterNetEvent(event.name)
    AddEventHandler(event.name, event.callback)
end

-- Register commands 
for _, command in pairs(commands) do
    print("^1[ChaosMod Client]^7: Registering command: " .. command.name)
    RegisterCommand(command.name, command.func)
end

-- Call for intial status when client is loaded
TriggerServerEvent('chaosMod:GetStatus')
