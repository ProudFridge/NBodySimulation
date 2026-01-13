local Gravity = {}
Gravity.__index = Gravity

local Utils = require("utils")

--Computes the gravitational force between two objects
function Gravity.computeGravitationalForce(planet1, planet2, constant)
    local distance = Utils.calcMagnitude(Utils.calcVector(planet1.positionVec.x, planet1.positionVec.y, planet1.positionVec.z, planet2.positionVec.x, planet2.positionVec.y, planet2.positionVec.z))
    if distance == 0 then
        return 0
    else
        return constant * (planet1.mass * planet2.mass) / (distance ^ 2)
    end
end

--Computes the velocity of a given object based off of the force acting on it
function Gravity.computeVelocity(planet1, planet2, dt, force)
    --Find the direction between planet1 and planet2 then find the unit vector to find the total force
    local distanceX, distanceY, distanceZ = Utils.calcVector(planet1.positionVec.x, planet1.positionVec.y, planet1.positionVec.z, planet2.positionVec.x, planet2.positionVec.y, planet2.positionVec.z)
    local directionX, directionY, directionZ = Utils.calcUnitVector(distanceX, distanceY, distanceZ)

    --Finding the acceleration from planet1 to planet2
    local acceleration = force / planet1.mass
    planet1.accelerationVec.x = directionX * acceleration
    planet1.accelerationVec.y = directionY * acceleration
    planet1.accelerationVec.z = directionZ * acceleration

    --Advance the velocities
    planet1.velocityVec.x = planet1.velocityVec.x + planet1.accelerationVec.x * dt
    planet1.velocityVec.y = planet1.velocityVec.y + planet1.accelerationVec.y * dt
    planet1.velocityVec.z = planet1.velocityVec.z + planet1.accelerationVec.z * dt
end

function Gravity.advancePosition(planet, dt)
    --Advance the position
    planet.positionVec.x = planet.positionVec.x + planet.velocityVec.x * dt
    planet.positionVec.y = planet.positionVec.y + planet.velocityVec.y * dt
    planet.positionVec.z = planet.positionVec.z + planet.velocityVec.z * dt
end

return Gravity
