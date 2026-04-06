local Gamestate = require("gamestate")
local NasaHorizons = require("libs.nasaHorizons")
local nuklear = require("nuklear")

local ui
local passedElements = {}
local menu = {}
local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
local integratorIdx = 1
local integrators = {"Euler", "Verlet"}
local uiWidth, uiHeight = 340, 260
local logo = love.graphics.newImage("Logo.png")

local editValues = {
    delta = {value=""},
    iterationTime = {value=""},
    searchedObject = {value=""}
}

--State variables
local active = false

local defaultPlanets = {
    {name="SUN" , value = true},
    {name="MERCURY" , value = true},
    {name="VENUS" , value = true},
    {name="EARTH" , value = true},
    {name="MOON" , value = true},
    {name="MARS" , value = true},
    {name="JUPITER" , value = true},
    {name="SATURN" , value = true},
    {name="URANUS" , value = true},
    {name="NEPTUNE" , value = true}
}

local function toTitleCase(str)
    -- capitalize first letter of each word
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

function menu:init()
    love.keyboard.setKeyRepeat(true)
    ui = nuklear.newUI()
    NasaHorizons.request("Earth", "2026-01-01")
    love.graphics.setBackgroundColor(100/255, 100/255, 104/255, 0)
end

function menu:update(dt)
    NasaHorizons.update()

	ui:frameBegin()
	if ui:windowBegin('Simulation Setup', centerX - uiWidth / 2, centerY - uiHeight / 2, uiWidth, uiHeight, 'border', 'title', 'movable', 'scalable', 'scrollbar', 'minimizable') then

		ui:layoutRow('dynamic', 30, 2)
 
        --TODo -> add info box when hovering over each item
        if ui:widgetIsHovered() then
            ui:tooltip("The timestep to use when advancing the planets each frame")
        end
		ui:label('Simulation timestep')
        ui:edit('simple', editValues.delta)

        ui:layoutRow('dynamic', 30, 2)
        if ui:widgetIsHovered() then
            ui:tooltip("The simulation time")
        end
		ui:label('Simulation time')
        ui:edit('simple', editValues.iterationTime)

        ui:layoutRow('dynamic', 30, 2)
        if ui:widgetIsHovered() then
            ui:tooltip("The integrator the simulation will use Different integrators have different advantages/disadvantages")
        end
        ui:label("Integrator:")
        integratorIdx = ui:combobox(integratorIdx, integrators)

        
        --Choosing which planets to include in the simulation
        local open = ui:treePush('node', "Planets (All are included by default)")
        if open then
            for _, state in ipairs(defaultPlanets) do
                ui:layoutRow('dynamic', 30 ,2)
                ui:label(state.name)
                
                state.value = ui:checkbox("Include", state.value)
            end
            ui:treePop()
        end
        
        --Importing data from NasaHorizons
        ui:layoutRow('dynamic', 30, 1)
        if ui:widgetIsHovered() then
            ui:tooltip("Lets you import the chosen planets' position at any given date from the nasa horizons system")
        end

        active = ui:checkbox('Import from nasa horizons', active)
        if active then
            ui:edit('simple', editValues.searchedObject)
            if ui:button('Add object') then
                print(NasaHorizons.request(toTitleCase(editValues.searchedObject.value), "2026-01-01"))
            end
        end
        
        --Starting the simulation
        ui:layoutRow('dynamic', 30, {0.25, 0.75})
        if ui:button('Start') then
            print('Starting simulation!')
            passedElements.params = {integrator = integrators[integratorIdx], delta = tonumber(editValues.delta.value), iterationTime = tonumber(editValues.iterationTime.value)}
            passedElements.planets = {}
            for i = 1, #defaultPlanets do
                if defaultPlanets[i].value then
                    table.insert(passedElements.planets, defaultPlanets[i].name)
                end
            end
            Gamestate.switch(require("states.simulation") )
        end
    end
	ui:windowEnd()
	ui:frameEnd()
end

function menu:draw()
    love.graphics.draw(logo, centerX - logo:getWidth() / 2, 200)
    ui:draw()
end

function menu:keyreleased(key, code)
    if ui:keyreleased(key, code) then
		return -- event consumed
	end
end

function menu:keypressed(key, scancode, isrepeat)
	if ui:keypressed(key, scancode, isrepeat) then
		return -- event consumed
	end
    if key == "escape" then love.event.quit() end
end

function menu:mousepressed(x, y, button, istouch, presses)
	if ui:mousepressed(x, y, button, istouch, presses) then
		return -- event consumed
	end
end

function menu:mousereleased(x, y, button, istouch, presses)
	if ui:mousereleased(x, y, button, istouch, presses) then
		return -- event consumed
	end
end

function menu:mousemoved(x, y, dx, dy, istouch)
	if ui:mousemoved(x, y, dx, dy, istouch) then
		return -- event consumed
	end
end

function menu:textinput(text)
	if ui:textinput(text) then
		return -- event consumed
	end
end

function menu:wheelmoved(x,y)
	ui:wheelmoved(x, y)
end

return menu