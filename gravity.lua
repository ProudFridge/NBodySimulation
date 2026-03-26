local vector3d = require "vector3d"
local Gravity = {}

---Computes the gravitational force between two objects
---@param planet1 Planet
---@param planet2 Planet
---@param constant number
---@return number force
function Gravity.computeGravitationalForce(planet1, planet2, constant)
    local distance = planet1.positionVec:substract(planet2.positionVec):magnitude()
    if distance ~= 0 then
        return constant * (planet1.mass * planet2.mass) / (distance ^ 2)
    else
        return 0
    end
end

---Computes the velocity of a given object based off of the force acting on it
---@param planet1 Planet
---@param planet2 Planet
---@param dt number
---@param force number
function Gravity.computeVelocity(planet1, planet2, dt, force)
    --Find the direction between planet1 and planet2 then find the unit vector to find the total force
    local direction = planet1.positionVec:substract(planet2.positionVec):unitVector()

    --Finding the acceleration from planet1 to planet2
    local acceleration = force / planet1.mass
    planet1.accelerationVec = direction:multiply(acceleration)

    --Advance the velocities using this equaton: velocity = velocity + acceleration * dt
    planet1.velocityVec = planet1.velocityVec:add(planet1.accelerationVec:multiply(dt))
end

---idk
---@param planet1 Planet
---@param planet2 Planet
---@param dt number
---@param force number
function Gravity.computeAcceleration(planet1, planet2, dt ,force)
    --Find the direction between planet1 and planet2 then find the unit vector to find the total force
    local direction = planet1.positionVec:substract(planet2.positionVec):unitVector()

    --Finding the acceleration from planet1 to planet2: accelerationVec = accelerationVec + directionVec * acceleration
    local acceleration = force / planet1.mass
    planet1.accelerationVec = planet1.accelerationVec:add(direction:multiply(acceleration))
end

---Advances the position of a planet using its velocityVec
---@param planet Planet Planet to be advanced
---@param dt number Delta time
function Gravity.advancePosition(planet, dt)
    --Advance the position: position = position + velocity * dt
    planet.oldPositionVec:set(planet.positionVec)
    planet.positionVec = planet.positionVec:add(planet.velocityVec:multiply(dt))
end

---Computes the next position of all planets for one iteration so verlet integration can ve used
---@param planet Planet Planet to be setup
---@param dt number Delta time
function Gravity.initialVerletSetup(planet, dt)
    planet.positionVec = planet.positionVec:add(planet.velocityVec:multiply(dt):add(planet.accelerationVec:multiply(0.5 * dt * dt)))
end

--Advances the planets using verlet integration
---Advances a planet using verlet integration
---@param planet Planet Planet to be advanced
---@param dt number Delta time
function Gravity.advanceVerlet(planet, dt)
    -- local newOldPosition = vector3d:new(planet.positionVec.x , planet.positionVec.y, planet.positionVec.z)
    local newOldPositionX = planet.positionVec.x
    local newOldPositionY = planet.positionVec.y
    local newOldPositionZ = planet.positionVec.z

    -- planet.positionVec = planet.positionVec:multiply(2):substract(planet.oldPositionVec:add(planet.accelerationVec:multiply(dt * dt)))
    planet.positionVec.x = 2 * planet.positionVec.x - planet.oldPositionVec.x + planet.accelerationVec.x * (dt * dt)
    planet.positionVec.y = 2 * planet.positionVec.y - planet.oldPositionVec.y + planet.accelerationVec.y * (dt * dt)
    planet.positionVec.z = 2 * planet.positionVec.z - planet.oldPositionVec.z + planet.accelerationVec.z * (dt * dt)

    -- planet.oldPositionVec = newOldPosition
    planet.oldPositionVec.x = newOldPositionX
    planet.oldPositionVec.y = newOldPositionY
    planet.oldPositionVec.z = newOldPositionZ
end

return Gravity
