-- =========================================
--  Zerivon Loader by Khayro
--  core/ui.lua
--  Interfaz con Linoria
-- =========================================

local UI = {}

local _library    = nil
local _window     = nil
local _tabs       = {}
local _groupboxes = {}

-- =========================================
--  Carga Linoria
-- =========================================
local function LoadLinoria()
    local Library = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua", true))()
    local ThemeManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua", true))()
    local SaveManager = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua", true))()
    return Library, ThemeManager, SaveManager
end

-- =========================================
--  Inicializa la UI
-- =========================================
function UI.Init(Config, Lang)
    local Library, ThemeManager, SaveManager = LoadLinoria()
    _library = Library

    Library:SetWatermark(Config.UI.Watermark)
    Library:SetWatermarkVisibility(true)

    _window = Library:CreateWindow({
        Title    = Config.Name,
        Center   = true,
        AutoShow = Config.UI.ShowOnLoad,
    })

    Library.ToggleKeybind = Config.UI.ToggleKey

    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("ZerivonLoader")
    ThemeManager:ApplyTheme(Config.Theme.Name)

    SaveManager:SetLibrary(Library)
    SaveManager:SetFolder("ZerivonLoader")

    _tabs.Main     = _window:AddTab(Lang.Get("GAME_LOADING"))
    _tabs.Settings = _window:AddTab("Settings")

    _groupboxes.Main = _tabs.Main:AddLeftGroupbox(Config.Name)
    _groupboxes.Main:AddLabel(Config.Name .. "  v" .. Config.Version)
    _groupboxes.Main:AddLabel(Lang.Get("UI_AUTHOR") .. " " .. Config.Author)

    print("[UI] Inicializada OK")
    return true
end

-- =========================================
--  Muestra el juego detectado
-- =========================================
function UI.SetGame(gameName, Lang)
    if not _groupboxes.Main then return end
    _groupboxes.Main:AddLabel(Lang.Get("GAME_DETECTED") .. ": " .. gameName)
end

-- =========================================
--  Agrega resultado de script
-- =========================================
function UI.AddScriptResult(result, Lang)
    if not _groupboxes.Main then return end

    local status
    if result.Skipped then
        status = "[" .. Lang.Get("SCRIPT_SKIP") .. "]"
    elseif result.Success then
        status = "[" .. Lang.Get("SCRIPT_OK") .. "]"
    else
        status = "[" .. Lang.Get("SCRIPT_FAIL") .. "]"
    end

    _groupboxes.Main:AddLabel(result.Name .. "  " .. status)
end

-- =========================================
--  Juego no soportado
-- =========================================
function UI.SetUnsupported(gameName, Lang)
    if not _groupboxes.Main then return end
    _groupboxes.Main:AddLabel(Lang.Get("GAME_UNKNOWN"))
    _groupboxes.Main:AddLabel(gameName)
end

-- =========================================
--  Tab settings
-- =========================================
function UI.BuildSettings(Config, Lang, UserConfig)
    if not _tabs.Settings then return end

    local Box = _tabs.Settings:AddLeftGroupbox("Settings")

    Box:AddDropdown("ZV_Language", {
        Text     = "Idioma / Language",
        Values   = Lang.Available(),
        Default  = UserConfig.Get("language"),
        Callback = function(value)
            UserConfig.Set("language", value)
        end
    })

    Box:AddDropdown("ZV_ToggleKey", {
        Text     = "Toggle Key",
        Values   = {"RightShift", "LeftAlt", "F1", "F2", "F3", "Insert", "Home"},
        Default  = UserConfig.Get("toggleKey") or "RightShift",
        Callback = function(value)
            UserConfig.Set("toggleKey", value)
            _library.ToggleKeybind = Enum.KeyCode[value]
        end
    })

    Box:AddToggle("ZV_AutoHide", {
        Text     = "Auto Hide",
        Default  = UserConfig.Get("autoHide"),
        Callback = function(value)
            UserConfig.Set("autoHide", value)
        end
    })

    local BoxR = _tabs.Settings:AddRightGroupbox("Info")
    BoxR:AddLabel(Config.Name .. "  v" .. Config.Version)
    BoxR:AddLabel(Lang.Get("UI_AUTHOR") .. " " .. Config.Author)

    print("[UI] Settings OK")
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
        _library    = nil
        _window     = nil
        _tabs       = {}
        _groupboxes = {}
        print("[UI] Destruida OK")
    end
end
return UI