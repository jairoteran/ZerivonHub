local Config = {}


Config.Name        = "Zerivon Loader"
Config.Version     = "0.0.1"
Config.Author      = "Khayro"
Config.Description = "Roblox Script Loader by Khayro"


Config.Theme = {
    Name          = "Default",   -- tema base de Linoria
    AccentColor   = Color3.fromRGB(100, 60, 220),  -- morado Zerivon
}


Config.UI = {
    ToggleKey     = Enum.KeyCode.RightShift,
    ShowOnLoad    = true,
    AutoHideDelay = 6,           -- segundos antes de ocultar al cargar
    Watermark     = "Zerivon Loader  v0.0.1  by Khayro",
}


Config.Discord = {
    Enabled = false,
    Invite  = "",
}


Config.Games = {

    {
        Name     = "Blade Ball",
        Keywords = {"blade", "ball", "blade ball"},
        Scripts  = {
            {
                Name    = "Auto Parry",
                Enabled = true,
                URL     = "games/bladeball/autoparry.lua",
            },
            {
                Name    = "ESP",
                Enabled = true,
                URL     = "games/bladeball/esp.lua",
            },
        }
    },

    {
        Name     = "Arsenal",
        Keywords = {"arsenal"},
        Scripts  = {
            {
                Name    = "Silent Aim",
                Enabled = true,
                URL     = "games/arsenal/silentaim.lua",
            },
        }
    },

    {
        Name     = "Da Hood",
        Keywords = {"da hood", "dahood", "hood"},
        Scripts  = {
            {
                Name    = "Aimbot",
                Enabled = true,
                URL     = "games/dahood/aimbot.lua",
            },
        }
    },

}

return Config