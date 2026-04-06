local Gamestate = require("gamestate")
local PlanetarySystem = require("planetarySystem")
local Camera = require("camera")
local Vector3D = require("vector3d")
local Planet = require("planet")
local nuklear = require("nuklear")

local simulation = {}

--Globals
local ui
local planetPositionUi
local constant = 2.9591220828559e-4 --When using Au, days and solar masses
local cameraSpeed = 1000
local currentPlanet = 0
local oldMousePositionX
local oldMousePositionY
local mousePositionX = love.mouse.getX()
local mousePositionY = love.mouse.getY()
local tempX = love.mouse.getX()
local tempY = love.mouse.getY()
-- local outputValues

local realTime = false
local showTrail = true
local solarSystem = true
local centerOnPlanet = false
local canSpawn = false
-- local plotGraph = true
-- local fileClosed = false
local render = true
local windowIsHovered1 = false
local windowIsHovered2 = false

--Objects
---@type PlanetarySystem
local system = PlanetarySystem:new("Verlet", constant, 0.1, math.huge)
local camera = Camera:new(0,0,0)


function simulation:enter(prev, config)
    ui = nuklear.newUI()
    planetPositionUi = nuklear.newUI()
    -- if plotGraph then outputValues = io.open("values.csv", "w") end
    system:selectActiveIntegrator(config.params.integrator)
    system.delta = config.params.delta or 0.1
    system.iterationTime = config.iterationTime or math.huge

    camera:setScale(1, 1)
    camera:scale(100)

    love.graphics.setBackgroundColor(0, 0, 0, 0)

    --Make a day pass each second
    if realTime then
        system.delta = 1/60
    end

    if solarSystem then
        camera:setScale(1, 1)
        camera:scale(300)

        --Positions of the solarSystem on 2026-01-01 00:00 UT
        local solarSystem = {
            {"Sun",{r=255/255,g=255/255,b=0/255}, nil, 1, 1408, Vector3D:new(0, 0, 0), Vector3D:new(0, 0, 0)}, --Sun
            {"Mercury",{r=192/255,g=192/255,b=192/255}, 1.63e-05, 1.66051140935277e-07, 5.4291, Vector3D:new(-2.182532148826417E-01, -4.147503430219470E-01, -1.357376603300347E-02), Vector3D:new(1.923954359892052E-02, -1.173646867098573E-02, -2.723258998211985E-03)}, --Mercury
            {"Venus",{r=255/255,g=153/255,b=153/255}, 4.05e-05, 2.44827371182131e-06, 5.2425, Vector3D:new(8.582590477234082E-02, -7.272937889997890E-01, -1.491326729034871E-02), Vector3D:new(1.994568152897905E-02, 2.400988121393758E-03, -1.117598418900537E-03)}, --Venus
            {"Earth",{r=51/255,g=255/255,b=51/255}, 4.26e-05, 3.00329789031573e-06, 1, Vector3D:new(-1.773625676903416E-01, 9.622230956380571E-01, 7.223916497206547E-05), Vector3D:new(-1.719732726632393E-02, -3.116668998580179E-03, 1.014395459100633E-07)}, -- Earth
            {"Moon",{r=224/255,g=224/255,b=224/255}, 1.16e-05, 3.673e-8, 1, Vector3D:new(-1.763982742720193E-01, 9.644251653583968E-01, 2.844972803225625E-04), Vector3D:new(-1.777741715778527E-02, -2.873710949519302E-03, 3.316236639603233E-06)}, -- Moon
            {"Mars",{r=255/255,g=51/255,b=51/255}, 2.27e-05, 3.22773848604808e-07, 3.9299, Vector3D:new(3.375236724053181E-01, -1.392531709307832E+00, -3.728574375535873E-02), Vector3D:new(1.412656035077045E-02, 4.540493711705869E-03, -2.512182043289334E-04)},--Mars
            {"Jupiter",{r=255/255,g=128/255,b=0/255}, 4.67e-04, 0.000954532562518104, 1.3262, Vector3D:new(-1.697076130448002E+00, 4.923347702917086e+00, 1.755806051536397E-02), Vector3D:new(-7.223436992215231E-03, -2.101370296453924E-03, 1.703650119141758E-04)},--Jupiter
            {"Saturn",{r=255/255,g=204/255,b=153/255}, 3.89e-04, 0.00028579654259599, 0.6871, Vector3D:new(9.504273970834813E+00, 2.522101664364687E-01, -3.828040603208088E-01), Vector3D:new(-4.561877280517422E-04, 5.564228180710301E-03, -7.827700476854283E-05)}, --Saturn
            {"Uranus",{r=102/255,g=255/255,b=255/255}, 1.70e-04, 4.3655207025844e-05, 1.2704, Vector3D:new(9.877240875409560E+00, 1.679448024414335E+01, -6.558791407095442E-02), Vector3D:new(-3.419297363931050E-03, 1.810588631864154E-03, 5.115493044190684E-05)},--Uranus
            {"Neptune",{r=102/255,g=178/255,b=255/255}, 1.65e-04, 5.1499991953912e-05, 1.6379, Vector3D:new(2.986905306243377E+01, 5.134087037148546E-01, -6.989358350296304E-01), Vector3D:new(-7.477087522444120E-05, 3.156853451464882E-03, -6.356496658297069E-05)} --Nepture
        }

        for i = 1, #solarSystem do
            local newPlanet = solarSystem[i]
            table.insert(system.planets, Planet:new(newPlanet[1], newPlanet[2], newPlanet[3], newPlanet[4], newPlanet[5], newPlanet[6], newPlanet[7]))
        end
        
        local newCenter = camera:rotateAll(system.planets[1].positionVec)
        camera:centerOnPosition(newCenter.x, newCenter.y)

        --Sets up initial values to use with verlet integration
        system:verletIntegratorSetup()
    end
