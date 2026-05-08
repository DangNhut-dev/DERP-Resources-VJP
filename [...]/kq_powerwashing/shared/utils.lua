local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1
L0_1 = table
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = ipairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    if L7_2 == A1_2 then
      L8_2 = true
      return L8_2
    end
  end
  L2_2 = false
  return L2_2
end
L0_1.contains = L1_1
while true do
  L0_1 = Citizen
  L0_1 = L0_1.InvokeNative
  L1_1 = 1990848031
  L2_1 = GetCurrentResourceName
  L2_1 = L2_1()
  L3_1 = ".fxap"
  L0_1 = L0_1(L1_1, L2_1, L3_1)
  if L0_1 then
    break
  end
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = 0
  L0_1(L1_1)
end
L0_1 = table
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = {}
  function L2_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
    L1_3 = type
    L2_3 = A0_3
    L1_3 = L1_3(L2_3)
    if "table" ~= L1_3 then
      return A0_3
    else
      L1_3 = L1_2
      L1_3 = L1_3[A0_3]
      if L1_3 then
        L1_3 = L1_2
        L1_3 = L1_3[A0_3]
        return L1_3
      end
    end
    L1_3 = {}
    L2_3 = L1_2
    L2_3[A0_3] = L1_3
    L2_3 = pairs
    L3_3 = A0_3
    L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
    for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
      L8_3 = L2_2
      L9_3 = L6_3
      L8_3 = L8_3(L9_3)
      L9_3 = L2_2
      L10_3 = L7_3
      L9_3 = L9_3(L10_3)
      L1_3[L8_3] = L9_3
    end
    return L1_3
  end
  L3_2 = L2_2
  L4_2 = A0_2
  return L3_2(L4_2)
end
L0_1.clone = L1_1
L0_1 = table
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L1_2 = {}
  L2_2 = pairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L7_2.order
    if L8_2 then
      L8_2 = table
      L8_2 = L8_2.insert
      L9_2 = L1_2
      L10_2 = {}
      L10_2.key = L6_2
      L10_2.value = L7_2
      L11_2 = L7_2.order
      L10_2.order = L11_2
      L8_2(L9_2, L10_2)
    end
  end
  L2_2 = table
  L2_2 = L2_2.sort
  L3_2 = L1_2
  function L4_2(A0_3, A1_3)
    local L2_3, L3_3
    L2_3 = A0_3.order
    L3_3 = A1_3.order
    L2_3 = L2_3 < L3_3
    return L2_3
  end
  L2_2(L3_2, L4_2)
  L2_2 = {}
  L3_2 = ipairs
  L4_2 = L1_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = table
    L9_2 = L9_2.insert
    L10_2 = L2_2
    L11_2 = L8_2.value
    L9_2(L10_2, L11_2)
  end
  return L2_2
end
L0_1.valuesByOrder = L1_1
L0_1 = table
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L2_2 = #A0_2
  L3_2 = #A1_2
  if L2_2 ~= L3_2 then
    L2_2 = false
    return L2_2
  end
  L2_2 = {}
  L3_2 = ipairs
  L4_2 = A1_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L2_2[L8_2] = true
  end
  L3_2 = ipairs
  L4_2 = A0_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = L2_2[L8_2]
    if not L9_2 then
      L9_2 = false
      return L9_2
    end
  end
  L3_2 = true
  return L3_2
end
L0_1.compare = L1_1
L0_1 = table
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L1_2 = {}
  L2_2 = pairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = table
    L8_2 = L8_2.insert
    L9_2 = L1_2
    L10_2 = L7_2
    L8_2(L9_2, L10_2)
  end
  return L1_2
