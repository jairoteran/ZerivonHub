-- =========================================
--  Zerivon Loader by Khayro
--  games/bladeball/autoparry.lua
-- =========================================

local VIM        = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local LP         = game:GetService("Players").LocalPlayer
local RS         = game:GetService("ReplicatedStorage")

local Config = {
    Enabled     = true,
    ParryKey    = Enum.KeyCode.F,
    HoldTime    = 0.05,
    Precision   = 1.0,
    MaxDelay    = 0.25,
    ShowLog     = true,
}

local ping          = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
local ParryButton   = RS.Remotes:FindFirstChild("ParryButtonPress")
local _parriedBalls = {}
local _lastParry    = 0
local _ballConns    = {}
local _conn         = nil
local _count        = 0
local _success      = 0

local PARRY_RADIUS = 15
local pingSec      = ping / 1000

local function GetDelay()
    local base = Config.MaxDelay * (1 - Config.Precision)
    if base <= 0 then return 0 end
    return base + (math.random() * base * 0.2)
end

local function DoParry(ball, dist)
    local now = tick()
    if _parriedBalls[ball] and now - _parriedBalls[ball] < 1.5 then return end
    if now - _lastParry < 0.3 then return end
    _lastParry = now
    _parriedBalls[ball] = now
    _count = _count + 1

    local delay = GetDelay()
    task.delay(delay, function()
        pcall(function()
            VIM:SendKeyEvent(true,  Config.ParryKey, false, game)
            task.wait(Config.HoldTime)
            VIM:SendKeyEvent(false, Config.ParryKey, false, game)
        end)
        pcall(function() if ParryButton then ParryButton:Fire() end end)
        if Config.ShowLog then
            print(string.format("[AutoParry #%d] dist=%.1f delay=%.3fs", _count, dist, delay))
        end
    end)
end

local function ConnectBall(ball)
    if not ball:IsA("BasePart") then return end
    if not ball:GetAttribute("realBall") then return end
    local c = ball.AttributeChanged:Connect(function(attr)
        if attr ~= "target" then return end
        if ball:GetAttribute("target") ~= LP.Name then
            _parriedBalls[ball] = nil
        end
    end)
    table.insert(_ballConns, c)
end

local function InitBalls()
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end
    for _, b in ipairs(balls:GetChildren()) do ConnectBall(b) end
    local c1 = balls.ChildAdded:Connect(function(b) task.wait(0.05); ConnectBall(b) end)
    local c2 = balls.ChildRemoved:Connect(function(b) _parriedBalls[b] = nil end)
    table.insert(_ballConns, c1)
    table.insert(_ballConns, c2)
end

local function StartLoop()
    _conn = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        local bs = workspace:FindFirstChild("Balls")
        if not bs then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local myPos = hrp.Position

        for _, ball in ipairs(bs:GetChildren()) do
            if not ball:IsA("BasePart") then continue end
            if ball:GetAttribute("target") ~= LP.Name then continue end

            local dist = (myPos - ball.Position).Magnitude
            local zoomies = ball:FindFirstChild("zoomies")
            local speed = zoomies and zoomies.VectorVelocity.Magnitude or 0

            local shouldParry = false
            if dist <= PARRY_RADIUS then
                shouldParry = true
            elseif speed > 1 then
                local timeToHit = (dist - PARRY_RADIUS) / speed
                shouldParry = timeToHit <= pingSec + 0.05
            end

            if shouldParry then DoParry(ball, dist) end
        end
    end)
end

-- =========================================
--  API publica
-- =========================================
local AutoParry = {}

function AutoParry.Start()
    Config.Enabled = true
    InitBalls()
    StartLoop()
    print("[AutoParry] Iniciado — ping=" .. math.floor(ping) .. "ms")
end

function AutoParry.Stop()
    Config.Enabled = false
    if _conn then _conn:Disconnect(); _conn = nil end
    for _, c in ipairs(_ballConns) do c:Disconnect() end
    _ballConns    = {}
    _parriedBalls = {}
    print("[AutoParry] Detenido")
end

function AutoParry.SetEnabled(v)   Config.Enabled   = v end
function AutoParry.SetPrecision(p) Config.Precision = math.clamp(p, 0, 1) end
function AutoParry.SetKey(k)       Config.ParryKey  = k end
function AutoParry.SetLog(v)       Config.ShowLog   = v end
function AutoParry.GetStats()      return { count = _count, success = _success, ping = math.floor(ping) } end
function AutoParry.GetConfig()     return Config end
function AutoParry.IsEnabled()     return Config.Enabled end
function AutoParry.SetParryRadius(r) PARRY_RADIUS = r end
function AutoParry.GetParryRadius()  return PARRY_RADIUS end

AutoParry.Start()
return AutoParry