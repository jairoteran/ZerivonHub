-- Watermark dinamico
task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    while task.wait(0.5) do
        local balls = workspace:FindFirstChild("Balls")
        local speed = 0
        local target = "-"
        if balls then
            for _, ball in ipairs(balls:GetChildren()) do
                if ball:IsA("BasePart") then
                    local z = ball:FindFirstChild("zoomies")
                    if z then
                        local s = math.floor(z.VectorVelocity.Magnitude)
                        if s > speed then
                            speed = s
                            target = ball:GetAttribute("target") or "-"
                        end
                    end
                end
            end
        end
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        UI.UpdateWatermark(string.format("Zerivon | %s | %d st/s | Target: %s | %dms",
            detectedGame and detectedGame.Name or "?",
            speed, target, ping))
    end
end)