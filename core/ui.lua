-- =========================================
--  Zerivon Loader by Khayro
--  core/ui.lua
-- =========================================

local UI = {}

local _library  = nil
local _window   = nil
local _tabs     = {}

local function LoadLinoria()
    local Library = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua", true))()
    local ThemeManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua", true))()
    local SaveManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua", true))()
    return Library, ThemeManager, SaveManager
end

function UI.Init(Config, Lang)
    local Library, ThemeManager, SaveManager = LoadLinoria()
    _library = Library

    Library:SetWatermark(Config.UI.Watermark)
    Library:SetWatermarkVisibility(true)

    _window = Library:CreateWindow({
        Title    = Config.Name .. " v" .. Config.Version,
        Center   = true,
        AutoShow = Config.UI.ShowOnLoad,
    })

    Library.ToggleKeybind = Config.UI.ToggleKey

    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("ZerivonLoader")
    ThemeManager:ApplyTheme(Config.Theme.Name)

    SaveManager:SetLibrary(Library)
    SaveManager:SetFolder("ZerivonLoader")

    print("[UI] Inicializada OK")
    return true
end

-- =========================================
--  Tab dinamico por juego
--  scripts = { AutoParry = module, ESP = module }
-- =========================================
function UI.BuildGameTab(gameName, scripts, Lang, UserConfig)
    if not _window then return end

    -- Tab con nombre del juego
    local tab = _window:AddTab(gameName)
    _tabs[gameName] = tab

    -- ===== AUTO PARRY =====
    if scripts.AutoParry then
        local AP = scripts.AutoParry
        local cfg = AP.GetConfig()

        local boxL = tab:AddLeftGroupbox("Auto Parry")

        boxL:AddToggle("AP_Enabled", {
            Text     = "Enabled",
            Default  = cfg.Enabled,
            Callback = function(v) AP.SetEnabled(v) end
        })

        boxL:AddSlider("AP_Precision", {
            Text    = "Precision",
            Min     = 0,
            Max     = 100,
            Default = math.floor(cfg.Precision * 100),
            Suffix  = "%",
            Rounding = 0,
            Callback = function(v) AP.SetPrecision(v / 100) end
        })

        boxL:AddSlider("AP_Delay", {
            Text    = "Max Delay (ms)",
            Min     = 0,
            Max     = 500,
            Default = math.floor(cfg.MaxDelay * 1000),
            Suffix  = "ms",
            Rounding = 0,
            Callback = function(v) cfg.MaxDelay = v / 1000 end
        })

        boxL:AddDropdown("AP_Key", {
            Text   = "Parry Key",
            Values = {"F", "Q", "E", "R", "T", "G", "V", "B"},
            Default = "F",
            Callback = function(v)
                AP.SetKey(Enum.KeyCode[v])
            end
        })

        boxL:AddToggle("AP_Log", {
            Text     = "Show Log",
            Default  = cfg.ShowLog,
            Callback = function(v) AP.SetLog(v) end
        })
    end

    -- ===== ESP =====
    if scripts.ESP then
        local ESP = scripts.ESP
        local cfg = ESP.GetConfig()

        local boxR = tab:AddRightGroupbox("ESP")

        boxR:AddToggle("ESP_Enabled", {
            Text     = "Enabled",
            Default  = cfg.Enabled,
            Callback = function(v) ESP.SetEnabled(v) end
        })

        boxR:AddToggle("ESP_Players", {
            Text     = "Players",
            Default  = cfg.ShowPlayers,
            Callback = function(v) cfg.ShowPlayers = v end
        })

        boxR:AddToggle("ESP_Names", {
            Text     = "Names",
            Default  = cfg.ShowNames,
            Callback = function(v) ESP.SetShowNames(v) end
        })

        boxR:AddToggle("ESP_Distance", {
            Text     = "Distance",
            Default  = cfg.ShowDistance,
            Callback = function(v) ESP.SetShowDistance(v) end
        })

        boxR:AddSlider("ESP_MaxDist", {
            Text     = "Max Distance",
            Min      = 50,
            Max      = 1000,
            Default  = cfg.MaxDistance,
            Suffix   = "m",
            Rounding = 0,
            Callback = function(v) ESP.SetMaxDistance(v) end
        })

        boxR:AddToggle("ESP_Balls", {
            Text     = "Ball ESP",
            Default  = cfg.ShowBalls,
            Callback = function(v) ESP.SetBallESP(v) end
        })

        boxR:AddToggle("ESP_Radius", {
            Text     = "Radius Circle",
            Default  = cfg.ShowRadius,
            Callback = function(v) ESP.SetRadius(v) end
        })

        boxR:AddSlider("ESP_RadiusSize", {
            Text     = "Radius Size",
            Min      = 5,
            Max      = 60,
            Default  = cfg.RadiusSize,
            Rounding = 0,
            Callback = function(v) ESP.SetRadiusSize(v) end
        })

        -- Colores
        local boxR2 = tab:AddRightGroupbox("Colores")

        boxR2:AddLabel("Enemy Color")
        boxR2:AddColorPicker("ESP_EnemyColor", {
            Default  = cfg.EnemyColor,
            Callback = function(v) ESP.SetEnemyColor(v) end
        })

        boxR2:AddLabel("Target Color (pelota dirigida)")
        boxR2:AddColorPicker("ESP_TargetColor", {
            Default  = cfg.TargetColor,
            Callback = function(v) ESP.SetTargetColor(v) end
        })

        boxR2:AddLabel("Ball Color")
        boxR2:AddColorPicker("ESP_BallColor", {
            Default  = cfg.BallColor,
            Callback = function(v) ESP.SetBallColor(v) end
        })

        boxR2:AddLabel("Ball Target Color")
        boxR2:AddColorPicker("ESP_BallTargetColor", {
            Default  = cfg.BallTargetColor,
            Callback = function(v) ESP.SetBallTargetColor(v) end
        })

        boxR2:AddLabel("Radius Color")
        boxR2:AddColorPicker("ESP_RadiusColor", {
            Default  = cfg.RadiusColor,
            Callback = function(v) ESP.SetRadiusColor(v) end
        })

        boxR2:AddSlider("ESP_FillTransp", {
            Text     = "Fill Transparency",
            Min      = 0,
            Max      = 100,
            Default  = math.floor(cfg.FillTransp * 100),
            Suffix   = "%",
            Rounding = 0,
            Callback = function(v) ESP.SetFillTransp(v / 100) end
        })
    end
