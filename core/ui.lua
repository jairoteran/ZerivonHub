-- =========================================
--  Zerivon Loader by Khayro
--  core/ui.lua
-- =========================================

local UI = {}

local _library = nil
local _window  = nil
local _tabs    = {}

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

-- Colores predefinidos
local COLORS = {
    "Rojo",
    "Naranja", 
    "Amarillo",
    "Verde",
    "Cyan",
    "Azul",
    "Morado",
    "Rosa",
    "Blanco",
    "Negro",
}

local COLOR_VALUES = {
    Rojo     = Color3.fromRGB(255, 50,  50),
    Naranja  = Color3.fromRGB(255, 150, 0),
    Amarillo = Color3.fromRGB(255, 220, 0),
    Verde    = Color3.fromRGB(50,  255, 100),
    Cyan     = Color3.fromRGB(0,   200, 255),
    Azul     = Color3.fromRGB(50,  100, 255),
    Morado   = Color3.fromRGB(150, 50,  255),
    Rosa     = Color3.fromRGB(255, 100, 200),
    Blanco   = Color3.fromRGB(255, 255, 255),
    Negro    = Color3.fromRGB(20,  20,  20),
}

local function ColorToName(c)
    local best, bestDist = "Rojo", math.huge
    for name, col in pairs(COLOR_VALUES) do
        local d = (c.R-col.R)^2 + (c.G-col.G)^2 + (c.B-col.B)^2
        if d < bestDist then bestDist = d; best = name end
    end
    return best
end

function UI.BuildGameTab(gameName, scripts, Lang, UserConfig)
    if not _window then return end

    local tab = _window:AddTab(gameName)
    _tabs[gameName] = tab

    -- ===== AUTO PARRY =====
    if scripts["Auto Parry"] then
        local AP  = scripts["Auto Parry"]
        local cfg = AP.GetConfig()

        local boxL = tab:AddLeftGroupbox("Auto Parry")

        boxL:AddToggle("AP_Enabled", {
            Text     = "Enabled",
            Default  = cfg.Enabled,
            Callback = function(v) AP.SetEnabled(v) end
        })

        boxL:AddSlider("AP_Precision", {
            Text     = "Precision",
            Min      = 0,
            Max      = 100,
            Default  = math.floor(cfg.Precision * 100),
            Suffix   = "%",
            Rounding = 0,
            Callback = function(v) AP.SetPrecision(v / 100) end
        })

        boxL:AddSlider("AP_Delay", {
            Text     = "Max Delay (ms)",
            Min      = 0,
            Max      = 500,
            Default  = math.floor(cfg.MaxDelay * 1000),
            Suffix   = "ms",
            Rounding = 0,
            Callback = function(v) cfg.MaxDelay = v / 1000 end
        })

        boxL:AddDropdown("AP_Key", {
            Text     = "Parry Key",
            Values   = {"F", "Q", "E", "R", "T", "G", "V", "B"},
            Default  = "F",
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
    if scripts["ESP"] then
        local ESP = scripts["ESP"]
        local cfg = ESP.GetConfig()

        local boxR = tab:AddRightGroupbox("ESP")

        boxR:AddToggle("ESP_Enabled", {
            Text     = "Enabled",
            Default  = cfg.Enabled,
            Callback = function(v)
                cfg.Enabled = v
                -- Oculta/muestra highlights manualmente
                if v then
                    ESP.Start()
                else
                    ESP.Stop()
                end
            end
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
        local boxR2 = tab:AddRightGroupbox("Colores ESP")

        boxR2:AddDropdown("ESP_EnemyColor", {
            Text     = "Enemy Color",
            Values   = COLORS,
            Default  = ColorToName(cfg.EnemyColor),
            Callback = function(v) ESP.SetEnemyColor(COLOR_VALUES[v]) end
        })

        boxR2:AddDropdown("ESP_TargetColor", {
            Text     = "Target Color",
            Values   = COLORS,
            Default  = ColorToName(cfg.TargetColor),
            Callback = function(v) ESP.SetTargetColor(COLOR_VALUES[v]) end
        })

        boxR2:AddDropdown("ESP_BallColor", {
            Text     = "Ball Color",
            Values   = COLORS,
            Default  = ColorToName(cfg.BallColor),
            Callback = function(v) ESP.SetBallColor(COLOR_VALUES[v]) end
        })

        boxR2:AddDropdown("ESP_BallTargetColor", {
            Text     = "Ball Target Color",
            Values   = COLORS,
            Default  = ColorToName(cfg.BallTargetColor),
            Callback = function(v) ESP.SetBallTargetColor(COLOR_VALUES[v]) end
        })

        boxR2:AddDropdown("ESP_RadiusColor", {
            Text     = "Radius Color",
            Values   = COLORS,
            Default  = ColorToName(cfg.RadiusColor),
            Callback = function(v) ESP.SetRadiusColor(COLOR_VALUES[v]) end
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

    -- Toggle manual de la UI
    boxL:AddButton({
        Text = "Toggle Menu",
        Func = function()
            if _library then _library:Toggle() end
        end
    })

    boxL:AddDropdown("ZV_Language", {
        Text     = "Idioma / Language",
        Values   = Lang.Available(),
        Default  = UserConfig.Get("language") or "ES",
        Callback = function(value)
            UserConfig.Set("language", value)
            UserConfig.Save()
            if _library then
                _library:Notify("Idioma cambiado a " .. value .. "\nReinicia para aplicar", 3)
            end
        end
    })

    boxL:AddDropdown("ZV_ToggleKey", {
        Text    = "Toggle Key",
        Values  = {"RightShift", "LeftAlt", "F1", "F2", "F3", "Insert", "Home", "End"},
        Default = UserConfig.Get("toggleKey") or "RightShift",
        Callback = function(value)
            UserConfig.Set("toggleKey", value)
            UserConfig.Save()
            if _library then
                _library.ToggleKeybind = Enum.KeyCode[value]
                _library:Notify("Toggle Key → " .. value, 2)
            end
        end
    })

    boxL:AddToggle("ZV_AutoHide", {
        Text     = "Auto Hide al cargar",
        Default  = UserConfig.Get("autoHide") or false,
        Callback = function(value)
            UserConfig.Set("autoHide", value)
            UserConfig.Save()
        end
    })

    boxL:AddSlider("ZV_AutoHideDelay", {
        Text     = "Auto Hide Delay",
        Min      = 1,
        Max      = 30,
        Default  = UserConfig.Get("autoHideDelay") or 6,
        Suffix   = "s",
        Rounding = 0,
        Callback = function(value)
            UserConfig.Set("autoHideDelay", value)
            UserConfig.Save()
        end
    })

    local boxR = tab:AddRightGroupbox("Info")
    boxR:AddLabel(Config.Name .. "  v" .. Config.Version)
    boxR:AddLabel("by " .. Config.Author)
    boxR:AddLabel("Loaded: Blade Ball")
    boxR:AddButton({
        Text = "Discord",
        Func = function()
            if _library then
                _library:Notify("Discord: discord.gg/zerivon", 4)
            end
        end
    })

    print("[UI] Settings OK")
end

return UI