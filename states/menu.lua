local Gamestate = require("gamestate")

local menu = {}

function menu:draw()
    love.graphics.print("Press Enter to continue", 10, 10)
end

function menu:keyreleased(key, code)
    if key == "return" then
        local Simulation = require("states.simulation")
        Gamestate.switch(Simulation)
    end
end

return menu