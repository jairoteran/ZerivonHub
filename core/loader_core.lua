-- =========================================
--  Zerivon Loader by Khayro
--  core/loader_core.lua
--  Descarga y ejecuta scripts del juego
-- =========================================

local LoaderCore = {}

local BASE = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"
local _notificationsEnabled = true
local _loadedScripts = {}

-- =========================================
--  Control de notificaciones
-- =========================================
function LoaderCore.SetNotifications(state)
    _notificationsEnabled = state
end

-- =========================================
--  Retorna lista de scripts cargados
-- =========================================
function LoaderCore.GetLoaded()
    return _loadedScripts
end

-- =========================================
--  Limpia el cache de scripts
-- =========================================
function LoaderCore.ClearCache()
    _loadedScripts = {}
end

-- =========================================
--  Ejecuta un script desde URL
--  Retorna: success (bool), error (string)
-- =========================================
function LoaderCore.Execute(scriptData)
    local url = BASE .. scriptData.URL

    -- Validacion de URL
    if not url or url == "" then
        return false, "URL vacia"
    end

    -- Fetch
    local fetchOk, src = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not fetchOk or not src or src == "" then
        return false, "Error de red: " .. tostring(src)
    end

    if src:find("404") then
        return false, "Script no encontrado (404)"
    end

    -- Compilacion
    local compOk, fn = pcall(loadstring, src)
    if not compOk or type(fn) ~= "function" then
        return false, "Error de compilacion: " .. tostring(fn)
    end

    -- Ejecucion
    local execOk, err = pcall(fn)
    if not execOk then
        return false, "Error de ejecucion: " .. tostring(err)
    end

    -- Exito
    _loadedScripts[scriptData.Name] = true
    return true, nil
end

-- =========================================
--  Ejecuta todos los scripts de un juego
--  Retorna: resultados tabla
--  { name, success, error }
-- =========================================
function LoaderCore.ExecuteAll(gameData)
    local results = {}

    for _, scriptData in ipairs(gameData.Scripts) do
        if scriptData.Enabled then
            local ok, err = LoaderCore.Execute(scriptData)
            table.insert(results, {
                Name    = scriptData.Name,
                Success = ok,
                Error   = err,
            })
        else
            table.insert(results, {
                Name    = scriptData.Name,
                Success = false,
                Error   = "desactivado",
                Skipped = true,
            })
        end
    end

    return results
end

return LoaderCore