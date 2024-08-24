local players = game:GetService("Players")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")  
local localPlayer = players.LocalPlayer
local distanceThreshold = 20
local silentAimRange = 50  -- Jarak maksimum untuk silent aim

local function showNotification(title, text)
    starterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 5; 
    })
end

local function createESP(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0) 

    player.CharacterAdded:Connect(function(character)
        highlight.Adornee = character
        highlight.Parent = character
    end)

    player.CharacterRemoving:Connect(function()
        if highlight then
            highlight:Destroy()
        end
    end)

    if player.Character then
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
    end
end

local function updateESP()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if not highlight then
                createESP(player)
                highlight = player.Character:FindFirstChild("ESPHighlight")
            end

            local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            
            if player.Team == localPlayer.Team then
                if distance <= distanceThreshold then
                    highlight.FillColor = Color3.fromRGB(0, 0, 255) 
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 255) 
                end
            else
                if distance <= distanceThreshold then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) 
                else
                    highlight.FillColor = Color3.fromRGB(255, 165, 0)
                end
            end
        end
    end
end

local function getVisibleEnemies()
    local enemies = {}
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Team ~= localPlayer.Team then
            local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance <= silentAimRange then
                table.insert(enemies, player)
            end
        end
    end
    return enemies
end

local function applySilentAim()
    local enemies = getVisibleEnemies()
    if #enemies > 0 then
        -- Ganti dengan kode yang mengarahkan senjata ke arah musuh
        -- Ini adalah contoh pseudo-kode; implementasikan sesuai dengan sistem senjata di game-mu
        local weapon = localPlayer.Character:FindFirstChildOfClass("Tool") -- Atau cari senjata sesuai implementasi game-mu
        if weapon and weapon:IsA("Tool") then
            -- Misalnya, jika menggunakan senjata yang memiliki fungsi setTarget, ganti dengan fungsi yang sesuai
            for _, enemy in pairs(enemies) do
                -- Misalnya, jika hanya ingin menargetkan satu musuh pada satu waktu, bisa menggunakan enemy[1]
                weapon:SetAttribute("AimAt", enemy.Character.HumanoidRootPart.Position)
                break -- Hanya menargetkan satu musuh jika diinginkan
            end
        end
    end
end

for _, player in pairs(players:GetPlayers()) do
    if player ~= localPlayer then
        createESP(player)
    end
end

players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createESP(player)
    end
end)

players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("ESPHighlight") then
        player.Character:FindFirstChild("ESPHighlight"):Destroy()
    end
end)

runService.RenderStepped:Connect(function()
    updateESP()
    applySilentAim()
end)

-- Menampilkan notifikasi bahwa script sudah aktif
showNotification("Script Active", "ESP script telah diaktifkan dan Silent Aim diatur untuk musuh.")