end

-- =========================================
--  Tab Settings
-- =========================================
function UI.BuildSettings(Config, Lang, UserConfig)
    if not _window then return end

    local tab = _window:AddTab("Settings")
    _tabs.Settings = tab

    local boxL = tab:AddLeftGroupbox("General")

    boxL:AddDropdown("ZV_Language", {
        Text     = "Idioma / Language",
        Values   = Lang.Available(),
        Default  = UserConfig.Get("language") or "ES",
        Callback = function(value)
            UserConfig.Set("language", value)
            UserConfig.Save()
        end
    })

    boxL:AddDropdown("ZV_ToggleKey", {
        Text    = "Toggle Key",
        Values  = {"RightShift", "LeftAlt", "F1", "F2", "F3", "Insert", "Home"},
        Default = UserConfig.Get("toggleKey") or "RightShift",
        Callback = function(value)
            UserConfig.Set("toggleKey", value)
            UserConfig.Save()
            _library.ToggleKeybind = Enum.KeyCode[value]
        end
    })

    boxL:AddToggle("ZV_AutoHide", {
        Text     = "Auto Hide",
        Default  = UserConfig.Get("autoHide") or false,
        Callback = function(value)
            UserConfig.Set("autoHide", value)
            UserConfig.Save()
        end
    })

    local boxR = tab:AddRightGroupbox("Info")
    boxR:AddLabel(Config.Name .. "  v" .. Config.Version)
    boxR:AddLabel("by " .. Config.Author)

    print("[UI] Settings OK")
end

-- =========================================
--  Watermark con juego detectado
-- =========================================
function UI.SetGame(gameName)
    if not _library then return end
    _library:SetWatermark("Zerivon | " .. gameName)
end

-- =========================================
--  Notificacion
-- =========================================
function UI.Notify(title, message, duration)
    if not _library then return end
    _library:Notify(title .. "\n" .. message, duration or 3)
end

-- =========================================
--  Auto hide
-- =========================================
function UI.StartAutoHide(delay)
    task.delay(delay or 6, function()
        if _library then
            _library:SetWatermarkVisibility(false)
            _library:Toggle()
        end
    end)
end

-- =========================================
--  Destruye la UI
-- =========================================
function UI.Destroy()
    if _library then
        _library:Unload()
        _library = nil
        _window  = nil
        _tabs    = {}
        print("[UI] Destruida OK")
    end
end

return UI