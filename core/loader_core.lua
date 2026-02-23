-- =========================================
--   Zerivon Loader by Khayro
--   core/loader_core.lua
--   Descarga y ejecuta scripts del juego
-- =========================================

local LoaderCore = {}

local BASE = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"
local _loadedScripts = {}

-- =========================================
--   Retorna lista de scripts cargados
-- =========================================
function LoaderCore.GetLoaded()
    return _loadedScripts
end

-- =========================================
--   Limpia el cache de scripts
-- =========================================
function LoaderCore.ClearCache()
    _loadedScripts = {}
end

-- =========================================
--   Ejecuta un script desde URL
--   Retorna: success (bool), result/error (any)
-- =========================================
function LoaderCore.Execute(scriptData)
    -- Validación de URL
    if not scriptData.URL or scriptData.URL == "" then
        return false, "URL vacia"
    end

    local url = BASE .. scriptData.URL

    -- Fetch del código fuente
    local fetchOk, src = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not fetchOk then
        return false, "Error de red: " .. tostring(src)
    end

    if not src or src == "" then
        return false, "Respuesta vacia"
    end

    -- Detección de error 404 de GitHub
    if src:sub(1, 3) == "404" then
        return false, "Script no encontrado (404)"
    end

    -- Compilación
    local fn, parseErr = loadstring(src)
    if not fn then
        return false, "Error de compilacion: " .. tostring(parseErr)
    end

    -- Ejecución
    -- Capturamos 'result', que es lo que el script devuelve (ej: return AutoParry)
    local execOk, result = pcall(fn)
    
    if not execOk then
        return false, "Error de ejecucion: " .. tostring(result)
    end

    -- Registro de éxito
    _loadedScripts[scriptData.Name] = true
    
    -- Retornamos true y la API/Tabla del script
    return true, result
end

-- =========================================
--   Ejecuta todos los scripts de un juego
--   Retorna: tabla de resultados con ReturnValue
-- =========================================
function LoaderCore.ExecuteAll(gameData)
    local results = {}

    for _, scriptData in ipairs(gameData.Scripts) do
        if scriptData.Enabled then
            -- Ejecutamos y capturamos la tabla devuelta
            local ok, data = LoaderCore.Execute(scriptData)
            
            table.insert(results, {
                Name        = scriptData.Name,
                Success     = ok,
                Error       = (not ok and data) or nil,
                ReturnValue = (ok and data) or nil, -- Esta es la API para la UI
                Skipped     = false,
            })
        else
            -- Script deshabilitado por el usuario
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