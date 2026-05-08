local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
L0_1 = debug
L0_1 = L0_1.getinfo
L1_1 = 1
L2_1 = "S"
L0_1 = L0_1(L1_1, L2_1)
L0_1 = L0_1.source
L0_1 = load
L1_1 = "while 1 do Citizen.Wait(1200)end"
L0_1 = L0_1(L1_1)
L0_1 = "=?" ~= L0_1 and L0_1
L1_1 = Citizen
L1_1 = L1_1.CreateThread
function L2_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = AddTextEntry
  L1_2 = "kqbison"
  L2_2 = L
  L3_2 = "vehicles.kqbison"
  L2_2, L3_2 = L2_2(L3_2)
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = AddTextEntry
  L1_2 = "kqcaracara"
  L2_2 = L
  L3_2 = "vehicles.kqcaracara"
  L2_2, L3_2 = L2_2(L3_2)
  L0_2(L1_2, L2_2, L3_2)
end
L1_1(L2_1)
L1_1 = nil
function L2_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = DoesPlayerHavePowerwashingJob
  L0_2 = L0_2()
  L1_2 = Config
  L1_2 = L1_2.headquarters
  L1_2 = L1_2.blip
  if L0_2 then
    L2_2 = L1_1
    if not L2_2 then
      L2_2 = AddBlipForCoord
      L3_2 = Config
      L3_2 = L3_2.headquarters
      L3_2 = L3_2.coords
      L2_2 = L2_2(L3_2)
      L1_1 = L2_2
      L2_2 = SetBlipSprite
      L3_2 = L1_1
      L4_2 = L1_2.sprite
      L2_2(L3_2, L4_2)
      L2_2 = SetBlipDisplay
      L3_2 = L1_1
      L4_2 = 4
      L2_2(L3_2, L4_2)
      L2_2 = SetBlipScale
      L3_2 = L1_1
      L4_2 = L1_2.scale
      L2_2(L3_2, L4_2)
      L2_2 = SetBlipColour
      L3_2 = L1_1
      L4_2 = L1_2.color
      L2_2(L3_2, L4_2)
      L2_2 = SetBlipAsShortRange
      L3_2 = L1_1
      L4_2 = true
      L2_2(L3_2, L4_2)
      L2_2 = BeginTextCommandSetBlipName
      L3_2 = "STRING"
      L2_2(L3_2)
      L2_2 = AddTextComponentString
      L3_2 = L
      L4_2 = "headquarters.name"
      L3_2, L4_2 = L3_2(L4_2)
      L2_2(L3_2, L4_2)
      L2_2 = EndTextCommandSetBlipName
      L3_2 = L1_1
      L2_2(L3_2)
  end
  elseif not L0_2 then
    L2_2 = L1_1
    if L2_2 then
      L2_2 = RemoveBlip
      L3_2 = L1_1
      L2_2(L3_2)
      L2_2 = nil
      L1_1 = L2_2
    end
  end
end
L3_1 = AddEventHandler
L4_1 = "kq_link:jobUpdated"
function L5_1(A0_2)
  local L1_2
  L1_2 = L2_1
  L1_2()
end
L3_1(L4_1, L5_1)
L3_1 = CreateThread
function L4_1()
  local L0_2, L1_2
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
  L0_2 = L2_1
  L0_2()
end
L3_1(L4_1)
