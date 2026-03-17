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
---@param scale number Scale the entire systeems values while keeping the graphics consistent
---@param cameraScale number Scales the trails appropriatly when renderTrail is true
---@param renderTrail boolean Whether or not the planet's trails should be rendered
function PlanetarySystem:draw(scale, cameraScale, renderTrail)
    for i = 1, #self.planets do
            local planet = self.planets[i]
            planet:draw(scale)
        end
    if renderTrail then
        love.graphics.setLineWidth(1 * cameraScale)
        for i = 1, #self.planets do
            local planet = self.planets[i]
            love.graphics.setColor(planet.color.r, planet.color.g, planet.color.b)
            love.graphics.line(planet.pointList)
        end
    end
end

---Iterates over the list of planets and advances each planet's position using Euler integration
---@param constant number
---@param delta number
---@param checks number
---@param scale number
function PlanetarySystem:eulerIntegrator(constant, delta, checks, scale)
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
        self.planets[i]:insertTrailPoint(100, 0.1, scale)
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
function PlanetarySystem:verletIntegrator(constant, delta, checks, scale)
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
        self.planets[i]:insertTrailPoint(100, 0.1, scale)
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

        table.insert(self.planets, planet.generateCircularOrbitPlanet(distance, angle, mass, constant))
        angle = angle + 2 * math.pi / numberOfPlanets
    end
end

return PlanetarySystem