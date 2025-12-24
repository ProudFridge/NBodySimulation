local Utils = {}
Utils.__index = Utils

function Utils.calcVector(pos_x1, pos_y1, pos_x2, pos_y2)
    return pos_x2 - pos_x1, pos_y2 - pos_y1
end

function Utils.calcMagnitude(x_component, y_component)
    return math.sqrt((x_component ^ 2) + (y_component ^ 2))
end

function Utils.calcUnitVector(x_component, y_component)
    local magnitude = Utils.calcMagnitude(x_component, y_component)
    return x_component / magnitude, y_component / magnitude
end

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