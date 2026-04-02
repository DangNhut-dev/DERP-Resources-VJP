--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║ 🔓 DECRYPTED & FIXED BY RIP_BYTECODE 🔓                       ║
    ║    💀 R.I.P ESCROW • discord.gg/buwp9gDp6v • 2024 💀          ║
    ╚═══════════════════════════════════════════════════════════════╝
]]--

local glm = require("glm")

Entity = {
    CurrentlySelectedIdentifier = "",
    DisabledControlsOn = false,
    Vars = {
        MainCamera = false,
        BaseData = {
            coords = false,
            centerData = {},
            rot = false
        },
        characters = {},
        currentCharacter = {},
        currentID = 1,
        isInLogoutState = false
    }
}

-- Get first character
function Entity.GetFirstCharacter()
    local result = nil
    local p = promise.new()
    
    Framework.TriggerServerCallback("DERP-multicharacter:Get:FirstChar", function(character)
        result = character
        p:resolve()
    end)
    
    Citizen.Await(p)
    
    if FrameworkSelected == "ESX" then
        Entity.CurrentlySelectedIdentifier = result.identifier
    else
        Entity.CurrentlySelectedIdentifier = result.citizenid
    end
    
    return result
end

-- Get character by number
function Entity.GetNumChar(charNum)
    local result = nil
    local p = promise.new()
    
    Framework.TriggerServerCallback("DERP-multicharacter:Get:NumChar", function(data)
        result = data.character
        p:resolve()
    end, charNum)
    
    Citizen.Await(p)
    return result
end
L1_1 = Entity
function L2_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L0_2 = PlayerPedId
  L0_2 = L0_2()
  L1_2 = GetEntityCoords
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  L2_2 = GetOffsetFromEntityInWorldCoords
  L3_2 = L0_2
  L4_2 = Config
  L4_2 = L4_2.CameraOffsets
  L4_2 = L4_2.coords
  L4_2 = L4_2.x
  L5_2 = Config
  L5_2 = L5_2.CameraOffsets
  L5_2 = L5_2.coords
  L5_2 = L5_2.y
  L6_2 = Config
  L6_2 = L6_2.CameraOffsets
  L6_2 = L6_2.coords
  L6_2 = L6_2.z
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  L3_2 = GetOffsetFromEntityInWorldCoords
  L4_2 = L0_2
  L5_2 = Config
  L5_2 = L5_2.CameraOffsets
  L5_2 = L5_2.rot
  L5_2 = L5_2.x
  L6_2 = Config
  L6_2 = L6_2.CameraOffsets
  L6_2 = L6_2.rot
  L6_2 = L6_2.y
  L7_2 = Config
  L7_2 = L7_2.CameraOffsets
  L7_2 = L7_2.rot
  L7_2 = L7_2.z
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  L4_2 = table
  L4_2 = L4_2.unpack
  L5_2 = L2_2
  L4_2, L5_2, L6_2 = L4_2(L5_2)
  L7_2 = Cameras
  L7_2 = L7_2.GetEulerRotationsFromCoords
  L8_2 = L3_2
  L9_2 = L2_2
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = debugPrint
  L9_2 = "Setting safe coord for entity [/]"
  L8_2(L9_2)
  L8_2 = Entity
  L8_2 = L8_2.Vars
  L8_2 = L8_2.BaseData
  L8_2.coords = L2_2
  L8_2 = Entity
  L8_2 = L8_2.Vars
  L8_2 = L8_2.BaseData
  L8_2.rot = L7_2
  L8_2 = SetCamCoord
  L9_2 = Entity
  L9_2 = L9_2.Vars
  L9_2 = L9_2.MainCamera
  L10_2 = L4_2
  L11_2 = L5_2
  L12_2 = L6_2
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = SetCamRot
  L9_2 = Entity
  L9_2 = L9_2.Vars
  L9_2 = L9_2.MainCamera
  L10_2 = L7_2
  L11_2 = 2
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = SetCamActive
  L9_2 = Entity
  L9_2 = L9_2.Vars
  L9_2 = L9_2.MainCamera
  L10_2 = true
  L8_2(L9_2, L10_2)
  L8_2 = DoScreenFadeIn
  L9_2 = 1000
  L8_2(L9_2)
  L8_2 = Client
  L8_2 = L8_2.BlackScreen
  L9_2 = false
  L10_2 = false
  L8_2(L9_2, L10_2)
end
L1_1.SetCoords = L2_1
L1_1 = Entity
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = Framework
  L1_2 = L1_2.TriggerServerCallback
  L2_2 = "DERP-multicharacter:Get:Properties"
  function L3_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
    L1_3 = Locations
    L1_3.Data = A0_3
    L1_3 = pairs
    L2_3 = Config
    L2_3 = L2_3.Locations
    L1_3, L2_3, L3_3, L4_3 = L1_3(L2_3)
    for L5_3, L6_3 in L1_3, L2_3, L3_3, L4_3 do
      L7_3 = Locations
      L7_3 = L7_3.Data
      L7_3[L5_3] = L6_3
    end
  end
  L4_2 = A0_2
  L1_2(L2_2, L3_2, L4_2)
end
L1_1.GetLocations = L2_1
L1_1 = Entity
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = promise
  L2_2 = L1_2
  L1_2 = L1_2.new
  L1_2 = L1_2(L2_2)
  L2_2 = {}
  L3_2 = Framework
  L3_2 = L3_2.TriggerServerCallback
  L4_2 = "DERP-multicharacter:Get:Properties"
  function L5_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
    L2_2 = A0_3
    L1_3 = pairs
    L2_3 = Config
    L2_3 = L2_3.Locations
    L1_3, L2_3, L3_3, L4_3 = L1_3(L2_3)
    for L5_3, L6_3 in L1_3, L2_3, L3_3, L4_3 do
      L7_3 = L2_2
      L7_3[L5_3] = L6_3
    end
    L1_3 = L1_2
    L2_3 = L1_3
    L1_3 = L1_3.resolve
    L1_3(L2_3)
  end
  L6_2 = A0_2
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = Citizen
  L3_2 = L3_2.Await
  L4_2 = L1_2
  L3_2(L4_2)
  return L2_2
