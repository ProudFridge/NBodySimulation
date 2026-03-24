local Utils = {}

--TODO make a vector3D class, will probably save lots of time

function Utils.calcVector(pos_x1, pos_y1, pos_z1, pos_x2, pos_y2, pos_z2)
    return pos_x2 - pos_x1, pos_y2 - pos_y1, pos_z2 - pos_z1
end

function Utils.calcVectorV(posVecO, posVecS)
    return {x=posVecS.x-posVecO.x,y=posVecS.y-posVecO.y,z=posVecS.z-posVecO.z}
end

function Utils.calcMagnitude(x_component, y_component, z_component)
    return math.sqrt((x_component ^ 2) + (y_component ^ 2) + (z_component ^2))
end

---Calculates the magnitude of a vector
---@param vec table
---@return number
function Utils.calcMagnitudeV(vec)
    return math.sqrt(vec.x^2 + vec.y^2 + vec.z^2)
end

function Utils.calcUnitVector(x_component, y_component, z_component)
    local magnitude = Utils.calcMagnitude(x_component, y_component, z_component)
    return x_component / magnitude, y_component / magnitude, z_component / magnitude
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