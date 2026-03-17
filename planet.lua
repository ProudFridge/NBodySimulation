local Utils = require("utils")

---@class Planet
---@field color table
---@field radius number
---@field mass number
---@field density number
---@field positionVec table
---@field velocityVec table
---@field oldPositionVec table
---@field accelerationVec table
---@field pointList table
local Planet = {}
Planet.__index = Planet

function Planet:new(color, radius, mass, density, positionVec, velocityVec)
    local newPlanet = {}
    setmetatable(newPlanet, Planet)

    --Creating the fields for the new object
    newPlanet.color = color
    newPlanet.mass = mass --kg
    newPlanet.density = density or 5.513 --kg per cubic meter
    newPlanet.radius = radius or ((3 * (newPlanet.mass / newPlanet.density) / 4 * math.pi) ^ 1/3) --meters
    newPlanet.positionVec = positionVec

    --Deep copy of the positionVec
    newPlanet.oldPositionVec = {x = 0, y = 0, z = 0}
    newPlanet.oldPositionVec.x = newPlanet.positionVec.x --Needed when using verlet integration
    newPlanet.oldPositionVec.y = newPlanet.positionVec.y --Needed when using verlet integration
    newPlanet.oldPositionVec.z = newPlanet.positionVec.z --Needed when using verlet integration

    newPlanet.velocityVec = velocityVec
    newPlanet.accelerationVec = {x = 0, y = 0, z = 0}
    newPlanet.pointList = {newPlanet.positionVec.x, newPlanet.positionVec.y, newPlanet.positionVec.x, newPlanet.positionVec.y}

    return newPlanet
end

function Planet:draw(scale)
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.ellipse("fill", self.positionVec.x * scale, self.positionVec.y * scale, self.radius * scale * 100, self.radius * scale * 100, 100)
end

function Planet:insertTrailPoint(maxPoints, interval, scale)
    -- interval = interval or 0
    --Removes points when they reach a certain threshold
    if #self.pointList > maxPoints then
        table.remove(self.pointList, 1)
        table.remove(self.pointList, 1)
    end
    
    --Calculates the distance between the last inserted point and the current planet's position
    local comX = self.pointList[#self.pointList-1]
    local comY = self.pointList[#self.pointList]

    local distanceX, distanceY = Utils.calcVector(comX, comY, 0, self.positionVec.x, self.positionVec.y, 0)
    local magnitude = Utils.calcMagnitude(distanceX, distanceY, 0)

    if magnitude >= interval then
        table.insert(self.pointList, self.positionVec.x * scale)
        table.insert(self.pointList, self.positionVec.y * scale)
    end
end

function Planet:printInfo()
    print(string.format("Color: %d, %d, %d", self.color.r, self.color.g, self.color.b))
    print(string.format("Radius: %d", self.radius))
    print(string.format("Mass: %d", self.mass))
    print(string.format("Density: %d", self.density))
    print(string.format("Position: %d, %d, %d", self.positionVec.x, self.positionVec.y, self.positionVec.z))
end

---Generates a planet with a Velocity vector such that it has a circular orbit
---@param distance number Distance from the sun
---@param angle number Angle at which to generate the new planet relative to the sun
---@param mass number Mass of the new planet
---@param constant number Gravitational constant
---@param sunPosition table Position vectors of the sun
---@param sunMass number Mass of the sun
---@return table
function Planet.generateCircularOrbitPlanet(distance, angle, mass, constant, sunPosition, sunMass)
    local positionX = distance * math.cos(angle)
    local positionY = distance * math.sin(angle)
    local centerMass
    local offsetX
    local offsetY

    --Temporary fix for whenever a the simualtion is cleared
    if sunPosition == nil or sunMass == nil then
        centerMass = 1
        offsetX = 0
        offsetY = 0
    else
        offsetX = sunPosition.x
        offsetY = sunPosition.y
        centerMass = sunMass
    end

    local velocity = math.sqrt(constant * centerMass / distance)

    --(x, y) -> (-y, x) for perpendicular vectors in 2D
    local velocityX = -velocity * (positionY / distance)
    local velocityY = velocity * (positionX / distance)

    return Planet:new({r=1,g=1,b=1}, nil, mass, 1.6379, {x=positionX + offsetX, y=positionY + offsetY,z=0},{x=velocityX,y=velocityY,z=0})
end

return Planet
