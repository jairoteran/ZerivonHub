-- =========================================
--  Zerivon Loader by Khayro
--  core/ui.lua
-- =========================================

local UI = {}

local _library = nil
local _window  = nil
local _tabs    = {}
local _listening = false

local function LoadLinoria()
    local ok1, Library = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua", true))()
    end)
    local ok2, ThemeManager = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua", true))()
    end)
    local ok3, SaveManager = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua", true))()
    end)
    if not ok1 then error("Library failed: " .. tostring(Library)) end
    if not ok2 then error("ThemeManager failed: " .. tostring(ThemeManager)) end
    if not ok3 then error("SaveManager failed: " .. tostring(SaveManager)) end
    return Library, ThemeManager, SaveManager
end

function UI.Init(Config, Lang)
    local Library, ThemeManager, SaveManager = LoadLinoria()
    _library = Library

    _window = Library:CreateWindow({
        Title    = Config.Name .. " v" .. Config.Version,
        Center   = true,
        AutoShow = Config.UI.ShowOnLoad,
    })

    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("ZerivonLoader")
    ThemeManager:ApplyTheme(Config.Theme.Name)

    SaveManager:SetLibrary(Library)
    SaveManager:SetFolder("ZerivonLoader")

    task.delay(0.3, function()
        Library:SetWatermark("Zerivon v" .. Config.Version)
        Library:SetWatermarkVisibility(true)
    end)

    print("[UI] Inicializada OK")
    return true
end

-- =========================================
--  Colores predefinidos
-- =========================================
local COLORS = {
    "Rojo", "Naranja", "Amarillo", "Verde",
    "Cyan", "Azul", "Morado", "Rosa", "Blanco", "Negro",
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

-- =========================================
--  Aplica toggle keybind
-- =========================================
local function ApplyToggleKey(keyName)
    if not _library then return end
    _library.ToggleKeybind = {
        Type  = "KeyPicker",
        Value = keyName,
    }
end

-- =========================================
--  Tab dinamico por juego
-- =========================================
function UI.BuildGameTab(gameName, scripts, Lang, UserConfig)
    if not _window then return end

    local tab = _window:AddTab(gameName)
    _tabs[gameName] = tab

    -- ===== AUTO PARRY =====
    local AP = scripts["Auto Parry"]
    if AP then
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
            Text     = "Max Delay",
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
            Callback = function(v) AP.SetKey(Enum.KeyCode[v]) end
        })

        boxL:AddToggle("AP_Log", {
            Text     = "Show Log",
            Default  = false,
            Callback = function(v) AP.SetLog(v) end
        })
    end

    -- ===== ESP =====
    local ESP = scripts["ESP"]
    if ESP then
        local cfg = ESP.GetConfig()
        local boxR = tab:AddRightGroupbox("ESP")

        boxR:AddToggle("ESP_Enabled", {
            Text     = "Enabled",
            Default  = cfg.Enabled,
            Callback = function(v)
                if v then ESP.Start() else ESP.Stop() end
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

        local boxR2 = tab:AddRightGroupbox("ESP Colors")

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
            Callback = function(v)
                ESP.ApplyFillTransp(v / 100)
            end
        })
    end

    print("[UI] Game tab OK → " .. gameName)
end

-- =========================================
--  Tab Settings
-- =========================================
function UI.BuildSettings(Config, Lang, UserConfig)
    if not _window then return end

    local tab = _window:AddTab("Settings")
    _tabs.Settings = tab

    local boxL = tab:AddLeftGroupbox("General")

    local savedKey = UserConfig.Get("toggleKey") or "RightShift"

    -- Label que se actualiza
    local keyLabelObj = boxL:AddLabel("Toggle Key: " .. savedKey)

    local keyLabelObj = boxL:AddLabel("Toggle Key: " .. savedKey)

    boxL:AddButton({
        Text = "Set Toggle Key (press after click)",
        Func = function()
            if _listening then return end
            _listening = true
            if _library then
                _library:Notify("Press any key...", 3)
            end

            local UIS = game:GetService("UserInputService")
            local conn
            conn = UIS.InputBegan:Connect(function(input, processed)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                local keyName = input.KeyCode.Name
                conn:Disconnect()
                _listening = false

                ApplyToggleKey(keyName)
                UserConfig.Set("toggleKey", keyName)
                UserConfig.Save()

                -- Actualiza el label correctamente
                keyLabelObj:SetText("Toggle Key: " .. keyName)

                if _library then
                    _library:Notify("Toggle Key → " .. keyName, 2)
                end
            end)
        end
    })

    boxL:AddDropdown("ZV_Language", {
        Text     = "Language",
        Values   = Lang.Available(),
        Default  = UserConfig.Get("language") or "ES",
        Callback = function(value)
            UserConfig.Set("language", value)
            UserConfig.Save()
            if _library then
                _library:Notify("Language: " .. value .. "\nRestart to apply", 3)
            end
        end
    })

    if savedKey ~= "RightShift" and savedKey ~= "RightControl" then
        task.delay(0.5, function()
            ApplyToggleKey(savedKey)
        end)
    end

    local boxR = tab:AddRightGroupbox("Info")
    boxR:AddLabel(Config.Name .. "  v" .. Config.Version)
    boxR:AddLabel("by " .. Config.Author)

    print("[UI] Settings OK")
end

-- =========================================
--  Watermark
-- =========================================
function UI.SetGame(gameName)
    if not _library then return end
    task.delay(0.5, function()
        _library:SetWatermark("Zerivon | " .. gameName)
        _library:SetWatermarkVisibility(true)
    end)
end

function UI.UpdateWatermark(info)
    if not _library then return end
    _library:SetWatermark(info)
end

-- =========================================
--  Notificacion
-- =========================================
function UI.Notify(title, message, duration)
    if not _library then return end
    _library:Notify(title .. "\n" .. message, duration or 3)
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