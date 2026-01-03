local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")
local Gravity = require("gravity")


local planetList = {}
local timer = Timer.new(0)

local debug = false
local simulation = true
local clear = false

local spawnGrid = true

-- local constant = 6.6743e-11
local constant = 3
local scale = 1/2

function love.load()
    if spawnGrid == true then
        local max = 10
        local color = {1,1,1}
        local newPosX = 0
        local newPosY = 0
        for i = 1, max do
            for j = 1, max do
                newPosX = 1000 * i/max
                newPosY = 1000 * j/max
                table.insert(planetList, Planet:new(color, nil, 100000, nil, newPosX * 1/scale, newPosY * 1/scale))
            end
        end
    end
end


-- local constant = 4
function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    if spawnGrid == true then
        local max = 10
        local color = {1,1,1}
        local newPosX = 0
        local newPosY = 0
        for i = 1, max do
            for j = 1, max do
                newPosX = 1000 * i/max
                newPosY = 1000 * j/max
                table.insert(planetList, Planet:new(color, nil, 100000, nil, newPosX * 1/scale, newPosY * 1/scale))
            end
        end
        spawnGrid = false
    end




    timer:tick(dt)
    local checks = 0
    local color = {1,1,1}
    --Insert new planet
    if love.keyboard.isDown("w") and timer.isDone == true then
        local newPosX = love.mouse.getX() * (1/scale)
        local newPosY = love.mouse.getY() * (1/scale)
        -- table.insert(planetList, Planet:new(color, nil, 5.972 * (10 ^ 24) , 5500000, love.mouse.getX() * (1/scale), love.mouse.getY() * (1/scale)))
        table.insert(planetList, Planet:new(color, nil, 100000, nil, newPosX, newPosY))
        
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
                local force = Gravity.computeGravitationalForce(planet1, planet2, constant)
                Gravity.computeVelocity(planet1, planet2, dt, force)

                checks = checks + 1
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
    love.graphics.push()
    love.graphics.scale(scale, scale)

    for i,planet in ipairs(planetList) do
        planet:render()
        -- planet:printInfo()
    end
    
    love.graphics.pop()
    if debug == true then
        Planet.renderLines(planetList, constant, scale)
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
    if key == "s" then
        if not spawnGrid then
            spawnGrid = true
        end
    end
    if key == "up" then
        scale = scale + 0.1
    end
    if key == "down" then
        scale = Utils.clamp(0,2,scale - 0.1)
    end
end