if not Config.LBPhone then return end

RegisterNetEvent("lb-phone:numberChanged", function(number)
  SendReactMessage("setHasPhone", number ~= nil)
end)

while GetResourceState("lb-phone") ~= "started" do
  Wait(0)
end
Wait(1000)

local function callPhoneExport(name, ...)
  local success, result = pcall(exports["lb-phone"][name], ...)
  if not success then
    debugprint("Error calling lb-phone export " .. name .. ": ")
    debugprint(result)
  end
  return result
end

function GetPhoneNumber()
  return callPhoneExport("GetEquippedPhoneNumber")
end

function GetCompanyCallsStatus()
  return callPhoneExport("GetCompanyCallsStatus")
end

function ToggleCompanyCalls()
  return callPhoneExport("ToggleCompanyCalls")
end

while not GetPhoneNumber() do
  Wait(500)
end

if LoadedNUI then
  SendReactMessage("setHasPhone", true)
end