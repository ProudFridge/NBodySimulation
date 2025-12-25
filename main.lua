local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")
local Gravity = require("gravity")

local planetList = {}
local timer = Timer.new(0.01)

local debug = false
local simulation = true
local clear = false

-- Runs every frame
function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end


    timer:tick(dt)
    local checks = 0

    --Insert new planet
    if love.keyboard.isDown("w") and timer.isDone == true then
        table.insert(planetList, Planet:new(1,1,1, nil, 120000, nil, love.mouse.getX(), love.mouse.getY()))
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
                local force = Gravity.computeGravitationalForce(planet1, planet2, 6.74)
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
    love.graphics.setColor(1,1,1)
    love.graphics.print("hiii", 1, 1, 0, 1, nil, 300, 200)
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

function renderLines(planetList)
    for i = 1, #planetList do
        for j = i + 1, #planetList do
            local planet1 = planetList[i]
            local planet2 = planetList[j]
            local x_component, y_component = Utils.calcVector(planet1.pos_x, planet1.pos_y,planet2.pos_x, planet2.pos_y)
            local distance = Utils.calcMagnitude(x_component, y_component)

            if distance < 800 then
                --Prints the distance between two planet at the midpoint of the line
                love.graphics.setColor(1, 1, 1, 400 / distance)
                love.graphics.printf(distance, x_component / 2 + planet1.pos_x, y_component / 2 + planet1.pos_y, 50, "left", math.atan2(y_component, x_component), 1, nil, 0, 25)

                --Draws the line between each planet
                love.graphics.setColor(100 / distance, 0, 0, 1 - 3 / distance)
                love.graphics.setLineWidth(Utils.clamp(1,10,Gravity.computeGravitationalForce(planet1, planet2, 6.74) / 1000000))
                love.graphics.line(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)
            end
        end
    end
end