local companies = {}
for _, company in ipairs(Config.Services.Companies) do
  companies[company.job] = company
end

local function getEmployees(company)
  if not company then return false end
  if Config.Services.SeeEmployees == "none" then
    debugprint("No one is allowed to see employees")
    return false
  elseif Config.Services.SeeEmployees == "employees" then
    if GetJob() ~= company then
      debugprint("Player has the wrong job")
      return false
    end
  end
  return AwaitCallback("services:getEmployeeList", company)
end

local function getRecentMessages(page)
  local messages = AwaitCallback("services:getRecentMessages", page)
  for _, msg in ipairs(messages) do
    if companies[msg.company] then
      msg.company = {
        icon = companies[msg.company].icon,
        name = companies[msg.company].name,
        job = companies[msg.company].job
      }
    end
  end
  return messages
end

local function getMessages(id, lastId)
  local messages = AwaitCallback("services:getMessages", id, lastId)
  local phoneNumber = Config.LBPhone and GetPhoneNumber()
  for _, msg in ipairs(messages) do
    msg.isSender = msg.sender == phoneNumber
  end
  return messages
end

ReactCallback("Services", function(data)
  if data.action == "getCompanies" then
    return AwaitCallback("services:getCompanies")
  elseif data.action == "getEmployees" then
    return getEmployees(data.company)
  elseif data.action == "getRecentMessages" then
    return getRecentMessages(data.page)
  elseif data.action == "getMessages" then
    return getMessages(data.id, data.lastId)
  elseif data.action == "getCompany" then
    return GetCompanyData()
  elseif data.action == "depositMoney" and Config.Services.Management.Deposit then
    return DepositMoney(data.amount)
  elseif data.action == "withdrawMoney" and Config.Services.Management.Withdraw then
    return WithdrawMoney(data.amount)
  elseif data.action == "hireEmployee" and Config.Services.Management.Hire then
    return HireEmployee(data.source)
  elseif data.action == "fireEmployee" and Config.Services.Management.Fire then
    return FireEmployee(data.employee)
  elseif data.action == "setGrade" and Config.Services.Management.Promote then
    return SetGrade(data.employee, data.grade)
  elseif data.action == "toggleDuty" and Config.Services.Management.Duty then
    ToggleDuty()
    return true
  elseif data.action == "toggleCalls" then
    return ToggleCompanyCalls()
  end
  debugprint("Services: invalid action", data.action)
end)

RegisterNetEvent("phone:services:newMessage", function(msg)
  msg.isSender = msg.sender == GetPhoneNumber()
  SendReactMessage("services:newMessage", msg)
end)

RegisterNetEvent("phone:services:channelDeleted", function(channel)
  SendReactMessage("services:channelDeleted", channel)
end)