local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")
local Gravity = require("gravity")
local Camera = require("camera")

local planetList = {}
local timer = Timer.new(1)

local debug = false
local showTrail = true
local simulation = false
local clear = false
local solarSystem = false
local spawnGrid = false

local checks = 0
local time = 0

local color = {1,1,1}

local camera = Camera:new()

-- local constant = 6.6743e-11
local constant = 3

local ratio = 1 -- each Au is  1/10px, or each pixel is equal to 10 Au

function love.load()
    --Initial planets to see if the simulation even works
    if solarSystem then
        camera:setScale(1, 1)
        camera:scale(12000)
        local centerX, centerY = camera:toGlobalCoordinate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
        camera:move(-centerX, -centerY)

        table.insert(planetList, Planet:new({255/255,255/255,0/255}, nil, 1, 100, 0, 0, 0, 0)) --Sun
        table.insert(planetList, Planet:new({192/255,192/255,192/255}, nil, 1.66051140935277e-07, 5.4291, 1.202266214811173e-02, 3.129738317339329e-01, -3.374999571504927e-02, -3.223139133573000e-04)) --Mercury
        table.insert(planetList, Planet:new({255/255,153/255,153/255}, nil, 2.44827371182131e-06, 5.2425, 6.036656393784035e-01, -4.041148416177896e-01, 1.125511509001221e-02, 1.664344623604423e-02)) --Venus
        table.insert(planetList, Planet:new({51/255,255/255,51/255}, nil, 3.00329789031573e-06, 5.5134, 1.241238601620544e-02, -1.011219129247450, 1.692619974976791e-02, 1.014868174374918e-04)) --Earth
        table.insert(planetList, Planet:new({255/255,51/255,51/255}, nil, 3.22773848604808e-07, 3.9299, -4.926800380968982e-01, 1.537007440322637, -1.278895103122624-02, -3.109871472361932e-03)) --Mars
        table.insert(planetList, Planet:new({255/255,128/255,0/255}, nil, 0.000954532562518104, 1.3262, -4.989446787630805, -2.184763688656508, 2.938669025252137e-03, -6.553859846840747e-03)) --Jupiter
        table.insert(planetList, Planet:new({255/255,204/255,153/255}, nil, 0.00028579654259599, 0.6871, 9.681157061545530e-01, -1.000423489517810e+01, 5.246396731312688e-03, -5.546463665223218e-04)) --Saturn
        table.insert(planetList, Planet:new({102/255,255/255,255/255}, nil, 4.3655207025844e-05, 1.2704, 1.806198902787260e+01, 8.416356280190394, 1.689894219169289e-03, 3.381692838015134e-03)) --Uranus
        table.insert(planetList, Planet:new({102/255,178/255,255/255}, nil, 5.1499991953912e-05, 1.6379, 2.850592355224314e+01, -9.173827312094703, 9.407596025584859e-04, 3.006460319698939e-03)) --Nepture
    end
    
end

function love.update(dt)
    -- dt = 10e-10
    -- dt = 1
    local delta = 0.0016
    
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    checks = 0

    --Spawns a grid of planets -> need to fix their position(preferably find a better way to switch between screen and global coordinates)
    if spawnGrid == true then
        local max = 20
        local seperation = 100
        local color = {1,1,1}
        local newPosX = 0
        local newPosY = 0
        for i = 1, max do
            for j = 1, max do
                newPosX = seperation * max * i/max
                newPosY = seperation * max * j/max
                table.insert(planetList, Planet:new(color, nil, 100000, nil, newPosX, newPosY))
            end
        end
        spawnGrid = false
    end

    --Insert new planet
    if love.mouse.isDown(1) then
        local newPosX, newPosY = camera:mousePosition()
        -- table.insert(planetList, Planet:new(color, nil, 5.972 * (10 ^ 24) , 5500000, love.mouse.getX() * (1/scale), love.mouse.getY() * (1/scale)))
        table.insert(planetList, Planet:new(color, nil, 100000, nil, newPosX, newPosY))
        
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
        time = time + delta
        --Calculate the acceleration and speed of each planet
        for i = 1, #planetList do
            for j = 1, #planetList do
                if j ~= i then
                    local planet1 = planetList[i]
                    local planet2 = planetList[j]
                    local force = Gravity.computeGravitationalForce(planet1, planet2, constant)
                    Gravity.computeVelocity(planet1, planet2, delta, force)

                    checks = checks + 1
                end
            end
        end

        for i, planet in ipairs(planetList) do
            Gravity.advancePosition(planet, delta)
            -- planet:insertTrailPoint(1111200)
        end
    end

    if debug == true then
        print(checks)
    end

    if love.keyboard.isDown("w") then
        camera:move(0,-10)
    end
    if love.keyboard.isDown("s") then
        camera:move(0,10)
    end
    if love.keyboard.isDown("d") then
        camera:move(10,0)
    end
    if love.keyboard.isDown("a") then
        camera:move(-10,0)
    end

    --TODO: add the option to center the camear on any planet
    
    -- camera:centerOnPosition(planetList[2].pos_x, planetList[2].pos_y)
    -- local globalX, globalY = camera:toGlobalCoordinate(planetList[2].pos_x, planetList[2].pos_y)
    -- camera:setPosition(globalX, globalY)
end

-- Draws everything
function love.draw()
    love.graphics.setColor(1,1,1 )
    love.graphics.print(string.format("%f bodies", #planetList), 0,0)
    love.graphics.print(string.format("%f checks", checks), 0, 12)
    love.graphics.print(string.format("%f seconds", time), 0, 24)
    love.graphics.print(string.format("Camera scale: %.3f,%.3f", camera.scaleX, camera.scaleY), 0, 36)
    love.graphics.print(string.format("Fps: %.3f", love.timer.getFPS()), 0, 48)

    for i,planet in ipairs(planetList) do
        love.graphics.print(string.format("Planet%.0f position: %.3f,%.3f", i - 1, planet.pos_x, planet.pos_y), 0, 48  + i * 12)
    end

    camera:set()

    for i,planet in ipairs(planetList) do
        planet:render(ratio)
    end
    if debug == true then
        Planet.renderLines(planetList, constant, camera.scaleX)
    end
    if showTrail == true then
        Planet.renderTrails(planetList)
    end

    camera:unset()
end

function love.keypressed(key)
    if key == "1" then
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
    if key == "2" then
        if not spawnGrid then
            spawnGrid = true
        end
    end
    if key == "up" then
        camera:scale(2)
        local centerX, centerY = camera:toGlobalCoordinate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
        camera:move(-centerX, -centerY)
    end
    if key == "down" then
        camera:scale(1/2)
        local centerX, centerY = camera:toGlobalCoordinate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
        camera:move(-centerX, -centerY)
    end
    if key == "t" then
        if showTrail then
            showTrail = false
        elseif showTrail == false then
            showTrail = true
        end
    end
end