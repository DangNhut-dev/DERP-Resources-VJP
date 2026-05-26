function getSocietyFund(source, mechanicName)
	if Config.UseFrameworkJobs then
		local locationConfig = Config.MechanicLocations[mechanicName]
		local jobName = locationConfig and locationConfig.job

		if not jobName then
			return 0
		end

		local balance = Framework.Server.GetSocietyBalance(jobName, "job")
		if not balance then
			balance = 0
		end
		return balance
	else
		local balance = MySQL.scalar.await("SELECT balance FROM mechanic_data WHERE name = ?", {
			mechanicName
		})

		return balance or 0
	end
end

function addToSocietyFund(source, mechanicName, amount)
	if not amount or amount < 0 then
		return false
	end

	if Config.UseFrameworkJobs then
		local locationConfig = Config.MechanicLocations[mechanicName]
		local jobName = locationConfig and locationConfig.job

		if not jobName then
			return false
		end

		Framework.Server.PayIntoSocietyFund(jobName, "job", amount)
	else
		MySQL.update.await("UPDATE mechanic_data SET balance = balance + ? WHERE name = ?", {
			amount,
			mechanicName
		})
	end

	return true
end

function removeFromSocietyFund(source, mechanicName, amount)
	if not amount or amount < 0 then
		return false
	end

	if Config.UseFrameworkJobs then
		local locationConfig = Config.MechanicLocations[mechanicName]
		local jobName = locationConfig and locationConfig.job

		if not jobName then
			return false
		end

		local societyBalance = Framework.Server.GetSocietyBalance(jobName, "job")

		if amount > societyBalance then
			Framework.Server.Notify(source, Locale.notEnoughMoney, "error")
			return false
		end

		Framework.Server.RemoveFromSocietyFund(jobName, "job", amount)
	else
		local balance = MySQL.scalar.await("SELECT balance FROM mechanic_data WHERE name = ?", {
			mechanicName
		})

		if amount > balance then
			Framework.Server.Notify(source, Locale.notEnoughMoney, "error")
			return false
		end

		MySQL.update.await("UPDATE mechanic_data SET balance = balance - ? WHERE name = ?", {
			amount,
			mechanicName
		})
	end

	return true
end

lib.callback.register("DERP-mechanic:server:get-mechanic-balance", function(source, mechanicName)
	local hasPermission = isEmployee(source, mechanicName, { "mechanic", "manager" }, true)

	if not hasPermission then
		Framework.Server.Notify(source, Locale.employeePermissionsError, "error")
		return false
	end

	return getSocietyFund(source, mechanicName)
end)

lib.callback.register("DERP-mechanic:server:get-mechanic-employees", function(source, mechanicName)
	local playerIdentifier = Framework.Server.GetPlayerIdentifier(source)

	if Config.UseFrameworkJobs then
		return {}
	end

	local hasPermission = isEmployee(source, mechanicName, "manager", true)
	if not hasPermission then
		Framework.Server.Notify(source, Locale.employeePermissionsError, "error")
		return false
	end

	local employees = MySQL.query.await("SELECT * FROM mechanic_employees WHERE mechanic = ?", {
		mechanicName
	})

	for index, employeeData in ipairs(employees) do
		local playerInfo = Framework.Server.GetPlayerInfoFromIdentifier(employeeData.identifier)
		local playerName = (playerInfo and playerInfo.name) or "-"

		employees[index] = {
			id = employeeData.player,
			identifier = employeeData.identifier,
			name = playerName,
			role = employeeData.role,
			joined = employeeData.joined,
			me = (playerIdentifier == employeeData.identifier)
		}
	end

	return employees
end)

lib.callback.register("DERP-mechanic:server:mechanic-deposit", function(source, mechanicName, accountType, amount)
	local hasPermission = isEmployee(source, mechanicName, "manager", true)
	if not hasPermission then
		Framework.Server.Notify(source, Locale.employeePermissionsError, "error")
		return false
	end

	if amount < 0 then
		Framework.Server.Notify(source, "Stop trying to exploit the script", "error")
		return false
	end

	local playerBalance = Framework.Server.GetPlayerBalance(source, accountType)
	if amount > playerBalance then
		Framework.Server.Notify(source, Locale.notEnoughMoney, "error")
		return false
	end

	Framework.Server.PlayerRemoveMoney(source, amount, accountType)
	MySQL.update.await("UPDATE mechanic_data SET balance = balance + ? WHERE name = ?", {
		amount,
		mechanicName
	})

	Framework.Server.Notify(source, Locale.depositSuccess, "success")
	sendWebhook(source, Webhooks.Mechanic, "Mechanic: Money Deposited", nil, {
		{ key = "Mechanic", value = mechanicName },
		{ key = "Amount", value = amount }
	})

	return true
end)

lib.callback.register("DERP-mechanic:server:mechanic-withdraw", function(source, mechanicName, amount)
	local hasPermission = isEmployee(source, mechanicName, "manager", true)
	if not hasPermission then
		Framework.Server.Notify(source, Locale.employeePermissionsError, "error")
		return false
	end

	if amount < 0 then
		Framework.Server.Notify(source, "Stop trying to exploit the script", "error")
		return false
	end

	local mechanicData = MySQL.single.await("SELECT * FROM mechanic_data WHERE name = ?", {
		mechanicName
	})

	if not mechanicData then
		return false
	end

	if amount > mechanicData.balance then
		Framework.Server.Notify(source, Locale.insufficientFunds:format(tostring(amount)), "error")
		return false
	end

	Framework.Server.PlayerAddMoney(source, amount, "bank")
	MySQL.update.await("UPDATE mechanic_data SET balance = balance - ? WHERE name = ?", {
		amount,
		mechanicName
	})

	Framework.Server.Notify(source, Locale.withdrawSuccess, "success")
	sendWebhook(source, Webhooks.Mechanic, "Mechanic: Money Withdraw", nil, {
		{ key = "Mechanic", value = mechanicName },
		{ key = "Amount", value = amount }
	})

	return true
end)

lib.callback.register("DERP-mechanic:server:update-mechanic-settings", function(source, mechanicName, settings)
	local hasPermission = isEmployee(source, mechanicName, "manager", true)
	if not hasPermission then
		Framework.Server.Notify(source, Locale.employeePermissionsError, "error")
		return false
	end

	MySQL.update.await("UPDATE mechanic_data SET label = ? WHERE name = ?", {
		settings.label,
		mechanicName
	})

	TriggerClientEvent("DERP-mechanic:client:refresh-mechanic-zones-and-blips", -1)

	sendWebhook(source, Webhooks.Mechanic, "Mechanic: Name Updated", nil, {
		{ key = "Mechanic", value = mechanicName },
		{ key = "New name", value = settings.label }
	})

	return true
end)