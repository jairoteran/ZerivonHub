-- =========================================
--  Zerivon Loader by Khayro
--  core/lang.lua
--  Sistema de idiomas ES/EN
-- =========================================

local Lang = {}

local _strings  = {}
local _current  = "ES"

-- =========================================
--  Inicializa con una tabla de strings
--  ya cargada externamente
-- =========================================
function Lang.Init(code, strings)
    if not strings or type(strings) ~= "table" then
        print("[Lang] Strings invalidos para → " .. tostring(code))
        return false
    end
    _current = code:upper()
    _strings = strings
    print("[Lang] Idioma cargado → " .. _current)
    return true
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
function Lang.Set(code, strings)
    return Lang.Init(code, strings)
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