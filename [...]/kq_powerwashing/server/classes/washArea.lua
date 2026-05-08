-- WashArea class: tracks the dirty/clean state of a wash area per contract
WashArea = {}
WashArea.__index = WashArea

function WashArea.new(id, contractId, areaData)
    local self = setmetatable({}, WashArea)
    self.id          = id
    self.contractId  = contractId
    self.areaData    = areaData
    self.pixelData   = {}      -- key = pixelIndex, value = cleanAmount (0.0-1.0)
    self.totalPixels = 0
    self.cleanedPixels = 0
    self.completionPercent = 0.0
    self.dirty       = true
    return self
end

function WashArea:ApplyDelta(delta)
    -- delta = { [pixelIndex] = cleanAmount, ... }
    if not delta then return end
    for pixelIndex, cleanAmount in pairs(delta) do
        local prev = self.pixelData[pixelIndex] or 0.0
        if cleanAmount > prev then
            self.pixelData[pixelIndex] = cleanAmount
        end
    end
    self:RecalcCompletion()
end

function WashArea:RecalcCompletion()
    local total   = 0
    local cleaned = 0
    for _, v in pairs(self.pixelData) do
        total = total + 1
        if v >= 0.95 then
            cleaned = cleaned + 1
        end
    end
    self.totalPixels   = total
    self.cleanedPixels = cleaned
    if total > 0 then
        self.completionPercent = (cleaned / total) * 100.0
    else
        self.completionPercent = 0.0
    end
end

function WashArea:IsComplete()
    return self.completionPercent >= 99.0
end

function WashArea:GetCompletionPercent()
    return self.completionPercent
end

function WashArea:Serialize()
    return {
        id                 = self.id,
        contractId         = self.contractId,
        pixelData          = self.pixelData,
        completionPercent  = self.completionPercent,
        isComplete         = self:IsComplete(),
    }
end
