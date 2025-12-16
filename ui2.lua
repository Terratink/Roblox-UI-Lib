-- EduUILibrary.lua
-- A simple educational Roblox UI Library
-- For learning purposes only - demonstrates basic GUI patterns
-- Returns a library table for modular use

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Helper: Create a draggable frame
local function makeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Create the main window
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Edu UI Library"
    local size = config.Size or UDim2.fromOffset(600, 400)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = size
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleLabel

    makeDraggable(mainFrame)

    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -90)
    contentFrame.Position = UDim2.new(0, 5, 0, 85)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Tabs = {},
    }

    function window:CreateTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = tabContainer
        tabButton.LayoutOrder = #window.Tabs + 1

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.ScrollBarThickness = 4
        tabContent.Visible = false
        tabContent.Parent = contentFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = tabContent

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        padding.Parent = tabContent

        local tab = {
            Button = tabButton,
            Content = tabContent,
            Elements = {},
        }

        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(window.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 160)
        end)

        if #window.Tabs == 0 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 160)
        end

        table.insert(window.Tabs, tab)

        -- Component creators for this tab
        function tab:Button(options)
            local text = options.Text or "Button"
            local callback = options.Callback or function() end

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = text
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamSemibold
            btn.Parent = tabContent

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(callback)

            return btn
        end

        function tab:Toggle(options)
            local text = options.Text or "Toggle"
            local default = options.Default or false
            local callback = options.Callback or function() end

            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 40)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            toggleFrame.Parent = tabContent

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 50, 0, 25)
            toggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
            toggleBtn.Text = ""
            toggleBtn.Parent = toggleFrame

            local toggleBtnCorner = Instance.new("UICorner")
            toggleBtnCorner.CornerRadius = UDim.new(0, 12)
            toggleBtnCorner.Parent = toggleBtn

            local state = default
            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)}):Play()
                callback(state)
            end)

            return {Update = function(newState) state = newState; toggleBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80) end}
        end

        function tab:Slider(options)
            local text = options.Text or "Slider"
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or 50
            local callback = options.Callback or function() end

            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 60)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderFrame.Parent = tabContent

            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 30)
            label.BackgroundTransparency = 1
            label.Text = text .. ": " .. default
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Parent = sliderFrame

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -20, 0, 10)
            bar.Position = UDim2.new(0, 10, 1, -20)
            bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            bar.Parent = sliderFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            fill.Parent = bar

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 5)
            fillCorner.Parent = fill

            local dragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativeX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * relativeX)
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    label.Text = text .. ": " .. value
                    callback(value)
                end
            end)

            return {Update = function(val) 
                local ratio = (val - min) / (max - min)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                label.Text = text .. ": " .. val
            end}
        end

        function tab:Dropdown(options)
            local text = options.Text or "Dropdown"
            local items = options.Items or {"Option 1", "Option 2"}
            local default = options.Default or items[1]
            local callback = options.Callback or function() end

            local dropFrame = Instance.new("Frame")
            dropFrame.Size = UDim2.new(1, 0, 0, 40)
            dropFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            dropFrame.Parent = tabContent

            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 6)
            dropCorner.Parent = dropFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = text .. ": " .. default
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Parent = dropFrame

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 30, 1, 0)
            arrow.Position = UDim2.new(1, -30, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Color3.new(1, 1, 1)
            arrow.Parent = dropFrame

            local open = false
            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(1, 0, 0, #items * 30)
            listFrame.Position = UDim2.new(0, 0, 1, 5)
            listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            listFrame.Visible = false
            listFrame.Parent = dropFrame

            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = listFrame

            for _, item in ipairs(items) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, 0, 0, 30)
                itemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                itemBtn.Text = item
                itemBtn.TextColor3 = Color3.new(1, 1, 1)
                itemBtn.Parent = listFrame

                itemBtn.MouseButton1Click:Connect(function()
                    label.Text = text .. ": " .. item
                    open = false
                    listFrame.Visible = false
                    callback(item)
                end)
            end

            dropFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    open = not open
                    listFrame.Visible = open
                end
            end)

            return {Update = function(newItem) label.Text = text .. ": " .. newItem end}
        end

        return tab
    end

    return window
end

return Library
