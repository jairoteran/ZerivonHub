-- =========================================
--  Zerivon Loader by Khayro
--  games/bladeball/autoparry.lua
--  Auto Parry configurable para Blade Ball
-- =========================================

local VIM        = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local LP         = game:GetService("Players").LocalPlayer
local RS         = game:GetService("ReplicatedStorage")

-- =========================================
--  Configuracion
-- =========================================
local Config = {
    Enabled       = true,
    Distance      = 25,
    Cooldown      = 0.3,
    ParryKey      = Enum.KeyCode.F,
    HoldTime      = 0.05,
    Precision     = 1.0,
    MaxDelay      = 0.15,

    -- Visual
    ShowRadiusESP = true,     -- circulo alrededor del personaje
    RadiusColor   = Color3.fromRGB(100, 200, 255),
    ShowBallESP   = true,     -- highlight en pelotas
    BallColor     = Color3.fromRGB(255, 200, 0),
    ESPTransp     = 0.6,

    ShowParryLog  = true,
}

-- =========================================
--  Estado
-- =========================================
local _last       = 0
local _conn       = nil
local _highlights = {}
local _radiusPart = nil

-- =========================================
--  Crea el circulo de radio alrededor
--  del personaje
-- =========================================
local function CreateRadiusESP()
    if _radiusPart then _radiusPart:Destroy() end

    local part = Instance.new("Part")
    part.Name      = "ZV_RadiusESP"
    part.Shape     = Enum.PartType.Cylinder
    part.Anchored  = true
    part.CanCollide = false
    part.CanQuery  = false
    part.CastShadow = false
    part.Material  = Enum.Material.Neon
    part.Color     = Config.RadiusColor
    part.Transparency = Config.ESPTransp
    part.Size      = Vector3.new(0.1, Config.Distance * 2, Config.Distance * 2)
    part.Parent    = workspace

    _radiusPart = part
end

local function UpdateRadiusESP()
    if not Config.ShowRadiusESP then
        if _radiusPart then
            _radiusPart.Transparency = 1
        end
        return
    end

    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not _radiusPart or not _radiusPart.Parent then
        CreateRadiusESP()
    end

    -- Actualiza posicion y tamaño
    _radiusPart.Transparency = Config.ESPTransp
    _radiusPart.Color        = Config.RadiusColor
    _radiusPart.Size         = Vector3.new(0.1, Config.Distance * 2, Config.Distance * 2)
    _radiusPart.CFrame       = CFrame.new(hrp.Position) * CFrame.Angles(0, 0, math.pi / 2)
end

-- =========================================
--  ESP en pelotas
-- =========================================
local function AddBallESP(ball)
    if not Config.ShowBallESP then return end
    if _highlights[ball] then return end

    local hl = Instance.new("SelectionBox")
    hl.Adornee           = ball
    hl.Color3            = Config.BallColor
    hl.LineThickness     = 0.05
    hl.SurfaceTransparency = 0.7
    hl.SurfaceColor3     = Config.BallColor
    hl.Parent            = workspace

    _highlights[ball] = hl

    ball.AncestryChanged:Connect(function()
        if not ball:IsDescendantOf(workspace) then
            hl:Destroy()
            _highlights[ball] = nil
        end
    end)
end

-- =========================================
--  Verifica si la pelota va hacia MI
--  personaje y no hacia otro jugador
-- =========================================
local function IsBallTargetingMe(ball, myPos)
    local zoomies = ball:FindFirstChild("zoomies")
    if not zoomies then return false end

    local vel = zoomies.VectorVelocity
    if vel.Magnitude < 5 then return false end

    local ballPos  = ball.Position
    local velDir   = vel.Unit
    local toMe     = (myPos - ballPos).Unit
    local dotMe    = toMe:Dot(velDir)

    -- La pelota debe apuntar hacia mi (dot > 0.5)
    if dotMe < 0.5 then return false end

    -- Verificamos que no hay otro jugador mas cercano
    -- en la direccion de la pelota
    local Players = game:GetService("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local toOther = (hrp.Position - ballPos).Unit
        local dotOther = toOther:Dot(velDir)

        -- Si otro jugador esta mas en la linea de fuego que yo
        local distOther = (hrp.Position - ballPos).Magnitude
        local distMe    = (myPos - ballPos).Magnitude

        if dotOther > dotMe and distOther < distMe then
            return false
        end
    end

    return true
end

-- =========================================
--  Delay segun precision
-- =========================================
local function GetDelay()
    local delay = Config.MaxDelay * (1 - Config.Precision)
    if delay > 0 then
        delay = delay + (math.random() * delay * 0.3)
    end
    return delay
end

-- =========================================
--  Loop principal
-- =========================================
local function StartLoop()
    _conn = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end

        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local myPos = hrp.Position

        local balls = workspace:FindFirstChild("Balls")
        if not balls then return end

        -- Actualiza radio ESP
        UpdateRadiusESP()

        -- Actualiza ball ESP
        if Config.ShowBallESP then
            for _, ball in ipairs(balls:GetChildren()) do
                if ball:IsA("BasePart") then
                    AddBallESP(ball)
                end
            end
        end

        local now = tick()
        if now - _last < Config.Cooldown then return end

        for _, ball in ipairs(balls:GetChildren()) do
            if not ball:IsA("BasePart") then continue end

            local dist = (myPos - ball.Position).Magnitude
            if dist > Config.Distance then continue end

            -- Solo parry si la pelota va hacia mi
            if not IsBallTargetingMe(ball, myPos) then continue end

            _last = now
            local delay = GetDelay()

            task.delay(delay, function()
                pcall(function()
                    VIM:SendKeyEvent(true,  Config.ParryKey, false, game)
                    task.wait(Config.HoldTime)
                    VIM:SendKeyEvent(false, Config.ParryKey, false, game)
                end)
                if Config.ShowParryLog then
                    print(string.format("[AutoParry] Parry! dist=%.1f delay=%.3f", dist, delay))
                end
            end)
            break
        end
    end)
end

-- =========================================
--  API publica
-- =========================================
local AutoParry = {}

function AutoParry.Start()
    Config.Enabled = true
    if not _conn then StartLoop() end
    print("[AutoParry] Iniciado")
end

function AutoParry.Stop()
    Config.Enabled = false
    if _conn then
        _conn:Disconnect()
        _conn = nil
    end
    if _radiusPart then
        _radiusPart:Destroy()
        _radiusPart = nil
    end
    for _, hl in pairs(_highlights) do
        hl:Destroy()
    end
    _highlights = {}
    print("[AutoParry] Detenido")
end

function AutoParry.SetEnabled(v)       Config.Enabled      = v; if v and not _conn then StartLoop() end end
function AutoParry.SetDistance(d)      Config.Distance     = d  end
function AutoParry.SetCooldown(c)      Config.Cooldown     = c  end
function AutoParry.SetPrecision(p)     Config.Precision    = math.clamp(p, 0, 1) end
function AutoParry.SetKey(k)           Config.ParryKey     = k  end
function AutoParry.SetRadiusESP(v)     Config.ShowRadiusESP = v end
function AutoParry.SetRadiusColor(c)   Config.RadiusColor  = c  end
function AutoParry.SetBallESP(v)       Config.ShowBallESP  = v  end
function AutoParry.SetBallColor(c)     Config.BallColor    = c  end
function AutoParry.SetTransparency(t)  Config.ESPTransp    = t  end
function AutoParry.SetLog(v)           Config.ShowParryLog = v  end
function AutoParry.GetConfig()         return Config            end
function AutoParry.IsEnabled()         return Config.Enabled    end

AutoParry.Start()

return AutoParry