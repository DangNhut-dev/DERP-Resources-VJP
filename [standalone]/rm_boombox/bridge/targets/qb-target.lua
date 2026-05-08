if cfg.framework.targetScript ~= "qb-target" then return end

madCore.addEntityTarget = function(entity, option)
	exports['qb-target']:AddTargetEntity(entity, {
		options = { 
			{
				icon = option.icon or "fa-brands fa-intercom",
				label = option.label,
				canInteract = option.canInteract,
				action = option.onSelect,
			}
		},
		distance = 2.0
	})
end