-- =========================================
--  Zerivon Loader by Khayro
--  core/updater.lua
--  Auto-update silencioso al ejecutar
-- =========================================

local Updater = {}

local BASE     = "https://raw.githubusercontent.com/jairoteran/ZerivonLoader/main/"
local FILES    = {
    "core/config.lua",
    "core/detector.lua",
    "core/loader_core.lua",
    "core/updater.lua",
    "core/userconfig.lua",
    "core/lang.lua",
    "core/ui.lua",
    "core/main.lua",
    "lang/es.lua",
    "lang/en.lua",
}

-- =========================================
--  Lee la version local guardada
-- =========================================
local function GetLocalVersion()
    local ok, v = pcall(readfile, "ZerivonLoader/version.txt")
    if ok and v then
        return v:gsub("%s+", "")
    end
    return nil
end

-- =========================================
--  Lee la version remota del repo
-- =========================================
local function GetRemoteVersion()
    local ok, v = pcall(function()
        return game:HttpGet(BASE .. "version.txt", true)
    end)
    if ok and v then
        return v:gsub("%s+", "")
    end
    return nil
end

-- =========================================
--  Descarga y guarda un archivo del repo
-- =========================================
local function DownloadFile(path)
    local ok, src = pcall(function()
        return game:HttpGet(BASE .. path, true)
    end)
    if not ok or not src or src:sub(1,3) == "404" then
        return false
    end
    -- Crea carpetas si no existen
    local folder = path:match("^(.+)/[^/]+$")
    if folder then
        pcall(makefolder, "ZerivonLoader/" .. folder)
    end
    pcall(writefile, "ZerivonLoader/" .. path, src)
    return true
end

-- =========================================
--  Comprueba y aplica updates si hay
--  Retorna: updated (bool), version (string)
-- =========================================
function Updater.Check()
    -- Crea carpeta raiz si no existe
    if not isfolder("ZerivonLoader") then
        makefolder("ZerivonLoader")
    end

    local localVersion  = GetLocalVersion()
    local remoteVersion = GetRemoteVersion()

    if not remoteVersion then
        print("[Updater] No se pudo obtener version remota")
        return false, localVersion or "0.0.0"
    end

    print("[Updater] Local: " .. tostring(localVersion) .. " | Remota: " .. remoteVersion)

    if localVersion == remoteVersion then
        print("[Updater] Sin updates")
        return false, remoteVersion
    end

    -- Hay update — descarga todos los archivos
    print("[Updater] Update disponible → descargando...")
    local failed = 0

    for _, file in ipairs(FILES) do
        local ok = DownloadFile(file)
        if ok then
            print("[Updater] OK → " .. file)
        else
            print("[Updater] FAIL → " .. file)
            failed = failed + 1
        end
    end

    -- Guarda nueva version local
    if failed == 0 then
        writefile("ZerivonLoader/version.txt", remoteVersion)
        print("[Updater] Update completo → v" .. remoteVersion)
        return true, remoteVersion
    else
        print("[Updater] Update incompleto → " .. failed .. " archivos fallaron")
        return false, localVersion or "0.0.0"
    end
end

return Updater