end
L0_1.values = L1_1
L0_1 = table
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = {}
  L3_2 = #A0_2
  if L3_2 > 0 then
    L3_2 = A0_2[1]
    if nil ~= L3_2 then
      L3_2 = 1
      L4_2 = #A0_2
      L5_2 = 1
      for L6_2 = L3_2, L4_2, L5_2 do
        L7_2 = A1_2
        L8_2 = A0_2[L6_2]
        L9_2 = L6_2
        L10_2 = A0_2
        L7_2 = L7_2(L8_2, L9_2, L10_2)
        L2_2[L6_2] = L7_2
      end
  end
  else
    L3_2 = pairs
    L4_2 = A0_2
    L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
    for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
      L9_2 = A1_2
      L10_2 = L8_2
      L11_2 = L7_2
      L12_2 = A0_2
      L9_2 = L9_2(L10_2, L11_2, L12_2)
      L2_2[L7_2] = L9_2
    end
  end
  return L2_2
end
L0_1.map = L1_1
L0_1 = table
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L2_2 = {}
  L3_2 = 1
  L4_2 = pairs
  L5_2 = A0_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = A1_2
    L11_2 = L9_2
    L12_2 = L8_2
    L13_2 = A0_2
    L10_2 = L10_2(L11_2, L12_2, L13_2)
    L2_2[L3_2] = L10_2
    L3_2 = L3_2 + 1
  end
  return L2_2
end
L0_1.mapValues = L1_1
L0_1 = table
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = {}
  L3_2 = pairs
  L4_2 = A0_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = A1_2
    L10_2 = L8_2
    L11_2 = L7_2
    L12_2 = A0_2
    L9_2 = L9_2(L10_2, L11_2, L12_2)
    if L9_2 then
      L2_2[L7_2] = L8_2
    end
  end
  return L2_2
end
L0_1.filter = L1_1
L0_1 = table
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = 0
  L2_2 = pairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2 in L2_2, L3_2, L4_2, L5_2 do
    L1_2 = L1_2 + 1
  end
  return L1_2
end
L0_1.length = L1_1
L0_1 = table
L1_1 = table
L1_1 = L1_1.length
L0_1.count = L1_1
L0_1 = table
function L1_1(...)
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  function L0_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3
    L1_3 = type
    L2_3 = A0_3
    L1_3 = L1_3(L2_3)
    if "table" ~= L1_3 then
      L1_3 = false
      return L1_3
    end
    L1_3 = 0
    L2_3 = pairs
    L3_3 = A0_3
    L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
    for L6_3 in L2_3, L3_3, L4_3, L5_3 do
      L1_3 = L1_3 + 1
      L7_3 = A0_3[L1_3]
      if nil == L7_3 then
        L7_3 = false
        return L7_3
      end
    end
    L2_3 = true
    return L2_3
  end
  function L1_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
    L1_3 = type
    L2_3 = A0_3
    L1_3 = L1_3(L2_3)
    if "table" ~= L1_3 then
      return A0_3
    end
    L1_3 = {}
    L2_3 = pairs
    L3_3 = A0_3
    L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
    for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
      L8_3 = L1_2
      L9_3 = L7_3
      L8_3 = L8_3(L9_3)
      L1_3[L6_3] = L8_3
    end
    return L1_3
  end
  function L2_2(A0_3, A1_3)
    local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
    L2_3 = L0_2
    L3_3 = A0_3
    L2_3 = L2_3(L3_3)
    if L2_3 then
      L2_3 = L0_2
      L3_3 = A1_3
      L2_3 = L2_3(L3_3)
      if L2_3 then
        L2_3 = 1
        L3_3 = #A1_3
        L4_3 = 1
        for L5_3 = L2_3, L3_3, L4_3 do
          L6_3 = #A0_3
          L6_3 = L6_3 + 1
          L7_3 = L1_2
          L8_3 = A1_3[L5_3]
          L7_3 = L7_3(L8_3)
          A0_3[L6_3] = L7_3
        end
    end
    else
      L2_3 = pairs
      L3_3 = A1_3
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
      for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
        L8_3 = type
        L9_3 = L7_3
        L8_3 = L8_3(L9_3)
        if "table" == L8_3 then
          L8_3 = type
          L9_3 = A0_3[L6_3]
          L8_3 = L8_3(L9_3)
          if "table" == L8_3 then
            L8_3 = L2_2
            L9_3 = A0_3[L6_3]
            L10_3 = L7_3
            L8_3(L9_3, L10_3)
        end
        else
          L8_3 = L1_2
          L9_3 = L7_3
          L8_3 = L8_3(L9_3)
          A0_3[L6_3] = L8_3
        end
      end
    end
  end
  L3_2 = {}
  L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2 = ...
  L3_2[1] = L4_2
  L3_2[2] = L5_2
  L3_2[3] = L6_2
  L3_2[4] = L7_2
  L3_2[5] = L8_2
  L3_2[6] = L9_2
  L3_2[7] = L10_2
  L3_2[8] = L11_2
  L3_2[9] = L12_2
  L4_2 = #L3_2
  if 0 == L4_2 then
    L4_2 = {}
    return L4_2
  end
  L4_2 = L1_2
  L5_2 = L3_2[1]
  L4_2 = L4_2(L5_2)
  L5_2 = 2
  L6_2 = select
  L7_2 = "#"
  L8_2, L9_2, L10_2, L11_2, L12_2 = ...
  L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  L7_2 = 1
  for L8_2 = L5_2, L6_2, L7_2 do
    L9_2 = L3_2[L8_2]
    L10_2 = type
    L11_2 = L9_2
    L10_2 = L10_2(L11_2)
    if "table" == L10_2 then
      L10_2 = L2_2
      L11_2 = L4_2
      L12_2 = L9_2
      L10_2(L11_2, L12_2)
    end
  end
  return L4_2
