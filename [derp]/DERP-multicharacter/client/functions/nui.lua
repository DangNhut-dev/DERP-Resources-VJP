--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║ 🔓 DECRYPTED & FIXED BY RIP_BYTECODE 🔓                       ║
    ║    💀 R.I.P ESCROW • discord.gg/buwp9gDp6v • 2024 💀          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

NUI = {
    Vars = {
        Ready = false,
        IsOn = false
    }
}

Music = {
    Ready = false
}

-- NUI Callback: Music ready
RegisterNUICallback("music_ready", function()
    Wait(200)
    Music.Ready = true
    debugPrint("Created player instance")
end)

-- Initialize NUI
function NUI.Init(state)
    SendNUIMessage({
        type = "INIT",
        state = state
    })
    
    SetNuiFocus(state, state)
    NUI.Vars.isOn = state
end

-- Control music playback
function NUI.Music(state)
    if Config.UseMusicFromUIV2 then
        exports.ZSX_UIV2:HandleMusic(state)
    else
        while not Music.Ready do
            Wait(0)
        end
        
        debugPrint("Adjusting music to state: " .. state)
        SendNUIMessage({
            type = "ADJUST_MUSIC",
            state = state
        })
    end
end

-- Handle screen changes
function NUI.HandleScreen(screen, init)
    debugPrint("Handling screen: " .. screen)
    SendNUIMessage({
        type = "HANDLE_SCREEN",
        screen = screen,
        init = init
    })
end

-- Prepare NUI with characters
function NUI.Prepare()
    debugPrint("Preparing NUI")
    
    Framework.TriggerServerCallback("DERP-multicharacter:Get:Characters", function(characters)
        SendNUIMessage({
            type = "ADD_CHARACTERS",
            data = characters
        })
        
        Entity.Vars.characters = characters
    end)
end

-- Show awaiter screen
function NUI.Awaiter(state, noMusic)
    SendNUIMessage({
        type = "AWAITER_INIT",
        state = state,
        noMusic = noMusic
    })
    
    Wait(300)
end

-- Play sound effect
function NUI.PlaySFX(sfx)
    if not sfx then
        debugPrint("No SFX has been parsed. Returning")
        return
    end
    
    SendNUIMessage({
        type = "PLAY_SFX",
        sfx = sfx
    })
end

-- Update entity display
function NUI.UpdateEntity(data, id)
    debugPrint("Updating entity with id " .. id)
    SendNUIMessage({
        type = "UPDATE_ENTITY",
        data = data,
        id = id
    })
end

-- Show/hide welcome screen
function NUI.WelcomeScreen(state)
    SendNUIMessage({
        type = "WELCOME_SCREEN",
        state = state
    })
    
    TriggerEvent("DERP-multicharacter:Listener:WelcomeScreenStateChanged", state)
end

-- Swap entity/character
function NUI.SwapEntity(charNum)
    NUI.UsageOfKeydowns(false)
    SetNuiFocus(true, false)
    
    Framework.TriggerServerCallback("DERP-multicharacter:Get:NumChar", function(result)
        if result.character then
            Entity.Vars.currentID = result.id
            Entity.Swap(result.character, result.id)
        end
    end, charNum)
end

-- Apply color theme
function NUI.ApplyColor(color)
    debugPrint("Applying UIV2 Color for [/]")
    SendNUIMessage({
        type = "SET_COLOR",
        data = {
            color = color
        }
    })
end

-- Set character slots
function NUI.SetSlots()
    debugPrint("Setting characters slots [/]")
    
    local p = promise.new()
    
    Framework.TriggerServerCallback("DERP-multicharacter:Get:PlayerSlots", function(slots)
        SendNUIMessage({
            type = "SET_SLOTS",
            data = slots
        })
        
        p:resolve()
    end)
    
    Citizen.Await(p)
end

-- Set logout state
function NUI.SetIsLogout(state)
    SendNUIMessage({
        type = "SET_IS_LOGOUT",
        state = state
    })
end

-- Send user config to NUI
function NUI.SendUserConfig()
    debugPrint("Sending default user config data [/]")
    SendNUIMessage({
        type = "SEND_USER_CONFIG",
        data = {
            Filters = Config.Filters,
            Cameras = Config.Cameras,
            Cartoons = Config.Cartoons
        }
    })
end

-- Enable/disable keydown usage
function NUI.UsageOfKeydowns(state)
    SendNUIMessage({
        type = "SET_KEYDOWN_ARE_USABLE",
        state = state
    })
end

-- Send config to NUI
function NUI.SendConfig()
    debugPrint("Sending config data [/]")
    SendNUIMessage({
        type = "SEND_CONFIG",
        data = Config
    })
end

-- Send default music data
function NUI.SendDefaultMusic()
    debugPrint("Sending default music data [/]")
    SendNUIMessage({
        type = "SEND_DEFAULT_MUSIC",
        data = Config.Music
    })
end

-- Send default settings
function NUI.SendDefaultSettings()
    print("=================================")
    debugPrint("Sending default settings [/]")
    
    local settings = {
        filters = {},
        cameras = {}
    }
    
    -- Find default filter
    for _, filter in ipairs(Config.Filters) do
        if filter.name == Config.DefaultSettings.Filters then
            settings.filters = filter
            break
        end
    end
    
    -- Find default camera
    for _, camera in ipairs(Config.Cameras) do
        if camera.name == Config.DefaultSettings.Cameras then
            settings.cameras = camera
            break
        end
    end
    
    SendNUIMessage({
        type = "SEND_DEFAULT_SETTIGNS",
        data = settings
    })
    
    debugPrint("Default settings set")
    print("=================================")
end

-- Show info text
function NUI.InfoText(state, text)
    SendNUIMessage({
        type = "INFO_TEXT",
        text = text,
        state = state
    })
end

-- NUI Callback: Swap entity
RegisterNUICallback("swapEntity", function(data)
    NUI.SwapEntity(tonumber(data.key))
end)
