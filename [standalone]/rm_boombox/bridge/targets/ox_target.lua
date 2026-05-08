if cfg.framework.targetScript ~= "ox_target" then return end

madCore.addEntityTarget = function(entity, option)
	exports.ox_target:addLocalEntity(entity, {
		{
			icon = option.icon or "fa-brands fa-intercom",
			label = option.label,
			canInteract = option.canInteract,
			onSelect = option.onSelect,
			distance = 2.0
		}
	})
end