end

function simulation:update(dt)
    if love.keyboard.isDown("escape") then love.event.quit() end

    system:integrate()

    ---Rotates the system by dragging the mouse
    tempX = mousePositionX
    tempY = mousePositionY

    mousePositionX = love.mouse.getX()
    mousePositionY = love.mouse.getY()

    oldMousePositionX = tempX
    oldMousePositionY = tempY

    -- delta = dt
    -- delta = dt / 86400

    if love.keyboard.isDown("up") then camera.rotX = camera.rotX + dt
    elseif love.keyboard.isDown("down") then camera.rotX = camera.rotX - dt
    end

    if love.keyboard.isDown("left") then camera.rotY = camera.rotY + dt
    elseif love.keyboard.isDown("right") then camera.rotY = camera.rotY - dt
    end

    -- Spawns planets throughout a certain interval
    if canSpawn then
        local from = 0.2
        local to = 4
        local max = 500
        local mass = 5.1499991953912e-05

        system:generatePlanets(from, to, mass, max, constant)
        canSpawn = not canSpawn
    end

    --Centers the camera on the specified planet
    if centerOnPlanet then
        local planet = system.planets[currentPlanet + 1]
        local newCenter = camera:rotateAll(planet.positionVec)
        camera:centerOnPosition(newCenter.x, newCenter.y)
    elseif not centerOnPlanet then
        if love.keyboard.isDown("w") then camera:move(0, -cameraSpeed * camera.scaleX * dt) end
        if love.keyboard.isDown("s") then camera:move(0, cameraSpeed * camera.scaleX * dt) end
        if love.keyboard.isDown("d") then camera:move(cameraSpeed * camera.scaleX * dt, 0) end
        if love.keyboard.isDown("a") then camera:move(-cameraSpeed * camera.scaleX * dt, 0) end
    end

    --Simulation details
    ui:frameBegin()
	if ui:windowBegin('Simulation Details', 5 , 5, 300, 160, 'border', 'title', 'movable', 'scalable', 'scrollbar', 'minimizable') then
		ui:layoutRow('dynamic', 12, 2)
        ui:label('FPS:')
        ui:label(string.format('%.2f', love.timer.getFPS()))
		ui:layoutRow('dynamic', 12, 2)
        ui:label('Active Integrator:')
        ui:label(string.format('%s', system.integrator))
		ui:layoutRow('dynamic', 12, 2)
		ui:label('Number of planets:')
		ui:label(string.format('%.0f', #system.planets))
		ui:layoutRow('dynamic', 12, 2)
		ui:label('Time passed (days):')
		ui:label(string.format('%.2f', system.totalTime))
		ui:layoutRow('dynamic', 12, 2)
        ui:label('Simulation timestep:')
        ui:label(string.format('%.2f', system.delta))
		ui:layoutRow('dynamic', 12, 2)
        ui:label('Current Planet:')
        ui:label(string.format('%.0f', currentPlanet))
		ui:layoutRow('dynamic', 12, 2)
        ui:label('ShowTrail:')
        ui:label(string.format('%s', showTrail))
    end

    windowIsHovered1 = ui:windowIsHovered()
	ui:windowEnd()
	ui:frameEnd()

    planetPositionUi:frameBegin()
	if planetPositionUi:windowBegin('Planet Positions', 5 , 170, 300, 160, 'border', 'title', 'movable', 'scalable', 'scrollbar', 'minimizable') then
        for i = 1, #system.planets do
            local planet = system.planets[i]
            planetPositionUi:layoutRow('dynamic', 12, 2)
            planetPositionUi:label(string.format("%s", planet.name))
            planetPositionUi:label(string.format('%0.3f, %0.3f, %0.3f', planet.positionVec.x, planet.positionVec.y, planet.positionVec.y))
        end
    end

    windowIsHovered2 = planetPositionUi:windowIsHovered()
    planetPositionUi:windowEnd()
    planetPositionUi:frameEnd()

    --Only rotate the view when not dragging the window
    if love.mouse.isDown(1) and not windowIsHovered1 and not windowIsHovered2  then
        local newAngleY =  (mousePositionX - oldMousePositionX) * 1/100
        local newAngleX = (mousePositionY - oldMousePositionY) * 1/100

        camera.rotX = camera.rotX + newAngleX
        camera.rotY = camera.rotY + newAngleY
    end
end

function simulation:draw()
    if render then
        camera:set()
        system:draw(showTrail, camera)
        camera:unset()
    end

    ui:draw()
    planetPositionUi:draw()
end

---Handle user detection for the ui
local function input(name, ...)
	return ui[name](ui, ...) or planetPositionUi[name](planetPositionUi, ...)
end

function simulation:keypressed(key, scancode, isrepeat)
    if key == "c" then system:clearAllPlanets() end
    if key == "space" then system.runSimulation = not system.runSimulation end
    if key == "f" then system.renderNames = not system.renderNames end
    if key == "t" then showTrail = not showTrail end
    if key == "x" then centerOnPlanet = not centerOnPlanet end
    if key == "n" then currentPlanet = (currentPlanet + 1) % #system.planets end
    if key == "l" then canSpawn = not canSpawn end
    if key == "r" then render = not render end

    input('keypressed', key, scancode, isrepeat)
end

function simulation:wheelmoved(z,y)
    if y > 0 then
        camera:zoom(1.1)
    elseif y < 0 then
        camera:zoom(0.9)
    end
end

function simulation:keyreleased(key, code)
    input('keyreleased', key, code)
end

function simulation:mousepressed(x, y, button, istouch, presses)
	input('mousepressed', x, y, button, istouch, presses)
end

function simulation:mousereleased(x, y, button, istouch, presses)
    input('mousereleased', x, y, button, istouch, presses)
end

function simulation:mousemoved(x, y, dx, dy, istouch)
    input('mousemoved', x, y, dx, dy, istouch)
end

function simulation:textinput(text)
    input('textinput', text)
end

return simulation