local Camera = {}
Camera.__index = Camera

--[[
Camera class taken from https://ebens.me/posts/cameras-in-love2d-part-1-the-basics
]]

function Camera:new()
    local newCamera = {}
    setmetatable(newCamera, Camera)

    newCamera.posX = 0
    newCamera.posY = 0
    newCamera.scaleX = 1
    newCamera.scaleY = 1
    newCamera.rotation = 0
    
    return newCamera
end

--To put at the start of love.draw()
function Camera:set()
    love.graphics.push()
    love.graphics.rotate(-self.rotation)
    love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
    love.graphics.translate(-self.posX, -self.posY)
end

--To put at the end of love.draw()
function Camera:unset()
    love.graphics.pop()
end

--The following methods can be used anywhere to modifity the camera's parameters
function Camera:move(dx, dy)
    self.posX = self.posX + (dx or 0)
    self.posY = self.posY + (dy or 0)
end

function Camera:rotate(dr)
    self.rotation = self.rotation + dr
end

--To zoom, sx must be bigger than 1
function Camera:scale(sx, sy)
    sx = sx or 1
    self.scaleX = self.scaleX * 1 / sx
    self.scaleY = self.scaleY * 1 / (sy or sx)
end

function Camera:setScale(sx, sy)
    self.scaleX = sx or self.scaleX
    self.scaleY = sy or self.scaleY
end

function Camera:setPosition(x, y)
    self.posX = x or self.posX
    self.posY = y or self.posY
end

function Camera:mousePosition()
  return love.mouse.getX() * self.scaleX + self.posX, love.mouse.getY() * self.scaleY + self.posY
end

function Camera:toGlobalCoordinate(posX, posY)
    return posX * self.scaleX + self.posX, posY * self.scaleY + self.posY
end

function Camera:centerOnPosition(posX, posY)
    local centerX, centerY = self:toGlobalCoordinate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self:move(-centerX + posX, -centerY + posY)
end

--Zooms in or out while keeping everything centered
--[[
HOW IT WORKS:
Calculates the coordinates of the center of the screen before scaling everything
Scale everything then calculate the new coordiantes for the center of the screen, which will have changed from before
Substract the old center coordiantes from the new ones to find the offset, which you then apply to the camera
--]]
function Camera:zoom(zx, zy)
    local oldCenterX, oldCenterY = self:toGlobalCoordinate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self:scale(zx, zy)
    local newCenterX, newCenterY = self:toGlobalCoordinate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    local offsetX, offsetY = newCenterX - oldCenterX, newCenterY - oldCenterY
    self:move(-offsetX, -offsetY)
end

return Camera