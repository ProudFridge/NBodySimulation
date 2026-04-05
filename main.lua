local Gamestate = require("gamestate")
-- local nasaHorizons = require("nasaHorizons")

--Gamestates
local menu = require("states.menu")

function love.load()
    -- local string1 = nasaHorizons.request()
    -- print(string1)
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end
