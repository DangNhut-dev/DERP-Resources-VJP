Filters = {
    Data = {
        filter = "none",
        strength = 1.0
    },
    Await = false
}

-- Show filter with fade-in effect
function Filters.Show(filterName, strength, fadeTime)
    if filterName == "none" then
        return Filters.Disable()
    end

    local startTime = GetGameTimer()
    local currentTime = startTime
    local duration = fadeTime or 300
    local endTime = startTime + duration

    SetTimecycleModifier(filterName)
    SetTimecycleModifierStrength(0.0)

    local progress = (currentTime - startTime) / duration

    while strength > progress do
        progress = (currentTime - startTime) / duration
        if strength < progress then
            progress = strength
        end

        SetTimecycleModifierStrength(progress)
        currentTime = GetGameTimer()
        Wait(0)
    end

    Filters.Data = {
        filter = filterName,
        strength = strength
    }
end

-- Initialize filter with fade-in
function Filters.Init(fadeTime)
    if Filters.Data.filter == "none" then
        return
    end

    local startTime = GetGameTimer()
    local currentTime = startTime
    local duration = fadeTime or 300
    local endTime = startTime + duration

    SetTimecycleModifier(Filters.Data.filter)
    SetTimecycleModifierStrength(0.0)

    local progress = (currentTime - startTime) / duration

    Citizen.CreateThread(function()
        while progress < Filters.Data.strength do
            progress = (currentTime - startTime) / duration

            if progress > Filters.Data.strength then
                progress = Filters.Data.strength
            end

            SetTimecycleModifierStrength(progress)
            currentTime = GetGameTimer()
            Wait(0)
        end
    end)
end

-- Debug command: Fix filters
RegisterCommand("fix_filters", function()
    Filters.Disable(1)
end)

-- Disable filter with fade-out effect
function Filters.Disable(fadeTime)
    if Filters.Data.filter == "none" then
        return ClearTimecycleModifier()
    end

    local currentStrength = Filters.Data.strength or 1.0
    local startTime = GetGameTimer()
    local currentTime = startTime
    local duration = fadeTime or 300
    local endTime = startTime + duration

    local progress = 1 - ((currentTime - startTime) / duration)

    while progress > 0 do
        progress = 1 - ((currentTime - startTime) / duration)

        if progress < 0 then
            progress = 0
        end

        SetTimecycleModifierStrength(currentStrength * progress)
        currentTime = GetGameTimer()
        Wait(0)
    end

    ClearTimecycleModifier()
end

-- Reset filter to default
function Filters.Reset()
    local startTime = GetGameTimer()
    local currentTime = startTime
    local duration = time or 300
    local endTime = startTime + duration

    local progress = 1 - ((currentTime - startTime) / duration)

    while progress > 0 do
        progress = 1 - ((currentTime - startTime) / duration)

        if progress < 0 then
            progress = 0
        end

        SetTimecycleModifierStrength(Filters.Data.strength * progress)
        currentTime = GetGameTimer()
        Wait(0)
    end

    ClearTimecycleModifier()
end
