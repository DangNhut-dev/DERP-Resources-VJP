Config = {}

Config.DefaultKeybind = 'LSHIFT'

-- just paste the name of model of the vehicle you want megaphone to be accessible from
Config.PoliceVehicles = {
    [`police`] = true,
    [`police2`] = true,
    [`police3`] = true,
    [`police4`] = true,
    [`police5`] = true,
    [`riot`] = true,
    [`riot2`] = true,
    [`sheriff`] = true,
    [`sheriff2`] = true,
    [`policeold1`] = true,
    [`policeold2`] = true,
    [`policet`] = true,
    [`policeb`] = true,
    [`pranger`] = true,
    [`fbi`] = true,
    [`fbi2`] = true,
    [`predator`] = true,
    [`polgauntlet`] = true,

    [`r1200rtp`] = true,
    [`npolmm`] = true,
    [`npolchar`] = true,
    [`npolvic`] = true,
    [`npolchal`] = true,
    [`npolstang`] = true,
    [`npolretinue`] = true,
    [`ucwashington`] = true,
    [`ucprimo`] = true,
    [`ucbuffalo`] = true,
    [`ucballer`] = true,
}
-- same as above, but for helicopters (of cource planes too, but why would somone install AP to plane?)
Config.Helis = {
    [`polmav`] = true,
    [`polas350`] = true,
}

--- don't forget to paste `setr voice_useNativeAudio true` into your server.cfg file
-- native audio distance seems to be larger then regular gta units
Config.MegaphoneProximity = 30.0
Config.HeliMegaphoneProximity = 100.0

Config.DefaultRadioFilter = {
    ["freq_low"] = 100.0,
    ["freq_hi"] = 5000.0,
    ["rm_mod_freq"] = 300.0,
    ["rm_mix"] = 0.1,
    ["fudge"] = 4.0,
    ["o_freq_lo"] = 300.0,
    ["o_freq_hi"] = 5000.0,
}


-- we need this functions only on client side 
if not IsDuplicityVersion() then
	function CreateAudioSubmix(name)
		return Citizen.InvokeNative(0x658d2bc8, name, Citizen.ResultAsInteger())
	end

	function AddAudioSubmixOutput(submixId, outputSubmixId)
		Citizen.InvokeNative(0xAC6E290D, submixId, outputSubmixId)
	end

	function MumbleSetSubmixForServerId(serverId, submixId)
		Citizen.InvokeNative(0xFE3A3054, serverId, submixId)
	end

	function SetAudioSubmixEffectParamFloat(submixId, effectSlot, paramIndex, paramValue)
		Citizen.InvokeNative(0x9A209B3C, submixId, effectSlot, paramIndex, paramValue)
	end

    function SetAudioSubmixEffectParamInt(submixId, effectSlot, paramIndex, paramValue)
        Citizen.InvokeNative(0x77FAE2B8, submixId, effectSlot, paramIndex, paramValue)
    end

    function SetAudioSubmixEffectRadioFx(submixId, effectSlot)
        Citizen.InvokeNative(0xAAA94D53, submixId, effectSlot)
    end

    function SetAudioSubmixOutputVolumes(submixId, outputSlot, frontLeftVolume, frontRightVolume, rearLeftVolume,
                                            rearRightVolume, channel5Volume, channel6Volume)
        Citizen.InvokeNative(0x825DC0D1, submixId, outputSlot, frontLeftVolume, frontRightVolume, rearLeftVolume,
            rearRightVolume, channel5Volume, channel6Volume)
    end
end

