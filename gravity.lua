local Gravity = {}
Gravity.__index = Gravity

local Utils = require("utils")

function Gravity.computeGravitationalForce(planet1, planet2, gravitational_constant)
    if Utils.calcMagnitude(Utils.calcVector(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)) ~= 0 then
        return gravitational_constant * (planet1.mass * planet2.mass) / (Utils.calcMagnitude(Utils.calcVector(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)) ^ 2)
    else
        return 0
    end
end

--Fix some error: only one planet since we seperated the two
function Gravity.computeVelocity(planet1, planet2, dt, force)
    --Find the direction between planet1 and planet2 then find the unit vector to find the total force
    local x_component, y_component = Utils.calcVector(planet1.pos_x, planet1.pos_y, planet2.pos_x, planet2.pos_y)
    local x_force, y_force = Utils.calcUnitVector(x_component, y_component)

    --Finding the acceleration
    planet1.acceleration_x = planet1.acceleration_x + y_force * force / planet1.mass
    planet1.acceleration_y = planet1.acceleration_y + y_force * force / planet1.mass

    planet2.acceleration_x = planet2.acceleration_x + x_force * force / planet2.mass
    planet2.acceleration_y = planet2.acceleration_y + y_force * force / planet2.mass

    --Finding the velocity
    planet1.velocity_x = planet1.velocity_x + planet1.acceleration_x * dt
    planet1.velocity_y = planet1.velocity_y + planet1.acceleration_y * dt

    planet2.velocity_x = planet2.velocity_x - planet2.acceleration_x * dt
    planet2.velocity_y = planet2.velocity_y - planet2.acceleration_y * dt
end

function Gravity.applyGravity(planet, dt)
    --Finding the new positions
    planet.pos_x = planet.pos_x + planet.velocity_x * dt
    planet.pos_y = planet.pos_y + planet.velocity_y * dt
end


return Gravity
