local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
L0_1 = {}
L1_1 = LoadResourceFile
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L3_1 = "shared/locale.lua"
L1_1 = L1_1(L2_1, L3_1)
L2_1 = L1_1
L1_1 = L1_1.sub
L3_1 = 1
L4_1 = 5
L1_1 = L1_1(L2_1, L3_1, L4_1)
if "FXAP\001" ~= L1_1 then
  L1_1 = erSyncObjects
  L1_1()
end
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = LoadResourceFile
  L3_2 = A0_2
  L4_2 = A1_2
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L3_2 = print
    L4_2 = "Error: Could not load file '%s' from resource '%s'"
    L5_2 = L4_2
    L4_2 = L4_2.format
    L6_2 = A1_2
    L7_2 = A0_2
    L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L4_2(L5_2, L6_2, L7_2)
    L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
    return
  end
  L3_2 = json
  L3_2 = L3_2.decode
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  if not L3_2 then
    L4_2 = print
    L5_2 = "Error: Could not parse JSON from file '%s' in resource '%s'"
    L6_2 = L5_2
    L5_2 = L5_2.format
    L7_2 = A1_2
    L8_2 = A0_2
    L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L5_2(L6_2, L7_2, L8_2)
    L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
    return
  end
  L4_2 = pairs
  L5_2 = L3_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = L0_1
    L10_2[L8_2] = L9_2
  end
end
loadLocale = L1_1
L1_1 = LoadResourceFile
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L3_1 = ".fxap"
L1_1 = L1_1(L2_1, L3_1)
if nil == L1_1 then
  L1_1 = Wait
  L2_1 = 950000
  L1_1(L2_1)
end
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = {}
  L3_2 = string
  L3_2 = L3_2.gmatch
  L4_2 = A0_2
  L5_2 = "[^%.]+"
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2, L5_2)
  for L7_2 in L3_2, L4_2, L5_2, L6_2 do
    L8_2 = table
    L8_2 = L8_2.insert
    L9_2 = L2_2
    L10_2 = L7_2
    L8_2(L9_2, L10_2)
  end
  L3_2 = L0_1
  L4_2 = ipairs
  L5_2 = L2_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L3_2 = L3_2[L9_2]
    if not L3_2 then
      L10_2 = "[MISSING_LOCALE] "
      L11_2 = A0_2
      L10_2 = L10_2 .. L11_2
      return L10_2
    end
  end
  L4_2 = type
  L5_2 = L3_2
  L4_2 = L4_2(L5_2)
  if "string" == L4_2 then
    L4_2 = string
    L4_2 = L4_2.gsub
    L5_2 = L3_2
    L6_2 = "{{%s*(%w+)%s*}}"
    function L7_2(A0_3)
      local L1_3, L2_3, L3_3
      L1_3 = A1_2
      L1_3 = L1_3[A0_3]
      if not L1_3 then
        L1_3 = "{{"
        L2_3 = A0_3
        L3_3 = "}}"
        L1_3 = L1_3 .. L2_3 .. L3_3
      end
      return L1_3
    end
    L4_2 = L4_2(L5_2, L6_2, L7_2)
    L3_2 = L4_2
  end
  return L3_2
end
L = L1_1
L1_1 = loadLocale
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L3_1 = "locales/"
L4_1 = Config
L4_1 = L4_1.locale
L5_1 = ".json"
L3_1 = L3_1 .. L4_1 .. L5_1
L1_1(L2_1, L3_1)
