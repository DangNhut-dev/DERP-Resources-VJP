Globals = {}
Functions = {}
Locale = Locales[Config.Locale or "en"]

exports("config", function()
  return Config
end)

function debugPrint(context, logType, ...)
  if not Config.Debug then
    return
  end

  local prefix = "^2[DEBUG]^7"
  if logType == "warning" then
    prefix = "^3[WARNING]^7"
  end

  local args = { ... }
  local outputString = ""
  for i = 1, #args do
    if type(args[i]) == "table" then
      outputString = outputString .. json.encode(args[i])
    elseif type(args[i]) ~= "string" then
      outputString = outputString .. tostring(args[i])
    else
      outputString = outputString .. args[i]
    end
    if i ~= #args then
      outputString = outputString .. " "
    end
  end
  print(prefix, context, outputString)
end

function getTrimmedVehiclePlate(vehicle)
  if not vehicle or not DoesEntityExist(vehicle) then
    return false
  end

  local plate = GetVehicleNumberPlateText(vehicle)
  if not plate then
    return false
  end

  return string.gsub(plate, "^%s*(.-)%s*$", "%1")
end

function isVehicleElectric(modelName)
  if GetGameBuildNumber() >= 3258 then
    return Citizen.InvokeNative(0x1F33C33A4FCC175B, joaat(modelName)) == 1
  end
  return lib.table.contains(Config.ElectricVehicles, modelName)
end

function round(number, decimals)
  local effectiveDecimals = decimals or 0
  local factor = 10 ^ effectiveDecimals
  return math.floor(number * factor + 0.5) / factor
end

function deepMerge(originalTable, newTable)
  for key, value in pairs(newTable) do
    if type(value) == "table" and type(originalTable[key]) == "table" then
      deepMerge(originalTable[key], value)
    elseif value == "nil (deleted)" then
      originalTable[key] = nil
    else
      originalTable[key] = value
    end
  end
  return originalTable
end

function tableConcat(table1, table2)
  local newTable = {}
  if #table1 > 0 and #table2 > 0 then
    for i = 1, #table1 do
      newTable[#newTable + 1] = table1[i]
    end
    for i = 1, #table2 do
      newTable[#newTable + 1] = table2[i]
    end
  else
    for key, value in pairs(table1) do
      newTable[key] = value
    end
    for key, value in pairs(table2) do
      newTable[key] = value
    end
  end
  return newTable
end

function tableKeys(inputTable)
  local keys = {}
  for key, _ in pairs(inputTable) do
    keys[#keys + 1] = key
  end
  return keys
end

function bitOper(val1, val2, op)
  local result = 0
  local powerOf2 = 2147483648
  local temp = 0
  repeat
    local calc = val1 + val2 + powerOf2
    local rem1 = val1 % powerOf2
    local rem2 = val2 % powerOf2
    val1 = rem1
    temp = calc
    local calc2 = powerOf2 * op
    local calc3 = temp - val1 - rem2
    calc2 = calc2 % calc3
    calc2 = result + calc2
    powerOf2 = powerOf2 / 2
    result = calc2
  until powerOf2 < 1
  return result
end

function hasFlag(flags, flag)
  return bitOper(flags, flag, 4) == flag
end

function addFlag(flags, flag)
  if hasFlag(flags, flag) then
    return flags
  end
  return math.floor(bitOper(flags, flag, 1))
end

function removeFlag(flags, flag)
  if not hasFlag(flags, flag) then
    return flags
  end
  return math.floor(bitOper(flags, flag, 3))
end

function parseControlBinding(control)
  local button = GetControlInstructionalButton(0, control, true)
  local parsedButton = string.gsub(button, "^t_", "")
  if button ~= parsedButton then
    return parsedButton
  end

  if CONTROL_KEYBINDS[button] then
    return CONTROL_KEYBINDS[button]
  end

  return button
end