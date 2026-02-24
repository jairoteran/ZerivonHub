-- =========================================
--  Zerivon Loader by Khayro
--  core/main.lua
-- =========================================

local BASE = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"

local function Load(path)
    return loadstring(game:HttpGet(BASE .. path, true))()
end

print("[Zerivon] Iniciando...")

local Config     = Load("core/config.lua")
local Updater    = Load("core/updater.lua")
local Lang       = Load("core/lang.lua")
local UserConfig = Load("core/userconfig.lua")
local Detector   = Load("core/detector.lua")
local LoaderCore = Load("core/loader_core.lua")
local Bypass     = Load("core/bypass.lua")
local UI         = Load("core/ui.lua")

print("[Zerivon] Modulos cargados OK")

UserConfig.Load()

local langCode    = UserConfig.Get("language") or "ES"
local langStrings = Load("lang/" .. langCode:lower() .. ".lua")
Lang.Init(langCode, langStrings)

print("[Zerivon] " .. Lang.Get("UPDATE_CHECKING"))
local updated, version = Updater.Check()
if updated then
    print("[Zerivon] " .. Lang.Get("UPDATE_DONE") .. " v" .. version)
else
    print("[Zerivon] " .. Lang.Get("UPDATE_NONE"))
end

Bypass.Run()
UI.Init(Config, Lang)

local gameName     = Detector.GetGameName()
local detectedGame = Detector.Detect(Config.Games)

if detectedGame then
    print("[Zerivon] " .. Lang.Get("GAME_DETECTED") .. ": " .. detectedGame.Name)
    UI.SetGame(detectedGame.Name)
else
    print("[Zerivon] " .. Lang.Get("GAME_UNKNOWN") .. ": " .. gameName)
end

if detectedGame then
    for _, scriptData in ipairs(detectedGame.Scripts) do
        local userEnabled = UserConfig.IsScriptEnabled(detectedGame.Name, scriptData.Name)
        scriptData.Enabled = userEnabled
    end
end

local loadedScripts = {}

if detectedGame then
    print("[Zerivon] " .. Lang.Get("GAME_LOADING"))
    local results = LoaderCore.ExecuteAll(detectedGame)

    for _, result in ipairs(results) do
        if result.Success and result.Module then
            loadedScripts[result.Name] = result.Module
        end
        if result.Skipped then
            print("[Zerivon] SKIP → " .. result.Name)
        elseif result.Success then
            print("[Zerivon] OK   → " .. result.Name)
        else
            print("[Zerivon] FAIL → " .. result.Name .. " | " .. tostring(result.Error))
        end
    end

    UI.Notify(
        Lang.Get("GAME_DETECTED"),
        detectedGame.Name .. " — " .. #detectedGame.Scripts .. " scripts",
        4
    )
end

if detectedGame then
    UI.BuildGameTab(detectedGame.Name, loadedScripts, Lang, UserConfig)
end

UI.BuildSettings(Config, Lang, UserConfig)

-- =========================================
--  Watermark dinamico
-- =========================================
task.spawn(function()
    local Stats = game:GetService("Stats")
    while task.wait(0.5) do
        local balls = workspace:FindFirstChild("Balls")
        local speed  = 0
        local target = "-"
        local myTarget = false

        if balls then
            local LP = game:GetService("Players").LocalPlayer
            for _, ball in ipairs(balls:GetChildren()) do
                if not ball:IsA("BasePart") then continue end
                local z = ball:FindFirstChild("zoomies")
                if z then
                    local s = math.floor(z.VectorVelocity.Magnitude)
                    if s > speed then
                        speed  = s
                        target = ball:GetAttribute("target") or "-"
                        myTarget = target == LP.Name
                    end
                end
            end
        end

        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        local targetStr = myTarget and (">> " .. target .. " <<") or target

        UI.UpdateWatermark(string.format(
            "Zerivon | %s | %d st/s | %s | %dms",
            detectedGame and detectedGame.Name or gameName,
            speed, targetStr, ping
        ))
    end
end)

print("[Zerivon] " .. Lang.Get("LOADED"))