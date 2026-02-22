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
    _