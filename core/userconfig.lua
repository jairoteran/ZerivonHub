-- =========================================
--  Zerivon Loader by Khayro
--  core/userconfig.lua
--  Guarda y carga preferencias del usuario
-- =========================================

local UserConfig = {}

local FOLDER = "ZerivonLoader"
local FILE   = "ZerivonLoader/userconfig.json"

local DEFAULTS = {
    language    = "ES",
    toggleKey   = "RightShift",
    showOnLoad  = true,
    autoHide    = true,
    autoHideDelay = 6,
    scripts     = {},
}

local _config = {}

-- =========================================
--  Copia defaults a una tabla
-- =========================================
local function CopyDefaults()
    local copy = {}
    for k, v in pairs(DEFAULTS) do
        copy[k] = v
    end
    return copy
end

-- =========================================
--  Serializa tabla a JSON simple
--  Solo soporta: string, number, bool, tabla
-- =========================================
local function Serialize(tbl, indent)
    indent = indent or 0
    local pad = string.rep("    ", indent)
    local lines = {"{"}
    local i = 0
    for k, v in pairs(tbl) do
        i = i + 1
        local key = '"' .. tostring(k) .. '"'
        local val
        if type(v) == "table" then
            val = Serialize(v, indent + 1)
        elseif type(v) == "string" then
            val = '"' .. v .. '"'
        elseif type(v) == "boolean" then
            val = tostring(v)
        elseif type(v) == "number" then
            val = tostring(v)
        else
            val = '"' .. tostring(v) .. '"'
        end
        table.insert(lines, pad .. "    " .. key .. ": " .. val .. ",")
    end
    table.insert(lines, pad .. "}")
    return table.concat(lines, "\n")
end

-- =========================================
--  Parsea JSON simple a tabla Lua
-- =========================================
local function Deserialize(str)
    local ok, result = pcall(function()
        -- Usamos HttpService para parsear JSON correctamente
        local HS = game:GetService("HttpService")
        return HS:JSONDecode(str)
    end)
    if ok and result then
        return result
    end
    return nil
end

-- =========================================
--  Carga la config del usuario
--  Si no existe crea una con defaults
-- =========================================
function UserConfig.Load()
    if not isfolder(FOLDER) then
        makefolder(FOLDER)
    end

    if not isfile(FILE) then
        _config = CopyDefaults()
        UserConfig.Save()
        print("[UserConfig] Creado con defaults")
        return _config
    end

    local ok, content = pcall(readfile, FILE)
    if not ok or not content or content == "" then
        _config = CopyDefaults()
        print("[UserConfig] Error leyendo archivo, usando defaults")
        return _config
    end

    local parsed = Deserialize(content)
    if not parsed then
        _config = CopyDefaults()
        print("[UserConfig] JSON invalido, usando defaults")
        return _config
    end

    -- Merge con defaults para keys faltantes
    _config = CopyDefaults()
    for k, v in pairs(parsed) do
        _config[k] = v
    end

    print("[UserConfig] Cargado OK")
    return _config
end

-- =========================================
--  Guarda la config actual
-- =========================================
function UserConfig.Save()
    if not isfolder(FOLDER) then
        makefolder(FOLDER)
    end

    local ok, err = pcall(function()
        local HS = game:GetService("HttpService")
        local json = HS:JSONEncode(_config)
        writefile(FILE, json)
    end)

    if ok then
        print("[UserConfig] Guardado OK")
    else
        print("[UserConfig] Error al guardar → " .. tostring(err))
    end

    return ok
end

-- =========================================
--  Obtiene un valor
-- =========================================
function UserConfig.Get(key)
    return _config[key]
end

-- =========================================
--  Establece un valor y guarda
-- =========================================
function UserConfig.Set(key, value)
    _config[key] = value
    UserConfig.Save()
end

-- =========================================
--  Verifica si un script esta habilitado
-- =========================================
function UserConfig.IsScriptEnabled(gameName, scriptName)
    if not _config.scripts then return true end
    if not _config.scripts[gameName] then return true end
    if _config.scripts[gameName][scriptName] == nil then return true end
    return _config.scripts[gameName][scriptName]
end

-- =========================================
--  Habilita o deshabilita un script
-- =========================================
function UserConfig.SetScript(gameName, scriptName, enabled)
    if not _config.scripts then
        _config.scripts = {}
    end
    if not _config.scripts[gameName] then
        _config.scripts[gameName] = {}
    end
    _config.scripts[gameName][scriptName] = enabled
    UserConfig.Save()
end

-- =========================================
--  Retorna toda la config
-- =========================================
function UserConfig.GetAll()
    return _config
end

-- =========================================
--  Resetea a defaults
-- =========================================
function UserConfig.Reset()
    _config = CopyDefaults()
    UserConfig.Save()
    print("[UserConfig] Reset a defaults")
end

return UserConfig