local Utils = {}

function Utils.clamp(minValue, maxValue, actualValue)
    local clampedValue = actualValue

    if actualValue > maxValue then
        clampedValue = maxValue
    elseif actualValue < minValue then
        clampedValue = minValue
    end

    return clampedValue
end

return Utils