end
L1_1.GetLocationsAsync = L2_1
L1_1 = Entity
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L2_2 = NUI
  L2_2 = L2_2.UsageOfKeydowns
  L3_2 = false
  L2_2(L3_2)
  L2_2 = NUI
  L2_2 = L2_2.WelcomeScreen
  L3_2 = true
  L2_2(L3_2)
  L2_2 = Entity
  L2_2 = L2_2.Vars
  L3_2 = tonumber
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  L2_2.currentID = L3_2
  L2_2 = Wait
  L3_2 = 1500
  L2_2(L3_2)
  L2_2 = NUI
  L2_2 = L2_2.Init
  L3_2 = false
  L2_2(L3_2)
  L2_2 = SetNuiFocus
  L3_2 = true
  L4_2 = false
  L2_2(L3_2, L4_2)
  L2_2 = debugPrint
  L3_2 = "Swapping entity [/]"
  L2_2(L3_2)
  L2_2 = Entity
  L2_2 = L2_2.Init
  L3_2 = A0_2
  L2_2(L3_2)
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = GetOffsetFromEntityInWorldCoords
  L4_2 = L2_2
  L5_2 = Config
  L5_2 = L5_2.CameraOffsets
  L5_2 = L5_2.rot
  L5_2 = L5_2.x
  L6_2 = Config
  L6_2 = L6_2.CameraOffsets
  L6_2 = L6_2.rot
  L6_2 = L6_2.y
  L7_2 = Config
  L7_2 = L7_2.CameraOffsets
  L7_2 = L7_2.rot
  L7_2 = L7_2.z
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
  L4_2 = Cameras
  L4_2 = L4_2.CreateRuntimeForAnimations
  L4_2, L5_2 = L4_2()
  L6_2 = GetOffsetFromEntityInWorldCoords
  L7_2 = L2_2
  L8_2 = Config
  L8_2 = L8_2.CameraOffsets
  L8_2 = L8_2.coords
  L8_2 = L8_2.x
  L9_2 = Config
  L9_2 = L9_2.CameraOffsets
  L9_2 = L9_2.coords
  L9_2 = L9_2.y
  L10_2 = Config
  L10_2 = L10_2.CameraOffsets
  L10_2 = L10_2.coords
  L10_2 = L10_2.z
  L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2)
  L7_2 = Cameras
  L7_2 = L7_2.GetEulerRotationsFromCoords
  L8_2 = L3_2
  L9_2 = L6_2
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = SetCamCoord
  L9_2 = Entity
  L9_2 = L9_2.Vars
  L9_2 = L9_2.MainCamera
  L10_2 = L4_2
  L8_2(L9_2, L10_2)
  L8_2 = SetCamRot
  L9_2 = Entity
  L9_2 = L9_2.Vars
  L9_2 = L9_2.MainCamera
  L10_2 = initialCameraRot
  L11_2 = 2
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = Locations
  L9_2 = Entity
  L9_2 = L9_2.GetLocationsAsync
  L10_2 = Entity
  L10_2 = L10_2.Vars
  L10_2 = L10_2.currentID
  L9_2 = L9_2(L10_2)
  L8_2.Data = L9_2
  L8_2 = Locations
  L8_2 = L8_2.Data
  L9_2 = {}
  L10_2 = GetEntityCoords
  L11_2 = PlayerPedId
  L11_2, L12_2, L13_2, L14_2, L15_2 = L11_2()
  L10_2 = L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
  L9_2.coords = L10_2
  L9_2.type = "last"
  L9_2.label = "Location"
  L8_2.last = L9_2
  L8_2 = Cameras
  L8_2 = L8_2.CamEaseIn
  L9_2 = Entity
  L9_2 = L9_2.Vars
  L9_2 = L9_2.MainCamera
  L10_2 = {}
  L10_2.coords = L6_2
  L11_2 = vector3
  L12_2 = L7_2.x
  L13_2 = 0.0
  L14_2 = L7_2.z
  L11_2 = L11_2(L12_2, L13_2, L14_2)
  L10_2.rot = L11_2
  L11_2 = Config
  L11_2 = L11_2.CameraFOV
  L10_2.fov = L11_2
  L11_2 = {}
  L12_2 = GetCamCoord
  L13_2 = Entity
  L13_2 = L13_2.Vars
  L13_2 = L13_2.MainCamera
  L12_2 = L12_2(L13_2)
  L11_2.coords = L12_2
  L11_2.rot = L5_2
  L12_2 = GetCamFov
  L13_2 = Entity
  L13_2 = L13_2.Vars
  L13_2 = L13_2.MainCamera
  L12_2 = L12_2(L13_2)
  L11_2.fov = L12_2
  L12_2 = 5000
  L13_2 = 2
  L14_2 = nil
  function L15_2()
    local L0_3, L1_3, L2_3, L3_3
    L0_3 = TriggerEvent
    L1_3 = "DERP-multicharacter:Listener:SwappedCharacter"
    L2_3 = A0_2
    L3_3 = Entity
    L3_3 = L3_3.Vars
    L3_3 = L3_3.currentID
    L0_3(L1_3, L2_3, L3_3)
    L0_3 = NUI
    L0_3 = L0_3.UsageOfKeydowns
    L1_3 = true
    L0_3(L1_3)
    L0_3 = NUI
    L0_3 = L0_3.UpdateEntity
    L1_3 = A0_2
    L2_3 = A1_2
    L0_3(L1_3, L2_3)
    L0_3 = NUI
    L0_3 = L0_3.Init
    L1_3 = true
    L0_3(L1_3)
    L0_3 = WorkerAfterPlayerSwapCharacter
    L0_3()
    L0_3 = Entity
    L0_3 = L0_3.Vars
    L0_3 = L0_3.BaseData
    L1_3 = GetCamCoord
    L2_3 = Entity
    L2_3 = L2_3.Vars
    L2_3 = L2_3.MainCamera
    L1_3 = L1_3(L2_3)
    L0_3.coords = L1_3
    L0_3 = Entity
    L0_3 = L0_3.Vars
    L0_3 = L0_3.BaseData
    L1_3 = GetCamRot
    L2_3 = Entity
    L2_3 = L2_3.Vars
    L2_3 = L2_3.MainCamera
    L3_3 = 2
    L1_3 = L1_3(L2_3, L3_3)
    L0_3.rot = L1_3
  end
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  L8_2 = NUI
  L8_2 = L8_2.WelcomeScreen
  L9_2 = false
  L8_2(L9_2)
