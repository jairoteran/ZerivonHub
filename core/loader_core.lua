-- =========================================
--  Zerivon Loader by Khayro
--  core/loader_core.lua
--  Descarga y ejecuta scripts del juego
-- =========================================

local LoaderCore = {}

local BASE = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"
local _loadedScripts = {}

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

    -- Validacion de URL antes de cualquier request
    if not scriptData.URL or scriptData.URL == "" then
        return false, "URL vacia"
    end

    local url = BASE .. scriptData.URL

    -- Fetch
    local fetchOk, src = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not fetchOk then
        return false, "Error de red: " .. tostring(src)
    end

    if not src or src == "" then
        return false, "Respuesta vacia"
    end

    -- Detecta 404 de GitHub
    if src:sub(1, 3) == "404" then
        return false, "Script no encontrado (404)"
    end

    -- Compilacion
    local compOk, fn = pcall(loadstring, src)

    if not compOk then
        return false, "Error de compilacion: " .. tostring(fn)
    end

    if type(fn) ~= "function" then
        return false, "Compilacion retorno nil — verifica que el script sea Lua valido"
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
--  Retorna: tabla de resultados
--  { Name, Success, Error, Skipped }
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
                Skipped = false,
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