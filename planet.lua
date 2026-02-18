local Planet = {}
Planet.__index = Planet

local Utils = require("utils")
local Gravity = require("gravity")

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

function Planet:render(scale)
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.ellipse("fill", self.positionVec.x * scale, self.positionVec.y * scale, self.radius * scale, self.radius * scale, 10000)
    -- love.graphics.ellipse("fill", self.positionVec.x, self.positionVec.y, self.radius * scale, self.radius * scale, 1000)
end

--Renders lines between each planet
function Planet.renderLines(planetList, constant, scale)
    for i = 1, #planetList do
        for j = 1, #planetList do
            if j ~= i then
                local planet1, planet2 = planetList[i], planetList[j]

                love.graphics.setColor(planet1.color.r, planet1.color.g, planet1.color.b)
                love.graphics.setLineWidth(1 * scale)
                love.graphics.line(planet1.positionVec.x, planet1.positionVec.y, planet2.positionVec.x, planet2.positionVec.y)
            end
        end
    end
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

function Planet.renderTrails(planetList, scale)
    love.graphics.setLineWidth(1 * scale)
    for i,planet in ipairs(planetList) do
        love.graphics.setColor(planet.color.r, planet.color.g, planet.color.b)
        love.graphics.line(planet.pointList)
    end
end

function Planet.clearAllPlanets(planetList)
    for i = 1, #planetList do
        planetList[i] = nil
    end
end

function Planet:printInfo()
    print(string.format("Color: %d, %d, %d", self.color.r, self.color.g, self.color.b))
    print(string.format("Radius: %d", self.radius))
    print(string.format("Mass: %d", self.mass))
    print(string.format("Density: %d", self.density))
    print(string.format("Position: %d, %d, %d", self.positionVec.x, self.positionVec.y, self.positionVec.z))
end

--Extend to 3D later
function Planet.generateCircularOrbitPlanet(planetList, distance, theta, mass, constant)
    local positionX = distance * math.cos(theta)
    local positionY = distance * math.sin(theta)

    --Temporary fix to whenever a the simualtion is cleared
    if planetList[1] == nil then
        centerMass = 1
        offsetX = 0
        offsetY = 0
    else
        offsetX = planetList[1].positionVec.x
        offsetY = planetList[1].positionVec.y
        centerMass = planetList[1].mass
    end

    local velocity = math.sqrt(constant * centerMass / distance)

    --(x, y) -> (-y, x) for perpendicular vectors in 2D
    local velocityX = -velocity * (positionY / distance)
    local velocityY = velocity * (positionX / distance)

    table.insert(planetList, Planet:new({r=1,g=1,b=1}, nil, mass, 1.6379, {x=positionX + offsetX, y=positionY + offsetY,z=0},{x=velocityX,y=velocityY,z=0}))
end

function Planet.generatePlanets(minimum, maximum, mass, numberOfPlanets, planetList, constant)
    local angle = 0;
    local distance
    
    for i = 1, numberOfPlanets do
        distance = minimum + (maximum - minimum) * love.math.random()

        Planet.generateCircularOrbitPlanet(planetList, distance, angle, mass, constant)
        angle = angle + 2 * math.pi / numberOfPlanets

        -- distance = distance - distance / max
        -- distance = math.sin(6 * angle) + 2
        -- distance = angle + 6 * 6
        -- distance = 1 * math.sin(2 * (angle * 5)) + 6
    end
end

return Planet
