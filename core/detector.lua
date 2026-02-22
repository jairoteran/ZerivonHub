-- =========================================
--  Zerivon Loader by Khayro
--  core/detector.lua
--  Detecta el juego activo por nombre
-- =========================================

local Detector = {}

local _cachedName = nil

-- =========================================
--  Obtiene el nombre real del juego
-- =========================================
function Detector.GetGameName()
    if _cachedName then
        return _cachedName
    end

    local ok, result = pcall(function()
        local MPS = game:GetService("MarketplaceService")
        return MPS:GetProductInfo(game.PlaceId).Name
    end)

    if ok and result then
        _cachedName = result
    else
        _cachedName = game.Name ~= "" and game.Name or "Unknown"
    end

    return _cachedName
end

-- =========================================
--  Normaliza texto para comparacion
-- =========================================
local function Normalize(str)
    return str:lower():gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
end

-- =========================================
--  Detecta el juego comparando keywords
-- =========================================
function Detector.Detect(games)
    local gameName = Detector.GetGameName()
    local normalized = Normalize(gameName)

    local bestMatch = nil
    local bestScore = 0

    for _, gameData in ipairs(games) do
        local score = 0
        local matched = {}

        for _, keyword in ipairs(gameData.Keywords) do
            if normalized:find(Normalize(keyword), 1, true) then
                score = score + 1
                table.insert(matched, keyword)
            end
        end

        if score > 0 and score > bestScore then
            bestScore = score
            bestMatch = gameData
            bestMatch.MatchedBy = table.concat(matched, ", ")
        end
    end

    return bestMatch
end

return Detector