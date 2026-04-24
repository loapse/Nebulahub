--NebulaHub

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "NebulaHub"

-- Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 330)
Frame.Position = UDim2.new(0, -300, 0.5, -165)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true

-- Smooth slide-in animation
TweenService:Create(Frame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0, 20, 0.5, -165)
}):Play()

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NebulaHub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(140, 120, 255)

-- UI List
local UIList = Instance.new("UIListLayout", Frame)
UIList.Padding = UDim.new(0, 8)
UIList.FillDirection = Enum.FillDirection.Vertical
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Top

-- Toggle creator
local function createToggle(name, default, callback)
    local button = Instance.new("TextButton", Frame)
    button.Size = UDim2.new(0.9, 0, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.Text = name .. ": " .. (default and "ON" or "OFF")
    button.AutoButtonColor = false

    button.MouseButton1Click:Connect(function()
        default = not default
        button.Text = name .. ": " .. (default and "ON" or "OFF")

        -- Smooth color tween
        TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundColor3 = default and Color3.fromRGB(60, 60, 90) or Color3.fromRGB(35, 35, 45)
        }):Play()

        callback(default)
    end)
end

-- UI Toggles
createToggle("Highlights", Settings.Highlights, function(v) Settings.Highlights = v end)
createToggle("Tracers", Settings.Tracers, function(v) Settings.Tracers = v end)
createToggle("Healthbars", Settings.Healthbars, function(v) Settings.Healthbars = v end)
-- ESP STORAGE
local tracers = {}

-- HIGHLIGHT
local function addHighlight(character)
    if character:FindFirstChild("ESP_Highlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = Settings.HighlightColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = character
end

-- HEALTHBAR
local function addHealthbar(character)
    if character:FindFirstChild("ESP_Healthbar") then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_Healthbar"
    gui.Size = UDim2.new(4, 0, 0.5, 0)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = character

    local bar = Instance.new("Frame", gui)
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, 0, 1, 0)

    humanoid.HealthChanged:Connect(function(health)
        local pct = math.clamp(health / humanoid.MaxHealth, 0, 1)
        bar.Size = UDim2.new(pct, 0, 1, 0)
        bar.BackgroundColor3 = Color3.fromRGB(255 - pct * 255, pct * 255, 0)
    end)
end

-- TRACERS
local function createTracer(player)
    local line = Drawing.new("Line")
    line.Color = Settings.TracerColor
    line.Thickness = Settings.TracerThickness
    line.Transparency = 1
    tracers[player] = line
end

local function removeTracer(player)
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

-- UPDATE LOOP
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            -- HIGHLIGHTS
            if Settings.Highlights and char then
                addHighlight(char)
            end

            -- HEALTHBARS
            if Settings.Healthbars and char then
                addHealthbar(char)
            end

            -- TRACERS
            local tracer = tracers[player]
            if Settings.Tracers then
                if not tracer then
                    createTracer(player)
                    tracer = tracers[player]
                end

                if root then
                    local pos, visible = Camera:WorldToViewportPoint(root.Position)
                    tracer.Visible = visible
                    if visible then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Color = Settings.TracerColor
                        tracer.Thickness = Settings.TracerThickness
                    end
                end
            else
                if tracer then tracer.Visible = false end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(removeTracer)
