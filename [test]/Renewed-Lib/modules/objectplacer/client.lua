local placingObj

local requestTimeouts = GetConvarInt('renewed_requesttimeouts', 10000)

-- Object placer --
local OxTxt = {
    '-- Đặt Vật Thể --  \n',
    '[E] Xác nhận đặt  \n',
    '[X] Hủy bỏ  \n',
    '[LĂN CHUỘT LÊN] Xoay vật thể  \n',
    '[LĂN CHUỘT XUỐNG] Xoay vật thể  \n',
    '[MŨI TÊN LÊN] Tăng độ cao  \n',
    '[MŨI TÊN XUỐNG] Giảm độ cao'
}

local function finishPlacing()
    lib.hideTextUI()
    DeleteObject(placingObj)
    placingObj = nil
end


---Sets the player up to place objects in the world using basic keybinds
---@param object string | number
---@param dist number?
---@param snapGround boolean?
---@param text table | string?
---@param allowedMats table?
---@param offset vector3?
---@return vector3?, number?
exports('placeObject', function(object, dist, snapGround, text, allowedMats, offset)
    if placingObj then return end

    if not object then
        lib.print.error("You didnt define any object to place")
    end

    local obj = type(object) == 'string' and joaat(object) or object
    local heading = 0.0
    local checkDist = dist or 10.0

    local txt = text or OxTxt
    local currentZ = 0.0

    lib.requestModel(obj, requestTimeouts)

    placingObj = CreateObject(obj, 1.0, 1.0, 1.0, false, true, true)
    SetModelAsNoLongerNeeded(obj)
    SetEntityAlpha(placingObj, 150)
    SetEntityCollision(placingObj, false, false)
    SetEntityInvincible(placingObj, true)
    FreezeEntityPosition(placingObj, true)

    lib.showTextUI(type(txt) == 'table' and table.concat(txt) or txt, {
        position = "left-center",
    })

    local outLine = false

    while placingObj do
        local hit, _, coords, _, materialHash = lib.raycast.cam(1, 4)
        if hit then
            if offset then
                coords += offset
            end

            SetEntityCoords(placingObj, coords.x, coords.y, coords.z)
            local distCheck = #(GetEntityCoords(cache.ped) - coords)
            SetEntityHeading(placingObj, heading)

            if snapGround then
                PlaceObjectOnGroundProperly(placingObj)
            end

            if currentZ ~= 0.0 then
                local currentPos = GetEntityCoords(placingObj)
                SetEntityCoords(placingObj, currentPos.x, currentPos.y, currentPos.z + currentZ)
            end

            if outLine then
                outLine = false
                SetEntityDrawOutline(placingObj, false)
            end

            if (allowedMats and not allowedMats[materialHash]) or distCheck >= checkDist then
                if not outLine then
                outLine = true
                SetEntityDrawOutline(placingObj, true)
                end
            end

            if IsControlJustReleased(0, 38) then
                if not outLine and (not allowedMats or allowedMats[materialHash]) and distCheck < checkDist then
                    finishPlacing()

---@diagnostic disable-next-line: redundant-return-value
                    return coords + vec3(0, 0, currentZ), heading
                end
            end

            if IsControlJustReleased(0, 73) then
                finishPlacing()

---@diagnostic disable-next-line: redundant-return-value
                return nil, nil
            end

            if IsControlJustReleased(0, 14) then
                heading = heading + 5
                if heading > 360 then heading = 0.0 end
            end

            if IsControlJustReleased(0, 15) then
                heading = heading - 5
                if heading < 0 then
                    heading = 360.0
                end
            end

            if IsControlPressed(0, 172) then
                currentZ = currentZ + 0.01
            end

            if IsControlPressed(0, 173) then
                currentZ = currentZ - 0.01
            end
        end
    end
end)


exports('stopPlacing', function()
    if placingObj then
        finishPlacing()
    end
end)
