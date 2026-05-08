local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1
L0_1 = {}
L1_1 = 1000
L2_1 = 35.0
L3_1 = 80.0
while true do
  L4_1 = LoadResourceFile
  L5_1 = GetCurrentResourceName
  L5_1 = L5_1()
  L6_1 = ".fxap"
  L4_1 = L4_1(L5_1, L6_1)
  if nil ~= L4_1 then
    break
  end
  L4_1 = Citizen
  L4_1 = L4_1.Wait
  L5_1 = 1500
  L4_1(L5_1)
end
function L4_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "GetDrawDistance_proximity"
  function L2_2()
    local L0_3, L1_3
    L0_3 = WASH_BLIPS_ACTIVE
    if L0_3 > 0 then
      L0_3 = L3_1
      return L0_3
    end
    L0_3 = L2_1
    return L0_3
  end
  L3_2 = 2000
  return L0_2(L1_2, L2_2, L3_2)
end
L5_1 = CreateThread
function L6_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2
  while true do
    L0_2 = Wait
    L1_2 = L1_1
    L0_2(L1_2)
    L0_2 = GlobalState
    L0_2 = L0_2.washAreas
    if not L0_2 then
      L0_2 = {}
    end
    L1_2 = GetEntityCoords
    L2_2 = PlayerPedId
    L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2 = L2_2()
    L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
    L2_2 = {}
    L3_2 = L4_1
    L3_2 = L3_2()
    L4_2 = ipairs
    L5_2 = L0_2
    L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
    for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
      L10_2 = L9_2.center
      L10_2 = L1_2 - L10_2
      L10_2 = #L10_2
      if L3_2 > L10_2 then
        L11_2 = table
        L11_2 = L11_2.insert
        L12_2 = L2_2
        L13_2 = L9_2.id
        L11_2(L12_2, L13_2)
      end
    end
    L4_2 = table
    L4_2 = L4_2.compare
    L5_2 = L0_1
    L6_2 = L2_2
    L4_2 = L4_2(L5_2, L6_2)
    if not L4_2 then
      L4_2 = Debug
      L5_2 = string
      L5_2 = L5_2.format
      L6_2 = "GlobalState has %d total areas, %d nearby (drawDist=%.1f)"
      L7_2 = #L0_2
      L8_2 = #L2_2
      L9_2 = L3_2
      L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
      L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
      L4_2 = ipairs
      L5_2 = L0_2
      L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
      for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
        L10_2 = L9_2.center
        L10_2 = L1_2 - L10_2
        L10_2 = #L10_2
        L11_2 = Debug
        L12_2 = string
        L12_2 = L12_2.format
        L13_2 = "Area %s: center=(%.1f,%.1f,%.1f), dist=%.1f, nearby=%s"
        L14_2 = L9_2.id
        L15_2 = L9_2.center
        L15_2 = L15_2.x
        L16_2 = L9_2.center
        L16_2 = L16_2.y
        L17_2 = L9_2.center
        L17_2 = L17_2.z
        L18_2 = L10_2
        if L3_2 > L10_2 then
          L19_2 = "YES"
          if L19_2 then
            goto lbl_78
          end
        end
        L19_2 = "NO"
        ::lbl_78::
        L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2 = L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
        L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
      end
      L0_1 = L2_2
      L4_2 = #L2_2
      if L4_2 > 0 then
        L4_2 = TriggerServerEvent
        L5_2 = "kq_powerwashing:server:updateProximity"
        L6_2 = L2_2
        L4_2(L5_2, L6_2)
      else
        L4_2 = TriggerServerEvent
        L5_2 = "kq_powerwashing:server:updateProximity"
        L6_2 = {}
        L4_2(L5_2, L6_2)
      end
    end
  end
end
L5_1(L6_1)
