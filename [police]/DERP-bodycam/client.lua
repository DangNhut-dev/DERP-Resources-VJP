RegisterNetEvent("DERP-bodycam:action",function(k, v)
    print(k)
    if not k then return end 
    if not v then return end
    if (k == "bodycam") then
        SendNUIMessage({
            action = "bodycam",
            name = v.name,
            grade = v.grade,
            desc = CAS.recordDesc,
            header = CAS.recordName,
            webhook = CAS.webhook
        })
    elseif (k == "records") then
        SendNUIMessage({
            action = "records",
            infos = v,
            header = CAS.Header,
            footer = CAS.Footer,
        })
        SetNuiFocus(true,true)
    end
end)

RegisterNUICallback("getVideoURL",function(data,cb)
    TriggerServerEvent("sendFileData", data.videoURL, data.videoName, data.videoDesc)
    cb("ok")
end)

RegisterNUICallback("escapeFromNUI",function(data,cb)
    SetNuiFocus(false,false)
end)

Videos = {}
infos = {}

RegisterNetEvent("cas-client:updatePlayerInfos",function(array)
    infos = array
end)

RegisterNetEvent("cas-client:updateVideos",function(array)
    Videos = array
    print("kanka update video")
end)

RegisterNetEvent("useBodycam",function()
    SendNUIMessage({
        action = "bodycam",
        name = infos.name,
        grade = infos.grade,
        desc = CAS.recordDesc,
        header = CAS.recordName,
        webhook = CAS.webhook
    })
end)

local function fetchInfo()
    TriggerServerEvent("getPlayerInfos")
    TriggerServerEvent("sendToClient")
    CreateThread(function()
        -- Kiểm tra CAS.Commands có tồn tại và có dữ liệu không
        if CAS.Commands and type(CAS.Commands) == "table" then
            for i, j in pairs(CAS.Commands) do
                -- Kiểm tra command có tồn tại không
                if j and j.command then
                    print("Registering command: " .. j.command)
                    RegisterCommand(j.command, function(source, args)
                        if j.action == "bodycam" then
                            SendNUIMessage({
                                action = "bodycam",
                                name = infos.name,
                                grade = infos.grade,
                                desc = CAS.recordDesc,
                                header = CAS.recordName,
                                webhook = CAS.webhook
                            })
                        elseif j.action == "recordmenu" then
                            SendNUIMessage({
                                action = "records",
                                infos = Videos,
                                header = CAS.Header,
                                footer = CAS.Footer,
                            })
                            print("records")
                            SetNuiFocus(true, true)
                        elseif j.action == "resume" then
                            SendNUIMessage("resume")
                        elseif j.action == "pause" then
                            SendNUIMessage("pause")
                        end
                    end)
                else
                    print("Warning: Command at index " .. tostring(i) .. " is missing command field")
                end
            end
        else
            print("Error: CAS.Commands is nil or not a table")
        end
    end)
end

RegisterCommand("ld",function()
    if CAS and CAS.playerLoaded then
        TriggerEvent(CAS.playerLoaded)
    end
end)

-- Chỉ đăng ký event nếu CAS.playerLoaded tồn tại
if CAS and CAS.playerLoaded then
    RegisterNetEvent(CAS.playerLoaded)
    AddEventHandler(CAS.playerLoaded,function()
        fetchInfo()
    end)
else
    print("^1[DERP-bodycam] Error: CAS.playerLoaded is not defined. Please check config.lua^7")
end