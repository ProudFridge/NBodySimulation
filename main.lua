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
local solarSystem = true
local spawnGrid = false

local centerOnPlanet = false
local currentPlanet = 0
local canSpawn = false
local preview = false

local checks = 0
local time = 0

local camera = Camera:new()

-- local constant = 6.6743e-11
local constant = 2.9591220828559e-4 --When using Au, days and solar masses

function love.load()
    --The planets in our solar system
    if solarSystem then
        camera:setScale(1, 1)
        camera:scale(12000)
        local centerX, centerY = camera:toGlobalCoordinate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
        camera:move(-centerX, -centerY)

        table.insert(planetList, Planet:new({255/255,255/255,0/255}, nil, 1, 100, 0, 0, 0, 0)) --Sun
        table.insert(planetList, Planet:new({192/255,192/255,192/255}, nil, 1.66051140935277e-07, 5.4291, 1.202266214811173e-02, 3.129738317339329e-01, -3.374999571504927e-02, -3.223139133573000e-04)) --Mercury
        table.insert(planetList, Planet:new({255/255,153/255,153/255}, nil, 2.44827371182131e-06, 5.2425, 6.036656393784035e-01, -4.041148416177896e-01, 1.125511509001221e-02, 1.664344623604423e-02)) --Venus
        table.insert(planetList, Planet:new({51/255,255/255,51/255}, nil, 3.00329789031573e-06, 5.5134, 1.241238601620544e-02, -1.011219129247450, 1.692619974976791e-02, 1.014868174374918e-04)) --Earth
        -- table.insert(planetList, Planet:new({255/255,51/255,51/255}, nil, 3.22773848604808e-07, 3.9299, -4.926800380968982e-01, 1.537007440322637, -1.278895103122624-02, -3.109871472361932e-03)) --Mars
        table.insert(planetList, Planet:new({255/255,51/255,51/255}, nil, 3.22773848604808e-07, 3.9299, -4.926800380968982e-01, 1.537007440322637, 1.692619974976791e-02, 1.014868174374918e-04)) --Mars
        table.insert(planetList, Planet:new({255/255,128/255,0/255}, nil, 0.000954532562518104, 1.3262, -4.989446787630805, -2.184763688656508, 2.938669025252137e-03, -6.553859846840747e-03)) --Jupiter
        table.insert(planetList, Planet:new({255/255,204/255,153/255}, nil, 0.00028579654259599, 0.6871, 9.681157061545530e-01, -1.000423489517810e+01, 5.246396731312688e-03, -5.546463665223218e-04)) --Saturn
        table.insert(planetList, Planet:new({102/255,255/255,255/255}, nil, 4.3655207025844e-05, 1.2704, 1.806198902787260e+01, 8.416356280190394, 1.689894219169289e-03, 3.381692838015134e-03)) --Uranus
        table.insert(planetList, Planet:new({102/255,178/255,255/255}, nil, 5.1499991953912e-05, 1.6379, 2.850592355224314e+01, -9.173827312094703, 9.407596025584859e-04, 3.006460319698939e-03)) --Nepture
    end
end

