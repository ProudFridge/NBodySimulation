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
    newPlanet.density = density or 5513 --kg per cubic meter
    -- newPlanet.radius = radius or ((3 * (newPlanet.mass / newPlanet.density) / 4 * math.pi) ^ 1/3) * 1/10e+19 --meters
    newPlanet.radius = radius or ((3 * (newPlanet.mass / newPlanet.density) / 4 * math.pi) ^ 1/3) * 1 --meters
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
    love.graphics.ellipse("fill", self.positionVec.x, self.positionVec.y, self.radius * scale, self.radius * scale, 100)
end

function Planet.renderLines(planetList, constant, scale)
    for i = 1, #planetList do
        for j = 1, #planetList do
            if j ~= i then
                local planet1, planet2 = planetList[i], planetList[j]

                -- local x_component, y_component = Utils.calcVector(planet1.pos_x, planet1.pos_y,planet2.pos_x, planet2.pos_y)
                -- local distance = Utils.calcMagnitude(x_component, y_component)
                -- local force = Gravity.computeGravitationalForce(planet1, planet2, constant)

                -- if distance < 200000 then
                    -- --Prints the distance between two planet at the midpoint of the line
                    -- love.graphics.setColor(1, 1, 1, 400 / distance)
                    -- love.graphics.print(string.format("%.2fm",distance), x_component / 2 + planet1.pos_x, y_component / 2 + planet1.pos_y, math.atan2(y_component, x_component), scale, nil, 0, 25)
                    -- -- love.graphics.print(string.format("%.10fN",force * 4e+30), x_component / 2 + planet1.pos_x, y_component / 2 + planet1.pos_y , math.atan2(y_component, x_component), scale, nil, 0, 50)
                    -- love.graphics.print(string.format("%.10fN",force), x_component / 2 + planet1.pos_x, y_component / 2 + planet1.pos_y , math.atan2(y_component, x_component), scale, nil, 0, 50)

                    --Draws the line between each planet
                    -- love.graphics.setColor(100 / distance, 0, 0, 1 - 3 / distance)

                    love.graphics.setColor(planet1.color.r, planet1.color.g, planet1.color.b)
                    love.graphics.setLineWidth(1 * scale)
                    love.graphics.line(planet1.positionVec.x, planet1.positionVec.y, planet2.positionVec.x, planet2.positionVec.y)
                -- end
            end
        end
    end
end

function Planet:insertTrailPoint(maxPoints, interval)
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
        --Inserts a new point each frame
        table.insert(self.pointList, self.positionVec.x)
        table.insert(self.pointList, self.positionVec.y)

        --Inserts some points at the end of the table that can be replace by the planet's position each frame
        -- table.insert(self.pointList, self.pos_x)
        -- table.insert(self.pointList, self.pos_y)
    -- else
    --     self.pointList[#self.pointList - 1] = self.pos_x
    --     self.pointList[#self.pointList] = self.pos_y
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

return Planet
