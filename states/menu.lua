local Gamestate = require("gamestate")
local nuklear = require("nuklear")

local ui
local menu = {}
local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
local integratorIdx = 1
local integrators = {"Euler", "Verlet"}
local delta = {value = ""}
local iterationTime = {value = ""}
local uiWidth, uiHeight = 340, 260
local logo = love.graphics.newImage("Logo.png")

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
            
        end
		ui:label('Simulation timestep')
        ui:edit('simple', delta)

        ui:layoutRow('dynamic', 30, 2)
		ui:label('Simulation time')
        ui:edit('simple', iterationTime)

        ui:layoutRow('dynamic', 30, 2)
        ui:label("Integrator:")
        integratorIdx = ui:combobox(integratorIdx, integrators)

        ui:layoutRow('dynamic', 30, 1)
        if ui:button('Start') then
            print('Starting simulation!')
            Gamestate.switch(require("states.simulation"), {integrator = integrators[integratorIdx], delta = tonumber(delta.value), iterationTime = tonumber(iterationTime.value) })
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
    if key == "return" then
        local Simulation = require("states.simulation")
        Gamestate.switch(Simulation)
    end

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

-- function menu.wheelmoved(x, y)
-- 	if ui:wheelmoved(x, y) then
-- 		return -- event consumed
-- 	end
-- end

return menu