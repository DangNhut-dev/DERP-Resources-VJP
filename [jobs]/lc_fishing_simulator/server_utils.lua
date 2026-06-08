WebhookURL = "" -- Webhook to send logs to discord

function beforeAccessLocation(source, user_id)
	-- Here you can do any verification when a player is opening the fisher UI for the first time only, like if player has the permission or money to that or anything else you want to check. return true or false
	return true
end

function onAccessLocation(source, user_id)
	-- Here you can do any verification when a player is opening the fisher UI, like if player has the permission or money to that or anything else you want to check. return true or false
	return true
end

function beforeBuyVehicle(source, vehicle_type, vehicle_name, price, user_id)
	-- Here you can do any verification when a player is buying a vehicle, like if player has driver license or anything else you want to check before buy the vehicle. return true or false
	return true
end

function beforeBuyProperty(source, property, price, user_id)
	-- Here you can do any verification when a player is buying a property, like if player has driver license or anything else you want to check before buy the property. return true or false
	return true
end

function beforeReceiveFish(source, fish_id, was_fish_released)
	-- Here you can do any verification when a player is receiving a fish. return true or false
	return true
end

function afterReceiveFish(source, fish_id, was_fish_released)
	-- Here you can do any verification after a player received a fish
end

function userCannotCarryFish(source, fish_id, amount)
	-- This function is executed when the player finishes fishing but cannot carry the fish. You can add any exports, such as dropping the fish on the ground, among others
end

function userCatchFish(source, fish_id)
	-- This function is executed when the player is receiving the fish in his inventory. Must return true if can carry the item, or false if not.
	-- If you are looking to put your inventory export to give item to the player, here is the wrong place. Please read: https://docs.lixeirocharmoso.com/utils/adding_your_exports
	return Utils.Framework.givePlayerItem(source, fish_id, 1)
end