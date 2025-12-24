local Timer = {}
Timer.__index = Timer

function Timer.new(totalTime)
    local newTimer = {}
    setmetatable(newTimer, Timer)

    newTimer.totalTime = totalTime
    newTimer.timeLeft = 0
    newTimer.isDone = true

    return newTimer
end

function Timer:tick(dt)
    --Lowers the timers remaining tiem each frame and stores a buffer for the next restart
    local buffer = 0
    if self.timeLeft + buffer - dt > 0 then
        self.timeLeft = self.timeLeft + buffer - dt
    else 
        self.isDone = true
        buffer = -self.timeLeft + dt
    end 
end

function Timer:reset()
    self.isDone = false
    self.timeLeft = self.totalTime
end

return Timer