-- =========================================
--  Zerivon Loader by Khayro
--  games/bladeball/esp.lua
-- =========================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP         = Players.LocalPlayer
local RS         = game:GetService("ReplicatedStorage")

local Config = {
    Enabled          = true,

    -- Jugadores
    ShowPlayers      = true,
    EnemyColor       = Color3.fromRGB(255, 50, 50),
    TargetColor      = Color3.fromRGB(255, 150, 0),  -- jugador al que le toca la pelota
    FillTransp       = 0.6,
    OutlineTransp    = 0,
    ShowNames        = true,
    ShowDistance     = true,
    MaxDistance      = 500,

    -- Radio alrededor del personaje
    ShowRadius       = true,
    RadiusColor      = Color3.fromRGB(100, 200, 255),
    RadiusTransp     = 0.6,
    RadiusSize       = 25,

    -- Pelotas
    ShowBalls        = true,
    BallColor        = Color3.fromRGB(255, 220, 0),
    BallTargetColor  = Color3.fromRGB(255, 50, 50),  -- pelota que te apunta a ti
    BallFillTransp   = 0.5,
}

local _conn        = nil
local _highlights  = {}  -- player -> {hl, billboard}
local _ballHL      = {}  -- ball -> SelectionBox
local _radiusPart  = nil
local _ballConns   = {}
local _currentTargets = {}  -- balls -> nombre del target actual

-- =========================================
--  Radius ESP en los pies
-- =========================================
local function CreateRadius()
    if _radiusPart then _radiusPart:Destroy() end
    local p = Instance.new("Part")
    p.Name          = "ZV_Radius"
    p.Shape         = Enum.PartType.Cylinder
    p.Anchored      = true
    p.CanCollide    = false
    p.CanQuery      = false
    p.CastShadow    = false
    p.Material      = Enum.Material.Neon
    p.Color         = Config.RadiusColor
    p.Transparency  = Config.RadiusTransp
    p.Size          = Vector3.new(0.05, Config.RadiusSize * 2, Config.RadiusSize * 2)
    p.Parent        = workspace
    _radiusPart     = p
end

local function UpdateRadius()
    if not Config.ShowRadius then
        if _radiusPart then _radiusPart.Transparency = 1 end
        return
    end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not _radiusPart or not _radiusPart.Parent then CreateRadius() end
    _radiusPart.Transparency = Config.RadiusTransp
    _radiusPart.Color        = Config.RadiusColor
    _radiusPart.Size         = Vector3.new(0.05, Config.RadiusSize * 2, Config.RadiusSize * 2)
    local feetY = hrp.Position.Y - 3
    _radiusPart.CFrame = CFrame.new(hrp.Position.X, feetY, hrp.Position.Z)
                       * CFrame.Angles(0, 0, math.pi / 2)
end

-- =========================================
--  Ball ESP
-- =========================================
local function AddBallESP(ball)
    if not Config.ShowBalls then return end
    if _ballHL[ball] then return end

    local hl = Instance.new("SelectionBox")
    hl.Adornee             = ball
    hl.Color3              = Config.BallColor
    hl.LineThickness       = 0.06
    hl.SurfaceTransparency = Config.BallFillTransp
    hl.SurfaceColor3       = Config.BallColor
    hl.Parent              = workspace
    _ballHL[ball]          = hl

    -- Cambia color segun target
    local conn = ball.AttributeChanged:Connect(function(attr)
        if attr ~= "target" then return end
        local target = ball:GetAttribute("target")
        _currentTargets[ball] = target
        local isMe = target == LP.Name
        local color = isMe and Config.BallTargetColor or Config.BallColor
        hl.Color3        = color
        hl.SurfaceColor3 = color
    end)
    table.insert(_ballConns, conn)

    ball.AncestryChanged:Connect(function()
        if not ball:IsDescendantOf(workspace) then
            hl:Destroy()
            _ballHL[ball] = nil
            _currentTargets[ball] = nil
        end
    end)
end

local function InitBallESP()
    local balls = workspace:FindFirstChild("Balls")
    if not balls then return end
    for _, ball in ipairs(balls:GetChildren()) do
        if ball:IsA("BasePart") then AddBallESP(ball) end
    end
    local conn = balls.ChildAdded:Connect(function(ball)
        task.wait(0.05)
        if ball:IsA("BasePart") then AddBallESP(ball) end
    end)
    table.insert(_ballConns, conn)
end

-- =========================================
--  Player ESP
-- =========================================
local function GetPlayerTarget()
    -- Retorna el nombre del jugador que tiene la pelota dirigida a el
    local targets = {}
    local balls = workspace:FindFirstChild("Balls")
    if balls then
        for _, ball in ipairs(balls:GetChildren()) do
            local t = ball:GetAttribute("target")
            if t then targets[t] = true end
        end
    end
    return targets
end

