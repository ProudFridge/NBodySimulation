local Gamestate = require("gamestate")
local nuklear = require("nuklear")

local fetch = require("fetch")
local opts = {}
local response

local solarSystemCodes = {10,199,299,401,402,499}
local file, err = io.open("planetDatas.txt", "w")
local link = [[https://ssd.jpl.nasa.gov/api/horizons.api?format=text
&COMMAND='MB'
&OBJ_DATA='NO'
&MAKE_EPHEM='YES'
&EPHEM_TYPE='VECTOR'
&VEC_TABLE='2'
&CENTER='500@399'
&START_TIME='2026-01-01 00:00'
&STOP_TIME='2026-01-01 00:01'
&STEP_SIZE='1%20d'
&CSV_FORMAT='YES']]

fetch(link, opts, function(res)
    print(res.code) -- status number
    print(res.headers) -- table key/value
    print(res.body) -- raw string with the respose
    response = res.body
    file:write(response)
    print(res.adapter) -- how the request was made
    file:close()
end)


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
    fetch.update()

	ui:frameBegin()
	if ui:windowBegin('Simulation Setup', centerX - uiWidth / 2, centerY - uiHeight / 2, uiWidth, uiHeight, 'border', 'title', 'movable', 'scalable', 'scrollbar', 'minimizable') then

		ui:layoutRow('dynamic', 30, 2)
 
        --TODo -> add info box when hovering over each item
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

return menu