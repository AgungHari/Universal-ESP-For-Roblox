local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local espEnabled = false 
local distanceThreshold = 20 


local function showNotification(title, text)
    game.StarterGui:SetCore("SendNotification", {
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
    if espEnabled then
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
end)


local screenGui = Instance.new("ScreenGui")
local espButton = Instance.new("TextButton")
local githubButton = Instance.new("TextButton")

screenGui.Name = "SimpleMenu"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false


espButton.Name = "ESPButton"
espButton.Parent = screenGui
espButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
espButton.Position = UDim2.new(0.05, 0, 0.05, 0)  
espButton.Size = UDim2.new(0, 150, 0, 50)  
espButton.Font = Enum.Font.SourceSans
espButton.Text = "Toggle ESP"
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.TextSize = 18  

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        showNotification("ESP", "ESP Activated")
    else
        showNotification("ESP", "ESP Deactivated")
    end
end)


githubButton.Name = "GitHubButton"
githubButton.Parent = screenGui
githubButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
githubButton.Position = UDim2.new(0.05, 0, 0.15, 0)  
githubButton.Size = UDim2.new(0, 150, 0, 50)  
githubButton.Font = Enum.Font.SourceSans
githubButton.Text = "GitHub"
githubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
githubButton.TextSize = 18  -- Ukuran teks lebih kecil

githubButton.MouseButton1Click:Connect(function()
    local url = "https://github.com/AgungHari" 
    showNotification("GitHub", "Opening GitHub...")

    syn.request({Url = url})
end)


showNotification("Script Active", "Menu sudah diaktifkan.")
