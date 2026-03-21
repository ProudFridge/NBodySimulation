local planet = require("planet")
local Camera = require("camera")
local planetarySystem = require("planetarySystem")

--Globals
local integrators = {"Euler", "Verlet"} --Verlet or Euler
local choice = 1
local integrator = integrators[choice]
local delta = 1/10
local scale = 1
local constant = 2.9591220828559e-4 --When using Au, days and solar masses
local iterationTime = math.huge --In days
local cameraSpeed = 1000
local checks = 0
local totalTime = 0
local currentPlanet = 0

local realTime = false
local debug = false
local showTrail = true
local simulation = false
local solarSystem = true
local centerOnPlanet = false
local canSpawn = false

local points = {{x = 1, y = 1, z = 1}, {x = 2, y = 3, z = 5}}


--Objects
---@type PlanetarySystem
local system = planetarySystem:new()
local camera = Camera:new(0,0,0)

function love.load()
    camera:setScale(1, 1)
    camera:scale(100)

    --Make a day pass each second
    if realTime then
        delta = 1/60
    end

    --The planets in our solar system
    if solarSystem then
        camera:setScale(1, 1)
        camera:scale(12000)

        --Positions of the solarSystem on 2026-01-01 00:00 UT
        local solarSystem = {
            {{r=255/255,g=255/255,b=0/255}, nil, 1, 1408, {x=0,y=0,z=0}, {x=0,y=0,z=0}}, --Sun
            {{r=192/255,g=192/255,b=192/255}, 1.63e-05, 1.66051140935277e-07, 5.4291, {x=-2.182532148826417E-01, y=-4.147503430219470E-01, z=-1.357376603300347E-02}, {x=1.923954359892052E-02, y=-1.173646867098573E-02, z=-2.723258998211985E-03}}, --Mercury
            {{r=255/255,g=153/255,b=153/255}, 4.05e-05, 2.44827371182131e-06, 5.2425, {x=8.582590477234082E-02, y=-7.272937889997890E-01, z=-1.491326729034871E-02}, {x=1.994568152897905E-02, y=2.400988121393758E-03, z=-1.117598418900537E-03}}, --Venus
            {{r=51/255,g=255/255,b=51/255}, 4.26e-05, 3.00329789031573e-06, 1, {x=-1.773625676903416E-01, y=9.622230956380571E-01, z=7.223916497206547E-05}, {x=-1.719732726632393E-02, y=-3.116668998580179E-03, z=1.014395459100633E-07}}, -- Earth
            {{r=224/255,g=224/255,b=224/255}, 1.16e-05, 3.673e-8, 1, {x=-1.763982742720193E-01, y=9.644251653583968E-01, z=2.844972803225625E-04}, {x=-1.777741715778527E-02, y=-2.873710949519302E-03, z=3.316236639603233E-06}}, -- Moon
            {{r=255/255,g=51/255,b=51/255}, 2.27e-05, 3.22773848604808e-07, 3.9299, {x=3.375236724053181E-01, y=-1.392531709307832E+00, z=-3.728574375535873E-02}, {x=1.412656035077045E-02, y=4.540493711705869E-03, z=-2.512182043289334E-04}},--Mars
            {{r=255/255,g=128/255,b=0/255}, 4.67e-04, 0.000954532562518104, 1.3262, {x=-1.697076130448002E+00, y=4.923347702917086e+00, z=1.755806051536397E-02}, {x=-7.223436992215231E-03, y=-2.101370296453924E-03, z=1.703650119141758E-04}},--Jupiter
            {{r=255/255,g=204/255,b=153/255}, 3.89e-04, 0.00028579654259599, 0.6871, {x=9.504273970834813E+00, y=2.522101664364687E-01, z=-3.828040603208088E-01}, {x=-4.561877280517422E-04, y=5.564228180710301E-03, z=-7.827700476854283E-05}}, --Saturn
            {{r=102/255,g=255/255,b=255/255}, 1.70e-04, 4.3655207025844e-05, 1.2704, {x=9.877240875409560E+00, y=1.679448024414335E+01, z=-6.558791407095442E-02}, {x=-3.419297363931050E-03, y=1.810588631864154E-03, z=5.115493044190684E-05}},--Uranus
            {{r=102/255,g=178/255,b=255/255}, 1.65e-04, 5.1499991953912e-05, 1.6379, {x=2.986905306243377E+01, y=5.134087037148546E-01, z=-6.989358350296304E-01}, {x=-7.477087522444120E-05, y=3.156853451464882E-03, z=-6.356496658297069E-05}} --Nepture
        }

        for i = 1, #solarSystem do
            local newPlanet = solarSystem[i]
            table.insert(system.planets, planet:new(newPlanet[1], newPlanet[2], newPlanet[3], newPlanet[4], newPlanet[5], newPlanet[6]))
        end
        
        camera:centerOnPosition(system.planets[1].positionVec.x * scale, system.planets[1].positionVec.y * scale)

        --Sets up initial values to use with verlet integration
        system:verletIntegratorSetup(constant, delta)
    end
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    camera.rotX = camera.rotX + dt * 0.2

    checks = 0
    -- delta = dt
    -- delta = dt / 86400
   
    -- Spawns planets throughout a certain interval
    if canSpawn then
        local from = 1
        local to = 8
        local max = 500
        local mass = 5.1499991953912e-05

        system:generatePlanets(from, to, mass, max, constant)
        canSpawn = not canSpawn
    end

    if simulation then
        if totalTime < iterationTime then
            totalTime = totalTime + delta

            --Simulates the system
            if integrator == "Euler" then
                system:eulerIntegrator(constant, delta, checks, scale)
            elseif integrator == "Verlet" then
                system:verletIntegrator(constant, delta, checks, scale)
            end
        end
    end

    --Centers the camera on the specified planet
    if centerOnPlanet then
        local planet = system.planets[currentPlanet + 1]
        camera:centerOnPosition(planet.positionVec.x * scale, planet.positionVec.y * scale)
    elseif not centerOnPlanet then
        if love.keyboard.isDown("w") then camera:move(0, -cameraSpeed * camera.scaleX * dt) end
        if love.keyboard.isDown("s") then camera:move(0, cameraSpeed * camera.scaleX * dt) end
        if love.keyboard.isDown("d") then camera:move(cameraSpeed * camera.scaleX * dt, 0) end
        if love.keyboard.isDown("a") then camera:move(-cameraSpeed * camera.scaleX * dt, 0) end
    end