end
L0_1.merge = L1_1
L0_1 = math
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  if not A1_2 then
    A1_2 = 0
  end
  L2_2 = 10
  L2_2 = L2_2 ^ A1_2
  L3_2 = A0_2 * L2_2
  L4_2 = L3_2 % 1
  L5_2 = 0.5
  if L4_2 > L5_2 then
    L4_2 = math
    L4_2 = L4_2.ceil
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    L3_2 = L4_2
  else
    L4_2 = math
    L4_2 = L4_2.floor
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    L3_2 = L4_2
  end
  L4_2 = L3_2 / L2_2
  return L4_2
end
L0_1.round = L1_1
L0_1 = math
function L1_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = math
  L2_2 = L2_2.floor
  L3_2 = A1_2 / 2
  L3_2 = A0_2 + L3_2
  L3_2 = L3_2 / A1_2
  L2_2 = L2_2(L3_2)
  L2_2 = L2_2 * A1_2
  return L2_2
end
L0_1.roundNearest = L1_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L0_2 = math
  L0_2 = L0_2.random
  L1_2 = string
  L1_2 = L1_2.format
  L2_2 = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  L3_2 = string
  L3_2 = L3_2.gsub
  L4_2 = L2_2
  L5_2 = "[xy]"
  function L6_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3
    if "x" == A0_3 then
      L1_3 = L0_2
      L2_3 = 0
      L3_3 = 15
      L1_3 = L1_3(L2_3, L3_3)
      if L1_3 then
        goto lbl_13
      end
    end
    L1_3 = L0_2
    L2_3 = 8
    L3_3 = 11
    L1_3 = L1_3(L2_3, L3_3)
    ::lbl_13::
    L2_3 = L1_2
    L3_3 = "%x"
    L4_3 = L1_3
    return L2_3(L3_3, L4_3)
  end
  return L3_2(L4_2, L5_2, L6_2)
end
GenerateUuid = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L2_2 = A0_2
  L1_2 = A0_2.lower
  L1_2 = L1_2(L2_2)
  A0_2 = L1_2
  L2_2 = A0_2
  L1_2 = A0_2.gsub
  L3_2 = "[^%w%s-]"
  L4_2 = ""
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  A0_2 = L1_2
  L2_2 = A0_2
  L1_2 = A0_2.gsub
  L3_2 = "%s+"
  L4_2 = "-"
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  A0_2 = L1_2
  L2_2 = A0_2
  L1_2 = A0_2.gsub
  L3_2 = "-+"
  L4_2 = "-"
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  A0_2 = L1_2
  L2_2 = A0_2
  L1_2 = A0_2.gsub
  L3_2 = "^-+"
  L4_2 = ""
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  A0_2 = L1_2
  L2_2 = A0_2
  L1_2 = A0_2.gsub
  L3_2 = "-+$"
  L4_2 = ""
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  A0_2 = L1_2
  return A0_2
