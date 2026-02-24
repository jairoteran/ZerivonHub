-- =========================================
--  Zerivon Loader by Khayro
--  core/loader_core.lua
-- =========================================

local LoaderCore = {}

local BASE = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"
local _loadedScripts = {}

function LoaderCore.GetLoaded()
    return _loadedScripts
end

function LoaderCore.ClearCache()
    _loadedScripts = {}
end

-- =========================================
--  Ejecuta un script y retorna el modulo
-- =========================================
function LoaderCore.Execute(scriptData)
    if not scriptData.URL or scriptData.URL == "" then
        return false, "URL vacia", nil
    end

    local url = BASE .. scriptData.URL

    local fetchOk, src = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not fetchOk then
        return false, "Error de red: " .. tostring(src), nil
    end

    if not src or src == "" then
        return false, "Respuesta vacia", nil
    end

    if src:sub(1, 3) == "404" then
        return false, "Script no encontrado (404)", nil
    end

    local compOk, fn = pcall(loadstring, src)
    if not compOk or type(fn) ~= "function" then
        return false, "Error de compilacion", nil
    end

    -- Ejecucion — capturamos el return del modulo
    local execOk, result = pcall(fn)
    if not execOk then
        return false, "Error de ejecucion: " .. tostring(result), nil
    end

    _loadedScripts[scriptData.Name] = true

    -- result es el modulo si el script hace return
    local module = (type(result) == "table") and result or nil
    return true, nil, module
end

-- =========================================
--  Ejecuta todos los scripts de un juego
-- =========================================
function LoaderCore.ExecuteAll(gameData)
    local results = {}

    for _, scriptData in ipairs(gameData.Scripts) do
        if scriptData.Enabled then
            local ok, err, module = LoaderCore.Execute(scriptData)
            table.insert(results, {
                Name    = scriptData.Name,
                Success = ok,
                Error   = err,
                Skipped = false,
                Module  = module,
            })
        else
            table.insert(results, {
                Name    = scriptData.Name,
                Success = false,
                Error   = "desactivado",
                Skipped = true,
                Module  = nil,
            })
        end
    end

    return results
end

return LoaderCore