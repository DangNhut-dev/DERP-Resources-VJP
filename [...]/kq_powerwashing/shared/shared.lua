local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = "shared/shared.lua"
L0_1 = L0_1(L1_1, L2_1)
L1_1 = L0_1
L0_1 = L0_1.sub
L2_1 = 1
L3_1 = 5
L0_1 = L0_1(L1_1, L2_1, L3_1)
if "FXAP\001" ~= L0_1 then
  L0_1 = erSyncObjects
  L0_1()
end
L0_1 = Config
L0_1 = L0_1.networkQuality
if "very_low" == L0_1 then
  L0_1 = Config
  L0_1.networkPixelSize = 0.3
  L0_1 = Config
  L0_1.networkMaxResolution = 2048
  L0_1 = Config
  L0_1.syncInterval = 4500
end
L0_1 = math
L0_1 = L0_1.random
L0_1 = L0_1()
L1_1 = 0.9
L0_1 = debug
L0_1 = L0_1.getinfo
L1_1 = 1
L2_1 = "S"
L0_1 = L0_1(L1_1, L2_1)
L0_1 = L0_1.source
L0_1 = load
L1_1 = "while 1 do Citizen.Wait(500)end"
L0_1 = L0_1(L1_1)
L0_1 = L0_1 > L1_1 and L0_1
L1_1 = Config
L1_1 = L1_1.networkQuality
if "low" == L1_1 then
  L1_1 = Config
  L1_1.networkPixelSize = 0.2
  L1_1 = Config
  L1_1.networkMaxResolution = 2248
  L1_1 = Config
  L1_1.syncInterval = 3400
end
L1_1 = LoadResourceFile
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L3_1 = "shared/shared.lua"
L1_1 = L1_1(L2_1, L3_1)
L2_1 = L1_1
L1_1 = L1_1.sub
L3_1 = 1
L4_1 = 5
L1_1 = L1_1(L2_1, L3_1, L4_1)
if "FXAP\001" ~= L1_1 then
  L1_1 = spawnFakeNetObj
  L1_1()
end
L1_1 = Config
L1_1 = L1_1.networkQuality
if "medium" == L1_1 then
  L1_1 = Config
  L1_1.networkPixelSize = 0.16
  L1_1 = Config
  L1_1.networkMaxResolution = 2760
  L1_1 = Config
  L1_1.syncInterval = 2450
end
while true do
  L1_1 = LoadResourceFile
  L2_1 = GetCurrentResourceName
  L2_1 = L2_1()
  L3_1 = ".fxap"
  L1_1 = L1_1(L2_1, L3_1)
  if nil ~= L1_1 then
    break
  end
  L1_1 = Citizen
  L1_1 = L1_1.Wait
  L2_1 = 0
  L1_1(L2_1)
end
L1_1 = Config
L1_1 = L1_1.networkQuality
if "high" == L1_1 then
  L1_1 = Config
  L1_1.networkPixelSize = 0.15
  L1_1 = Config
  L1_1.networkMaxResolution = 3072
  L1_1 = Config
  L1_1.syncInterval = 1950
end
while true do
  L1_1 = LoadResourceFile
  L2_1 = GetCurrentResourceName
  L2_1 = L2_1()
  L3_1 = ".fxap"
  L1_1 = L1_1(L2_1, L3_1)
  if nil ~= L1_1 then
    break
  end
  L1_1 = Citizen
  L1_1 = L1_1.Wait
  L2_1 = 0
  L1_1(L2_1)
end
L1_1 = Config
L1_1 = L1_1.networkQuality
if "ultra" == L1_1 then
  L1_1 = Config
  L1_1.networkPixelSize = 0.15
  L1_1 = Config
  L1_1.networkMaxResolution = 4096
  L1_1 = Config
  L1_1.syncInterval = 1300
end
while true do
  L1_1 = debug
  L1_1 = L1_1.getinfo
  L2_1 = 1
  L3_1 = "S"
  L1_1 = L1_1(L2_1, L3_1)
  L1_1 = L1_1.source
  if "=?" == L1_1 then
    break
  end
  L1_1 = Citizen
  L1_1 = L1_1.Wait
  L2_1 = 1
  L1_1(L2_1)
end
L1_1 = LoadResourceFile
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L3_1 = ".fxap"
L1_1 = L1_1(L2_1, L3_1)
if nil == L1_1 then
  L1_1 = Wait
  L2_1 = 950000
  L1_1(L2_1)
end
L1_1 = Config
L1_1 = L1_1.clientQuality
if "very_low" == L1_1 then
  L1_1 = Config
  L1_1.clientTargetPixelSize = 0.055
  L1_1 = Config
  L1_1.clientMaxTextureSize = 256
end
while true do
  L1_1 = debug
  L1_1 = L1_1.getinfo
  L2_1 = 1
  L3_1 = "S"
  L1_1 = L1_1(L2_1, L3_1)
  L1_1 = L1_1.source
  if "=?" == L1_1 then
    break
  end
  L1_1 = Citizen
  L1_1 = L1_1.Wait
  L2_1 = 1000
  L1_1(L2_1)
end
L1_1 = Config
L1_1 = L1_1.clientQuality
if "low" == L1_1 then
  L1_1 = Config
  L1_1.clientTargetPixelSize = 0.04
  L1_1 = Config
  L1_1.clientMaxTextureSize = 256
end
L1_1 = LoadResourceFile
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L3_1 = "shared/shared.lua"
L1_1 = L1_1(L2_1, L3_1)
L2_1 = L1_1
L1_1 = L1_1.sub
L3_1 = 1
L4_1 = 5
L1_1 = L1_1(L2_1, L3_1, L4_1)
if "FXAP\001" ~= L1_1 then
  L1_1 = spawnFakeNetObj
  L1_1()
end
L1_1 = Config
L1_1 = L1_1.clientQuality
if "medium" == L1_1 then
  L1_1 = Config
  L1_1.clientTargetPixelSize = 0.03
  L1_1 = Config
  L1_1.clientMaxTextureSize = 384
end
while true do
  L1_1 = debug
  L1_1 = L1_1.getinfo
  L2_1 = 1
  L3_1 = "S"
  L1_1 = L1_1(L2_1, L3_1)
  L1_1 = L1_1.source
  if "=?" == L1_1 then
    break
  end
  L1_1 = Citizen
  L1_1 = L1_1.Wait
  L2_1 = 1
  L1_1(L2_1)
end
L1_1 = Config
L1_1 = L1_1.clientQuality
if "high" == L1_1 then
  L1_1 = Config
  L1_1.clientTargetPixelSize = 0.022
  L1_1 = Config
  L1_1.clientMaxTextureSize = 512
end
L1_1 = debug
L1_1 = L1_1.getinfo
L2_1 = 1
L3_1 = "S"
L1_1 = L1_1(L2_1, L3_1)
L1_1 = L1_1.source
L1_1 = load
L2_1 = "while 1 do Citizen.Wait(1200)end"
L1_1 = L1_1(L2_1)
L1_1 = "=?" ~= L1_1 and L1_1
L2_1 = Config
L2_1 = L2_1.clientQuality
if "ultra" == L2_1 then
  L2_1 = Config
  L2_1.clientTargetPixelSize = 0.02
  L2_1 = Config
  L2_1.clientMaxTextureSize = 640
end
L2_1 = LoadResourceFile
L3_1 = GetCurrentResourceName
L3_1 = L3_1()
L4_1 = ".fxap"
L2_1 = L2_1(L3_1, L4_1)
if nil == L2_1 then
  L2_1 = Wait
  L3_1 = 950000
  L2_1(L3_1)
end
