local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")
local Gravity = require("gravity")

local planetList = {}
local timer = Timer.new(1)

local debug = false
local simulation = false
local clear = false

local spawnGrid = false

-- local constant = 6.6743e-11
local constant = 3
local scale = 2
local checks = 0
local time = 0

local color = {1,1,1}

function love.load()
    --Initial planets to see if the simulation even works
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2 

    table.insert(planetList, Planet:new(color, nil, 5, 2, centerX, centerY, -0.3, 3))
    table.insert(planetList, Planet:new(color, nil, 10, 2, centerX + 8, centerY + 6, 0, 0))
end

function love.update(dt)
    -- dt = 0.0005
    
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    checks = 0

    --Spawns a grid of planets -> need to fix their position(preferably find a better way to switch between scree nadn global coordinates)
    if spawnGrid == true then
        local max = 20
        local seperation = 100
        local color = {1,1,1}
        local newPosX = 0
        local newPosY = 0
        scale = 1/seperation * max
        for i = 1, max do
            for j = 1, max do
                newPosX = seperation * max * i/max
                newPosY = seperation * max * j/max
                table.insert(planetList, Planet:new(color, nil, 100000, nil, newPosX * 1/scale, newPosY * 1/scale))
            end
        end
        spawnGrid = false
    end

    timer:tick(dt)
    
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
        time = time + dt
        --Calculate the acceleration and speed of each planet
        for i = 1, #planetList do
            for j = 1, #planetList do
                if j ~= i then
                    local planet1 = planetList[i]
                    local planet2 = planetList[j]
                    local force = Gravity.computeGravitationalForce(planet1, planet2, constant)
                    Gravity.computeVelocity(planet1, planet2, dt, force)

                    checks = checks + 1
                end
            end
        end

        for i, planet in ipairs(planetList) do
            Gravity.advancePosition(planet, dt)
            planet:insertTrailPoint(200)
        end
    end

    if debug == true then
        print(checks)
    end
end

-- Draws everything
function love.draw()
    love.graphics.setColor(1,1,1 )
    love.graphics.print(string.format("%f bodies", #planetList), 0,0)
    love.graphics.print(string.format("%f checks", checks), 0, 12)
    love.graphics.print(string.format("%f seconds", time), 0, 24)

    love.graphics.push()
    love.graphics.scale(scale, scale)

    love.graphics.setLineWidth(1)
    Planet.renderTrails(planetList)

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