local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")
local Gravity = require("gravity")

local planetList = {}
local timer = Timer.new(0.001)
local debug = false

-- Runs every frame
function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    timer:tick(dt)
    local checks = 0
    --Insert new planet
    if love.keyboard.isDown("w") and timer.isDone == true then
        table.insert(planetList, Planet:new(1,1,1, 100, 1200, nil, love.mouse.getX(), love.mouse.getY()))
        timer:reset()
        planetList[#planetList]:printInfo()
    end


    for i, planet in ipairs(planetList) do
        planet.acceleration_x = 0
        planet.acceleration_y = 0
    end


    for i = 1, #planetList do
        for j = i + 1, #planetList do
            local planet1 = planetList[i]
            local planet2 = planetList[j]
            checks = checks + 1
            local force = Gravity.computeGravitationalForce(planet1, planet2, 6.74)
            Gravity.computeVelocity(planet1, planet2, dt, force)
        end
    end

    for i, planet in ipairs(planetList) do
        Gravity.applyGravity(planet, dt)
    end

    if debug == true then
        print(#planetList)
        print(checks)
    end

end

-- Draws everything
function love.draw()
    if debug == true then
        renderLines(planetList)
    end

    for i,planet in ipairs(planetList) do
        planet:render()
        -- planet:printInfo()
    end 
end


function love.keypressed(key)
    if key == "e" then
        if debug then
            debug = false
        elseif debug == false  then
            debug = true
        end
    end
end

function renderLines(planetList)
    for i = 1, #planetList do
        for j = i + 1, #planetList do
            local planet1 = planetList[i]
            local planet2 = planetList[j]
            local x_component, y_component = Utils.calcVector(planet1.pos_x, planet1.pos_y,planet2.pos_x, planet2.pos_y)
            local distance = Utils.calcMagnitude(x_component, y_component)
            if distance < 800 then
                love.graphics.setColor(100 / distance, 0, 0, 400 / distance)
                love.graphics.setLineWidth(Utils.clamp(1,10,Gravity.computeGravitationalForce(planet1, planet2, 6.74) / 255))
                love.graphics.line(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)
            end
        end
    end
end