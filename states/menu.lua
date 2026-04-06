local Gamestate = require("libs.gamestate")
local nuklear = require("nuklear")

local ui
local passedElements = {}
local menu = {}
local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
local integratorIdx = 1
local integrators = {"Euler", "Verlet"}
local uiWidth, uiHeight = 360, 260
local logo = love.graphics.newImage("Logo.png")

local editValues = {
    delta = {value=""},
    iterationTime = {value=""},
    searchedObject = {value=""}
}

function menu:init()
    love.keyboard.setKeyRepeat(true)
    ui = nuklear.newUI()
    love.graphics.setBackgroundColor(100/255, 100/255, 104/255, 0)
end

function menu:update(dt)
	ui:frameBegin()
	if ui:windowBegin('Simulation Setup', centerX - uiWidth / 2, centerY - uiHeight / 2, uiWidth, uiHeight, 'border', 'title', 'movable', 'scalable', 'scrollbar', 'minimizable') then

		ui:layoutRow('dynamic', 30, 2)
 
        if ui:widgetIsHovered() then
            ui:tooltip("The timestep to use when advancing the planets each frame, in days")
        end
		ui:label('Simulation timestep (days)')
        ui:edit('simple', editValues.delta)

        ui:layoutRow('dynamic', 30, 2)
        if ui:widgetIsHovered() then
            ui:tooltip("The simulation time, in days")
        end
		ui:label('Simulation time (days)')
        ui:edit('simple', editValues.iterationTime)

        ui:layoutRow('dynamic', 30, 2)
        if ui:widgetIsHovered() then
            ui:tooltip("The integrator the simulation will use Different integrators have different advantages/disadvantages")
        end
        ui:label("Integrator:")
        integratorIdx = ui:combobox(integratorIdx, integrators)

        --Starting the simulation
        ui:layoutRow('dynamic', 30, 1)
        if ui:button('Start') then
            passedElements.params = {integrator = integrators[integratorIdx], delta = tonumber(editValues.delta.value), iterationTime = tonumber(editValues.iterationTime.value)}

            Gamestate.switch(require("states.simulation"), passedElements)
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