end
L1_1.Swap = L2_1
L1_1 = Entity
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L1_2 = type
  L2_2 = A0_2.position
  L1_2 = L1_2(L2_2)
  if "string" == L1_2 then
    L1_2 = json
    L1_2 = L1_2.decode
    L2_2 = A0_2.position
    L1_2 = L1_2(L2_2)
    A0_2.position = L1_2
  end
  L1_2 = type
  L2_2 = A0_2.skin
  L1_2 = L1_2(L2_2)
  if "string" == L1_2 then
    L1_2 = json
    L1_2 = L1_2.decode
    L2_2 = A0_2.skin
    L1_2 = L1_2(L2_2)
    A0_2.skin = L1_2
  end
  L1_2 = Entity
  L1_2 = L1_2.Vars
  L1_2.currentCharacter = A0_2
  L1_2 = debugPrint
  L2_2 = "Preparing entity [/]"
  L1_2(L2_2)
  L1_2 = SetEntityVisible
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = true
  L1_2(L2_2, L3_2)
  L1_2 = Framework
  L1_2 = L1_2.SetSkin
  L2_2 = A0_2.skin
  L3_2 = A0_2.sex
  if L3_2 then
    L3_2 = A0_2.sex
    if "m" == L3_2 then
      L3_2 = "m"
      if L3_2 then
        goto lbl_48
      end
    end
    L3_2 = "f"
    if L3_2 then
      goto lbl_48
    end
  end
  L3_2 = "m"
  ::lbl_48::
  L4_2 = A0_2.model
  L1_2(L2_2, L3_2, L4_2)
  L1_2 = vector3
  L2_2 = A0_2.position
  L2_2 = L2_2.x
  L3_2 = A0_2.position
  L3_2 = L3_2.y
  L4_2 = A0_2.position
  L4_2 = L4_2.z
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  L2_2 = World
  L2_2 = L2_2.PrepareCoords
  L3_2 = L1_2
  L2_2(L3_2)
  L2_2 = FreezeEntityPosition
  L3_2 = PlayerPedId
  L3_2 = L3_2()
  L4_2 = true
  L2_2(L3_2, L4_2)
  L2_2 = SetEntityCoords
  L3_2 = PlayerPedId
  L3_2 = L3_2()
  L4_2 = vector3
  L5_2 = L1_2.x
  L6_2 = L1_2.y
  L7_2 = L1_2.z
  L7_2 = L7_2 + 1.0
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2, L6_2, L7_2)
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
  L2_2 = SetEntityHeading
  L3_2 = PlayerPedId
  L3_2 = L3_2()
  L4_2 = A0_2.position
  L4_2 = L4_2.heading
  L2_2(L3_2, L4_2)
  L2_2 = World
  L2_2.AlgorithmFailuresCount = 0
  L2_2 = Algorithms
  L2_2 = L2_2.PreloadInterior
  L3_2 = vector3
  L4_2 = L1_2.x
  L5_2 = L1_2.y
  L6_2 = L1_2.z
  L6_2 = L6_2 + 1.0
  L3_2, L4_2, L5_2, L6_2, L7_2 = L3_2(L4_2, L5_2, L6_2)
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
  L2_2 = FreezeEntityPosition
  L3_2 = PlayerPedId
  L3_2 = L3_2()
  L4_2 = false
  L2_2(L3_2, L4_2)
  L2_2 = World
  L2_2 = L2_2.EntityOnGround
  L3_2 = L1_2
  L2_2(L3_2)
  L2_2 = Wait
  L3_2 = 500
  L2_2(L3_2)
  L2_2 = Algorithms
  L2_2 = L2_2.CheckHeading
  L2_2()
  L2_2 = FrameworkSelected
  if "ESX" == L2_2 then
    L2_2 = TriggerEvent
    L3_2 = "playerSpawned"
    L2_2(L3_2)
  end
