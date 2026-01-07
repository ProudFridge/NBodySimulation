local Planet = {}
Planet.__index = Planet

local Utils = require("utils")
local Gravity = require("gravity")

function Planet:new(color, radius, mass, density, pos_x, pos_y, velocity_x, velocity_y, acceleration_x, acceleration_y, pointList)
    local newPlanet = {}
    setmetatable(newPlanet, Planet)

    --Creating the fields for the new object
    newPlanet.color = color
    newPlanet.mass = mass --kg
    newPlanet.density = density or 5513 --kg per cubic meter
    -- newPlanet.radius = radius or ((3 * (newPlanet.mass / newPlanet.density) / 4 * math.pi) ^ 1/3) * 1/10e+19 --meters
    newPlanet.radius = radius or ((3 * (newPlanet.mass / newPlanet.density) / 4 * math.pi) ^ 1/3) * 1 --meters
    newPlanet.pos_x = pos_x
    newPlanet.pos_y = pos_y
    newPlanet.velocity_x = velocity_x or 0
    newPlanet.velocity_y = velocity_y or 0
    newPlanet.acceleration_x = acceleration_x or 0
    newPlanet.acceleration_y = acceleration_y or 0
    newPlanet.pointList = {newPlanet.pos_x, newPlanet.pos_y, newPlanet.pos_x, newPlanet.pos_y}

    return newPlanet
end

function Planet:render(scale)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.ellipse("fill", self.pos_x, self.pos_y, self.radius * scale, self.radius * scale, 100)
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

                    love.graphics.setColor(planet1.color[1],planet1.color[2],planet1.color[3])
                    love.graphics.setLineWidth(1 * scale)
                    love.graphics.line(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)
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

    local distanceX, distanceY = Utils.calcVector(comX, comY, self.pos_x, self.pos_y)
    local magnitude = Utils.calcMagnitude(distanceX, distanceY)

    if magnitude >= interval then
        --Inserts a new point each frame
        table.insert(self.pointList, self.pos_x)
        table.insert(self.pointList, self.pos_y)

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
        love.graphics.setColor(planet.color[1], planet.color[2], planet.color[3])
        love.graphics.line(planet.pointList)
    end
end

function Planet.clearAllPlanets(planetList)
    for i = 1, #planetList do
            planetList[i] = nil
    end
end


function Planet:printInfo()
    print("Color: ", self.r, self.g, self.b, "\nRadius: ", self.radius, "\nMass: ", self.mass, "\nDensity: ", self.density, "\nPositionX: ", self.pos_x, "\nPositionY: ", self.pos_y)
end

return Planet
