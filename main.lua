local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")

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
    local checks = 0
    --Insert new planet
    if love.keyboard.isDown("w") and timer.isDone == true then
        table.insert(planetList, Planet:new(1,1,1, 100, 1200, nil, love.mouse.getX(), love.mouse.getY()))
        timer:reset()
        planetList[#planetList]:printInfo()
    end

    print(#planetList)

    for i = 1, #planetList do
        for j = i + 1, #planetList do
            local planet1 = planetList[i]
            local planet2 = planetList[j]
            checks = checks + 1
            local force = computeGravity(planet1, planet2, 6.74)
            applyGravity(planet1, planet2, dt, force)
        end
    end
    print(checks)

end

-- Draws everything
function love.draw()
    for i,planet in ipairs(planetList) do
        planet:render()
        -- planet:printInfo()
    end

    renderLines(planetList)

end

function computeGravity(planet1, planet2, gravitational_constant)
    if Utils.calcMagnitude(Utils.calcVector(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)) ~= 0 then
        return gravitational_constant * (planet1.mass * planet2.mass) / (Utils.calcMagnitude(Utils.calcVector(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)) ^ 2)
    else
        return 0
    end
end

--Moves two objects according to the gravitational force that's acting on them
function applyGravity(planet1, planet2, dt, force)
    --Find the direction between planet1 and planet2 then find the unit vector to find the total force
    local x_component, y_component = Utils.calcVector(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)
    local x_force, y_force = Utils.calcUnitVector(x_component, y_component)

    --Finding the acceleration
    local acceleration_x1 = x_force * force / planet1.mass
    local acceleration_y1 = y_force * force / planet1.mass

    local acceleration_x2 = x_force * force / planet2.mass
    local acceleration_y2 = y_force * force / planet2.mass

    --Finding the velocity
    planet1.velocity_x = planet1.velocity_x + acceleration_x1 * dt
    planet1.velocity_y = planet1.velocity_y + acceleration_y1 * dt

    planet2.velocity_x = planet2.velocity_x - acceleration_x2 * dt
    planet2.velocity_y = planet2.velocity_y - acceleration_y2 * dt

    --Finding the new positions
    planet1.pos_x = planet1.pos_x + planet1.velocity_x * dt
    planet1.pos_y = planet1.pos_y + planet1.velocity_y * dt

    planet2.pos_x = planet2.pos_x + planet2.velocity_x * dt
    planet2.pos_y = planet2.pos_y + planet2.velocity_y * dt
end

function renderLines(planetList)
    for i = 1, #planetList do
        for j = i + 1, #planetList do
            local planet1 = planetList[i]
            local planet2 = planetList[j]
            love.graphics.setColor(planet2.r, planet2.g, planet2.b)
            love.graphics.line(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)
        end
    end

end