local Planet = {}
Planet.__index = Planet

function Planet:new(r, g, b, radius, mass, density, pos_x, pos_y, velocity_x, velocity_y, acceleration_x, acceleration_y)
    local newPlanet = {}
    setmetatable(newPlanet, Planet)

    --Creating the fields for the new object
    -- newPlanet.color = color Will fix later
    newPlanet.r = math.random()
    newPlanet.g = math.random()
    newPlanet.b = math.random()
    newPlanet.mass = mass --kg
    newPlanet.density = density or 5513 --kg per cubic meter
    newPlanet.radius = radius or (3 * (newPlanet.mass / newPlanet.density) / 4 * math.pi) ^ 1/3 --meters

    --To change later
    newPlanet.pos_x = pos_x --love.graphics.getWidth() / 2
    newPlanet.pos_y = pos_y --love.graphics.getHeight() / 2

    newPlanet.velocity_x = velocity_x or 0
    newPlanet.velocity_y = velocity_y or 0

    newPlanet.acceleration_x = acceleration_x or 0
    newPlanet.acceleration_y = acceleration_y or 0


    return newPlanet
end

function Planet:render()
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.setColor(1, 1, 1)
    love.graphics.ellipse("fill", self.pos_x, self.pos_y, self.radius, self.radius, 100)
    -- love.graphics.ellipse("fill", self.pos_x, self.pos_y, 10, 10, 100)
end

function Planet:printInfo()
    print("Color: ", self.r, self.g, self.b, "\nRadius: ", self.radius, "\nMass: ", self.mass, "\nDensity: ", self.density, "\nPositionX: ", self.pos_x, "\nPositionY: ", self.pos_y)
end

return Planet
