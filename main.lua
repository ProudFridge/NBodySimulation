local Planet = require("planet")
local Timer = require("timer")
local Utils = require("utils")
local Gravity = require("gravity")
local Camera = require("camera")

local planetList = {}
local debug = false
local showTrail = true
local simulation = false
local solarSystem = true
local spawnGrid = false

local centerOnPlanet = false
local currentPlanet = 0
local canSpawn = false
local preview = false

local checks = 0
local time = 0

local camera = Camera:new()
local integrators = {"Euler", "Verlet"} --Verlet or Euler
local choice = 1
local delta = 1

-- local constant = 6.6743e-11
local constant = 2.9591220828559e-4 --When using Au, days and solar masses

function love.load()
    --The planets in our solar system
    if solarSystem then
        camera:setScale(1, 1)
        camera:scale(12000)

        --Positions of the solarSystem on 2026-01-01 00:00 UT
        table.insert(planetList, Planet:new({r=255/255,g=255/255,b=0/255}, nil, 1, 100, {x=0,y=0,z=0}, {x=0,y=0,z=0})) --Sun
        table.insert(planetList, Planet:new({r=192/255,g=192/255,b=192/255}, nil, 1.66051140935277e-07, 5.4291, {x=-2.182532148826417E-01, y=-4.147503430219470E-01, z=-1.357376603300347E-02}, {x=1.923954359892052E-02, y=-1.173646867098573E-02, z=-2.723258998211985E-03})) --Mercury
        table.insert(planetList, Planet:new({r=255/255,g=153/255,b=153/255}, nil, 2.44827371182131e-06, 5.2425, {x=8.582590477234082E-02, y=-7.272937889997890E-01, z=-1.491326729034871E-02}, {x=1.994568152897905E-02, y=2.400988121393758E-03, z=-1.117598418900537E-03})) --Venus
        table.insert(planetList, Planet:new({r=51/255,g=255/255,b=51/255}, nil, 3.00329789031573e-06, 1, {x=-1.773625676903416E-01, y=9.622230956380571E-01, z=7.223916497206547E-05}, {x=-1.719732726632393E-02, y=-3.116668998580179E-03, z=1.014395459100633E-07})) -- Earth
        table.insert(planetList, Planet:new({r=224/255,g=224/255,b=224/255}, nil, 3.673E-8, 1, {x=-1.763982742720193E-01, y=9.644251653583968E-01, z=2.844972803225625E-04}, {x=-1.777741715778527E-02, y=-2.873710949519302E-03, z=3.316236639603233E-06})) -- Moon
        table.insert(planetList, Planet:new({r=255/255,g=51/255,b=51/255}, nil, 3.22773848604808e-07, 3.9299, {x=3.375236724053181E-01, y=-1.392531709307832E+00, z=-3.728574375535873E-02}, {x=1.412656035077045E-02, y=4.540493711705869E-03, z=-2.512182043289334E-04})) --Mars
        table.insert(planetList, Planet:new({r=255/255,g=128/255,b=0/255}, nil, 0.000954532562518104, 1.3262, {x=-1.697076130448002E+00, y=4.923347702917086e+00, z=1.755806051536397E-02}, {x=-7.223436992215231E-03, y=-2.101370296453924E-03, z=1.703650119141758E-04})) --Jupiter
        table.insert(planetList, Planet:new({r=255/255,g=204/255,b=153/255}, nil, 0.00028579654259599, 0.6871, {x=9.504273970834813E+00, y=2.522101664364687E-01, z=-3.828040603208088E-01}, {x=-4.561877280517422E-04, y=5.564228180710301E-03, z=-7.827700476854283E-05})) --Saturn
        table.insert(planetList, Planet:new({r=102/255,g=255/255,b=255/255}, nil, 4.3655207025844e-05, 1.2704, {x=9.877240875409560E+00, y=1.679448024414335E+01, z=-6.558791407095442E-02}, {x=-3.419297363931050E-03, y=1.810588631864154E-03, z=5.115493044190684E-05})) --Uranus
        table.insert(planetList, Planet:new({r=102/255,g=178/255,b=255/255}, nil, 5.1499991953912e-05, 1.6379, {x=2.986905306243377E+01, y=5.134087037148546E-01, z=-6.989358350296304E-01}, {x=-7.477087522444120E-05, y=3.156853451464882E-03, z=-6.356496658297069E-05})) --Nepture

        camera:centerOnPosition(planetList[1].positionVec.x, planetList[1].positionVec.y)

        --Sets up initial values to use with verlet integration
        for i = 1, #planetList do
            for j = 1, #planetList do
                if j ~= i then
                    local planet1 = planetList[i]
                    local planet2 = planetList[j]

                    local force = Gravity.computeGravitationalForce(planet1, planet2, constant)
                    Gravity.computeVelocity(planet1, planet2, delta, force)
                end 
            end
        end

        for i = 1, #planetList do
            Gravity.initialVerletSetup(planetList[i], delta)
        end
    end
