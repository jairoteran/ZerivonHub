-- =========================================
--  Zerivon Loader by Khayro
--  core/lang.lua
--  Sistema de idiomas ES/EN
-- =========================================

local Lang = {}

local BASE = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"

local _strings  = {}
local _current  = "ES"
local _fallback = "ES"

-- =========================================
--  Carga un idioma desde el repo
-- =========================================
local function LoadLang(code)
    local path = "lang/" .. code:lower() .. ".lua"
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE .. path, true))()
    end)
    if ok and type(result) == "table" then
        return result
    end
    return nil
end

-- =========================================
--  Inicializa el sistema con un idioma
-- =========================================
function Lang.Init(code)
    code = code or "ES"
    _current = code:upper()

    local strings = LoadLang(_current)

    if not strings then
        print("[Lang] Idioma '" .. _current .. "' no disponible, usando fallback ES")
        _current = _fallback
        strings = LoadLang(_current)
    end

    if strings then
        _strings = strings
        print("[Lang] Idioma cargado → " .. _current)
        return true
    end

    print("[Lang] Error critico — no se pudo cargar ningun idioma")
    return false
end

-- =========================================
--  Obtiene un texto por key
--  Si no existe retorna la key misma
-- =========================================
function Lang.Get(key)
    return _strings[key] or key
end

-- =========================================
--  Cambia el idioma en runtime
-- =========================================
function Lang.Set(code)
    return Lang.Init(code)
end

-- =========================================
--  Retorna el idioma actual
-- =========================================
function Lang.Current()
    return _current
end

-- =========================================
--  Retorna todos los idiomas disponibles
-- =========================================
function Lang.Available()
    return {"ES", "EN"}
end

return Lang