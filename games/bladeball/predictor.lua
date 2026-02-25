-- =========================================
--  Zerivon Loader by Khayro
--  games/bladeball/predictor.lua
-- =========================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP         = Players.LocalPlayer

local Config = {
    Enabled      = true,
    Color        = Color3.fromRGB(255, 50, 50),
    ColorSafe    = Color3.fromRGB(50, 255, 100),
    Thickness    = 0.12,
    Steps        = 12,       -- puntos de prediccion
    StepTime     = 0.06,     -- segundos por paso
    OnlyTarget   = true,     -- solo cuando nos apunta
    ShowDot      = true,     -- punto de impacto estimado
}

-- Partes para dibujar la linea
local _parts   = {}
local _dot     = nil
local _conn    = nil
local _folder  = nil

local function CreateFolder()
    _folder = Instance.new("Folder")
    _folder.Name   = "ZV_Predictor"
    _folder.Parent = workspace
end

local function CreatePart(color)
    local p = Instance.new("Part")
    p.Name        = "ZV_PredLine"
    p.Anchored    = true
    p.CanCollide  = false
    p.CanQuery    = false
    p.CastShadow  = false
    p.Material    = Enum.Material.Neon
    p.Color       = color
    p.Size        = Vector3.new(Config.Thickness, Config.Thickness, 1)
    p.Parent      = _folder or workspace
    return p
end

local function CreateDot()
    local p = Instance.new("Part")
    p.Name        = "ZV_PredDot"
    p.Anchored    = true
    p.CanCollide  = false
    p.CanQuery    = false
    p.CastShadow  = false
    p.Material    = Enum.Material.Neon
    p.Shape       = Enum.PartType.Ball
    p.Color       = Config.Color
    p.Size        = Vector3.new(1.5, 1.5, 1.5)
    p.Parent      = _folder or workspace
    return p
end

local function InitParts()
    if _folder then _folder:Destroy() end
    CreateFolder()
    _parts = {}
    for i = 1, Config.Steps do
        _parts[i] = CreatePart(Config.Color)
    end
    if Config.ShowDot then
        _dot = CreateDot()
    end
end

local function HideAll()
    for _, p in ipairs(_parts) do
        p.Transparency = 1
    end
    if _dot then _dot.Transparency = 1 end
end

local function UpdatePredictor()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local balls = workspace:FindFirstChild("Balls")

    if not balls or not hrp then HideAll() return end

    -- Buscamos la pelota que nos apunta
    local targetBall = nil
    for _, ball in ipairs(balls:GetChildren()) do
        if not ball:IsA("BasePart") then continue end
        if not ball:GetAttribute("realBall") then continue end
        if Config.OnlyTarget and ball:GetAttribute("target") ~= LP.Name then continue end
        targetBall = ball
        break
    end

    if not targetBall then HideAll() return end

    local zoomies = targetBall:FindFirstChild("zoomies")
    if not zoomies then HideAll() return end

    local pos = targetBall.Position
    local vel = zoomies.VectorVelocity
    local speed = vel.Magnitude

    if speed < 1 then HideAll() return end

    -- Calculamos aceleracion aproximada (la pelota acelera con el tiempo)
    -- Basado en los datos: la pelota gana ~0.5 studs/s por segundo hacia el target
    local toTarget = (hrp.Position - pos)
    local distToTarget = toTarget.Magnitude
    local accelDir = distToTarget > 0 and toTarget.Unit or Vector3.new(0,0,0)
    local accelMag = 8  -- aceleracion promedio observada

    -- Dibujamos la trayectoria predicha
    local prevPos = pos
    local impactPos = pos

    for i = 1, Config.Steps do
        local t = i * Config.StepTime
        -- Posicion predicha con aceleracion
        local predPos = pos 
            + vel * t 
            + accelDir * accelMag * t * t * 0.5

        local segLen  = (predPos - prevPos).Magnitude
        local midPos  = (prevPos + predPos) * 0.5
        local segDir  = (predPos - prevPos).Unit

        local part = _parts[i]
        if not part then break end

        -- Color: rojo si cerca, verde si lejos
        local distNow = (hrp.Position - predPos).Magnitude
        part.Color = distNow < 20 and Config.Color or Config.ColorSafe
        part.Size  = Vector3.new(Config.Thickness, Config.Thickness, segLen)
        part.CFrame = CFrame.lookAt(midPos, prevPos + segDir * 100)
        part.Transparency = 0.2 + (i / Config.Steps) * 0.6  -- fade

        prevPos  = predPos
        impactPos = predPos
    end

    -- Dot en el punto de impacto estimado
    if _dot and Config.ShowDot then
        _dot.Position    = impactPos
        _dot.Color       = Config.Color
        _dot.Transparency = 0.2
    end
end

-- =========================================
--  API publica
-- =========================================
local Predictor = {}

function Predictor.Start()
    Config.Enabled = true
    InitParts()
    _conn = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        UpdatePredictor()
    end)
    print("[Predictor] Iniciado")
end

function Predictor.Stop()
    Config.Enabled = false
    if _conn then _conn:Disconnect(); _conn = nil end
    if _folder then _folder:Destroy(); _folder = nil end
    _parts = {}
    _dot   = nil
    print("[Predictor] Detenido")
end

function Predictor.SetEnabled(v)
    Config.Enabled = v
    if not v then HideAll() end
end
function Predictor.SetColor(c)       Config.Color     = c end
function Predictor.SetColorSafe(c)   Config.ColorSafe = c end
function Predictor.SetThickness(t)   Config.Thickness = t; InitParts() end
function Predictor.SetSteps(s)       Config.Steps     = s; InitParts() end
function Predictor.SetStepTime(t)    Config.StepTime  = t end
function Predictor.SetOnlyTarget(v)  Config.OnlyTarget = v end
function Predictor.SetShowDot(v)
    Config.ShowDot = v
    if not v and _dot then _dot.Transparency = 1 end
end
function Predictor.GetConfig()       return Config end

Predictor.Start()
return Predictor