end
Slugify = L0_1
function L0_1(A0_2, ...)
  local L1_2, L2_2, L3_2
  L1_2 = Config
  L1_2 = L1_2.debug
  if L1_2 then
    L1_2 = type
    L2_2 = A0_2
    L1_2 = L1_2(L2_2)
    if "function" == L1_2 then
      L1_2 = print
      L2_2 = A0_2
      L2_2 = L2_2()
      L3_2 = ...
      L1_2(L2_2, L3_2)
      return
    end
    L1_2 = print
    L2_2 = A0_2
    L3_2 = ...
    L1_2(L2_2, L3_2)
  end
end
Debug = L0_1
function L0_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L3_2 = A0_2.x
  L4_2 = A1_2.x
  L3_2 = L3_2 - L4_2
  L4_2 = A0_2.y
  L5_2 = A1_2.y
  L4_2 = L4_2 - L5_2
  L5_2 = A0_2.z
  if not L5_2 then
    L5_2 = 0.0
  end
  L6_2 = A1_2.z
  if not L6_2 then
    L6_2 = 0.0
  end
  L5_2 = L5_2 - L6_2
  L6_2 = L3_2 * L3_2
  L7_2 = L4_2 * L4_2
  L6_2 = L6_2 + L7_2
  L7_2 = L5_2 * L5_2
  L6_2 = L6_2 + L7_2
  L7_2 = A2_2 * A2_2
  L8_2 = L6_2 <= L7_2
  return L8_2
end
IsWithinDistance = L0_1
function L0_1(A0_2)
  local L1_2
  L1_2 = math
  L1_2 = L1_2.pi
  L1_2 = A0_2 * L1_2
  L1_2 = L1_2 / 180
  return L1_2
end
function L1_1(A0_2)
  local L1_2, L2_2
  L1_2 = A0_2 * 180
  L2_2 = math
  L2_2 = L2_2.pi
  L1_2 = L1_2 / L2_2
  return L1_2
end
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L1_2 = L0_1
  L2_2 = A0_2.x
  L1_2 = L1_2(L2_2)
  L2_2 = L0_1
  L3_2 = A0_2.y
  L2_2 = L2_2(L3_2)
  L3_2 = L0_1
  L4_2 = A0_2.z
  L3_2 = L3_2(L4_2)
  L4_2 = math
  L4_2 = L4_2.cos
  L5_2 = L1_2
  L4_2 = L4_2(L5_2)
  L5_2 = math
  L5_2 = L5_2.sin
  L6_2 = L1_2
  L5_2 = L5_2(L6_2)
  L6_2 = math
  L6_2 = L6_2.cos
  L7_2 = L2_2
  L6_2 = L6_2(L7_2)
  L7_2 = math
  L7_2 = L7_2.sin
  L8_2 = L2_2
  L7_2 = L7_2(L8_2)
  L8_2 = math
  L8_2 = L8_2.cos
  L9_2 = L3_2
  L8_2 = L8_2(L9_2)
  L9_2 = math
  L9_2 = L9_2.sin
  L10_2 = L3_2
  L9_2 = L9_2(L10_2)
  L10_2 = {}
  L11_2 = {}
  L12_2 = L6_2 * L8_2
  L13_2 = -L4_2
  L13_2 = L13_2 * L9_2
  L14_2 = L5_2 * L7_2
  L14_2 = L14_2 * L8_2
  L13_2 = L13_2 + L14_2
  L14_2 = L5_2 * L9_2
  L15_2 = L4_2 * L7_2
  L15_2 = L15_2 * L8_2
  L14_2 = L14_2 + L15_2
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L11_2[3] = L14_2
  L12_2 = {}
  L13_2 = L6_2 * L9_2
  L14_2 = L4_2 * L8_2
  L15_2 = L5_2 * L7_2
  L15_2 = L15_2 * L9_2
  L14_2 = L14_2 + L15_2
  L15_2 = -L5_2
  L15_2 = L15_2 * L8_2
  L16_2 = L4_2 * L7_2
  L16_2 = L16_2 * L9_2
  L15_2 = L15_2 + L16_2
  L12_2[1] = L13_2
  L12_2[2] = L14_2
  L12_2[3] = L15_2
  L13_2 = {}
  L14_2 = -L7_2
  L15_2 = L5_2 * L6_2
  L16_2 = L4_2 * L6_2
  L13_2[1] = L14_2
  L13_2[2] = L15_2
  L13_2[3] = L16_2
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L10_2[3] = L13_2
  return L10_2