local function AddPlayerESP(player)
    if player == LP then return end
    if _highlights[player] then return end

    local hl = Instance.new("Highlight")
    hl.Name                = "ZV_ESP"
    hl.FillTransparency    = Config.FillTransp
    hl.OutlineTransparency = Config.OutlineTransp
    hl.OutlineColor        = Config.EnemyColor
    hl.FillColor           = Config.EnemyColor
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop

    local bb = Instance.new("BillboardGui")
    bb.Name        = "ZV_Label"
    bb.AlwaysOnTop = true
    bb.Size        = UDim2.new(0, 120, 0, 45)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)

    local nameL = Instance.new("TextLabel")
    nameL.BackgroundTransparency = 1
    nameL.Size                   = UDim2.new(1, 0, 0.6, 0)
    nameL.TextColor3             = Config.EnemyColor
    nameL.TextStrokeTransparency = 0
    nameL.TextStrokeColor3       = Color3.new(0,0,0)
    nameL.Font                   = Enum.Font.GothamBold
    nameL.TextScaled             = true
    nameL.Text                   = player.Name
    nameL.Parent                 = bb

    local distL = Instance.new("TextLabel")
    distL.BackgroundTransparency = 1
    distL.Size                   = UDim2.new(1, 0, 0.4, 0)
    distL.Position               = UDim2.new(0, 0, 0.6, 0)
    distL.TextColor3             = Color3.fromRGB(220, 220, 220)
    distL.TextStrokeTransparency = 0
    distL.TextStrokeColor3       = Color3.new(0,0,0)
    distL.Font                   = Enum.Font.Gotham
    distL.TextScaled             = true
    distL.Text                   = ""
    distL.Parent                 = bb

    _highlights[player] = { hl = hl, bb = bb, nameL = nameL, distL = distL }

    local function OnChar(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        hl.Adornee = char
        bb.Adornee = hrp or char
        hl.Parent  = char
        bb.Parent  = char
    end

    if player.Character then OnChar(player.Character) end
    player.CharacterAdded:Connect(OnChar)

    player.AncestryChanged:Connect(function()
        if not player:IsDescendantOf(game) then
            local d = _highlights[player]
            if d then
                if d.hl and d.hl.Parent then d.hl:Destroy() end
                if d.bb and d.bb.Parent then d.bb:Destroy() end
                _highlights[player] = nil
            end
        end
    end)
end

local function UpdatePlayerESP()
    local myChar = LP.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targets = GetPlayerTarget()

    for player, data in pairs(_highlights) do
        if not player:IsDescendantOf(game) then
            _highlights[player] = nil
            continue
        end
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local dist = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0
        local visible = Config.ShowPlayers and Config.Enabled and dist <= Config.MaxDistance
        data.hl.Enabled = visible
        data.bb.Enabled = visible
        if not visible then continue end

        -- Color segun si le toca la pelota
        local isTarget = targets[player.Name] == true
        local color = isTarget and Config.TargetColor or Config.EnemyColor
        data.hl.OutlineColor  = color
        data.hl.FillColor     = color
        data.nameL.TextColor3 = color
        data.nameL.Text       = player.Name
        data.nameL.Visible    = Config.ShowNames
        data.distL.Text       = Config.ShowDistance and (dist .. "m") or ""
    end
end

-- =========================================
--  Loop principal
-- =========================================
local function StartLoop()
    _conn = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        UpdateRadius()
        UpdatePlayerESP()
    end)
end

-- =========================================
--  API publica
-- =========================================
local ESP = {}

function ESP.Start()
    Config.Enabled = true
    for _, p in ipairs(Players:GetPlayers()) do AddPlayerESP(p) end
    Players.PlayerAdded:Connect(AddPlayerESP)
    InitBallESP()
    StartLoop()
    print("[ESP] Iniciado")
end

function ESP.Stop()
    Config.Enabled = false
    if _conn then _conn:Disconnect(); _conn = nil end
    for _, c in ipairs(_ballConns) do c:Disconnect() end
    _ballConns = {}
    -- Oculta highlights en vez de destruirlos
    for player, data in pairs(_highlights) do
        if data.hl then data.hl.Enabled = false end
        if data.bb then data.bb.Enabled = false end
    end
    for _, hl in pairs(_ballHL) do
        hl.Enabled = false
    end
    if _radiusPart then _radiusPart.Transparency = 1 end
    print("[ESP] Detenido")
end

function ESP.SetEnabled(v)          Config.Enabled        = v end
function ESP.SetEnemyColor(c)       Config.EnemyColor     = c end
function ESP.SetTargetColor(c)      Config.TargetColor    = c end
function ESP.SetFillTransp(t)       Config.FillTransp     = t end
function ESP.SetShowNames(v)        Config.ShowNames      = v end
function ESP.SetShowDistance(v)     Config.ShowDistance   = v end
function ESP.SetMaxDistance(d)      Config.MaxDistance    = d end
function ESP.SetRadius(v)           Config.ShowRadius     = v end
function ESP.SetRadiusColor(c)      Config.RadiusColor    = c end
function ESP.SetRadiusSize(s)       Config.RadiusSize     = s end
function ESP.SetRadiusTransp(t)     Config.RadiusTransp   = t end
function ESP.SetBallESP(v)          Config.ShowBalls      = v end
function ESP.SetBallColor(c)        Config.BallColor      = c end
function ESP.SetBallTargetColor(c)  Config.BallTargetColor = c end
function ESP.GetConfig()            return Config end
function ESP.IsEnabled()            return Config.Enabled end

ESP.Start()

function ESP.ApplyFillTransp(t)
    for _, data in pairs(_highlights) do
        if data.hl then
            data.hl.FillTransparency = t
        end
    end
end
return ESP