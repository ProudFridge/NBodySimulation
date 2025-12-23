-- Load some default values
function love.load()
    x, y, w, h = 20, 20, 60, 20
end

-- Runs every frame
function love.update(dt)
    w = w + 1
    h = h + 1
end

-- Draws everything
function love.draw()
    love.graphics.setColor(0, 0.5, 0.4)
    love.graphics.rectangle("fill", x, y, w, h)
end