end

function love.update(dt)
    local integrator = integrators[choice]

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    checks = 0

    --Add a spawning function
    if canSpawn then
        local max = 25
        local angle = 0;
        local distance = 6;
        -- local mass =1.66051140935277e-07
        local mass =5.1499991953912e-05
        for i = 1, max do
            Planet.generatePlanet(planetList, distance, angle, mass, constant)
            distance = distance - distance / max
            angle = angle + 2 * math.pi / max
        end
        -- Planet.generatePlanet(planetList, 1, math.pi / 2, constant)
        canSpawn = not canSpawn
    end

    if simulation then
        time = time + delta
        --Calculate the acceleration and speed of each planet
        if integrator == "Euler" then
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
        elseif integrator == "Verlet" then
            for i = 1, #planetList do
                planetList[i].accelerationVec.x = 0
                planetList[i].accelerationVec.y = 0
                planetList[i].accelerationVec.z = 0
            end
            for i = 1, #planetList do
                for j = 1, #planetList do
                    if j ~= i then
                        local planet1 = planetList[i]
                        local planet2 = planetList[j]
                        local force = Gravity.computeGravitationalForce(planet1, planet2, constant)
                        Gravity.computeAcceleration(planet1, planet2, delta, force)
                        checks = checks + 1
                    end
                end
            end
        end

        for i, planet in ipairs(planetList) do
            if integrator == "Euler" then
                Gravity.advancePosition(planet, delta)
            elseif integrator == "Verlet" then
                Gravity.advanceVerlet(planet, delta)
            end

            planet:insertTrailPoint(100, 0.1)
        end
    end

    --Centers the camera on the specified planet
    if centerOnPlanet then
        local planet = planetList[currentPlanet + 1]
        camera:centerOnPosition(planet.positionVec.x, planet.positionVec.y)
        -- camera:centerOnPosition(planet.positionVec.x, planet.positionVec.y)
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
    love.graphics.print(string.format("%s", integrators[choice]), love.graphics.getWidth() / 2, 0)


    love.graphics.print(string.format("%.0f bodies", #planetList), 0,0)
    love.graphics.print(string.format("%.0f checks", checks), 0, 12)
    love.graphics.print(string.format("%f seconds", time), 0, 24)
    love.graphics.print(string.format("Camera scale: %.3f,%.3f", camera.scaleX, camera.scaleY), 0, 36)
    love.graphics.print(string.format("Camera zoom: %.3f", camera.scaleX), 0, 48)
    love.graphics.print(string.format("Camera x and y: %.3f, %.3f", camera.posX, camera.posY), 0, 60)
    love.graphics.print(string.format("Current Planet: %.0f", currentPlanet), 0, 72)
    love.graphics.print(string.format("delta: %.2f", delta), 0, 84)
    love.graphics.print(string.format("Fps: %.2f", love.timer.getFPS()), 0, 96)
    -- love.graphics.print(string.format("Fps: %.3f", love.timer.getFPS()), 0, 48)

    local endHeight;
    for i,planet in ipairs(planetList) do
        love.graphics.print(string.format("Planet%.0f position: %.3f,%.3f,%.3f  %.8f", i - 1, planet.positionVec.x, planet.positionVec.y, planet.positionVec.z, planet.radius), 0, 96 + i * 12)
        endHeight = 96 + i * 12
    end
    endHeight = endHeight + 12
    for i,planet in ipairs(planetList) do
        love.graphics.print(string.format("Planet%.0f oldPosition: %.3f,%.3f,%.3f  %.8f", i - 1, planet.oldPositionVec.x, planet.oldPositionVec.y, planet.oldPositionVec.z, planet.accelerationVec.x), 0, endHeight + (i) * 12)
    end


    camera:set()

    planetList[1]:render(20)
    --Temporary solution for the sun's huge radius
    for i = 2, #planetList do
        local planet = planetList[i]
        planet:render(500)
    end

    -- for i ,planet in ipairs(planetList) do
    --     planet:render(20)
    -- end
    if debug == true then
        Planet.renderLines(planetList, constant, camera.scaleX)
        print(checks)
    end
    if showTrail == true then
        Planet.renderTrails(planetList, camera.scaleX)
    end

    camera:unset()
end

--Controls
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

    if key == "space" then simulation = not simulation end
    if key == "1" then debug = not debug end
    if key == "t" then showTrail = not showTrail end
    if key == "x" then centerOnPlanet = not centerOnPlanet end
    if key == "i" then choice = (choice % 2) + 1 end

    if key == "up" then delta = delta + 0.1 end
    if key == "down" then delta = delta - 0.1 end
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