end

-- Draws everything
function love.draw()
    love.graphics.setColor(1,1,1 )
    love.graphics.print(string.format("%s", integrators[choice]), love.graphics.getWidth() / 2, 0)

    love.graphics.print(string.format("%.0f bodies", #system.planets), 0,0)
    love.graphics.print(string.format("%.0f checks", checks), 0, 12)
    love.graphics.print(string.format("%f seconds", totalTime * 86400), 0, 24)
    love.graphics.print(string.format("Camera scale: %.3f,%.3f", camera.scaleX, camera.scaleY), 0, 36)
    love.graphics.print(string.format("Camera zoom: %.3f", camera.scaleX), 0, 48)
    love.graphics.print(string.format("Camera x and y: %.3f, %.3f", camera.posX, camera.posY), 0, 60)
    love.graphics.print(string.format("Current Planet: %.0f", currentPlanet), 0, 72)
    love.graphics.print(string.format("delta: %.8f", delta), 0, 84)
    love.graphics.print(string.format("Fps: %.2f", love.timer.getFPS()), 0, 96)

    for i,planet in ipairs(system.planets) do
        love.graphics.print(string.format("Planet%.0f position: %.3f,%.3f,%.3f  %.15f", i - 1, planet.positionVec.x, planet.positionVec.y, planet.positionVec.z, planet.radius * scale), 0, 96 + i * 12)
    end

    camera:set()

    system:draw(scale, camera.scaleX ,showTrail, camera)

    -- for i = 1, #points do
    --     local newPosition = camera:rotateAll(points[i])
    --     love.graphics.ellipse("fill", newPosition.x, newPosition.y, 0.5, 0.5)
    -- end


    camera:unset()
end

--Controls
function love.keypressed(key, scancode, isrepeat)
    if key == "c" then system:clearAllPlanets() end
    if key == "n" then
        currentPlanet = (currentPlanet + 1) % #system.planets
    end

    if key == "space" then simulation = not simulation end
    if key == "1" then debug = not debug end
    if key == "t" then showTrail = not showTrail end
    if key == "x" then centerOnPlanet = not centerOnPlanet end
    if key == "i" then 
        choice = (choice % 2) + 1 
        integrator = integrators[choice]
    end
    if key == "l" then canSpawn = not canSpawn end

    if key == "up" then delta = delta + 0.1 end
    if key == "down" then delta = delta - 0.1 end
end

function love.wheelmoved(x, y)
    if y > 0 then
        camera:zoom(1.1)
    elseif y < 0 then
        camera:zoom(0.9)
    end
end
