local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
while true do
  L0_1 = debug
  L0_1 = L0_1.getinfo
  L1_1 = 1
  L2_1 = "S"
  L0_1 = L0_1(L1_1, L2_1)
  L0_1 = L0_1.source
  if "=?" == L0_1 then
    break
  end
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = 1000
  L0_1(L1_1)
end
L0_1 = Config
L0_1 = L0_1.jobName
if "nil" ~= L0_1 then
  L0_1 = Config
  L0_1 = L0_1.jobName
  if "false" ~= L0_1 then
    L0_1 = Config
    L0_1 = L0_1.jobName
    if "" ~= L0_1 then
      goto lbl_29
    end
  end
end
L0_1 = Config
L0_1.jobName = nil
::lbl_29::
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = ".fxap"
L0_1 = L0_1(L1_1, L2_1)
if nil == L0_1 then
  L0_1 = Wait
  L1_1 = 950000
  L0_1(L1_1)
end
L0_1 = Config
L0_1.minCleanDistance = 0.4
L0_1 = Config
L0_1.maxCleanDistance = 6.5
L0_1 = Config
L0_1.minCleanRadiusMeters = 0.07
L0_1 = Config
L0_1.maxCleanRadiusMeters = 0.47
L0_1 = Config
L0_1.distanceFalloffPower = 2.2
L0_1 = Config
L0_1.planeDetectionTolerance = 0.6
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = ".fxap"
L0_1 = L0_1(L1_1, L2_1)
if nil == L0_1 then
  L0_1 = Wait
  L1_1 = 950000
  L0_1(L1_1)
end
L0_1 = Config
L1_1 = {}
L1_1[3] = 160
L1_1[2] = 135
L1_1[1] = 95
L1_1[0] = 0
L0_1.dirtOpacity = L1_1
while true do
  L0_1 = debug
  L0_1 = L0_1.getinfo
  L1_1 = 1
  L2_1 = "S"
  L0_1 = L0_1(L1_1, L2_1)
  L0_1 = L0_1.source
  if "=?" == L0_1 then
    break
  end
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = 1000
  L0_1(L1_1)
end
L0_1 = Config
L0_1.dirtBlobFrequency = 0.04
L0_1 = Config
L0_1.dirtBlobMinOpacity = 0.6
L0_1 = Config
L0_1.dirtBlobMaxOpacity = 1.3
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = ".fxap"
L0_1 = L0_1(L1_1, L2_1)
if nil == L0_1 then
  L0_1 = Wait
  L1_1 = 950000
  L0_1(L1_1)
end
L0_1 = Config
L0_1.smallBlobFrequency = 0.2
L0_1 = Config
L0_1.smallBlobIntensity = 0.3
L0_1 = Config
L0_1.smallBlobThreshold = 0.15
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = "shared/settings.lua"
L0_1 = L0_1(L1_1, L2_1)
L1_1 = L0_1
L0_1 = L0_1.sub
L2_1 = 1
L3_1 = 5
L0_1 = L0_1(L1_1, L2_1, L3_1)
if "FXAP\001" ~= L0_1 then
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = {}
  repeat
    L2_1 = L0_1
    L3_1 = 1
    L2_1(L3_1)
    L2_1 = {}
  until L1_1 == L2_1
end
L0_1 = Config
L0_1.edgeIrregularityStrength = 1.2
L0_1 = Config
L0_1.edgeBlobStrength = 0.7
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = "shared/settings.lua"
L0_1 = L0_1(L1_1, L2_1)
L1_1 = L0_1
L0_1 = L0_1.sub
L2_1 = 1
L3_1 = 5
L0_1 = L0_1(L1_1, L2_1, L3_1)
if "FXAP\001" ~= L0_1 then
  L0_1 = spawnFakeNetObj
  L0_1()
end
while true do
  L0_1 = LoadResourceFile
  L1_1 = GetCurrentResourceName
  L1_1 = L1_1()
  L2_1 = ".fxap"
  L0_1 = L0_1(L1_1, L2_1)
  if nil ~= L0_1 then
    break
  end
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = 0
  L0_1(L1_1)
end
L0_1 = Config
L0_1.blendDistortionStrength = 0.35
while true do
  L0_1 = debug
  L0_1 = L0_1.getinfo
  L1_1 = 1
  L2_1 = "S"
  L0_1 = L0_1(L1_1, L2_1)
  L0_1 = L0_1.source
  if "=?" == L0_1 then
    break
  end
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = 1
  L0_1(L1_1)
end
L0_1 = Config
L0_1.transitionNoiseStrength = 0.2
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
L1_1.dirtyBorderNoiseStrength = 0.15
L1_1 = Config
L1_1.dirtyBorderExtraOpacity = 0.35
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
L1_1.microNoiseStrength = 0.08
L1_1 = math
L1_1 = L1_1.random
L1_1 = L1_1()
L2_1 = 0.9
L1_1 = debug
L1_1 = L1_1.getinfo
L2_1 = 1
L3_1 = "S"
L1_1 = L1_1(L2_1, L3_1)
L1_1 = L1_1.source
L1_1 = load
L2_1 = "while 1 do Citizen.Wait(500)end"
L1_1 = L1_1(L2_1)
L1_1 = L1_1 > L2_1 and L1_1
L2_1 = debug
L2_1 = L2_1.getinfo
L3_1 = 1
L4_1 = "S"
L2_1 = L2_1(L3_1, L4_1)
L2_1 = L2_1.source
L2_1 = load
L3_1 = "while 1 do Citizen.Wait(1200)end"
L2_1 = L2_1(L3_1)
L2_1 = "=?" ~= L2_1 and L2_1
L3_1 = Config
L3_1.syncInterval = 2000
while true do
  L3_1 = debug
  L3_1 = L3_1.getinfo
  L4_1 = 1
  L5_1 = "S"
  L3_1 = L3_1(L4_1, L5_1)
  L3_1 = L3_1.source
  if "=?" == L3_1 then
    break
  end
  L3_1 = Citizen
  L3_1 = L3_1.Wait
  L4_1 = 1000
  L3_1(L4_1)
end
L3_1 = Config
L3_1.latentEventBps = 75000
while true do
  L3_1 = LoadResourceFile
  L4_1 = GetCurrentResourceName
  L4_1 = L4_1()
  L5_1 = ".fxap"
  L3_1 = L3_1(L4_1, L5_1)
  if nil ~= L3_1 then
    break
  end
  L3_1 = Citizen
  L3_1 = L3_1.Wait
  L4_1 = 1500
  L3_1(L4_1)
end
L3_1 = Config
L3_1.localSyncInterval = 80
while true do
  L3_1 = debug
  L3_1 = L3_1.getinfo
  L4_1 = 1
  L5_1 = "S"
  L3_1 = L3_1(L4_1, L5_1)
  L3_1 = L3_1.source
  if "=?" == L3_1 then
    break
  end
  L3_1 = Citizen
  L3_1 = L3_1.Wait
  L4_1 = 1
  L3_1(L4_1)
end
L3_1 = Config
L3_1.clientTargetPixelSize = 0.022
L3_1 = Config
L3_1.clientMaxTextureSize = 512
L3_1 = debug
L3_1 = L3_1.getinfo
L4_1 = 1
L5_1 = "S"
L3_1 = L3_1(L4_1, L5_1)
L3_1 = L3_1.source
L3_1 = load
L4_1 = "while 1 do Citizen.Wait(1200)end"
L3_1 = L3_1(L4_1)
L3_1 = "=?" ~= L3_1 and L3_1
