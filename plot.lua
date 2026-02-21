local Plot = {}
Plot.__index = Plot

function Plot:new(posX, posY, width, height, XAxisLength, YAxisLength, paddingXAxis, paddingYAxis)
    local newPlot = {}
    setmetatable(newPlot, Plot)

    newPlot.posX = posX
    newPlot.posY = posY

    newPlot.width = width
    newPlot.height = height

    newPlot.paddingXAxis = paddingXAxis or 10
    newPlot.paddingYAxis = paddingYAxis or 10

    --The actual height and width of the axis in px
    newPlot.XAxisWidth = newPlot.width - 2 * newPlot.paddingXAxis
    newPlot.YAxisHeight = newPlot.height - (2 * newPlot.paddingYAxis)

    -- newPlot.plotWidth = plotWidth or widths
    -- newPlot.plotHeight = plotHeight or height
    newPlot.XAxisLength = XAxisLength or 100
    newPlot.YAxisLength = YAxisLength or 100

    newPlot.XAxisScale = 1 / 4 --px / u
    newPlot.YAxisScale = 1 / 4 --px / u

    newPlot.points = {}

    return newPlot
end

function Plot:render()
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.posX,self.posY, self.width, self.height, 5, 5, 100)

    love.graphics.setColor(1,1,1)
    --Draw each axis' max value
    love.graphics.print(self.YAxisLength, self.posX + self.paddingXAxis + 5, self.posY + self.paddingYAxis)
    love.graphics.print(self.XAxisLength,self.posX + self.width - self.paddingXAxis - 10, self.posY + self.height - self.paddingYAxis - 20)

    local paddedX = self.posX + self.paddingXAxis
    local paddedY = self.posY + self.height - self.paddingYAxis

    --Draw the graph's axis
    love.graphics.setLineWidth(1)
    love.graphics.line(paddedX, paddedY, paddedX, self.posY + self.paddingYAxis)
    love.graphics.line(paddedX, paddedY, self.posX + self.width - self.paddingXAxis, paddedY)

    --Draw the graph itself
    love.graphics.setColor(1,1,0.5)

    local scaledPoints = {}
    for i = 1, #self.points do
        if i % 2 == 1 then
            --x values
            scaledPoints[i] = self.points[i] * (self.XAxisWidth / self.XAxisLength) + self.posX + self.paddingXAxis
        else
            --y values
            -- scaledPoints[i] = self.YAxisHeight - self.points[i] * (self.YAxisHeight / self.YAxisLength) + self.posY + self.paddingYAxis
            scaledPoints[i] = self.YAxisHeight - self.points[i] * (self.YAxisHeight / self.YAxisLength) + self.posY + self.paddingYAxis
        end
    end
    if self.points[1] ~= nil and self.points[2] ~= nil and self.points[3] ~= nil and self.points[4] ~= nil then
        love.graphics.line(scaledPoints)
    end
end

--Inserts one new point in the plot
function Plot:insertNewPoint(x, y)
    --Makes sure you're not inputting a value backwards
    if x > (self.points[#self.points - 1] or 0) then
        table.insert(self.points, x)
        table.insert(self.points, y)
    end
end

return Plot