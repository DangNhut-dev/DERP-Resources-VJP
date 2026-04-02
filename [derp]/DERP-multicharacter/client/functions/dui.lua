--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║ 🔓 DECRYPTED & FIXED BY RIP_BYTECODE 🔓                       ║
    ║    💀 R.I.P ESCROW • discord.gg/buwp9gDp6v • 2024 💀          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

-- Cleanup DUI on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DUI.Destroy()
    end
end)

-- DUI (Direct UI) System
DUI = {
    Data = false,
    Object = false,
    Handle = false,
    Stream = "generic_texture_renderer",
    Name = "gfx_" .. GetCurrentResourceName(),
    TextureDict = CreateRuntimeTxd("gfx_" .. GetCurrentResourceName() .. "_main"),
    TextureDUI = false,
    Scaleform = false,
    URL = "nui://" .. GetCurrentResourceName() .. "/client/html/dui.html",
    Dimensions = {
        width = 1600,
        height = 400
    }
}

-- Prepare DUI
function DUI.Prepare()
    do return end -- Disabled
    
    debugPrint("Preparing Direct Rendered-UI [/]")
    
    DUI.Object = CreateDui(DUI.URL, DUI.Dimensions.width, DUI.Dimensions.height)
    DUI.Handle = GetDuiHandle(DUI.Object)
    DUI.TextureDUI = CreateRuntimeTextureFromDuiHandle(DUI.TextureDict, DUI.Name, DUI.Handle)
    
    debugPrint("Direct Rendered-UI created")
end

-- Initialize DUI on resource start
Citizen.CreateThread(function()
    DUI.Prepare()
end)

-- Load Scaleform
function DUI.LoadScaleform()
    debugPrint("Preparing Scaleform [/]")
    
    local scaleform = RequestScaleformMovie(DUI.Stream)
    
    while not HasScaleformMovieLoaded(scaleform) do
        scaleform = RequestScaleformMovie(DUI.Stream)
        Wait(0)
    end
    
    debugPrint("Scaleform created")
    DUI.Scaleform = scaleform
end

-- Create and render DUI
function DUI.Create()
    DUI.LoadScaleform()
    
    -- Setup scaleform texture
    PushScaleformMovieFunction(DUI.Scaleform, "SET_TEXTURE")
    PushScaleformMovieMethodParameterString(DUI.Name .. "_main")
    PushScaleformMovieMethodParameterString(DUI.Name)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(1400)
    PushScaleformMovieFunctionParameterInt(500)
    PopScaleformMovieFunctionVoid()
    
    local ped = PlayerPedId()
    local pos1 = GetOffsetFromEntityInWorldCoords(ped, -1.4, -1.0, 1.1)
    local pos2 = GetOffsetFromEntityInWorldCoords(ped, -1.4, 5.0, 1.1)
    
    Citizen.CreateThread(function()
        debugPrint("Rendering Direct Rendered-UI [/]")
        
        SendDuiMessage(DUI.Object, json.encode({
            type = "INITIALIZE",
            state = true
        }))
        
        while DUI.Scaleform do
            ped = PlayerPedId()
            pos1 = GetOffsetFromEntityInWorldCoords(ped, -1.4, -1.0, 1.1)
            pos2 = GetOffsetFromEntityInWorldCoords(ped, -1.4, 5.0, 1.1)
            
            local duiRotation = GetEntityRotation(ped)
            
            DrawScaleformMovie_3dSolid(
                DUI.Scaleform,
                pos1,
                0.0,
                0.0,
                duiRotation.z,
                90.0,
                90.0,
                90.0,
                0.11,
                0.061875,
                1,
                0
            )
            
            Wait(0)
        end
    end)
end

-- Disable DUI
function DUI.Disable(shouldDestroy)
    debugPrint("Disabling Direct Rendered-UI [/]")
    
    SendDuiMessage(DUI.Object, json.encode({
        type = "INITIALIZE",
        state = false
    }))
    
    debugPrint("Direct Rendered-UI disabled")
    
    if shouldDestroy then
        Citizen.CreateThread(function()
            Wait(310)
            DUI.Destroy()
        end)
    end
end

-- Destroy DUI
function DUI.Destroy()
    if DUI.Scaleform then
        debugPrint("Destroying Direct Rendered-UI [/]")
        
        SetScaleformMovieAsNoLongerNeeded(DUI.Scaleform)
        Wait(100)
        DUI.Scaleform = false
        
        debugPrint("Direct Rendered-UI destroyed")
    end
end

-- Check if DUI exists
function DUI.Exists()
    return HasScaleformMovieLoaded(DUI.Stream)
end

-- Update DUI content
function DUI.UpdateContent(data)
    if DUI.Exists then
        SendDuiMessage(DUI.Object, json.encode({
            type = "UPDATE_CONTENT",
            data = data
        }))
    end
end

-- Debug command
RegisterCommand("updateContent", function()
    DUI.UpdateContent()
end)
