local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1
L0_1 = RegisterKeyMapping
L1_1 = RegisterCommand
L2_1 = GetPauseMenuState
L3_1 = IsNuiFocused
L4_1 = {}
LocalPlayer = L4_1
L4_1 = false
L5_1 = 0
L6_1 = 500
L7_1 = Citizen
L7_1 = L7_1.CreateThread
function L8_1()
  local L0_2, L1_2
  while true do
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
    L0_2 = SetPauseMenuActive
    L1_2 = false
    L0_2(L1_2)
  end
end
L7_1(L8_1)
function L7_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = L0_1
  L1_2 = CFG
  L1_2 = L1_2.KeyBind
  L1_2 = L1_2.Command
  L2_2 = "Toggle Pause Menu"
  L3_2 = "keyboard"
  L4_2 = CFG
  L4_2 = L4_2.KeyBind
  L4_2 = L4_2.Key
  L0_2(L1_2, L2_2, L3_2, L4_2)
  L0_2 = L1_1
  L1_2 = "pauseMenu"
  function L2_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
    L0_3 = GetGameTimer
    L0_3 = L0_3()
    L1_3 = L4_1
    if not L1_3 then
      L1_3 = L5_1
      L1_3 = L0_3 - L1_3
      L2_3 = L6_1
      if not (L1_3 < L2_3) then
        goto lbl_20
      end
    end
    L1_3 = CFG
    L1_3 = L1_3.Debug
    if L1_3 then
      L1_3 = DebugPrint
      L2_3 = "[UI] Command ignored - spam protection active"
      L1_3(L2_3)
    end
    do return end
    ::lbl_20::
    L1_3 = CFG
    L1_3 = L1_3.isPlayerDead
    L1_3 = L1_3()
    if L1_3 then
      return
    end
    L1_3 = L2_1
    L1_3 = L1_3()
    if 0 == L1_3 then
      L1_3 = L3_1
      L1_3 = L1_3()
      if false == L1_3 then
        L1_3 = true
        L4_1 = L1_3
        L5_1 = L0_3
        L1_3 = CFG
        L1_3 = L1_3.Framework
        if "esx" == L1_3 then
          L1_3 = TriggerServerCallback
          L2_3 = "esx:getplayerData"
          L1_3 = L1_3(L2_3)
          if L1_3 then
            L2_3 = CFG
            L2_3 = L2_3.Debug
            if L2_3 then
              L2_3 = L1_3.personalData
              if nil == L2_3 then
                L2_3 = L1_3.playTime
                if L2_3 then
                  L2_3 = DebugPrint
                  L3_3 = "[UI] fetched ESX playTime="
                  L4_3 = tostring
                  L5_3 = L1_3.playTime
                  L4_3 = L4_3(L5_3)
                  L3_3 = L3_3 .. L4_3
                  L2_3(L3_3)
                end
              end
            end
            LocalPlayer = L1_3
          end
        else
          L1_3 = CFG
          L1_3 = L1_3.Framework
          if "qbox" == L1_3 then
            L1_3 = TriggerServerCallback
            L2_3 = "qbox:getPlayerData"
            L1_3 = L1_3(L2_3)
            if L1_3 then
              L2_3 = CFG
              L2_3 = L2_3.Debug
              if L2_3 then
                L2_3 = L1_3.personalData
                if nil == L2_3 then
                  L2_3 = L1_3.playTime
                  if L2_3 then
                    L2_3 = DebugPrint
                    L3_3 = "[UI] fetched QBOX playTime="
                    L4_3 = tostring
                    L5_3 = L1_3.playTime
                    L4_3 = L4_3(L5_3)
                    L3_3 = L3_3 .. L4_3
                    L2_3(L3_3)
                  end
                end
              end
              LocalPlayer = L1_3
            end
          else
            L1_3 = CFG
            L1_3 = L1_3.Framework
            if "qb" == L1_3 then
              L1_3 = TriggerServerCallback
              L2_3 = "qb:getPlayerData"
              L1_3 = L1_3(L2_3)
              if L1_3 then
                L2_3 = CFG
                L2_3 = L2_3.Debug
                if L2_3 then
                  L2_3 = L1_3.personalData
                  if nil == L2_3 then
                    L2_3 = L1_3.playTime
                    if L2_3 then
                      L2_3 = DebugPrint
                      L3_3 = "[UI] fetched QB playTime="
                      L4_3 = tostring
                      L5_3 = L1_3.playTime
                      L4_3 = L4_3(L5_3)
                      L3_3 = L3_3 .. L4_3
                      L2_3(L3_3)
                    end
                  end
                end
                LocalPlayer = L1_3
              end
            end
          end
        end
        L1_3 = Functions
        L1_3 = L1_3.getPlayerStreetName
        L1_3 = L1_3()
        L2_3 = {}
        L3_3 = CFG
        L3_3 = L3_3.Style
        if not L3_3 then
          L3_3 = {}
        end
        L2_3.style = L3_3
        L3_3 = Locales
        L4_3 = CFG
        L4_3 = L4_3.Locale
        L3_3 = L3_3[L4_3]
        if not L3_3 then
          L3_3 = Locales
          L3_3 = L3_3.en
          if not L3_3 then
            L3_3 = {}
          end
        end
        L2_3.lang = L3_3
        L3_3 = CFG
        L3_3 = L3_3.Links
        if not L3_3 then
          L3_3 = {}
        end
        L2_3.links = L3_3
        L3_3 = {}
        L3_3.location = L1_3
        L2_3.strings = L3_3
        L3_3 = LocalPlayer
        L2_3.personalData = L3_3
        L3_3 = CFG
        L3_3 = L3_3.EnabledCam
        if L3_3 then
          L2_3.show = "side"
          L3_3 = Functions
          L3_3 = L3_3.TogglePauseMenu
          L4_3 = true
          L5_3 = L2_3
          L3_3(L4_3, L5_3)
          L3_3 = CFG
          L3_3 = L3_3.Debug
          if L3_3 then
            L3_3 = L2_3.personalData
            if L3_3 then
              L3_3 = L2_3.personalData
              L3_3 = L3_3.playTime
              if L3_3 then
                goto lbl_180
              end
            end
            L3_3 = L2_3.playTime
            ::lbl_180::
            L4_3 = DebugPrint
            L5_3 = "[UI] sent NUI open (side), playTime="
            L6_3 = tostring
            L7_3 = L3_3
            L6_3 = L6_3(L7_3)
            L5_3 = L5_3 .. L6_3
            L4_3(L5_3)
          end
          L3_3 = Functions
          L3_3 = L3_3.PedIsInVehicle
          L3_3 = L3_3()
          if L3_3 then
            L3_3 = false
            L4_1 = L3_3
            return
          end
          L3_3 = CFG
          L3_3 = L3_3.Anim
          if L3_3 then
            L3_3 = CFG
            L3_3 = L3_3.Anim
            L3_3 = L3_3.Enabled
            if L3_3 then
              L3_3 = Functions
              L3_3 = L3_3.StartPlayerAnim
              L4_3 = CFG
              L4_3 = L4_3.Anim
              L4_3 = L4_3.AnimName
              if not L4_3 then
                L4_3 = "default_anim"
              end
              L5_3 = CFG
              L5_3 = L5_3.Anim
              L5_3 = L5_3.DictName
              if not L5_3 then
                L5_3 = "default_dict"
              end
              L6_3 = CFG
              L6_3 = L6_3.Anim
              L6_3 = L6_3.PropName
              if not L6_3 then
                L6_3 = nil
              end
              L3_3(L4_3, L5_3, L6_3)
            end
          end
          L3_3 = Cam
          L3_3 = L3_3.StartCamera
          L4_3 = 1.8
          L5_3 = 0.6
          L3_3(L4_3, L5_3)
        else
          L2_3.show = "center"
          L3_3 = Functions
          L3_3 = L3_3.TogglePauseMenu
          L4_3 = true
          L5_3 = L2_3
          L3_3(L4_3, L5_3)
          L3_3 = CFG
          L3_3 = L3_3.Debug
          if L3_3 then
            L3_3 = L2_3.personalData
            if L3_3 then
              L3_3 = L2_3.personalData
              L3_3 = L3_3.playTime
              if L3_3 then
                goto lbl_249
              end
            end
            L3_3 = L2_3.playTime
            ::lbl_249::
            L4_3 = DebugPrint
            L5_3 = "[UI] sent NUI open (center), playTime="
            L6_3 = tostring
            L7_3 = L3_3
            L6_3 = L6_3(L7_3)
            L5_3 = L5_3 .. L6_3
            L4_3(L5_3)
          end
        end
        L3_3 = SetTimeout
        L4_3 = 300
        function L5_3()
          local L0_4, L1_4
          L0_4 = false
          L4_1 = L0_4
        end
        L3_3(L4_3, L5_3)
    end
    else
      L1_3 = false
      L4_1 = L1_3
    end
  end
  L0_2(L1_2, L2_2)
