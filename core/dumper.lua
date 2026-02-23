-- =========================================
--  Zerivon Loader by Khayro
--  core/dumper.lua
--  Dumper de remotes, instancias y scripts
-- =========================================

local Dumper = {}

-- =========================================
--  Encuentra todos los RemoteEvents y
--  RemoteFunctions en un servicio
-- =========================================
function Dumper.GetRemotes(parent)
    local remotes = {}
    local ok = pcall(function()
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(remotes, {
                    Type = v.ClassName,
                    Name = v.Name,
                    Path = v:GetFullName(),
                })
            end
        end
    end)
    return remotes
end

-- =========================================
--  Obtiene hijos directos de un servicio
-- =========================================
function Dumper.GetChildren(instance)
    local children = {}
    local ok = pcall(function()
        for _, v in ipairs(instance:GetChildren()) do
            table.insert(children, {
                Type      = v.ClassName,
                Name      = v.Name,
                Children  = #v:GetChildren(),
            })
        end
    end)
    return children
end

-- =========================================
--  Dump completo guardado en archivo
-- =========================================
function Dumper.SaveDump()
    local lines = {}
    local function add(str) table.insert(lines, str) end

    add("=== ZERIVON DUMPER ===")
    add("Juego: " .. tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name))
    add("PlaceId: " .. tostring(game.PlaceId))
    add("Fecha: " .. os.date("%Y-%m-%d %H:%M:%S"))
    add("")

    -- ReplicatedStorage remotes
    add("=== REMOTES (ReplicatedStorage) ===")
    local remotes = Dumper.GetRemotes(game:GetService("ReplicatedStorage"))
    for _, r in ipairs(remotes) do
        add("[" .. r.Type .. "] " .. r.Path)
    end
    add("Total: " .. #remotes)
    add("")

    -- Workspace hijos
    add("=== WORKSPACE ===")
    local ws = Dumper.GetChildren(workspace)
    for _, c in ipairs(ws) do
        add("[" .. c.Type .. "] " .. c.Name .. " (" .. c.Children .. " hijos)")
    end
    add("")

    -- Players
    add("=== PLAYERS ===")
    local Players = game:GetService("Players")
    for _, p in ipairs(Players:GetPlayers()) do
        add("  " .. p.Name .. " (UserId: " .. p.UserId .. ")")
    end
    add("")

    -- LocalPlayer
    add("=== LOCALPLAYER ===")
    local LP = Players.LocalPlayer
    add("Name: " .. LP.Name)
    add("UserId: " .. LP.UserId)
    local ok = pcall(function()
        for _, v in ipairs(LP.leaderstats:GetChildren()) do
            add("  " .. v.Name .. " = " .. tostring(v.Value))
        end
    end)
    add("")

    -- Guarda el archivo
    local content = table.concat(lines, "\n")
    if not isfolder("ZerivonLoader") then makefolder("ZerivonLoader") end
    writefile("ZerivonLoader/dump.txt", content)
    print("[Dumper] Guardado → ZerivonLoader/dump.txt")
    print("[Dumper] " .. #remotes .. " remotes encontrados")
    return content
end

-- =========================================
--  Busca instancias por nombre
-- =========================================
function Dumper.Search(name)
    local results = {}
    name = name:lower()
    local ok = pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v.Name:lower():find(name) then
                table.insert(results, {
                    Type = v.ClassName,
                    Path = v:GetFullName(),
                })
                if #results >= 50 then return end
            end
        end
    end)
    return results
end

return Dumper