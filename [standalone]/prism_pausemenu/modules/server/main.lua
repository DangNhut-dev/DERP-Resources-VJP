local L0_1, L1_1, L2_1
L0_1 = RegisterServerEvent
L1_1 = "prism_pausemenu:disconnect"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = ESX
  L1_2 = L1_2.GetPlayerFromId
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  if L1_2 then
    L2_2 = L1_2.getIdentifier
    L2_2 = L2_2()
    if L2_2 then
      L2_2 = DropPlayer
      L3_2 = A0_2
      L4_2 = "You have disconnected"
      L2_2(L3_2, L4_2)
  end
  else
    L2_2 = print
    L3_2 = "Invalid disconnection attempt by the player: "
    L4_2 = A0_2
    L3_2 = L3_2 .. L4_2
    L2_2(L3_2)
  end
end
L0_1(L1_1, L2_1)
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = CFG
  L1_2 = L1_2.GetGangFunction
  L2_2 = type
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  if "function" == L2_2 then
    L2_2 = pcall
    L3_2 = L1_2
    L4_2 = A0_2
    L2_2, L3_2 = L2_2(L3_2, L4_2)
    if L2_2 and L3_2 then
      return L3_2
    else
      L4_2 = print
      L5_2 = "[ERROR] Error calling export function:"
      L6_2 = L3_2
      L4_2(L5_2, L6_2)
      L4_2 = ""
      return L4_2
    end
  else
    L2_2 = type
    L3_2 = L1_2
    L2_2 = L2_2(L3_2)
    if "string" == L2_2 then
      if "rcore_gangs" == L1_2 then
        L2_2 = exports
        L2_2 = L2_2.rcore_gangs
        L3_2 = L2_2
        L2_2 = L2_2.GetPlayerGang
        L4_2 = A0_2
        L2_2 = L2_2(L3_2, L4_2)
        if not L2_2 then
          L3_2 = ""
          return L3_2
        end
        L3_2 = L2_2.name
        return L3_2
      elseif "op-crime" == L1_2 then
        L2_2 = GetPrimaryIdentifier
        L3_2 = A0_2
        L2_2 = L2_2(L3_2)
        L3_2 = exports
        L3_2 = L3_2["op-crime"]
        L4_2 = L3_2
        L3_2 = L3_2.getPlayerOrganisation
        L5_2 = L2_2
        L3_2 = L3_2(L4_2, L5_2)
        if not L3_2 then
          L4_2 = ""
          return L4_2
        end
        L4_2 = L3_2.orgData
        L4_2 = L4_2.label
        if not L4_2 then
          L4_2 = ""
        end
        return L4_2
      elseif "brutal_gangs" == L1_2 then
        L2_2 = exports
        L2_2 = L2_2.brutal_gangs
        L3_2 = L2_2
        L2_2 = L2_2.GetPlayerGangName
        L4_2 = A0_2
        L2_2 = L2_2(L3_2, L4_2)
        if not L2_2 then
          L3_2 = ""
          return L3_2
        end
        return L2_2
      elseif "rk_factions" == L1_2 then
        L2_2 = exports
        L2_2 = L2_2.rk_factions
        L3_2 = L2_2
        L2_2 = L2_2.GetPlayerFInfo
        L4_2 = A0_2
        L2_2 = L2_2(L3_2, L4_2)
        if not L2_2 then
          L3_2 = ""
          return L3_2
        end
        L3_2 = L2_2.factionName
        return L3_2
      elseif "qbcore" == L1_2 then
        L2_2 = QBCore
        L2_2 = L2_2.Functions
        L2_2 = L2_2.GetPlayer
        L3_2 = A0_2
        L2_2 = L2_2(L3_2)
        if not L2_2 then
          L3_2 = ""
          return L3_2
        end
        L3_2 = L2_2.PlayerData
        L3_2 = L3_2.gang
        L3_2 = L3_2.label
        if not L3_2 then
          L3_2 = ""
        end
        return L3_2
      elseif "qbox" == L1_2 then
        L2_2 = exports
        L2_2 = L2_2.qbx_core
        L3_2 = L2_2
        L2_2 = L2_2.GetPlayer
        L4_2 = A0_2
        L2_2 = L2_2(L3_2, L4_2)
        if not L2_2 then
          L3_2 = ""
          return L3_2
        end
        L3_2 = L2_2.PlayerData
        L3_2 = L3_2.gang
        L3_2 = L3_2.label
        if not L3_2 then
          L3_2 = ""
        end
        return L3_2
      else
        return L1_2
      end
    else
      L2_2 = print
      L3_2 = "CFG.GetGangFunction is neither function nor string"
      L2_2(L3_2)
      L2_2 = ""
      return L2_2
    end
  end
end
CfgGetGang = L0_1