end
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L2_2 = {}
  L3_2 = 1
  L4_2 = 3
  L5_2 = 1
  for L6_2 = L3_2, L4_2, L5_2 do
    L7_2 = {}
    L2_2[L6_2] = L7_2
    L7_2 = 1
    L8_2 = 3
    L9_2 = 1
    for L10_2 = L7_2, L8_2, L9_2 do
      L11_2 = L2_2[L6_2]
      L11_2[L10_2] = 0
      L11_2 = 1
      L12_2 = 3
      L13_2 = 1
      for L14_2 = L11_2, L12_2, L13_2 do
        L15_2 = L2_2[L6_2]
        L16_2 = L2_2[L6_2]
        L16_2 = L16_2[L10_2]
        L17_2 = A0_2[L6_2]
        L17_2 = L17_2[L14_2]
        L18_2 = A1_2[L14_2]
        L18_2 = L18_2[L10_2]
        L17_2 = L17_2 * L18_2
        L16_2 = L16_2 + L17_2
        L15_2[L10_2] = L16_2
      end
    end
  end
  return L2_2
end
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = {}
  L3_2 = A0_2.x
  L4_2 = A1_2[1]
  L4_2 = L4_2[1]
  L3_2 = L3_2 * L4_2
  L4_2 = A0_2.y
  L5_2 = A1_2[1]
  L5_2 = L5_2[2]
  L4_2 = L4_2 * L5_2
  L3_2 = L3_2 + L4_2
  L4_2 = A0_2.z
  L5_2 = A1_2[1]
  L5_2 = L5_2[3]
  L4_2 = L4_2 * L5_2
  L3_2 = L3_2 + L4_2
  L2_2.x = L3_2
  L3_2 = A0_2.x
  L4_2 = A1_2[2]
  L4_2 = L4_2[1]
  L3_2 = L3_2 * L4_2
  L4_2 = A0_2.y
  L5_2 = A1_2[2]
  L5_2 = L5_2[2]
  L4_2 = L4_2 * L5_2
  L3_2 = L3_2 + L4_2
  L4_2 = A0_2.z
  L5_2 = A1_2[2]
  L5_2 = L5_2[3]
  L4_2 = L4_2 * L5_2
  L3_2 = L3_2 + L4_2
  L2_2.y = L3_2
  L3_2 = A0_2.x
  L4_2 = A1_2[3]
  L4_2 = L4_2[1]
  L3_2 = L3_2 * L4_2
  L4_2 = A0_2.y
  L5_2 = A1_2[3]
  L5_2 = L5_2[2]
  L4_2 = L4_2 * L5_2
  L3_2 = L3_2 + L4_2
  L4_2 = A0_2.z
  L5_2 = A1_2[3]
  L5_2 = L5_2[3]
  L4_2 = L4_2 * L5_2
  L3_2 = L3_2 + L4_2
  L2_2.z = L3_2
  return L2_2
