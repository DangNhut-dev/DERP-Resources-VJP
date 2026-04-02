-- Preload interior at coordinates
function Algorithms.PreloadInterior(coords)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    
    -- Skip if interior check is disabled
    if not Config.UseInteriorCheck then
        return true
    end
    
    debugPrint("[^2ALGORITHM.PRELOADINTERIOR^7] Preparing interior asset loadup [/]")
    
    -- Use ped coords if no coords provided
    if not coords then
        coords = pedCoords
    end
    
    local interiorAtCoords = GetInteriorAtCoords(coords)
    local interiorFromEntity = GetInteriorFromEntity(ped)
    local interiorLocation = GetInteriorLocationAndNamehash(interiorAtCoords)
    
    -- Check if player is in an interior
    if interiorAtCoords == 0 or interiorAtCoords ~= interiorFromEntity then
        debugPrint("[^2ALGORITHM.PRELOADINTERIOR^7] Player is not in interior, returning.")
        return true
    end
    
    -- Check if interior is already loaded
    if IsInteriorReady(interiorAtCoords) then
        debugPrint("[^2ALGORITHM.PRELOADINTERIOR^7] Interior already loaded, returning.")
        return true
    end
    
    debugPrint("[^2ALGORITHM.PRELOADINTERIOR^7] Awaiting interior load [/]")
    NUI.InfoText(true, Translations.InfoText.preparing_interior)
    
    local startTime = GetGameTimer()
    local currentTime = startTime
    local maxTime = startTime + Config.InteriorCheckerDurationMax
    
    -- Wait for interior to load (with timeout)
    while not IsInteriorReady(interiorAtCoords) and currentTime <= maxTime do
        currentTime = GetGameTimer()
        Wait(100)
    end
    
    debugPrint("[^2ALGORITHM.PRELOADINTERIOR^7] Interior loaded, continue.")
    NUI.InfoText(false)
    
    return true
end
