local gravity = require("gravity")
local planet = require("planet")

---@class PlanetarySystem
---@field planets Planet
local PlanetarySystem = {}

PlanetarySystem.__index = PlanetarySystem

function PlanetarySystem:new()
    local newPlanetarySystem = {}
    setmetatable(newPlanetarySystem, PlanetarySystem)

    newPlanetarySystem.planets = {}

    return newPlanetarySystem
end

---Draws all the planets in the system
---@param renderTrail boolean Whether or not the planet's trails should be rendered
---@param camera Camera Camera object
function PlanetarySystem:draw(renderTrail, camera)
    for i = 1, #self.planets do
            local planet = self.planets[i]
            planet:draw(camera)
        end
    if renderTrail then
        local convert = function (pointList)
            local newPoints = {}
            for i = 1, #pointList do
                local newVec = camera:rotateAll(pointList[i])
                table.insert(newPoints, newVec.x)
                table.insert(newPoints, newVec.y)
            end
            return newPoints
        end

        -- love.graphics.setLineWidth(camera.scaleX)
        love.graphics.setLineWidth(camera.scaleX)
        love.graphics.setColor({1,1,1,1})
        for i = 1, #self.planets do
            local planet = self.planets[i]
            love.graphics.setColor(planet.color.r, planet.color.g, planet.color.b)
            local newPointList = convert(planet.pointList)

            love.graphics.line(newPointList)
        end
    end
end

---Iterates over the list of planets and advances each planet's position using Euler integration
---@param constant number
---@param delta number
---@param checks number
---@param scale number
function PlanetarySystem:eulerIntegrator(constant, delta, checks)
    for i = 1, #self.planets do
        for j = 1, #self.planets do 
            if j ~= i then
                local planet1 = self.planets[i]
                local planet2 = self.planets[j]
                local force = gravity.computeGravitationalForce(planet1, planet2, constant)
                gravity.computeVelocity(planet1, planet2, delta, force)
                checks = checks + 1
            end
        end
    end

    for i = 1, #self.planets do
        gravity.advancePosition(self.planets[i], delta)
        self.planets[i]:insertTrailPoint(100, 0.1)
    end
end

---The following method must be used at the start of the simulation so that Verlet integration will work
---@param constant number
---@param delta number
function PlanetarySystem:verletIntegratorSetup(constant, delta)
    for i = 1, #self.planets do
        for j = 1, #self.planets do
            if j ~= i then
                local planet1 = self.planets[i]
                local planet2 = self.planets[j]

                local force = gravity.computeGravitationalForce(planet1, planet2, constant)
                gravity.computeVelocity(planet1, planet2, delta, force)
            end 
        end
    end

    for i = 1, #self.planets do
        gravity.initialVerletSetup(self.planets[i], delta)
    end
end

---Iterates over a planetList and advances each planet's position using Verlet integration
---@param constant number
---@param delta number
---@param checks number
---@param scale number
function PlanetarySystem:verletIntegrator(constant, delta, checks)
    for i = 1, #self.planets do
        self.planets[i].accelerationVec.x = 0
        self.planets[i].accelerationVec.y = 0
        self.planets[i].accelerationVec.z = 0
    end

    for i = 1, #self.planets do
        for j = 1, #self.planets do
            if j ~= i then
                local planet1 = self.planets[i]
                local planet2 = self.planets[j]
                local force = gravity.computeGravitationalForce(planet1, planet2, constant)
                gravity.computeAcceleration(planet1, planet2, delta, force)
                checks = checks + 1
            end
        end
    end

    for i = 1, #self.planets do
        gravity.advanceVerlet(self.planets[i], delta)
        self.planets[i]:insertTrailPoint(100, 0.1)
    end
end

---Deletes all planets from the system
function PlanetarySystem:clearAllPlanets()
    for i = 1, #self.planets do
        self.planets[i] = nil
    end
end

---Generates planets that orbit around the sun
---@param minimum number Minimum distance from the sun
---@param maximum number Maximum distance from the sun
---@param mass number Mass of the new planets
---@param numberOfPlanets number Amount of new planets to generate
---@param constant number Gravitational constant
function PlanetarySystem:generatePlanets(minimum, maximum, mass, numberOfPlanets, constant)
    local angle = 0;
    local distance
    
    for i = 1, numberOfPlanets do
        distance = minimum + (maximum - minimum) * love.math.random()
        -- distance = 10 * math.cos( 8 * angle) + 15

        table.insert(self.planets, planet.generateCircularOrbitPlanet(distance, angle, mass, constant, nil, nil))
        angle = angle + 2 * math.pi / numberOfPlanets
    end
end

---Computes the total energy of the planetary system
---@param constant number
---@return integer totalEnergy
function PlanetarySystem:computeTotalEnergy(constant)
    local totalEnergy = 0
    for i = 1, #self.planets do
        for j = 1, #self.planets do
            if i ~= j then
                local planetO = self.planets[i]
                local planetE = self.planets[j]
                local distanceVec = planetO.positionVec:substract(planetE.positionVec)
                local distance = distanceVec:magnitude()

                local kEnergy = 0.5 * planetO.mass * planetO.velocityVec:magnitude() ^ 2
                local gEnergy = -1 * constant * planetO.mass * planetE.mass / distance
                totalEnergy = totalEnergy + kEnergy + gEnergy
            end
        end
    end
    return totalEnergy
end

return PlanetarySystem