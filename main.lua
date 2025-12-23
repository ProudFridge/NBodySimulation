local Planet = require("planet")

local planet1 = Planet:new(1,1,1, 5500, 12)

function love.load()
    planet1:printInfo()
end

-- Runs every frame
function love.update(dt)
end

-- Draws everything
function love.draw()
    planet1:render()
end