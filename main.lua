local Gamestate = require("gamestate")

--Gamestates
local menu = require("states.menu")

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.update(dt)
end

-- Draws everything
function love.draw()

end

--Controls
function love.keypressed(key, scancode, isrepeat)
end
