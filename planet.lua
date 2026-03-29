local Vector3D = require("vector3d")

---@class Planet
---@field name string
---@field color table
---@field radius number
---@field mass number
---@field density number
---@field positionVec Vector3D
---@field velocityVec Vector3D
---@field oldPositionVec Vector3D
---@field accelerationVec Vector3D
---@field pointList table
local Planet = {}
Planet.__index = Planet

---Planet constructor
---@param name string
---@param color table
---@param radius number
---@param mass number
---@param density number
---@param positionVec Vector3D
---@param velocityVec Vector3D
---@return table
function Planet:new(name, color, radius, mass, density, positionVec, velocityVec)
    local newPlanet = {}
    setmetatable(newPlanet, Planet)

    --Creating the fields for the new object
    newPlanet.name = name
    newPlanet.color = color
    newPlanet.mass = mass --kg
    newPlanet.density = density or 5.513 --kg per cubic meter
    newPlanet.radius = radius or ((3 * (newPlanet.mass / newPlanet.density) / 4 * math.pi) ^ 1/3) --meters
    newPlanet.positionVec = positionVec
    newPlanet.oldPositionVec = Vector3D:new(positionVec.x, positionVec.y, positionVec.z)
    newPlanet.velocityVec = velocityVec
    newPlanet.accelerationVec = Vector3D:new(0, 0, 0)
    newPlanet.pointList = {{x=newPlanet.positionVec.x, y=newPlanet.positionVec.y, z=newPlanet.positionVec.z}, {x=newPlanet.positionVec.x, y=newPlanet.positionVec.y, z=newPlanet.positionVec.z}}

    return newPlanet
end

---Draws the camera in 3D
---@param camera Camera
---@param renderNames boolean
function Planet:draw(camera, renderNames)
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    local newVector = camera:rotateAll({x=self.positionVec.x,y=self.positionVec.y,z=self.positionVec.z})
    love.graphics.ellipse("fill", newVector.x, newVector.y, self.radius * 100, self.radius * 100, 100)

    --Print the names of each planets
    if renderNames then
        love.graphics.print(string.format("%s", self.name), newVector.x, newVector.y, 0, camera.scaleX, camera.scaleY)
    end
end

function Planet:insertTrailPoint(maxPoints, interval)
    --Removes points when they reach a certain threshold
    if #self.pointList > maxPoints then
        table.remove(self.pointList, 1)
    end
    
    --Calculates the distance between the last inserted point and the current planet's position
    local lastPosition = self.pointList[#self.pointList]
    local lastPositionVec = Vector3D:new(lastPosition.x, lastPosition.y, lastPosition.z)

    local distanceVec = lastPositionVec:substract(self.positionVec)
    local magnitude = distanceVec:magnitude()

    -- print(magnitude)
    if magnitude >= interval then
        table.insert(self.pointList, {x=self.positionVec.x, y=self.positionVec.y, z=self.positionVec.z})
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

    return Planet:new("CircularOrbit",{r=1,g=1,b=1}, nil, mass, 1.6379, Vector3D:new(positionX + offsetX, positionY + offsetY,0), Vector3D:new(velocityX, velocityY, 0))
end

return Planet
