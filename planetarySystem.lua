local PlanetarySystem = {}

PlanetarySystem.__index = PlanetarySystem

local Utils = require("utils")
local Gravity = require("gravity")

function PlanetarySystem:new()
    local newPlanetarySystem = {}
    setmetatable(newPlanetarySystem, PlanetarySystem)

    newPlanetarySystem.planets = {}

    return newPlanetarySystem
end





return PlanetarySystem