function love.update(dt)
    -- dt = 10e-10
    -- delta = 1/60
    local delta = 1
    
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    checks = 0

    --Spawns a grid of planets -> need to fix their position(preferably find a better way to switch between screen and global coordinates)
    if spawnGrid == true then
        local max = 30
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

    --[[
    TODO
    Make this into a function in planet.lua
    ]]
    -- --Insert new planet
    -- if preview then
    --     local newPosX, newPosY = camera:mousePosition()
    --     previewPlanet = Planet:new(color, nil, 1.66051140935277e-07, 3.9299, newPosX, newPosY)
    --     points[1] = newPosX
    --     points[2] = newPosY
    --     points[3] = previewPlanet.pos_x
    --     points[4] = previewPlanet.pos_y
    --     if canSpawn then
    --         canSpawn = false
    --         local newPosX, newPosY = camera:mousePosition()
    --         local newVelocityX, newVelocityY = Utils.calcVector(newPosX, newPosY, previewPlanet.pos_x, previewPlanet.pos_y)
    --         previewPlanet.velocity_x = newVelocityX
    --         previewPlanet.velocity_y = newVelocityY
    --         table.insert(planetList, previewPlanet)
        
    --         planetList[#planetList]:printInfo()
    --     end
    -- end

    if canSpawn then
        local color = {1,1,1}
        canSpawn = false
        local newPosX, newPosY = camera:mousePosition()
        -- table.insert(planetList, Planet:new(color, nil, 5.972 * (10 ^ 24) , 5500000, love.mouse.getX() * (1/scale), love.mouse.getY() * (1/scale)))
        table.insert(planetList, Planet:new(color, nil, 1.66051140935277e-07, 3.9299, newPosX, newPosY))
        
        planetList[#planetList]:printInfo()
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
            planet:insertTrailPoint(1000, 0.1)
        end
    end

    if debug == true then
        print(checks)
    end

    --Centers the camera on the specified planet
    if centerOnPlanet then
        local planet = planetList[currentPlanet + 1]
        camera:centerOnPosition(planet.pos_x, planet.pos_y)
    end
    
    local cameraSpeed = 1000
    if not centerOnPlanet then
        if love.keyboard.isDown("w") then camera:move(0, -cameraSpeed * camera.scaleX * dt) end
        if love.keyboard.isDown("s") then camera:move(0, cameraSpeed * camera.scaleX * dt) end
        if love.keyboard.isDown("d") then camera:move(cameraSpeed * camera.scaleX * dt, 0) end
        if love.keyboard.isDown("a") then camera:move(-cameraSpeed * camera.scaleX * dt, 0) end
    end
end

-- Draws everything
function love.draw()
    love.graphics.setColor(1,1,1 )
    love.graphics.print(string.format("%.0f bodies", #planetList), 0,0)
    love.graphics.print(string.format("%.0f checks", checks), 0, 12)
    love.graphics.print(string.format("%f seconds", time), 0, 24)
    love.graphics.print(string.format("Camera scale: %.3f,%.3f", camera.scaleX, camera.scaleY), 0, 36)
    love.graphics.print(string.format("Camera zoom: %.3f", camera.scaleX), 0, 48)
    love.graphics.print(string.format("Camera x and y: %.3f, %.3f", camera.posX, camera.posY), 0, 60)
    love.graphics.print(string.format("Current Planet: %.0f", currentPlanet), 0, 72)
    -- love.graphics.print(string.format("Fps: %.3f", love.timer.getFPS()), 0, 48)

    for i,planet in ipairs(planetList) do
        love.graphics.print(string.format("Planet%.0f position: %.3f,%.3f,  %.8f", i - 1, planet.pos_x, planet.pos_y, planet.radius), 0, 72 + i * 12)
    end

    camera:set()

    planetList[1]:render(20)
    for i = 2, #planetList do
        local planet = planetList[i]
        planet:render(500)
    end

    -- for i ,planet in ipairs(planetList) do
    --     planet:render(20)
    -- end
    if debug == true then
        Planet.renderLines(planetList, constant, camera.scaleX)
    end
    if showTrail == true then
        Planet.renderTrails(planetList, camera.scaleX)
    end

    camera:unset()
end

function love.keypressed(key)
    if key == "c" then
        Planet.clearAllPlanets(planetList)
    end
    if key == "2" then
        if not spawnGrid then
            spawnGrid = true
        end
    end
    if key == "n" then
        currentPlanet = (currentPlanet + 1) % #planetList
    end

    if key == "up" then camera:zoom(2) end
    if key == "down" then camera:zoom(0.5) end

    if key == "space" then simulation = not simulation end
    if key == "1" then debug = not debug end
    if key == "t" then showTrail = not showTrail end
    if key == "x" then centerOnPlanet = not centerOnPlanet end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        preview = not preview
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        canSpawn = not canSpawn 
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        camera:zoom(2)
    elseif y < 0 then
        camera:zoom(0.5)
    end
end