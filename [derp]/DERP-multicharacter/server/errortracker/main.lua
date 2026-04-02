--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║ 🔓 DECRYPTED & FIXED BY RIP_BYTECODE 🔓                       ║
    ║    💀 R.I.P ESCROW • discord.gg/buwp9gDp6v • 2024 💀          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

-- Module loader function
local function loadModule(modulePath)
    local fileContent = LoadResourceFile(GetCurrentResourceName(), modulePath)
    
    if not fileContent then
        error(string.format("Failed to load module: %s", modulePath), 2)
    end
    
    local loadedFunc, loadError = load(fileContent, string.format("@%s", modulePath), "t")
    
    if not loadedFunc then
        error(string.format("Failed to load module: %s - %s", modulePath, loadError), 2)
    end
    
    return loadedFunc()
end

-- Load all required modules
local frameworkCheck = loadModule("server/errortracker/modules/framework_check.lua")
local configMultichar = loadModule("server/errortracker/modules/config_multichar.lua")
local userPrefix = loadModule("server/errortracker/modules/user_prefix.lua")
local multicharactersRunning = loadModule("server/errortracker/modules/multicharacters_running.lua")
local uiv2Integration = loadModule("server/errortracker/modules/uiv2_integration.lua")
local compatibleAppearances = loadModule("server/errortracker/modules/compatible_appearances.lua")
local solutionList = loadModule("server/errortracker/data/solution_list.lua")

-- Integration status
local integrationStatus = {
    framework = false,
    other_multichar_running = false
}

-- Display integration results
local function displayIntegrationResults()
    local checkOrder = {
        "framework",
        "uiv2_integrated",
        "appearance_integrated",
        "other_multichar_running",
        "is_config_multichar_enabled",
        "user_prefix_proper"
    }
    
    local checkLabels = {
        framework = "Framework Detected",
        is_config_multichar_enabled = "Config.Multichar properly set",
        other_multichar_running = "Other Multicharacters not detected",
        user_prefix_proper = "Identifier prefix correct",
        uiv2_integrated = "UIV2 Integrated",
        appearance_integrated = "Appearance Integrated"
    }
    
    local errors = {}
    
    for _, checkName in pairs(checkOrder) do
        if integrationStatus[checkName] == false then
            table.insert(errors, solutionList[checkName])
        end
        
        if integrationStatus[checkName] ~= nil then
            local label = checkLabels[checkName]
            local padding = 40 - label:len()
            local spaces = ""
            
            for i = 1, padding do
                spaces = spaces .. " "
            end
            
            local status = integrationStatus[checkName] and "[^2STATUS OK^7]" or "[^1STATUS ERROR^7]"
            print("  -  " .. label .. spaces .. status)
            
            if checkName == "appearance_integrated" then
                print("    [-] Selected: [^2" .. integrationStatus.appearance_integrated .. "^7]")
            end
            
            if checkName == "framework" then
                print("    [-] Selected: [^2" .. FrameworkSelected .. "^7]")
            end
            
            if checkName == "other_multichar_running" then
                if not integrationStatus.other_multichar_running then
                    print("    [-] Detected: [^2" .. multicharactersRunning().name .. "^7]")
                end
            end
            
            Wait(math.random(250, 650))
        end
    end
    
    print("\n")
    
    local errorCount = #errors > 0 and ("1" .. #errors) or ("2" .. "0")
    print("[^1ERROR_DATA^7] Errors found [^" .. errorCount .. "^7]")
    
    if #errors > 0 then
        print([[
[^6-^7] Some errors has been found. To show possible solutions to your issues use a command 
    ^2multicharacter_solutions^7 below [^1NOT YET AVAILABLE^7].]])
    else
        print([[

[^6-^7] No known errors has been found. If you encounter any issues visit ^5https://discord.gg/zsx^7 
    for more information]])
    end
    
    print("============================================================================================")
    print("\n\n\n\n\n")
end

-- Main integration check function
local function runIntegrationCheck()
    if not Config.CheckIntegration then
        return
    end
    
    print("\n\n\n\n\n")
    print("===========================[^2MULTICHARACTER INTEGRATION CHECK^7]===============================")
    print("[^4/^7] Warmin up integration")
    Wait(math.random(100, 300))
    print("[^2STATUS OK^7] Integration prepared!\n")
    print("[^4/^7] Gathering debug data")
    Wait(math.random(50, 500))
    
    integrationStatus.framework = frameworkCheck()
    
    if FrameworkSelected == "ESX" then
        integrationStatus.is_config_multichar_enabled = configMultichar()
        integrationStatus.user_prefix_proper = userPrefix()
    end
    
    if IsUIV2Active then
        integrationStatus.uiv2_integrated = uiv2Integration()
    end
    
    integrationStatus.appearance_integrated = compatibleAppearances()
    integrationStatus.other_multichar_running = multicharactersRunning().state
    
    displayIntegrationResults()
end

-- Start integration check after delay
Citizen.CreateThread(function()
    Wait(3000)
    runIntegrationCheck()
end)
