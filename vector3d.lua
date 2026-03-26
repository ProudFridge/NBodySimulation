---@class Vector3D
---@field x number x component
---@field y number y component
---@field z number z component
local Vector3D = {}
Vector3D.__index = Vector3D

---Constructor
---@param x number
---@param y number
---@param z number
---@return Vector3D
function Vector3D:new(x, y, z)
    local newVector3D = {}
    setmetatable(newVector3D, Vector3D)

    newVector3D.x = x
    newVector3D.y = y
    newVector3D.z = z

    return newVector3D
end

---Adds two vectors
---@param Vector Vector3D
---@return Vector3D OutputVector
function Vector3D:add(Vector)
    return Vector3D:new(self.x + Vector.x, self.y + Vector.y, self.z + Vector.z)
end

---Substracts a vector from another vector
---@param Vector Vector3D Destination Vector
---@return Vector3D OutputVector
function Vector3D:substract(Vector)
    return Vector3D:new(Vector.x - self.x, Vector.y - self.y, Vector.z - self.z)
end

---Multiplies a vector by a scalar
---@param scalar number
---@return Vector3D OutputVector
function Vector3D:multiply(scalar)
    return Vector3D:new(self.x * scalar, self.y * scalar, self.z * scalar)
end

---Calculates the magnitude of a vector
---@return number Magnitude
function Vector3D:magnitude()
    return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

---Calcualtes the unit vector of a vector
---@return Vector3D unitVector
function Vector3D:unitVector()
    local magnitude = self:magnitude()
    return Vector3D:new(self.x / magnitude, self.y / magnitude, self.z / magnitude)
end

---Sets the values of a vector
---@param Vector Vector3D Values to be set as
function Vector3D:set(Vector)
    self.x = Vector.x
    self.y = Vector.y
    self.z = Vector.z
end


return Vector3D