end
L8_1 = L1_1
L9_1 = CFG
L9_1 = L9_1.FixAnimationCommands
function L10_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L0_2 = PlayerPedId
  L0_2 = L0_2()
  L1_2 = 0
  L2_2 = 5
  L3_2 = 1
  for L4_2 = L1_2, L2_2, L3_2 do
    L5_2 = GetPedPropIndex
    L6_2 = L0_2
    L7_2 = L4_2
    L5_2 = L5_2(L6_2, L7_2)
    if -1 ~= L5_2 then
      L6_2 = ClearPedProp
      L7_2 = L0_2
      L8_2 = L4_2
      L6_2(L7_2, L8_2)
    end
  end
  L1_2 = GetEntityAttachedTo
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  if L1_2 and 0 ~= L1_2 then
    L2_2 = DetachEntity
    L3_2 = L1_2
    L4_2 = true
    L5_2 = true
    L2_2(L3_2, L4_2, L5_2)
    L2_2 = DeleteEntity
    L3_2 = L1_2
    L2_2(L3_2)
  end
  L2_2 = ClearPedTasksImmediately
  L3_2 = L0_2
  L2_2(L3_2)
  L2_2 = ClearPedSecondaryTask
  L3_2 = L0_2
  L2_2(L3_2)
  L2_2 = ClearPedTasks
  L3_2 = L0_2
  L2_2(L3_2)
  L2_2 = false
  L4_1 = L2_2
  L2_2 = Functions
  if L2_2 then
    L2_2 = Functions
    L2_2 = L2_2.ResetAnimationState
    if L2_2 then
      L2_2 = Functions
      L2_2 = L2_2.ResetAnimationState
      L2_2()
    end
  end
end
L8_1(L9_1, L10_1)
L8_1 = CreateThread
L9_1 = L7_1
L8_1(L9_1)

