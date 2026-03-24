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
    local distanceVec = planet1.positionVec:substract(planet2.positionVec)
    local direction = distanceVec:unitVector()

    --Finding the acceleration from planet1 to planet2
    local acceleration = force / planet1.mass
    planet1.accelerationVec.x = direction.x * acceleration
    planet1.accelerationVec.y = direction.y * acceleration
    planet1.accelerationVec.z = direction.z * acceleration

    --Advance the velocities
    planet1.velocityVec.x = planet1.velocityVec.x + planet1.accelerationVec.x * dt
    planet1.velocityVec.y = planet1.velocityVec.y + planet1.accelerationVec.y * dt
    planet1.velocityVec.z = planet1.velocityVec.z + planet1.accelerationVec.z * dt
end

---idk
---@param planet1 Planet
---@param planet2 Planet
---@param dt number
---@param force number
function Gravity.computeAcceleration(planet1, planet2, dt ,force)
    --Find the direction between planet1 and planet2 then find the unit vector to find the total force
    local distance = planet1.positionVec:substract(planet2.positionVec)
    local direction = distance:unitVector()

    --Finding the acceleration from planet1 to planet2
    local acceleration = force / planet1.mass
    planet1.accelerationVec.x = planet1.accelerationVec.x + direction.x * acceleration
    planet1.accelerationVec.y = planet1.accelerationVec.y + direction.y * acceleration
    planet1.accelerationVec.z = planet1.accelerationVec.z + direction.z * acceleration
end

function Gravity.advancePosition(planet, dt)
    --Advance the position
    planet.oldPositionVec.x = planet.positionVec.x
    planet.oldPositionVec.y = planet.positionVec.y
    planet.oldPositionVec.z = planet.positionVec.z

    planet.positionVec.x = planet.positionVec.x + planet.velocityVec.x * dt
    planet.positionVec.y = planet.positionVec.y + planet.velocityVec.y * dt
    planet.positionVec.z = planet.positionVec.z + planet.velocityVec.z * dt
end

--Computes the next position of all planets for one tick so verlet can ve used
function Gravity.initialVerletSetup(planet, dt)
    planet.positionVec.x = planet.positionVec.x + planet.velocityVec.x * dt + 0.5 * planet.accelerationVec.x * (dt * dt)
    planet.positionVec.y = planet.positionVec.y + planet.velocityVec.y * dt + 0.5 * planet.accelerationVec.y * (dt * dt)
    planet.positionVec.z = planet.positionVec.z + planet.velocityVec.z * dt + 0.5 * planet.accelerationVec.z * (dt * dt)
end

--Advances the planets using verlet integration
function Gravity.advanceVerlet(planet, dt)
    local newOldPositionX = planet.positionVec.x
    local newOldPositionY = planet.positionVec.y
    local newOldPositionZ = planet.positionVec.z

    planet.positionVec.x = 2 * planet.positionVec.x - planet.oldPositionVec.x + planet.accelerationVec.x * (dt * dt)
    planet.positionVec.y = 2 * planet.positionVec.y - planet.oldPositionVec.y + planet.accelerationVec.y * (dt * dt)
    planet.positionVec.z = 2 * planet.positionVec.z - planet.oldPositionVec.z + planet.accelerationVec.z * (dt * dt)

    planet.oldPositionVec.x = newOldPositionX
    planet.oldPositionVec.y = newOldPositionY
    planet.oldPositionVec.z = newOldPositionZ
end

return Gravity
