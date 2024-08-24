-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()("Module")
local AimingChecks = Aiming.Checks
local AimingSelected = Aiming.Selected
local AimingSettingsIgnored = Aiming.Settings.Ignored
local AimingSettingsIgnoredPlayers = Aiming.Settings.Ignored.Players
local AimingSettingsIgnoredWhitelistMode = AimingSettingsIgnored.WhitelistMode

-- // Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- // Config
local SilentAimConfig = {
    Enabled = true,
    Method = "FindPartOnRay",
    FocusMode = false,
    ToggleBind = false,
    Keybind = Enum.UserInputType.MouseButton2,
    CurrentlyFocused = nil,

    MethodResolve = {
        raycast = { Real = "Raycast", Metamethod = "__namecall", Aliases = {"raycast"} },
        findpartonray = { Real = "FindPartOnRay", Metamethod = "__namecall", Aliases = {"findPartOnRay"} },
        findpartonraywithwhitelist = { Real = "FindPartOnRayWithWhitelist", Metamethod = "__namecall", Aliases = {"findPartOnRayWithWhitelist"} },
        findpartonraywithignorelist = { Real = "FindPartOnRayWithIgnoreList", Metamethod = "__namecall", Aliases = {"findPartOnRayWithIgnoreList"} },
        target = { Real = "Target", Metamethod = "__index", Aliases = {"target"} },
        hit = { Real = "Hit", Metamethod = "__index", Aliases = {"hit"} },
        x = { Real = "X", Metamethod = "__index", Aliases = {"x"} },
        y = { Real = "Y", Metamethod = "__index", Aliases = {"y"} },
        unitray = { Real = "UnitRay", Metamethod = "__index", Aliases = {"unitray"} },
    },

    ExpectedArguments = {
        FindPartOnRayWithIgnoreList = { ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean", "boolean"} },
        FindPartOnRayWithWhitelist = { ArgCountRequired = 3, Args = {"Instance", "Ray", "table", "boolean"} },
        FindPartOnRay = { ArgCountRequired = 2, Args = {"Instance", "Ray", "Instance", "boolean", "boolean"} },
        Raycast = { ArgCountRequired = 3, Args = {"Instance", "Vector3", "Vector3", "RaycastParams"} }
    }
}
local IsToggled = false
Aiming.SilentAim = SilentAimConfig

-- // ESP Config
local DistanceThreshold = 20

local function ShowNotification(Title, Text)
    StarterGui:SetCore("SendNotification", {
        Title = Title;
        Text = Text;
        Duration = 5; 
    })
end

local function CreateESP(Player)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESPHighlight"
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0.5
    Highlight.OutlineColor = Color3.fromRGB(0, 0, 0) 

    Player.CharacterAdded:Connect(function(Character)
        Highlight.Adornee = Character
        Highlight.Parent = Character
    end)

    Player.CharacterRemoving:Connect(function()
        if Highlight then
            Highlight:Destroy()
        end
    end)

    if Player.Character then
        Highlight.Adornee = Player.Character
        Highlight.Parent = Player.Character
    end
end

local function UpdateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Highlight = Player.Character:FindFirstChild("ESPHighlight")
            if not Highlight then
                CreateESP(Player)
                Highlight = Player.Character:FindFirstChild("ESPHighlight")
            end

            local Distance = (Player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            
            if Player.Team == LocalPlayer.Team then
                if Distance <= DistanceThreshold then
                    Highlight.FillColor = Color3.fromRGB(0, 0, 255) 
                else
                    Highlight.FillColor = Color3.fromRGB(0, 255, 255) 
                end
            else
                if Distance <= DistanceThreshold then
                    Highlight.FillColor = Color3.fromRGB(255, 0, 0) 
                else
                    Highlight.FillColor = Color3.fromRGB(255, 165, 0)
                end
            end
        end
    end
end

for _, Player in pairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end)

Players.PlayerRemoving:Connect(function(Player)
    if Player.Character and Player.Character:FindFirstChild("ESPHighlight") then
        Player.Character:FindFirstChild("ESPHighlight"):Destroy()
    end
end)

RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- // Functions
local function CalculateDirection(Origin, Destination, Length)
    return (Destination - Origin).Unit * Length
end

local function ValidateArguments(Args, Method)
    local TypeInformation = SilentAimConfig.ExpectedArguments[Method]
    if not TypeInformation then return false end
    local Matches = 0
    for ArgumentPosition, Argument in pairs(Args) do
        if typeof(Argument) == TypeInformation.Args[ArgumentPosition] then
            Matches = Matches + 1
        end
    end
    return #Args == Matches
end

function SilentAimConfig.AdditionalCheck(metamethod, method, callingscript, ...)
    return true
end

local function IsMethodEnabled(Method, Given, PossibleMethods)
    PossibleMethods = PossibleMethods or string.split(SilentAimConfig.Method, ",")
    Given = Given or Method
    local LoweredMethod = string.lower(Method)
    local MethodData = SilentAimConfig.MethodResolve[LoweredMethod]
    if not MethodData then return false, nil end
    local Matches = LoweredMethod == string.lower(Given)
    local RealMethod = MethodData.Real
    local Found = table.find(PossibleMethods, RealMethod)
    return (Matches and Found), RealMethod
end

function SilentAimConfig.ToggleMethod(Method, State)
    local EnabledMethods = string.split(SilentAimConfig.Method, ",")
    local FoundI = table.find(EnabledMethods, Method)
    if State then
        if not FoundI then
            table.insert(EnabledMethods, Method)
        end
    else
        if FoundI then
            table.remove(EnabledMethods, FoundI)
        end
    end
    SilentAimConfig.Method = table.concat(EnabledMethods, ",")
end

function SilentAimConfig.ModifyCFrame(OnScreen)
    return OnScreen and AimingSelected.Position or AimingSelected.Part.CFrame
end

local Backup = {table.unpack(SilentAimConfig.Settings.Ignored.Players)}
function SilentAimConfig.FocusPlayer(Player)
    table.insert(SilentAimConfig.Settings.Ignored.Players, Player)
    SilentAimConfig.Settings.Ignored.WhitelistMode.Players = true
end

function SilentAimConfig.Unfocus(Player)
    local PlayerI = table.find(SilentAimConfig.Settings.Ignored.Players, Player)
    if PlayerI then
        table.remove(SilentAimConfig.Settings.Ignored.Players, PlayerI)
    end
    SilentAimConfig.Settings.Ignored.WhitelistMode.Players = false
end

function SilentAimConfig.UnfocusAll(Replacement)
    Replacement = Replacement or Backup
    SilentAimConfig.Settings.Ignored.Players = Replacement
    SilentAimConfig.Settings.Ignored.WhitelistMode.Players = false
end

function SilentAimConfig.FocusHandler()
    if SilentAimConfig.CurrentlyFocused then
        SilentAimConfig.Unfocus(SilentAimConfig.CurrentlyFocused)
        SilentAimConfig.CurrentlyFocused = nil
        return
    end
    if AimingChecks.IsAvailable() then
        SilentAimConfig.FocusPlayer(AimingSelected.Instance)
        SilentAimConfig.CurrentlyFocused = AimingSelected.Instance
    end
end

local function CheckInput(Input, Expected)
    local InputType = Expected.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType"
    return Input[InputType] == Expected
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then return end
    local FocusMode = SilentAimConfig.FocusMode
    if CheckInput(Input, SilentAimConfig.Keybind) then
        if SilentAimConfig.ToggleBind then
            IsToggled = not IsToggled
        else
            IsToggled = true
        end
        if FocusMode then
            SilentAimConfig.FocusHandler()
        end
    end
    if typeof(FocusMode) == "boolean" and FocusMode then
        if Input.KeyCode == Enum.KeyCode.E then
            SilentAimConfig.FocusHandler()
        end
    end
end)

function SilentAimConfig.RayCast()
    local Target = AimingSelected.Part
    if not Target then return end
    local Ray = workspace.CurrentCamera:ScreenPointToRay(Target.Position.X, Target.Position.Y)
    local Result = workspace:Raycast(Ray.Origin, Ray.Direction * 500, RaycastParams.new())
    return Result
end

local function CalculateAim(Target, InputPosition)
    local Vector = (Target - InputPosition).Unit
    local Aim = Vector * (SilentAimConfig.AimDistance or 500)
    return Aim
end

function SilentAimConfig.SilentAim()
    if not IsToggled or not AimingChecks.IsAvailable() then return end
    local Result = SilentAimConfig.RayCast()
    if Result then
        local HitPart = Result.Instance
        if HitPart and HitPart.Parent then
            local Position = CalculateAim(HitPart.Position, AimingSelected.Position)
            AimingSelected.Part.CFrame = CFrame.new(Position)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if IsToggled then
        SilentAimConfig.SilentAim()
    end
    UpdateESP()
end)

-- Menampilkan notifikasi bahwa script sudah aktif
ShowNotification("Script Active", "Silent Aim dan ESP script telah diaktifkan.")