end
function L5_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L1_2 = math
  L1_2 = L1_2.sqrt
  L2_2 = A0_2[1]
  L2_2 = L2_2[1]
  L3_2 = A0_2[1]
  L3_2 = L3_2[1]
  L2_2 = L2_2 * L3_2
  L3_2 = A0_2[2]
  L3_2 = L3_2[1]
  L4_2 = A0_2[2]
  L4_2 = L4_2[1]
  L3_2 = L3_2 * L4_2
  L2_2 = L2_2 + L3_2
  L1_2 = L1_2(L2_2)
  L2_2 = 1.0E-6
  L2_2 = L1_2 < L2_2
  L3_2 = nil
  L4_2 = nil
  L5_2 = nil
  if not L2_2 then
    L6_2 = math
    L6_2 = L6_2.atan2
    L7_2 = A0_2[3]
    L7_2 = L7_2[2]
    L8_2 = A0_2[3]
    L8_2 = L8_2[3]
    L6_2 = L6_2(L7_2, L8_2)
    L3_2 = L6_2
    L6_2 = math
    L6_2 = L6_2.atan2
    L7_2 = A0_2[3]
    L7_2 = L7_2[1]
    L7_2 = -L7_2
    L8_2 = L1_2
    L6_2 = L6_2(L7_2, L8_2)
    L4_2 = L6_2
    L6_2 = math
    L6_2 = L6_2.atan2
    L7_2 = A0_2[2]
    L7_2 = L7_2[1]
    L8_2 = A0_2[1]
    L8_2 = L8_2[1]
    L6_2 = L6_2(L7_2, L8_2)
    L5_2 = L6_2
  else
    L6_2 = math
    L6_2 = L6_2.atan2
    L7_2 = A0_2[2]
    L7_2 = L7_2[3]
    L7_2 = -L7_2
    L8_2 = A0_2[2]
    L8_2 = L8_2[2]
    L6_2 = L6_2(L7_2, L8_2)
    L3_2 = L6_2
    L6_2 = math
    L6_2 = L6_2.atan2
    L7_2 = A0_2[3]
    L7_2 = L7_2[1]
    L7_2 = -L7_2
    L8_2 = L1_2
    L6_2 = L6_2(L7_2, L8_2)
    L4_2 = L6_2
    L5_2 = 0
  end
  L6_2 = vector3
  L7_2 = L1_1
  L8_2 = L3_2
  L7_2 = L7_2(L8_2)
  L8_2 = L1_1
  L9_2 = L4_2
  L8_2 = L8_2(L9_2)
  L9_2 = L1_1
  L10_2 = L5_2
  L9_2, L10_2 = L9_2(L10_2)
  return L6_2(L7_2, L8_2, L9_2, L10_2)
end
function L6_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L4_2 = L2_1
  L5_2 = A1_2
  L4_2 = L4_2(L5_2)
  L5_2 = L2_1
  L6_2 = A3_2
  L5_2 = L5_2(L6_2)
  L6_2 = L4_1
  L7_2 = A2_2
  L8_2 = L4_2
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = vector3
  L8_2 = A0_2.x
  L9_2 = L6_2.x
  L8_2 = L8_2 + L9_2
  L9_2 = A0_2.y
  L10_2 = L6_2.y
  L9_2 = L9_2 + L10_2
  L10_2 = A0_2.z
  L11_2 = L6_2.z
  L10_2 = L10_2 + L11_2
  L7_2 = L7_2(L8_2, L9_2, L10_2)
  L8_2 = L3_1
  L9_2 = L4_2
  L10_2 = L5_2
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = L5_1
  L10_2 = L8_2
  L9_2 = L9_2(L10_2)
  L10_2 = L7_2
  L11_2 = L9_2
  return L10_2, L11_2
end
ConvertOffsetToWorld = L6_1
function L6_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = L2_1
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L3_2 = L2_1
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  L4_2 = L3_1
  L5_2 = L2_2
  L6_2 = L3_2
  L4_2 = L4_2(L5_2, L6_2)
  L5_2 = L5_1
  L6_2 = L4_2
  L5_2 = L5_2(L6_2)
  return L5_2
end
CombineRotations = L6_1
function L6_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2
  L1_2 = vector3
  L2_2 = math
  L2_2 = L2_2.rad
  L3_2 = A0_2.x
  L2_2 = L2_2(L3_2)
  L3_2 = math
  L3_2 = L3_2.rad
  L4_2 = A0_2.y
  L3_2 = L3_2(L4_2)
  L4_2 = math
  L4_2 = L4_2.rad
  L5_2 = A0_2.z
  L4_2, L5_2 = L4_2(L5_2)
  return L1_2(L2_2, L3_2, L4_2, L5_2)
