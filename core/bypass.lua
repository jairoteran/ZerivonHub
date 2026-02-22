-- =========================================
--  Zerivon Loader by Khayro
--  core/bypass.lua
--  Bypasses y patches previos a los scripts
-- =========================================

local Bypass = {}

-- =========================================
--  Deshabilita restricciones comunes
-- =========================================
local function PatchGameSettings()
    local ok = pcall(function()
        settings().Rendering.QualityLevel = 1
    end)
end

-- =========================================
--  Hookea metodos problematicos
-- =========================================
local function PatchMetamethods()
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        local oldNewIndex = mt.__newindex

        setrawmetatable(game, mt)
        mt.__newindex = function(self, key, value)
            return oldNewIndex(self, key, value)
        end
    end)
    if ok then
        print("[Bypass] Metamethods OK")
    end
end

-- =========================================
--  Deshabilita deteccion de scripts
-- =========================================
local function PatchScriptDetection()
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        mt.__index = newcclosure(function(self, key)
            if key == "ScriptContext" then
                return nil
            end
            return oldIndex(self, key)
        end)
    end)
    if ok then
        print("[Bypass] ScriptDetection OK")
    end
end

-- =========================================
--  Ejecuta todos los bypasses
--  Retorna: success (bool)
-- =========================================
function Bypass.Run()
    print("[Bypass] Ejecutando...")

    PatchGameSettings()
    PatchMetamethods()
    PatchScriptDetection()

    print("[Bypass] Completado")
    return true
end

return Bypass