local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Theme = {
	Bg = Color3.fromRGB(16, 16, 18),
	Button = Color3.fromRGB(22, 22, 26),
	Stroke = Color3.fromRGB(40, 40, 46),
	Accent = Color3.fromRGB(0, 170, 255),
	Text = Color3.fromRGB(235, 235, 240),
	Muted = Color3.fromRGB(160, 160, 170),
	Font = Enum.Font.Gotham
}

local info = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

if localPlayer:GetAttribute("AntiBagged") == true then
	StarterGui:SetCore("SendNotification", {
		Title = "R I F T",
		Text = "O script já está executado",
		Duration = 5
	})
	return
end
localPlayer:SetAttribute("AntiBagged", true)

localPlayer.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end)

local function enable()
	if not humanoid then return end
	
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://87058607990254"

	local track = humanoid:LoadAnimation(animation)
	track.Looped = false
	track.Priority = Enum.AnimationPriority.Action4
	track:Play()
	track:AdjustSpeed(10)
	
	animation:Destroy()
	
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if track.TimePosition >= 0.8 then
			track:AdjustSpeed(0)
			connection:Disconnect()
		end
	end)
end

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

local button = Instance.new("TextButton")
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.fromScale(1, 0.5)
button.Size = UDim2.fromOffset(150, 50)
button.BackgroundColor3 = Theme.Button
button.BorderSizePixel = 0
button.Font = Theme.Font
button.TextSize = 25
button.TextColor3 = Theme.Text
button.Text = "Anti-bag"
button.AutoButtonColor = false
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

button.MouseEnter:Connect(function()
	TweenService:Create(button, info,
		{BackgroundColor3 = Theme.Button:Lerp(Theme.Bg, 0.35), TextColor3 = Theme.Text}
	):Play()
end)

button.MouseLeave:Connect(function()
	TweenService:Create(button, info,
		{BackgroundColor3 = Theme.Bg, TextColor3 = Theme.Text}
	):Play()
end)

button.MouseButton1Down:Connect(function()
	TweenService:Create(button, info,
		{BackgroundColor3 = Theme.Text, TextColor3 = Theme.Bg}
	):Play()
end)

button.MouseButton1Click:Connect(function()
	TweenService:Create(button, info,
		{BackgroundColor3 = Theme.Button:Lerp(Theme.Bg, 0.35), TextColor3 = Theme.Text}
	):Play()
	enable()
end)
