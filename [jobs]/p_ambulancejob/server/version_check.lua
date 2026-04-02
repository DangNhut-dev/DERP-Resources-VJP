-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Version check configuration
local VERSION_URL = "https://gist.githubusercontent.com/PiotreeQ/63d180c056580b26633342c1ef762e66/raw/f41813b982d75633bec3b5cac780b79f3a46f144/gistfile1.txt"
local CURRENT_VERSION = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

-- Parse a semantic version string (e.g., "1.2.3" or "v1.2.3")
local function parseVersion(versionString)
  if not versionString then
    return nil
  end
  
  -- Remove "v" prefix if present
  versionString = versionString:gsub("^v", "")
  
  -- Extract major, minor, and patch numbers
  local major, minor, patch = versionString:match("(%d+)%.(%d+)%.(%d+)")
  
  if not major then
    return nil
  end
  
  return {
    major = tonumber(major),
    minor = tonumber(minor),
    patch = tonumber(patch),
    original = versionString
  }
end

-- Compare two parsed version objects
-- Returns true if remoteVersion is newer than currentVersion
local function isNewerVersion(currentVersion, remoteVersion)
  if not currentVersion or not remoteVersion then
    return false
  end
  
  -- Compare major version
  if remoteVersion.major > currentVersion.major then
    return true
  elseif remoteVersion.major < currentVersion.major then
    return false
  end
  
  -- Compare minor version
  if remoteVersion.minor > currentVersion.minor then
    return true
  elseif remoteVersion.minor < currentVersion.minor then
    return false
  end
  
  -- Compare patch version
  if remoteVersion.patch > currentVersion.patch then
    return true
  end
  
  return false
end

-- Perform version check
local function checkForUpdates()
  print("^3[Version Check]^7 Checking for updates...")
  print("^3[Version Check]^7 Current version: ^5" .. (CURRENT_VERSION or "Unknown") .. "^7")
  
  PerformHttpRequest(VERSION_URL, function(statusCode, response, headers)
    if statusCode == 200 then
      -- Parse JSON response
      local success, data = pcall(json.decode, response)
      
      if success and data and data.version then
        -- Parse both versions
        local currentVersion = parseVersion(CURRENT_VERSION)
        local remoteVersion = parseVersion(data.version)
        
        if not currentVersion then
          print("^1[Version Check]^7 Error: Could not parse current version")
          return
        end
        
        if not remoteVersion then
          print("^1[Version Check]^7 Error: Could not parse remote version")
          return
        end
        
        -- Check if update is available
        if isNewerVersion(currentVersion, remoteVersion) then
          -- Update available - display detailed information
          print("^2[Version Check]^7 ========================================")
          print("^2[Version Check]^7 🔔 UPDATE AVAILABLE!")
          print("^2[Version Check]^7 Current Version: ^5v" .. currentVersion.original .. "^7")
          print("^2[Version Check]^7 Latest Version:  ^2v" .. remoteVersion.original .. "^7")
          print("^2[Version Check]^7 ========================================")
          
          -- Display changelog if available
          if data.changelog then
            print("^2[Version Check]^7 📋 Changelog:")
            for _, change in ipairs(data.changelog) do
              print("^2[Version Check]^7   • " .. change)
            end
            print("^2[Version Check]^7 ========================================")
          end
          
          -- Display download URL if available
          if data.download_url then
            print("^2[Version Check]^7 📥 Download: ^3" .. data.download_url .. "^7")
          end
          
          -- Display additional notes if available
          if data.notes then
            print("^2[Version Check]^7 📝 " .. data.notes)
          end
          
          print("^2[Version Check]^7 ========================================")
        else
          -- Already up to date
          print("^2[Version Check]^7 ✅ You are running the latest version!")
        end
      else
        print("^1[Version Check]^7 ❌ Error: Invalid JSON response")
      end
      
    elseif statusCode == 404 then
      print("^1[Version Check]^7 ❌ Error: Version file not found (404)")
      print("^1[Version Check]^7 Check your Gist URL!")
    else
      print("^1[Version Check]^7 ❌ Error: HTTP " .. statusCode)
    end
  end, "GET", "", {})
end

-- Run version check after server startup
Citizen.CreateThread(function()
  Citizen.Wait(5000) -- Wait 5 seconds for server to fully initialize
  checkForUpdates()
end)