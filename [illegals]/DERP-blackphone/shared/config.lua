Config = {}

Config.Debug = true

Config.Item = 'blackphone'

Config.OpenKeybind = false
Config.KeybindKey = 'F1'

Config.UseConditions = {
    disableOnCuffed = true,
    disableOnDead = true,
    allowInVehicle = true,
    allowWhileSwimming = false,
    allowWhileFalling = false
}

Config.DisableControlsOnOpen = {
    0, 1, 2, 24, 25, 257, 263, 47, 58, 140, 141, 142, 143, 263, 264
}

Config.AnimationDict = 'cellphone@'
Config.AnimationName = 'cellphone_text_read_base'

Config.Prop = {
    enabled = true,
    model = `prop_phone_ing`,
    bone = 28422,
    offset = vec3(0.0, 0.0, 0.0),
    rotation = vec3(0.0, 0.0, 0.0)
}

Config.CloseOnDeath = true
Config.CloseOnCuffed = true