local Gamestate = require("gamestate")

--Gamestates
local menu = require("states.menu")

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end