end
function L7_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L3_2 = L6_1
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  L4_2 = math
  L4_2 = L4_2.sin
  L5_2 = L3_2.x
  L4_2 = L4_2(L5_2)
  L5_2 = math
  L5_2 = L5_2.cos
  L6_2 = L3_2.x
  L5_2 = L5_2(L6_2)
  L6_2 = math
  L6_2 = L6_2.sin
  L7_2 = L3_2.y
  L6_2 = L6_2(L7_2)
  L7_2 = math
  L7_2 = L7_2.cos
  L8_2 = L3_2.y
  L7_2 = L7_2(L8_2)
  L8_2 = math
  L8_2 = L8_2.sin
  L9_2 = L3_2.z
  L8_2 = L8_2(L9_2)
  L9_2 = math
  L9_2 = L9_2.cos
  L10_2 = L3_2.z
  L9_2 = L9_2(L10_2)
  L10_2 = {}
  L11_2 = {}
  L12_2 = L9_2 * L7_2
  L13_2 = L9_2 * L6_2
  L13_2 = L13_2 * L4_2
  L14_2 = L8_2 * L5_2
  L13_2 = L13_2 - L14_2
  L14_2 = L9_2 * L6_2
  L14_2 = L14_2 * L5_2
  L15_2 = L8_2 * L4_2
  L14_2 = L14_2 + L15_2
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L11_2[3] = L14_2
  L12_2 = {}
  L13_2 = L8_2 * L7_2
  L14_2 = L8_2 * L6_2
  L14_2 = L14_2 * L4_2
  L15_2 = L9_2 * L5_2
  L14_2 = L14_2 + L15_2
  L15_2 = L8_2 * L6_2
  L15_2 = L15_2 * L5_2
  L16_2 = L9_2 * L4_2
  L15_2 = L15_2 - L16_2
  L12_2[1] = L13_2
  L12_2[2] = L14_2
  L12_2[3] = L15_2
  L13_2 = {}
  L14_2 = -L6_2
  L15_2 = L7_2 * L4_2
  L16_2 = L7_2 * L5_2
  L13_2[1] = L14_2
  L13_2[2] = L15_2
  L13_2[3] = L16_2
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L10_2[3] = L13_2
  L11_2 = A2_2.x
  L12_2 = A0_2.x
  L11_2 = L11_2 - L12_2
  L12_2 = A2_2.y
  L13_2 = A0_2.y
  L12_2 = L12_2 - L13_2
  L13_2 = A2_2.z
  L14_2 = A0_2.z
  L13_2 = L13_2 - L14_2
  L14_2 = vector3
  L15_2 = L10_2[1]
  L15_2 = L15_2[1]
  L15_2 = L15_2 * L11_2
  L16_2 = L10_2[2]
  L16_2 = L16_2[1]
  L16_2 = L16_2 * L12_2
  L15_2 = L15_2 + L16_2
  L16_2 = L10_2[3]
  L16_2 = L16_2[1]
  L16_2 = L16_2 * L13_2
  L15_2 = L15_2 + L16_2
  L16_2 = L10_2[1]
  L16_2 = L16_2[2]
  L16_2 = L16_2 * L11_2
  L17_2 = L10_2[2]
  L17_2 = L17_2[2]
  L17_2 = L17_2 * L12_2
  L16_2 = L16_2 + L17_2
  L17_2 = L10_2[3]
  L17_2 = L17_2[2]
  L17_2 = L17_2 * L13_2
  L16_2 = L16_2 + L17_2
  L17_2 = L10_2[1]
  L17_2 = L17_2[3]
  L17_2 = L17_2 * L11_2
  L18_2 = L10_2[2]
  L18_2 = L18_2[3]
  L18_2 = L18_2 * L12_2
  L17_2 = L17_2 + L18_2
  L18_2 = L10_2[3]
  L18_2 = L18_2[3]
  L18_2 = L18_2 * L13_2
  L17_2 = L17_2 + L18_2
  return L14_2(L15_2, L16_2, L17_2)
end
GetOffsetFromWorldGivenWorldCoords = L7_1
