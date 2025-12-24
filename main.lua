local Planet = require("planet")
local Timer = require("timer")

local planetList = {}
local timer = Timer.new(0.1)

function love.load()
end

-- Runs every frame
function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    timer:tick(dt)

    --Insert new planet
    if love.keyboard.isDown("w") and timer.isDone == true then
        table.insert(planetList, Planet:new(1,1,1, 10, 12, nil, love.mouse.getX(), love.mouse.getY()))

        timer:reset()
        
        planetList[#planetList]:printInfo()
    end
end

-- Draws everything
function love.draw()
    for i,planet in ipairs(planetList) do
        planet:render()
        -- planet:printInfo()
    end
end