if Config.VersionCheck.Enabled then
    if not Config.DevMode then
        goto continueScript
    end
end
do return end
::continueScript::

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
local resourceName = "17mov_GarbageCollector"
local packageId = 5207678
local asciiArt = [[
 _ _____                         ___           _                        ___      _ _           _
/ |___  | __ ___   _____   __   / _ \__ _ _ __| |__   __ _  __ _  ___  / __\___ | | | ___  ___| |_ ___  _ __
| |  / / '_ ` _ \ / _ \ \ / /  / /_\/ _` | '__| '_ \ / _` |/ _` |/ _ \/ /  / _ \| | |/ _ \/ __| __/ _ \| '__|
| | / /| | | | | | (_) \ V /  / /_\\ (_| | |  | |_) | (_| | (_| |  __/ /__| (_) | | |  __/ (__| || (_) | |
|_|/_/ |_| |_| |_|\___/ \_/___\____/\__,_|_|  |_.__/ \__,_|\__, |\___\____/\___/|_|_|\___|\___|\__\___/|_|
                         |_____|                           |___/
]]

local function checkVersion()
    local p = promise.new()
    PerformHttpRequest("https://17movement.net/api/version-check", function(status, body)
        local data = json.decode(body or "{}")
        local lines = {}

        if Config.VersionCheck.DisplayAsciiArt then
            lines[#lines + 1] = ("^1%s^0"):format(asciiArt)
        end

        if status ~= 200 or not data then
            lines[#lines + 1] = [[
^1Failed to check version. Usually this means that your server is blocked from accessing the internet.
Please check your server's firewall settings or contact your hosting provider.^0]]
            p:resolve(lines)
            return
        end

        if data.upToDate then
            lines[#lines + 1] = ("^2You are using the latest version (%s) of %s.^0"):format(currentVersion, resourceName)
            p:resolve(lines)
            return
        end

        local newVersion = data.version
        local skippedVersions = data.skippedVersions
        local changelog = data.changelog
        local files = data.files

        if not (newVersion and skippedVersions and changelog) or not files then
            lines[#lines + 1] = "^1Failed to retrieve version information. Please try again later.^0"
            p:resolve(lines)
            return
        end

        lines[#lines + 1] = ([[
^3%s has a new version available: %s
^3You are currently using version %s - it's %s versions behind.^0]]):format(resourceName, newVersion, currentVersion, skippedVersions)

        if Config.VersionCheck.DisplayChangelog then
            lines[#lines + 1] = ([[

^5Changelog:^0
- %s]]):format(table.concat(changelog, [[

- ]]))
        end

        if Config.VersionCheck.DisplayFiles then
            lines[#lines + 1] = ([[

^5Files to update:^0
- %s]]):format(table.concat(files, [[

- ]]))
        end

        lines[#lines + 1] = ([[

^5You can download latest version on cfx.re Portal:^0 https://portal.cfx.re/assets/granted-assets]]):format(table.concat(files, [[

- ]]))

        p:resolve(lines)
    end, "POST", json.encode({
        packageId = packageId,
        currentVersion = currentVersion,
    }), {
        ["Content-Type"] = "application/json",
    })

    return Citizen.Await(p)
end

CreateThread(function()
    while true do
        local startingCount = 0
        for i = 0, GetNumResources(), 1 do
            local res = GetResourceByFindIndex(i)
            if res then
                if GetResourceState(res) == "starting" then
                    startingCount = startingCount + 1
                end
            end
        end
        if startingCount == 0 then
            Wait(500)
            print(table.concat(checkVersion(), "\n"))
            break
        end
        Wait(100)
    end
end)
