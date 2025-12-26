local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")
local Gravity = require("gravity")

local planetList = {}
local timer = Timer.new(0.5)

local debug = false
local simulation = true
local clear = false

-- local constant = 6.6743e-11
local constant = 4
function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end


    timer:tick(dt)
    local checks = 0
    local color = {1,1,0.2}
    --Insert new planet
    if love.keyboard.isDown("w") and timer.isDone == true then
        -- table.insert(planetList, Planet:new(color, nil, 5.972 * (10 ^ 24) , nil, love.mouse.getX(), love.mouse.getY()))
        table.insert(planetList, Planet:new(color, nil, 120000, nil, love.mouse.getX(), love.mouse.getY()))
        
        timer:reset()
        planetList[#planetList]:printInfo()
    end

    --Deleting all the planets
    if clear then
        for i = 1, #planetList do
            planetList[i] = nil
        end
        clear = false
    end

    if simulation then
        --Reset acceleration of each planet
        for i, planet in ipairs(planetList) do
            planet.acceleration_x = 0
            planet.acceleration_y = 0
        end

        --Calculate the acceleration and speed of each lanet
        for i = 1, #planetList do
            for j = i + 1, #planetList do
                local planet1 = planetList[i]
                local planet2 = planetList[j]
                checks = checks + 1
                local force = Gravity.computeGravitationalForce(planet1, planet2, constant)
                Gravity.computeVelocity(planet1, planet2, dt, force)
            end
        end

        for i, planet in ipairs(planetList) do
            Gravity.applyGravity(planet, dt)
        end
    end

    if debug == true then
        print(#planetList)
        print(checks)
    end
    
end

-- Draws everything
function love.draw()
    if debug == true then
        Planet.renderLines(planetList, constant)
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
    if key == "space" then
        if simulation then
            simulation = false
        elseif simulation == false then
            simulation = true
        end
    end
    if key == "c" then
        if not clear then
            clear = true
        end
    end
end