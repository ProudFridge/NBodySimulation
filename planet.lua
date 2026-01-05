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

function Planet:render(ratio)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.ellipse("fill", self.pos_x * ratio, self.pos_y * ratio, self.radius * ratio, self.radius * ratio, 100)
    -- love.graphics.ellipse("fill", self.pos_x, self.pos_y, self.radius, self.radius, 100)
end

function Planet.renderLines(planetList, constant, scale)
    for i = 1, #planetList do
        for j = i + 1, #planetList do
            local planet1 = planetList[i]
            local planet2 = planetList[j]
            local x_component, y_component = Utils.calcVector(planet1.pos_x, planet1.pos_y,planet2.pos_x, planet2.pos_y)
            local distance = Utils.calcMagnitude(x_component, y_component)
            local force = Gravity.computeGravitationalForce(planet1, planet2, constant)

            if distance < 200 then
                --Prints the distance between two planet at the midpoint of the line
                love.graphics.setColor(1, 1, 1, 400 / distance)
                love.graphics.print(string.format("%.2fm",distance), x_component / 2 + planet1.pos_x, y_component / 2 + planet1.pos_y, math.atan2(y_component, x_component), scale, nil, 0, 25)
                -- love.graphics.print(string.format("%.10fN",force * 4e+30), x_component / 2 + planet1.pos_x, y_component / 2 + planet1.pos_y , math.atan2(y_component, x_component), scale, nil, 0, 50)
                love.graphics.print(string.format("%.10fN",force), x_component / 2 + planet1.pos_x, y_component / 2 + planet1.pos_y , math.atan2(y_component, x_component), scale, nil, 0, 50)

                --Draws the line between each planet
                love.graphics.setColor(100 / distance, 0, 0, 1 - 3 / distance)
                love.graphics.setLineWidth(Utils.clamp(0,0.1,Gravity.computeGravitationalForce(planet1, planet2, constant)))
                -- love.graphics.line(planet1.pos_x * 1/scale, planet1.pos_y * 1/scale, planet2.pos_x * 1/scale, planet2.pos_y * 1/scale)
                love.graphics.line(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)
            end
        end
    end
end

function Planet:insertTrailPoint(maxPoints)
    --Removes points when they reach a certain threshold
    if #self.pointList > maxPoints then
        table.remove(self.pointList, 1)
        table.remove(self.pointList, 1)
    end

    --Inserts a new point each frame
    table.insert(self.pointList, self.pos_x)
    table.insert(self.pointList, self.pos_y)
end

function Planet.renderTrails(planetList)
    love.graphics.setLineWidth(0.001)
    for i,planet in ipairs(planetList) do
        love.graphics.line(planet.pointList)
    end
end

function Planet:printInfo()
    print("Color: ", self.r, self.g, self.b, "\nRadius: ", self.radius, "\nMass: ", self.mass, "\nDensity: ", self.density, "\nPositionX: ", self.pos_x, "\nPositionY: ", self.pos_y)
end

return Planet
