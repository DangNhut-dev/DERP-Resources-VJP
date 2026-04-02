-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



local test

function test()
  local globalState = GlobalState["p_dmvschool/Schools"]
  if globalState then
    globalState = globalState[k]
    if globalState then
      globalState = globalState.theoryQuestions
    end
  end
end

-- TV/Terminal management system for hospitals
TV = {
  tvs = {}
}

-- Initialize global state
GlobalState["p_ambulancejob/TV"] = TV.tvs

-- Event: Set terminal/TV display data
RegisterNetEvent("p_ambulancejob/server/tv/setTerminal", function(data)
  -- Validate input data
  if not data or type(data) ~= "table" or not data.hospital or not data.tv then
    return
  end
  
  local sourcePlayer = source
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Initialize hospital TV data if not exists
  if not TV.tvs[data.hospital] then
    TV.tvs[data.hospital] = {}
  end
  
  -- Clear or set TV data
  if data.clear then
    -- Remove TV entry
    TV.tvs[data.hospital][data.tv] = nil
  else
    -- Set TV data
    TV.tvs[data.hospital][data.tv] = data
  end
  
  -- Update global state to sync to all clients
  GlobalState["p_ambulancejob/TV"] = TV.tvs
end)