end
L1_1.Init = L2_1
L1_1 = Entity
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = TriggerServerEvent
  L2_2 = "DERP-multicharacter:Event:SetPlayerState"
  if A0_2 then
    L3_2 = "LOG_OFF_USER"
    if L3_2 then
      goto lbl_9
    end
  end
  L3_2 = "LOG_IN_USER"
  ::lbl_9::
  L1_2(L2_2, L3_2)
  L1_2 = DisableDispatch
  L1_2()
  if A0_2 then
    L1_2 = Entity
    L1_2 = L1_2.DisableControls
    L1_2()
    L1_2 = UserInterfaceActive
    if L1_2 then
      L1_2 = UserInterfaceActive
      if not L1_2 then
        goto lbl_31
      end
      L1_2 = Config
      L1_2 = L1_2.UserInterface
      if "START_AFTER" ~= L1_2 then
        goto lbl_31
      end
    end
    L1_2 = SetNuiFocus
    L2_2 = true
    L3_2 = false
    L1_2(L2_2, L3_2)
    ::lbl_31::
    L1_2 = Citizen
    L1_2 = L1_2.CreateThread
    function L2_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3
      L0_3 = NUI
      L0_3 = L0_3.UsageOfKeydowns
      L1_3 = false
      L0_3(L1_3)
      L0_3 = DoScreenFadeOut
      L1_3 = 1
      L0_3(L1_3)
      L0_3 = SetGameplayCamRelativeRotation
      L1_3 = 0
      L2_3 = 0
      L3_3 = 0
      L0_3(L1_3, L2_3, L3_3)
      L0_3 = NUI
      L0_3 = L0_3.SetIsLogout
      L1_3 = false
      L0_3(L1_3)
      L0_3 = NUI
      L0_3 = L0_3.SetSlots
      L0_3()
      L0_3 = NUI
      L0_3 = L0_3.Prepare
      L0_3()
      L0_3 = Config
      L0_3 = L0_3.UseFastTransition
      if not L0_3 then
        L0_3 = NUI
        L0_3 = L0_3.WelcomeScreen
        L1_3 = true
        L0_3(L1_3)
      end
      L0_3 = Entity
      L0_3 = L0_3.GetFirstCharacter
      L0_3 = L0_3()
      L1_3 = Entity
      L1_3 = L1_3.Vars
      L2_3 = tonumber
      L3_3 = L0_3.id
      L2_3 = L2_3(L3_3)
      L1_3.currentID = L2_3
      L1_3 = Locations
      L2_3 = Entity
      L2_3 = L2_3.GetLocationsAsync
      L3_3 = Entity
      L3_3 = L3_3.Vars
      L3_3 = L3_3.currentID
      L2_3 = L2_3(L3_3)
      L1_3.Data = L2_3
      L1_3 = Entity
      L1_3 = L1_3.Init
      L2_3 = L0_3
      L1_3(L2_3)
      L1_3 = UserInterfaceActive
      if L1_3 then
        L1_3 = Config
        L1_3 = L1_3.UserInterface
        if "START_BEFORE" == L1_3 then
          L1_3 = Wait
          L2_3 = 500
          L1_3(L2_3)
          L1_3 = debugPrint
          L2_3 = "Starting Interface on \"START_BEFORE\""
          L1_3(L2_3)
          L1_3 = exports
          L2_3 = ZSX_UI
          L1_3 = L1_3[L2_3]
          L2_3 = L1_3
          L1_3 = L1_3.InitializeMulticharacter
          L1_3(L2_3)
          while true do
            L1_3 = exports
            L2_3 = ZSX_UI
            L1_3 = L1_3[L2_3]
            L2_3 = L1_3
            L1_3 = L1_3.GetUIState
            L3_3 = "Game"
            L1_3 = L1_3(L2_3, L3_3)
            if L1_3 then
              break
            end
            L1_3 = Wait
            L2_3 = 0
            L1_3(L2_3)
          end
          L1_3 = debugPrint
          L2_3 = "Game Ready continue"
          L1_3(L2_3)
        end
      end
      L1_3 = SetNuiFocus
      L2_3 = true
      L3_3 = false
      L1_3(L2_3, L3_3)
      L1_3 = Filters
      L1_3 = L1_3.Init
      L2_3 = 100
      L1_3(L2_3)
      L1_3 = debugPrint
      L2_3 = "Awaiting for MUSIC"
      L1_3(L2_3)
      while true do
        L1_3 = Music
        L1_3 = L1_3.Ready
        if L1_3 then
          break
        end
        L1_3 = Wait
        L2_3 = 0
        L1_3(L2_3)
      end
      L1_3 = NUI
      L1_3 = L1_3.Music
      L2_3 = "START"
      L1_3(L2_3)
      L1_3 = debugPrint
      L2_3 = "Awaiting for NUI"
      L1_3(L2_3)
      while true do
        L1_3 = NUI
        L1_3 = L1_3.Vars
        L1_3 = L1_3.Ready
        if L1_3 then
          break
        end
        L1_3 = Wait
        L2_3 = 100
        L1_3(L2_3)
      end
      L1_3 = debugPrint
      L2_3 = "NUI is ready"
      L1_3(L2_3)
      L1_3 = DisplayRadar
      L2_3 = false
      L1_3(L2_3)
      L1_3 = PlayerPedId
      L1_3 = L1_3()
      L2_3 = GetEntityCoords
      L3_3 = L1_3
      L2_3 = L2_3(L3_3)
      L3_3 = Config
      L3_3 = L3_3.CameraOffsets
      L3_3 = L3_3.coords
      L4_3 = Config
      L4_3 = L4_3.CameraOffsets
      L4_3 = L4_3.rot
      L5_3 = GetOffsetFromEntityInWorldCoords
      L6_3 = L1_3
      L7_3 = L4_3.x
      L8_3 = L4_3.y
      L9_3 = L4_3.z
      L5_3 = L5_3(L6_3, L7_3, L8_3, L9_3)
      L6_3 = Cameras
      L6_3 = L6_3.CreateRuntimeForAnimations
      L6_3, L7_3 = L6_3()
      L8_3 = GetOffsetFromEntityInWorldCoords
      L9_3 = L1_3
      L10_3 = L3_3.x
      L11_3 = L3_3.y
      L12_3 = L3_3.z
      L8_3 = L8_3(L9_3, L10_3, L11_3, L12_3)
      L9_3 = Cameras
      L9_3 = L9_3.GetEulerRotationsFromCoords
      L10_3 = L5_3
      L11_3 = L8_3
      L9_3 = L9_3(L10_3, L11_3)
      L10_3 = Entity
      L10_3 = L10_3.Vars
      L11_3 = CreateCamWithParams
      L12_3 = "DEFAULT_SCRIPTED_CAMERA"
      L13_3 = L6_3
      L14_3 = L7_3
      L15_3 = 20.0
      L16_3 = true
      L17_3 = 2
      L11_3 = L11_3(L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
      L10_3.MainCamera = L11_3
      L10_3 = SetCamUseShallowDofMode
      L11_3 = Entity
      L11_3 = L11_3.Vars
      L11_3 = L11_3.MainCamera
      L12_3 = true
      L10_3(L11_3, L12_3)
      L10_3 = SetCamNearDof
      L11_3 = Entity
      L11_3 = L11_3.Vars
      L11_3 = L11_3.MainCamera
      L12_3 = 0.0
      L10_3(L11_3, L12_3)
      L10_3 = SetCamFarDof
      L11_3 = Entity
      L11_3 = L11_3.Vars
      L11_3 = L11_3.MainCamera
      L12_3 = 12.3
      L10_3(L11_3, L12_3)
      L10_3 = SetCamDofStrength
      L11_3 = Entity
      L11_3 = L11_3.Vars
      L11_3 = L11_3.MainCamera
      L12_3 = 3.8
      L10_3(L11_3, L12_3)
      L10_3 = RenderScriptCams
      L11_3 = true
      L12_3 = true
      L10_3(L11_3, L12_3)
      L10_3 = SetCamRot
      L11_3 = Entity
      L11_3 = L11_3.Vars
      L11_3 = L11_3.MainCamera
      L12_3 = tempRotFirst
      L13_3 = 2
      L10_3(L11_3, L12_3, L13_3)
      L10_3 = SetCamActive
      L11_3 = Entity
      L11_3 = L11_3.Vars
      L11_3 = L11_3.MainCamera
      L12_3 = true
      L10_3(L11_3, L12_3)
      L10_3 = DoScreenFadeIn
      L11_3 = 1
      L10_3(L11_3)
      L10_3 = UserInterfaceActive
      if L10_3 then
        L10_3 = exports
        L11_3 = ZSX_UI
        L10_3 = L10_3[L11_3]
        L11_3 = L10_3
        L10_3 = L10_3.HideUI
        L12_3 = true
        L10_3(L11_3, L12_3)
      end
      L10_3 = HandleHud
      L11_3 = true
      L10_3(L11_3)
      L10_3 = Config
      L10_3 = L10_3.UseFastTransition
      if not L10_3 then
        L10_3 = Wait
        L11_3 = 1500
        L10_3(L11_3)
        L10_3 = NUI
        L10_3 = L10_3.WelcomeScreen
        L11_3 = false
        L10_3(L11_3)
      end
      L10_3 = Cameras
      L10_3 = L10_3.HandleMotionBlur
      L11_3 = true
      L10_3(L11_3)
      L10_3 = NUI
      L10_3 = L10_3.Vars
      L10_3.Ready = false
      L10_3 = Locations
      L10_3 = L10_3.Data
      L11_3 = {}
      L12_3 = GetEntityCoords
      L13_3 = PlayerPedId
      L13_3, L14_3, L15_3, L16_3, L17_3 = L13_3()
      L12_3 = L12_3(L13_3, L14_3, L15_3, L16_3, L17_3)
      L11_3.coords = L12_3
      L11_3.type = "last"
      L11_3.label = "Location"
      L10_3.last = L11_3
      L10_3 = TriggerEvent
      L11_3 = "DERP-multicharacter:Listener:NUIReady"
      L12_3 = false
      L10_3(L11_3, L12_3)
      L10_3 = Config
      L10_3 = L10_3.UseFastTransition
      if not L10_3 then
        L10_3 = Client
        L10_3 = L10_3.BlackScreen
        L11_3 = false
        L12_3 = true
        L10_3(L11_3, L12_3)
        L10_3 = Cameras
        L10_3 = L10_3.CamEaseIn
        L11_3 = Entity
        L11_3 = L11_3.Vars
        L11_3 = L11_3.MainCamera
        L12_3 = {}
        L12_3.coords = L8_3
        L13_3 = vector3
        L14_3 = L9_3.x
        L15_3 = L9_3.y
        L16_3 = L9_3.z
        L13_3 = L13_3(L14_3, L15_3, L16_3)
        L12_3.rot = L13_3
        L13_3 = Config
        L13_3 = L13_3.CameraFOV
        L12_3.fov = L13_3
        L13_3 = {}
        L14_3 = GetCamCoord
        L15_3 = Entity
        L15_3 = L15_3.Vars
        L15_3 = L15_3.MainCamera
        L14_3 = L14_3(L15_3)
        L13_3.coords = L14_3
        L13_3.rot = L7_3
        L14_3 = GetCamFov
        L15_3 = Entity
        L15_3 = L15_3.Vars
        L15_3 = L15_3.MainCamera
        L14_3 = L14_3(L15_3)
        L13_3.fov = L14_3
        L14_3 = 5000
        L15_3 = 2
        L16_3 = nil
        function L17_3()
          local L0_4, L1_4, L2_4, L3_4
          L0_4 = NUI
          L0_4 = L0_4.UpdateEntity
          L1_4 = L0_3
          L2_4 = 1
          L0_4(L1_4, L2_4)
          L0_4 = NUI
          L0_4 = L0_4.Init
          L1_4 = true
          L0_4(L1_4)
          L0_4 = TriggerEvent
          L1_4 = "DERP-multicharacter:Listener:MulticharacterInitialized"
          L2_4 = false
          L0_4(L1_4, L2_4)
          L0_4 = WorkerAfterInitialization
          L0_4()
          L0_4 = NUI
          L0_4 = L0_4.UsageOfKeydowns
          L1_4 = true
          L0_4(L1_4)
          L0_4 = Entity
          L0_4 = L0_4.Vars
          L0_4 = L0_4.BaseData
          L1_4 = GetCamCoord
          L2_4 = Entity
          L2_4 = L2_4.Vars
          L2_4 = L2_4.MainCamera
          L1_4 = L1_4(L2_4)
          L0_4.coords = L1_4
          L0_4 = Entity
          L0_4 = L0_4.Vars
          L0_4 = L0_4.BaseData
          L1_4 = GetCamRot
          L2_4 = Entity
          L2_4 = L2_4.Vars
          L2_4 = L2_4.MainCamera
          L3_4 = 2
          L1_4 = L1_4(L2_4, L3_4)
          L0_4.rot = L1_4
        end
        L10_3(L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
      else
        L10_3 = SetCamCoord
        L11_3 = Entity
        L11_3 = L11_3.Vars
        L11_3 = L11_3.MainCamera
        L12_3 = L8_3
        L10_3(L11_3, L12_3)
        L10_3 = SetCamRot
        L11_3 = Entity
        L11_3 = L11_3.Vars
        L11_3 = L11_3.MainCamera
        L12_3 = vector3
        L13_3 = L9_3.x
        L14_3 = L9_3.y
        L15_3 = L9_3.z
        L12_3 = L12_3(L13_3, L14_3, L15_3)
        L13_3 = 2
        L10_3(L11_3, L12_3, L13_3)
        L10_3 = SetCamFov
        L11_3 = Entity
        L11_3 = L11_3.Vars
        L11_3 = L11_3.MainCamera
        L12_3 = Config
        L12_3 = L12_3.CameraFOV
        L10_3(L11_3, L12_3)
        L10_3 = Wait
        L11_3 = 250
        L10_3(L11_3)
        L10_3 = Client
        L10_3 = L10_3.BlackScreen
        L11_3 = false
        L12_3 = true
        L10_3(L11_3, L12_3)
        L10_3 = NUI
        L10_3 = L10_3.UpdateEntity
        L11_3 = L0_3
        L12_3 = 1
        L10_3(L11_3, L12_3)
        L10_3 = NUI
        L10_3 = L10_3.Init
        L11_3 = true
        L10_3(L11_3)
        L10_3 = TriggerEvent
        L11_3 = "DERP-multicharacter:Listener:MulticharacterInitialized"
        L12_3 = false
        L10_3(L11_3, L12_3)
        L10_3 = WorkerAfterInitialization
        L10_3()
        L10_3 = NUI
        L10_3 = L10_3.UsageOfKeydowns
        L11_3 = true
        L10_3(L11_3)
        L10_3 = Entity
        L10_3 = L10_3.Vars
        L10_3 = L10_3.BaseData
        L11_3 = GetCamCoord
        L12_3 = Entity
        L12_3 = L12_3.Vars
        L12_3 = L12_3.MainCamera
        L11_3 = L11_3(L12_3)
        L10_3.coords = L11_3
        L10_3 = Entity
        L10_3 = L10_3.Vars
        L10_3 = L10_3.BaseData
        L11_3 = GetCamRot
        L12_3 = Entity
        L12_3 = L12_3.Vars
        L12_3 = L12_3.MainCamera
        L13_3 = 2
        L11_3 = L11_3(L12_3, L13_3)
        L10_3.rot = L11_3
      end
      L10_3 = Citizen
      L10_3 = L10_3.CreateThread
      function L11_3()
        local L0_4, L1_4
        while true do
          L0_4 = DoesCamExist
          L1_4 = Entity
          L1_4 = L1_4.Vars
          L1_4 = L1_4.MainCamera
          L0_4 = L0_4(L1_4)
          if L0_4 then
            break
          end
          L0_4 = Wait
          L1_4 = 0
          L0_4(L1_4)
        end
        while true do
          L0_4 = DoesCamExist
          L1_4 = Entity
          L1_4 = L1_4.Vars
          L1_4 = L1_4.MainCamera
          L0_4 = L0_4(L1_4)
          if not L0_4 then
            break
          end
          L0_4 = SetUseHiDof
          L0_4()
          L0_4 = Citizen
          L0_4 = L0_4.Wait
          L1_4 = 0
          L0_4(L1_4)
        end
      end
      L10_3(L11_3)
    end
    L1_2(L2_2)
  else
    L1_2 = WorkerBeforePlayerSelection
    L1_2()
    L1_2 = Entity
    L1_2.DisabledControlsOn = false
    L1_2 = SetGameplayCamRelativeRotation
    L2_2 = 0.0
    L3_2 = 0.0
    L4_2 = 0.0
    L1_2(L2_2, L3_2, L4_2)
    L1_2 = SetGameplayCamRelativePitch
    L2_2 = 0.0
    L2_2 = 0.0 + L2_2
    L3_2 = 1.0
    L1_2(L2_2, L3_2)
    L1_2 = Wait
    L2_2 = 10
    L1_2(L2_2)
    L1_2 = Entity
    L1_2 = L1_2.Vars
    L1_2.isInLogoutState = false
    L1_2 = true
    L2_2 = Cameras
    L2_2 = L2_2.HandleMotionBlur
    L3_2 = false
    L2_2(L3_2)
    L2_2 = Citizen
    L2_2 = L2_2.CreateThread
    function L3_2()
      local L0_3, L1_3
      while true do
        L0_3 = L1_2
        if not L0_3 then
          break
        end
        L0_3 = DisableAllControlActions
        L1_3 = 0
        L0_3(L1_3)
        L0_3 = Wait
        L1_3 = 0
        L0_3(L1_3)
      end
    end
    L2_2(L3_2)
    L2_2 = FX
    L2_2 = L2_2.LoadBucketAnim
    L2_2()
    L2_2 = NUI
    L2_2 = L2_2.Init
    L3_2 = false
    L2_2(L3_2)
    L2_2 = NUI
    L2_2 = L2_2.Music
    L3_2 = "STOP"
    L2_2(L3_2)
    L2_2 = Citizen
    L2_2 = L2_2.CreateThread
    function L3_2()
      local L0_3, L1_3
      L0_3 = Wait
      L1_3 = 1500
      L0_3(L1_3)
      L0_3 = Filters
      L0_3 = L0_3.Disable
      L1_3 = 1500
      L0_3(L1_3)
    end
    L2_2(L3_2)
    L2_2 = Cameras
    L2_2 = L2_2.CamEaseIn
    L3_2 = Entity
    L3_2 = L3_2.Vars
    L3_2 = L3_2.MainCamera
    L4_2 = {}
    L5_2 = GetGameplayCamCoord
    L5_2 = L5_2()
    L4_2.coords = L5_2
    L5_2 = GetGameplayCamRot
    L6_2 = 2
    L5_2 = L5_2(L6_2)
    L4_2.rot = L5_2
    L5_2 = GetGameplayCamFov
    L5_2 = L5_2()
    L4_2.fov = L5_2
    L5_2 = {}
    L6_2 = GetCamCoord
    L7_2 = Entity
    L7_2 = L7_2.Vars
    L7_2 = L7_2.MainCamera
    L6_2 = L6_2(L7_2)
    L5_2.coords = L6_2
    L6_2 = GetCamRot
    L7_2 = Entity
    L7_2 = L7_2.Vars
    L7_2 = L7_2.MainCamera
    L8_2 = 2
    L6_2 = L6_2(L7_2, L8_2)
    L5_2.rot = L6_2
    L6_2 = GetCamFov
    L7_2 = Entity
    L7_2 = L7_2.Vars
    L7_2 = L7_2.MainCamera
    L6_2 = L6_2(L7_2)
    L5_2.fov = L6_2
    L6_2 = 4000
    L7_2 = 2
    L8_2 = nil
    function L9_2()
      local L0_3, L1_3, L2_3
      L0_3 = SetPlayerInvincible
      L1_3 = PlayerId
      L1_3 = L1_3()
      L2_3 = 0
      L0_3(L1_3, L2_3)
      L0_3 = UserInterfaceActive
      if L0_3 then
        L0_3 = exports
        L1_3 = ZSX_UI
        L0_3 = L0_3[L1_3]
        L1_3 = L0_3
        L0_3 = L0_3.HideUI
        L2_3 = false
        L0_3(L1_3, L2_3)
      end
      L0_3 = HandleHud
      L1_3 = false
      L0_3(L1_3)
      L0_3 = WorkerAfterPlayerSelection
      L0_3()
      L0_3 = UserInterfaceActive
      if L0_3 then
        L0_3 = Config
        L0_3 = L0_3.UserInterface
        if "START_AFTER" == L0_3 then
          L0_3 = exports
          L1_3 = ZSX_UI
          L0_3 = L0_3[L1_3]
          L1_3 = L0_3
          L0_3 = L0_3.Initialize
          L0_3(L1_3)
        end
      end
      L0_3 = TriggerEvent
      L1_3 = "DERP-multicharacter:Listener:MainFinishedWork"
      L0_3(L1_3)
      L0_3 = TriggerEvent
      L1_3 = "DERP-multicharacter:Listener:MulticharacterFinished"
      L0_3(L1_3)
      L0_3 = false
      L1_2 = L0_3
      L0_3 = DestroyCam
      L1_3 = Entity
      L1_3 = L1_3.Vars
      L1_3 = L1_3.MainCamera
      L0_3(L1_3)
      L0_3 = RenderScriptCams
      L1_3 = false
      L2_3 = false
      L0_3(L1_3, L2_3)
    end
    L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  end
end
L1_1.Cam = L2_1

-- Debug command: Set camera rotation
RegisterCommand("setrot", function(source, args, rawCommand)
    local x = tonumber(args[1] + 0.0)
    local y = tonumber(args[2] + 0.0)
    local z = tonumber(args[3] + 0.0)
    SetCamRot(Entity.Vars.MainCamera, x, y, z, 2)
end)
L1_1 = Entity
function L2_1()
  local L0_2, L1_2, L2_2
  L0_2 = TriggerServerEvent
  L1_2 = "DERP-multicharacter:Event:SetPlayerState"
  L2_2 = "LOG_OFF_USER"
  L0_2(L1_2, L2_2)
  L0_2 = Citizen
  L0_2 = L0_2.CreateThread
  function L1_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3
    L0_3 = Entity
    L0_3 = L0_3.DisableControls
    L0_3()
    L0_3 = UserInterfaceActive
    if L0_3 then
      L0_3 = exports
      L1_3 = ZSX_UI
      L0_3 = L0_3[L1_3]
      L1_3 = L0_3
      L0_3 = L0_3.HideUI
      L2_3 = true
      L0_3(L1_3, L2_3)
    end
    L0_3 = HandleHud
    L1_3 = true
    L0_3(L1_3)
    L0_3 = NUI
    L0_3 = L0_3.UsageOfKeydowns
    L1_3 = false
    L0_3(L1_3)
    L0_3 = NUI
    L0_3 = L0_3.SetIsLogout
    L1_3 = true
    L0_3(L1_3)
    L0_3 = NUI
    L0_3 = L0_3.SetSlots
    L0_3()
    L0_3 = NUI
    L0_3 = L0_3.Prepare
    L0_3()
    L0_3 = Entity
    L0_3 = L0_3.GetNumChar
    L1_3 = Entity
    L1_3 = L1_3.Vars
    L1_3 = L1_3.currentID
    L0_3 = L0_3(L1_3)
    L1_3 = Algorithms
    L1_3 = L1_3.CheckHeading
    L1_3()
    L1_3 = Filters
    L1_3 = L1_3.Init
    L2_3 = 800
    L1_3(L2_3)
    L1_3 = NUI
    L1_3 = L1_3.Music
    L2_3 = "START"
    L1_3(L2_3)
    L1_3 = DisplayRadar
    L2_3 = false
    L1_3(L2_3)
    L1_3 = PlayerPedId
    L1_3 = L1_3()
    L2_3 = GetOffsetFromEntityInWorldCoords
    L3_3 = L1_3
    L4_3 = Config
    L4_3 = L4_3.CameraOffsets
    L4_3 = L4_3.rot
    L4_3 = L4_3.x
    L5_3 = Config
    L5_3 = L5_3.CameraOffsets
    L5_3 = L5_3.rot
    L5_3 = L5_3.y
    L6_3 = Config
    L6_3 = L6_3.CameraOffsets
    L6_3 = L6_3.rot
    L6_3 = L6_3.z
    L2_3 = L2_3(L3_3, L4_3, L5_3, L6_3)
    L3_3 = GetGameplayCamRot
    L4_3 = 2
    L3_3 = L3_3(L4_3)
    L4_3 = GetGameplayCamCoord
    L4_3 = L4_3()
    L5_3 = GetGameplayCamFov
    L5_3 = L5_3()
    L6_3 = GetOffsetFromEntityInWorldCoords
    L7_3 = L1_3
    L8_3 = Config
    L8_3 = L8_3.CameraOffsets
    L8_3 = L8_3.coords
    L8_3 = L8_3.x
    L9_3 = Config
    L9_3 = L9_3.CameraOffsets
    L9_3 = L9_3.coords
    L9_3 = L9_3.y
    L10_3 = Config
    L10_3 = L10_3.CameraOffsets
    L10_3 = L10_3.coords
    L10_3 = L10_3.z
    L6_3 = L6_3(L7_3, L8_3, L9_3, L10_3)
    L7_3 = Cameras
    L7_3 = L7_3.GetEulerRotationsFromCoords
    L8_3 = L2_3
    L9_3 = L6_3
    L7_3 = L7_3(L8_3, L9_3)
    L8_3 = Entity
    L8_3 = L8_3.Vars
    L9_3 = CreateCamWithParams
    L10_3 = "DEFAULT_SCRIPTED_CAMERA"
    L11_3 = L4_3
    L12_3 = L3_3
    L13_3 = L5_3
    L14_3 = true
    L15_3 = 2
    L9_3 = L9_3(L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
    L8_3.MainCamera = L9_3
    L8_3 = SetCamUseShallowDofMode
    L9_3 = Entity
    L9_3 = L9_3.Vars
    L9_3 = L9_3.MainCamera
    L10_3 = true
    L8_3(L9_3, L10_3)
    L8_3 = SetCamNearDof
    L9_3 = Entity
    L9_3 = L9_3.Vars
    L9_3 = L9_3.MainCamera
    L10_3 = 0.0
    L8_3(L9_3, L10_3)
    L8_3 = SetCamFarDof
    L9_3 = Entity
    L9_3 = L9_3.Vars
    L9_3 = L9_3.MainCamera
    L10_3 = 12.3
    L8_3(L9_3, L10_3)
    L8_3 = SetCamDofStrength
    L9_3 = Entity
    L9_3 = L9_3.Vars
    L9_3 = L9_3.MainCamera
    L10_3 = 3.8
    L8_3(L9_3, L10_3)
    L8_3 = Entity
    L8_3 = L8_3.Vars
    L8_3.isInLogoutState = true
    L8_3 = RenderScriptCams
    L9_3 = true
    L10_3 = true
    L8_3(L9_3, L10_3)
    L8_3 = SetCamActive
    L9_3 = Entity
    L9_3 = L9_3.Vars
    L9_3 = L9_3.MainCamera
    L10_3 = true
    L8_3(L9_3, L10_3)
    L8_3 = Cameras
    L8_3 = L8_3.HandleMotionBlur
    L9_3 = true
    L8_3(L9_3)
    L8_3 = NUI
    L8_3 = L8_3.Vars
    L8_3.Ready = false
    L8_3 = Locations
    L9_3 = Entity
    L9_3 = L9_3.GetLocationsAsync
    L10_3 = Entity
    L10_3 = L10_3.Vars
    L10_3 = L10_3.currentID
    L9_3 = L9_3(L10_3)
    L8_3.Data = L9_3
    L8_3 = Locations
    L8_3 = L8_3.Data
    L9_3 = {}
    L10_3 = GetEntityCoords
    L11_3 = PlayerPedId
    L11_3, L12_3, L13_3, L14_3, L15_3 = L11_3()
    L10_3 = L10_3(L11_3, L12_3, L13_3, L14_3, L15_3)
    L9_3.coords = L10_3
    L9_3.type = "last"
    L9_3.label = "Location"
    L8_3.last = L9_3
    L8_3 = TriggerEvent
    L9_3 = "DERP-multicharacter:Listener:NUIReady"
    L10_3 = false
    L8_3(L9_3, L10_3)
    L8_3 = Cameras
    L8_3 = L8_3.CamEaseIn
    L9_3 = Entity
    L9_3 = L9_3.Vars
    L9_3 = L9_3.MainCamera
    L10_3 = {}
    L10_3.coords = L6_3
    L10_3.rot = L7_3
    L11_3 = Config
    L11_3 = L11_3.CameraFOV
    L10_3.fov = L11_3
    L11_3 = {}
    L12_3 = GetCamCoord
    L13_3 = Entity
    L13_3 = L13_3.Vars
    L13_3 = L13_3.MainCamera
    L12_3 = L12_3(L13_3)
    L11_3.coords = L12_3
    L12_3 = GetCamRot
    L13_3 = Entity
    L13_3 = L13_3.Vars
    L13_3 = L13_3.MainCamera
    L14_3 = 2
    L12_3 = L12_3(L13_3, L14_3)
    L11_3.rot = L12_3
    L12_3 = GetCamFov
    L13_3 = Entity
    L13_3 = L13_3.Vars
    L13_3 = L13_3.MainCamera
    L12_3 = L12_3(L13_3)
    L11_3.fov = L12_3
    L12_3 = 3000
    L13_3 = 2
    L14_3 = nil
    function L15_3()
      local L0_4, L1_4, L2_4, L3_4
      L0_4 = NUI
      L0_4 = L0_4.UsageOfKeydowns
      L1_4 = true
      L0_4(L1_4)
      L0_4 = NUI
      L0_4 = L0_4.UpdateEntity
      L1_4 = L0_3
      L2_4 = Entity
      L2_4 = L2_4.Vars
      L2_4 = L2_4.currentID
      L0_4(L1_4, L2_4)
      L0_4 = NUI
      L0_4 = L0_4.Init
      L1_4 = true
      L0_4(L1_4)
      L0_4 = FreezeEntityPosition
      L1_4 = PlayerPedId
      L1_4 = L1_4()
      L2_4 = false
      L0_4(L1_4, L2_4)
      L0_4 = TriggerEvent
      L1_4 = "DERP-multicharacter:Listener:MulticharacterInitialized"
      L2_4 = true
      L0_4(L1_4, L2_4)
      L0_4 = Entity
      L0_4 = L0_4.Vars
      L0_4 = L0_4.BaseData
      L1_4 = GetCamCoord
      L2_4 = Entity
      L2_4 = L2_4.Vars
      L2_4 = L2_4.MainCamera
      L1_4 = L1_4(L2_4)
      L0_4.coords = L1_4
      L0_4 = Entity
      L0_4 = L0_4.Vars
      L0_4 = L0_4.BaseData
      L1_4 = GetCamRot
      L2_4 = Entity
      L2_4 = L2_4.Vars
      L2_4 = L2_4.MainCamera
      L3_4 = 2
      L1_4 = L1_4(L2_4, L3_4)
      L0_4.rot = L1_4
    end
    L8_3(L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
    L8_3 = Citizen
    L8_3 = L8_3.CreateThread
    function L9_3()
      local L0_4, L1_4
      while true do
        L0_4 = DoesCamExist
        L1_4 = Entity
        L1_4 = L1_4.Vars
        L1_4 = L1_4.MainCamera
        L0_4 = L0_4(L1_4)
        if L0_4 then
          break
        end
        L0_4 = Wait
        L1_4 = 0
        L0_4(L1_4)
      end
      while true do
        L0_4 = DoesCamExist
        L1_4 = Entity
        L1_4 = L1_4.Vars
        L1_4 = L1_4.MainCamera
        L0_4 = L0_4(L1_4)
        if not L0_4 then
          break
        end
        L0_4 = SetUseHiDof
        L0_4()
        L0_4 = Citizen
        L0_4 = L0_4.Wait
        L1_4 = 0
        L0_4(L1_4)
      end
    end
    L8_3(L9_3)
  end
  L0_2(L1_2)
end
L1_1.Logout = L2_1

-- Disable all controls
function Entity.DisableControls()
    Entity.DisabledControlsOn = true
    
    Citizen.CreateThread(function()
        while Entity.DisabledControlsOn do
            DisableAllControlActions(0)
            Wait(0)
        end
    end)
end
