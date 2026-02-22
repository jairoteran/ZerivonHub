-- =========================================
--  Zerivon Loader by Khayro
--  core/main.lua
--  Orquesta todos los modulos
-- =========================================

local BASE = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"

local function Load(path)
    return loadstring(game:HttpGet(BASE .. path, true))()
end

-- =========================================
--  1. CARGA DE MODULOS
-- =========================================
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

-- =========================================
--  2. USERCONFIG
-- =========================================
UserConfig.Load()

-- =========================================
--  3. IDIOMA
-- =========================================
local langCode = UserConfig.Get("language") or "ES"
local langStrings = Load("lang/" .. langCode:lower() .. ".lua")
Lang.Init(langCode, langStrings)

-- =========================================
--  4. AUTO UPDATE
-- =========================================
print("[Zerivon] " .. Lang.Get("UPDATE_CHECKING"))
local updated, version = Updater.Check()
if updated then
    print("[Zerivon] " .. Lang.Get("UPDATE_DONE") .. " v" .. version)
else
    print("[Zerivon] " .. Lang.Get("UPDATE_NONE"))
end

-- =========================================
--  5. BYPASS
-- =========================================
Bypass.Run()

-- =========================================
--  6. UI
-- =========================================
UI.Init(Config, Lang)

-- =========================================
--  7. DETECCION DEL JUEGO
-- =========================================
local gameName     = Detector.GetGameName()
local detectedGame = Detector.Detect(Config.Games)

if detectedGame then
    print("[Zerivon] " .. Lang.Get("GAME_DETECTED") .. ": " .. detectedGame.Name)
    UI.SetGame(detectedGame.Name, Lang)
else
    print("[Zerivon] " .. Lang.Get("GAME_UNKNOWN") .. ": " .. gameName)
    UI.SetUnsupported(gameName, Lang)
end

-- =========================================
--  8. USERCONFIG — aplica preferencias
--     de scripts del usuario al gameData
-- =========================================
if detectedGame then
    for _, scriptData in ipairs(detectedGame.Scripts) do
        local userEnabled = UserConfig.IsScriptEnabled(
            detectedGame.Name,
            scriptData.Name
        )
        scriptData.Enabled = userEnabled
    end
end

-- =========================================
--  9. EJECUCION DE SCRIPTS
-- =========================================
if detectedGame then
    print("[Zerivon] " .. Lang.Get("GAME_LOADING"))
    local results = LoaderCore.ExecuteAll(detectedGame)

    for _, result in ipairs(results) do
        UI.AddScriptResult(result, Lang)
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

-- =========================================
--  10. SETTINGS TAB
-- =========================================
UI.BuildSettings(Config, Lang, UserConfig)

-- =========================================
--  11. AUTO HIDE
-- =========================================
if UserConfig.Get("autoHide") then
    UI.StartAutoHide(UserConfig.Get("autoHideDelay") or 6)
end

print("[Zerivon] " .. Lang.Get("LOADED"))