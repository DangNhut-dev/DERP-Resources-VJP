-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Initialize Sounds object
Sounds = {}

-- Play a sound file with specified volume
function Sounds.play(self, soundFile, volume)
  if Config.Sounds.enabled then
    SendNUIMessage({
      action = "playSound",
      data = {
        file = soundFile,
        volume = volume
      }
    })
  end
end

-- Play a random sound from a preset collection
function Sounds.preset(self, presetName)
  if not Config.Sounds.enabled then
    return
  end
  
  local preset = Config.Sounds.presets[presetName]
  
  if preset then
    -- Select random sound from preset
    local randomIndex = math.random(1, #preset.sounds)
    local selectedSound = preset.sounds[randomIndex]
    
    -- Play the selected sound
    self:play(selectedSound, preset.volume)
  end
end

-- Network event: Play sound (triggered from server)
RegisterNetEvent("p_policejob/sounds/play", function(soundFile, volume)
  Sounds:play(soundFile, volume)
end)