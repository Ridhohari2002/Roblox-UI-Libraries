--[[
    ========================================================================
    🎨 2D CARTOON UI LIBRARY FOR ROBLOX (GITHUB READY)
    ========================================================================
    Dirancang khusus untuk di-host di GitHub & dipanggil via:
    
    local CartoonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/UI%202D%20Cartoon.lua"))()

    local Window = CartoonUI.CreateWindow({
        Title = "Boyfinity HUB",
        Subtitle = "by ridho hari",
        Icon = "⚡",                          -- Emoji atau rbxassetid://
        ToggleKey = Enum.KeyCode.RightControl, -- Keybind minimize/buka
        Size = UDim2.new(0, 560, 0, 390),
        FloatButton = {
            Enabled = true,                    -- Tampilkan tombol melayang
            Icon = "🎮",
        },
        RightButtons = {                       -- Tombol tambahan di header (sebelah minimize/close)
            {
                Icon = "💬",
                Tooltip = "Discord",
                Color = Color3.fromRGB(114, 137, 218),
                Callback = function()
                    setclipboard("https://discord.gg/yourlink")
                end
            }
        }
    })
    ========================================================================
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Safe Parent Detection (CoreGui / gethui untuk Executor / fallback PlayerGui untuk Studio)
local function getSafeParent()
    local success, core = pcall(function()
        return (gethui and gethui()) or CoreGui
    end)
    if success and core then
        return core
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ========================================================================
-- TEMA WARNA & GAYA 2D CARTOON DEFAULT
-- ========================================================================
local DefaultTheme = {
    Background = Color3.fromRGB(246, 248, 255),
    Sidebar = Color3.fromRGB(235, 240, 255),
    CardBg = Color3.fromRGB(255, 255, 255),
    CardDark = Color3.fromRGB(240, 243, 250),
    
    Outline = Color3.fromRGB(35, 38, 56),      -- Line-art navy pekat
    Shadow = Color3.fromRGB(25, 28, 42),       -- Bayangan kartun
    
    Primary = Color3.fromRGB(255, 107, 107),   -- Coral Pink
    PrimaryDark = Color3.fromRGB(218, 77, 77),
    Secondary = Color3.fromRGB(78, 205, 196), -- Mint Cyan
    SecondaryDark = Color3.fromRGB(53, 163, 155),
    Yellow = Color3.fromRGB(255, 217, 61),    -- Sunshine Yellow
    YellowDark = Color3.fromRGB(224, 186, 38),
    Green = Color3.fromRGB(106, 222, 126),     -- Lime Green
    Purple = Color3.fromRGB(142, 108, 239),   -- Bubblegum Purple
    
    TextDark = Color3.fromRGB(35, 38, 56),
    TextMuted = Color3.fromRGB(120, 126, 150),
    TextLight = Color3.fromRGB(255, 255, 255),
    
    FontBold = Enum.Font.FredokaOne,
    FontRegular = Enum.Font.GothamBold,
}

local function mergeTheme(custom)
    local merged = {}
    for k, v in pairs(DefaultTheme) do
        merged[k] = v
    end
    if type(custom) == "table" then
        for k, v in pairs(custom) do
            merged[k] = v
        end
    end
    return merged
end

-- ========================================================================
-- HELPER UTILITIES
-- ========================================================================
local function tween(object, info, properties)
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

local function addCartoonStroke(object, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 2.5
    stroke.Color = color or DefaultTheme.Outline
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = object
    return stroke
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = object
    return corner
end

local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            })
        end
    end)
end

-- ========================================================================
-- CARTOON UI LIBRARY
-- ========================================================================
local CartoonUI = {}
CartoonUI.__index = CartoonUI

-- Custom Cursor Manager
local ActiveCustomCursor = nil
function CartoonUI.SetCursor(cursorConfig)
    if not cursorConfig then
        if ActiveCustomCursor then
            ActiveCustomCursor:Destroy()
            ActiveCustomCursor = nil
            UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
        end
        return
    end

    local cursorIcon = type(cursorConfig) == "string" and cursorConfig or (cursorConfig.Icon or "🎯")
    local cursorSize = (type(cursorConfig) == "table" and cursorConfig.Size) or 24
    local cursorColor = (type(cursorConfig) == "table" and cursorConfig.Color) or Color3.fromRGB(255, 217, 61)

    local parent = getSafeParent()
    if ActiveCustomCursor then
        ActiveCustomCursor:Destroy()
        ActiveCustomCursor = nil
    end

    local CursorGui = Instance.new("ScreenGui")
    CursorGui.Name = "CartoonUI_CustomCursor"
    CursorGui.ResetOnSpawn = false
    CursorGui.DisplayOrder = 99999
    CursorGui.Parent = parent

    local CursorLabel = Instance.new("TextLabel")
    CursorLabel.Size = UDim2.new(0, cursorSize, 0, cursorSize)
    CursorLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    CursorLabel.BackgroundTransparency = 1
    CursorLabel.Font = DefaultTheme.FontBold
    CursorLabel.Text = cursorIcon
    CursorLabel.TextSize = cursorSize
    CursorLabel.TextColor3 = cursorColor
    CursorLabel.ZIndex = 100000
    CursorLabel.Parent = CursorGui

    local conn = RunService.RenderStepped:Connect(function()
        if not CursorGui.Parent then return end
        local mousePos = UserInputService:GetMouseLocation()
        CursorLabel.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    end)

    CursorGui.Destroying:Connect(function()
        if conn then conn:Disconnect() end
    end)

    ActiveCustomCursor = CursorGui
    return CursorGui
end

function CartoonUI.CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Boyfinity HUB"
    local Subtitle = config.Subtitle or "by ridho hari"
    local WindowIcon = config.Icon or "⚡"
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local Size = config.Size or UDim2.new(0, 560, 0, 390)
    local Theme = mergeTheme(config.Theme)
    
    local floatConfig = config.FloatButton or {}
    local floatEnabled = (floatConfig.Enabled ~= false)
    local floatIcon = floatConfig.Icon or "🎮"
    local floatColor = floatConfig.Color or Theme.Yellow

    -- Hapus instance lama jika ada
    local guiName = "CartoonUI_" .. Title:gsub("%s+", "_")
    local parent = getSafeParent()
    if parent:FindFirstChild(guiName) then
        parent[guiName]:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = guiName
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = parent

    -- ========================================================================
    -- NOTIFICATION CONTAINER
    -- ========================================================================
    local notifContainer = Instance.new("Frame")
    notifContainer.Name = "NotificationContainer"
    notifContainer.Size = UDim2.new(0, 270, 0.7, 0)
    notifContainer.Position = UDim2.new(1, -290, 0, 20)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = ScreenGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Parent = notifContainer

    local function notify(titleText, msgText, duration, iconColor)
        duration = duration or 3
        iconColor = iconColor or Theme.Yellow

        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(1, 0, 0, 56)
        toast.BackgroundColor3 = Theme.CardBg
        toast.BorderSizePixel = 0
        addCorner(toast, 14)
        addCartoonStroke(toast, 2.5, Theme.Outline)

        local shadow = Instance.new("Frame")
        shadow.Size = UDim2.new(1, 0, 0, 6)
        shadow.Position = UDim2.new(0, 0, 1, -6)
        shadow.BackgroundColor3 = Theme.CardDark
        shadow.BorderSizePixel = 0
        addCorner(shadow, 14)
        shadow.Parent = toast

        local iconBadge = Instance.new("Frame")
        iconBadge.Size = UDim2.new(0, 36, 0, 36)
        iconBadge.Position = UDim2.new(0, 10, 0.5, -18)
        iconBadge.BackgroundColor3 = iconColor
        iconBadge.BorderSizePixel = 0
        addCorner(iconBadge, 10)
        addCartoonStroke(iconBadge, 2, Theme.Outline)
        iconBadge.Parent = toast

        local iconEmoji = Instance.new("TextLabel")
        iconEmoji.Size = UDim2.new(1, 0, 1, 0)
        iconEmoji.BackgroundTransparency = 1
        iconEmoji.Font = Theme.FontBold
        iconEmoji.Text = "★"
        iconEmoji.TextColor3 = Theme.Outline
        iconEmoji.TextSize = 20
        iconEmoji.Parent = iconBadge

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -60, 0, 18)
        tLabel.Position = UDim2.new(0, 54, 0, 8)
        tLabel.BackgroundTransparency = 1
        tLabel.Font = Theme.FontBold
        tLabel.Text = titleText or "Notifikasi"
        tLabel.TextColor3 = Theme.TextDark
        tLabel.TextSize = 14
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.Parent = toast

        local dLabel = Instance.new("TextLabel")
        dLabel.Size = UDim2.new(1, -60, 0, 18)
        dLabel.Position = UDim2.new(0, 54, 0, 26)
        dLabel.BackgroundTransparency = 1
        dLabel.Font = Theme.FontRegular
        dLabel.Text = msgText or ""
        dLabel.TextColor3 = Theme.TextMuted
        dLabel.TextSize = 12
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.Parent = toast

        toast.Parent = notifContainer
        toast.Size = UDim2.new(0, 0, 0, 56)
        tween(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 56)
        })

        task.delay(duration, function()
            if toast and toast.Parent then
                local t = tween(toast, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 56)
                })
                t.Completed:Connect(function()
                    toast:Destroy()
                end)
            end
        end)
    end

    -- ========================================================================
    -- TOOLTIP SYSTEM (CARTOON BUBBLE HOVER)
    -- ========================================================================
    local TooltipFrame = Instance.new("Frame")
    TooltipFrame.Name = "CartoonTooltip"
    TooltipFrame.Size = UDim2.new(0, 120, 0, 28)
    TooltipFrame.BackgroundColor3 = Theme.Outline
    TooltipFrame.BorderSizePixel = 0
    TooltipFrame.Visible = false
    TooltipFrame.ZIndex = 50000
    addCorner(TooltipFrame, 8)
    TooltipFrame.Parent = ScreenGui

    local TooltipLabel = Instance.new("TextLabel")
    TooltipLabel.Size = UDim2.new(1, -12, 1, 0)
    TooltipLabel.Position = UDim2.new(0, 6, 0, 0)
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.Font = Theme.FontRegular
    TooltipLabel.TextColor3 = Theme.TextLight
    TooltipLabel.TextSize = 11
    TooltipLabel.ZIndex = 50001
    TooltipLabel.TextXAlignment = Enum.TextXAlignment.Center
    TooltipLabel.Parent = TooltipFrame

    local function attachTooltip(guiObject, tooltipText)
        if not tooltipText or tooltipText == "" then return end
        local hoverConn
        guiObject.MouseEnter:Connect(function()
            TooltipLabel.Text = tooltipText
            local textBounds = TooltipLabel.TextBounds.X + 18
            TooltipFrame.Size = UDim2.new(0, math.clamp(textBounds, 70, 240), 0, 28)
            TooltipFrame.Visible = true

            if hoverConn then hoverConn:Disconnect() end
            hoverConn = RunService.RenderStepped:Connect(function()
                if not TooltipFrame.Visible then
                    if hoverConn then hoverConn:Disconnect() end
                    return
                end
                local mousePos = UserInputService:GetMouseLocation()
                TooltipFrame.Position = UDim2.new(0, mousePos.X + 14, 0, mousePos.Y + 12)
            end)
        end)
        guiObject.MouseLeave:Connect(function()
            TooltipFrame.Visible = false
            if hoverConn then
                hoverConn:Disconnect()
                hoverConn = nil
            end
        end)
    end

    -- ========================================================================
    -- MAIN WINDOW CONTAINER & SHADOW
    -- ========================================================================
    local MainShadow = Instance.new("Frame")
    MainShadow.Name = "MainShadow"
    MainShadow.Size = Size
    MainShadow.Position = UDim2.new(0.5, -Size.X.Offset / 2 + 6, 0.5, -Size.Y.Offset / 2 + 8)
    MainShadow.BackgroundColor3 = Theme.Outline
    MainShadow.BorderSizePixel = 0
    addCorner(MainShadow, 20)
    MainShadow.Parent = ScreenGui

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = Size
    MainWindow.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    MainWindow.BackgroundColor3 = Theme.Background
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = false
    addCorner(MainWindow, 18)
    addCartoonStroke(MainWindow, 3.5, Theme.Outline)
    MainWindow.Parent = ScreenGui

    MainWindow:GetPropertyChangedSignal("Position"):Connect(function()
        MainShadow.Position = UDim2.new(
            MainWindow.Position.X.Scale,
            MainWindow.Position.X.Offset + 6,
            MainWindow.Position.Y.Scale,
            MainWindow.Position.Y.Offset + 8
        )
    end)
    MainWindow:GetPropertyChangedSignal("Visible"):Connect(function()
        MainShadow.Visible = MainWindow.Visible
    end)

    makeDraggable(MainWindow)

    -- ========================================================================
    -- TOP HEADER BAR
    -- ========================================================================
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 54)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.BorderSizePixel = 0
    addCorner(Header, 18)
    Header.Parent = MainWindow

    local HeaderFix = Instance.new("Frame")
    HeaderFix.Size = UDim2.new(1, 0, 0, 14)
    HeaderFix.Position = UDim2.new(0, 0, 1, -14)
    HeaderFix.BackgroundColor3 = Theme.Sidebar
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Parent = Header

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 3)
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.BackgroundColor3 = Theme.Outline
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Header

    -- Logo Badge (Bisa Emoji atau Gambar Asset ID)
    local LogoBadge = Instance.new("Frame")
    LogoBadge.Size = UDim2.new(0, 36, 0, 36)
    LogoBadge.Position = UDim2.new(0, 12, 0.5, -18)
    LogoBadge.BackgroundColor3 = Theme.Yellow
    LogoBadge.BorderSizePixel = 0
    addCorner(LogoBadge, 10)
    addCartoonStroke(LogoBadge, 2.5, Theme.Outline)
    LogoBadge.Parent = Header

    if string.find(tostring(WindowIcon), "rbxasset") or tonumber(WindowIcon) then
        local LogoImg = Instance.new("ImageLabel")
        LogoImg.Size = UDim2.new(1, -6, 1, -6)
        LogoImg.Position = UDim2.new(0, 3, 0, 3)
        LogoImg.BackgroundTransparency = 1
        LogoImg.Image = tonumber(WindowIcon) and ("rbxassetid://" .. WindowIcon) or WindowIcon
        LogoImg.Parent = LogoBadge
    else
        local LogoEmoji = Instance.new("TextLabel")
        LogoEmoji.Size = UDim2.new(1, 0, 1, 0)
        LogoEmoji.BackgroundTransparency = 1
        LogoEmoji.Font = Theme.FontBold
        LogoEmoji.Text = tostring(WindowIcon)
        LogoEmoji.TextSize = 22
        LogoEmoji.TextColor3 = Theme.Outline
        LogoEmoji.Parent = LogoBadge
    end

    -- Title & Subtitle (Customizable: "Boyfinity HUB" & "by ridho hari")
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0, 240, 0, 22)
    TitleLabel.Position = UDim2.new(0, 56, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Theme.FontBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.TextDark
    TitleLabel.TextSize = 17
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "SubtitleLabel"
    SubtitleLabel.Size = UDim2.new(0, 240, 0, 16)
    SubtitleLabel.Position = UDim2.new(0, 56, 0, 28)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Theme.FontRegular
    SubtitleLabel.Text = Subtitle
    SubtitleLabel.TextColor3 = Theme.TextMuted
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = Header

    -- ========================================================================
    -- RIGHT SIDE BUTTONS CONTAINER
    -- ========================================================================
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 240, 0, 34)
    Controls.Position = UDim2.new(1, -250, 0.5, -17)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Header

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 6)
    ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlsLayout.Parent = Controls

    -- Helper pembuat Button Header Kartun
    local function createHeaderButton(iconText, color, hoverColor, callback, layoutOrder)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Font = Theme.FontBold
        btn.Text = iconText
        btn.TextColor3 = Theme.Outline
        btn.TextSize = 16
        btn.AutoButtonColor = false
        btn.LayoutOrder = layoutOrder or 10
        addCorner(btn, 10)
        addCartoonStroke(btn, 2.5, Theme.Outline)
        btn.Parent = Controls

        btn.MouseEnter:Connect(function()
            tween(btn, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 35, 0, 35),
                BackgroundColor3 = hoverColor
            })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 32, 0, 32),
                BackgroundColor3 = color
            })
        end)
        btn.MouseButton1Down:Connect(function()
            tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 28, 0, 28)
            })
        end)
        btn.MouseButton1Up:Connect(function()
            tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 32, 0, 32)
            })
        end)
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        return btn
    end

    -- ========================================================================
    -- MINIMIZE & VISIBILITY STATE
    -- ========================================================================
    local isMinimized = false
    local isWindowVisible = true
    local originalSize = Size
    local minimizedSize = UDim2.new(0, Size.X.Offset, 0, 54)

    local MinBtn, CloseBtn

    local function setMinimized(minimize)
        isMinimized = minimize
        if isMinimized then
            tween(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
                Size = minimizedSize
            })
            tween(MainShadow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
                Size = minimizedSize
            })
            if MinBtn then MinBtn.Text = "＋" end
            notify("UI Dikecilkan", "Klik tombol ＋ atau tombol melayang untuk membuka", 2.5, Theme.Yellow)
        else
            tween(MainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = originalSize
            })
            tween(MainShadow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = originalSize
            })
            if MinBtn then MinBtn.Text = "—" end
        end
    end

    local function toggleWindowVisibility()
        isWindowVisible = not isWindowVisible
        if isWindowVisible then
            MainWindow.Visible = true
            MainShadow.Visible = true
            MainWindow.Size = UDim2.new(0, 0, 0, 0)
            local targetSize = isMinimized and minimizedSize or originalSize
            tween(MainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = targetSize
            })
            tween(MainShadow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = targetSize
            })
        else
            local t = tween(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            tween(MainShadow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            t.Completed:Connect(function()
                if not isWindowVisible then
                    MainWindow.Visible = false
                    MainShadow.Visible = false
                end
            end)
        end
    end

    -- ========================================================================
    -- CUSTOM RIGHT SIDE BUTTONS DARI CONFIG
    -- ========================================================================
    if type(config.RightButtons) == "table" then
        for i, btnData in ipairs(config.RightButtons) do
            local bColor = btnData.Color or Theme.Secondary
            local bHover = btnData.HoverColor or Color3.fromRGB(110, 225, 218)
            local hBtn = createHeaderButton(btnData.Icon or "★", bColor, bHover, function()
                if btnData.Callback then
                    btnData.Callback()
                end
            end, i)
            if btnData.Tooltip then
                attachTooltip(hBtn, btnData.Tooltip)
            end
        end
    end

    -- Tombol Minimize & Close Default di Ujung Kanan
    MinBtn = createHeaderButton("—", Theme.Yellow, Color3.fromRGB(255, 235, 120), function()
        setMinimized(not isMinimized)
    end, 98)

    CloseBtn = createHeaderButton("✕", Theme.Primary, Color3.fromRGB(255, 130, 130), function()
        toggleWindowVisibility()
        notify("UI Ditutup", "Buka kembali dengan tombol melayang atau tombol keybind", 3, Theme.Primary)
    end, 99)

    -- ========================================================================
    -- FLOATING BUTTON (DRAGGABLE & BOUNCY)
    -- ========================================================================
    local FloatBtn = Instance.new("ImageButton")
    FloatBtn.Name = "FloatButton"
    FloatBtn.Size = UDim2.new(0, 54, 0, 54)
    FloatBtn.Position = floatConfig.Position or UDim2.new(0, 25, 0.5, -27)
    FloatBtn.BackgroundColor3 = floatColor
    FloatBtn.BorderSizePixel = 0
    FloatBtn.AutoButtonColor = false
    FloatBtn.Visible = floatEnabled
    addCorner(FloatBtn, 27)
    addCartoonStroke(FloatBtn, 3, Theme.Outline)
    FloatBtn.Parent = ScreenGui

    local FloatShadow = Instance.new("Frame")
    FloatShadow.Name = "FloatShadow"
    FloatShadow.Size = UDim2.new(0, 54, 0, 54)
    FloatShadow.Position = UDim2.new(
        FloatBtn.Position.X.Scale,
        FloatBtn.Position.X.Offset + 4,
        FloatBtn.Position.Y.Scale,
        FloatBtn.Position.Y.Offset + 4
    )
    FloatShadow.BackgroundColor3 = Theme.Outline
    FloatShadow.BorderSizePixel = 0
    addCorner(FloatShadow, 27)
    FloatShadow.Parent = ScreenGui
    FloatShadow.ZIndex = FloatBtn.ZIndex - 1

    FloatBtn:GetPropertyChangedSignal("Position"):Connect(function()
        FloatShadow.Position = UDim2.new(
            FloatBtn.Position.X.Scale,
            FloatBtn.Position.X.Offset + 4,
            FloatBtn.Position.Y.Scale,
            FloatBtn.Position.Y.Offset + 4
        )
    end)
    FloatBtn:GetPropertyChangedSignal("Visible"):Connect(function()
        FloatShadow.Visible = FloatBtn.Visible
    end)

    local FloatIcon = Instance.new("TextLabel")
    FloatIcon.Size = UDim2.new(1, 0, 1, 0)
    FloatIcon.BackgroundTransparency = 1
    FloatIcon.Font = Theme.FontBold
    FloatIcon.Text = tostring(floatIcon)
    FloatIcon.TextSize = 26
    FloatIcon.TextColor3 = Theme.Outline
    FloatIcon.Parent = FloatBtn

    makeDraggable(FloatBtn)

    FloatBtn.MouseEnter:Connect(function()
        tween(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 60, 0, 60)
        })
    end)
    FloatBtn.MouseLeave:Connect(function()
        tween(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 54, 0, 54)
        })
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        if not isWindowVisible then
            toggleWindowVisibility()
        elseif isMinimized then
            setMinimized(false)
        else
            setMinimized(true)
        end
    end)

    -- ========================================================================
    -- CUSTOM KEYBIND SYSTEM
    -- ========================================================================
    local currentKeybind = ToggleKey

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == currentKeybind then
            toggleWindowVisibility()
        end
    end)

    -- ========================================================================
    -- BODY (SIDEBAR TABS & PAGES CONTAINER)
    -- ========================================================================
    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1, 0, 1, -54)
    Body.Position = UDim2.new(0, 0, 0, 54)
    Body.BackgroundTransparency = 1
    Body.ClipsDescendants = true
    Body.Parent = MainWindow

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Body

    local SidebarCornerFix = Instance.new("Frame")
    SidebarCornerFix.Size = UDim2.new(0, 18, 0, 18)
    SidebarCornerFix.Position = UDim2.new(0, 0, 1, -18)
    SidebarCornerFix.BackgroundColor3 = Theme.Sidebar
    SidebarCornerFix.BorderSizePixel = 0
    addCorner(SidebarCornerFix, 18)
    SidebarCornerFix.Parent = Sidebar

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 3, 1, 0)
    SidebarDivider.Position = UDim2.new(1, -3, 0, 0)
    SidebarDivider.BackgroundColor3 = Theme.Outline
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -8, 1, -16)
    TabScroll.Position = UDim2.new(0, 4, 0, 8)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 3
    TabScroll.ScrollBarImageColor3 = Theme.Outline
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Size = UDim2.new(1, -158, 1, -16)
    PagesContainer.Position = UDim2.new(0, 154, 0, 8)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = Body

    -- ========================================================================
    -- WINDOW OBJECT & API
    -- ========================================================================
    local WindowHandler = {
        CurrentTab = nil,
        Tabs = {},
        ScreenGui = ScreenGui,
        MainWindow = MainWindow,
        FloatButton = FloatBtn
    }

    function WindowHandler:SetTitle(newTitle)
        TitleLabel.Text = newTitle
    end

    function WindowHandler:SetSubtitle(newSubtitle)
        SubtitleLabel.Text = newSubtitle
    end

    function WindowHandler:SetToggleKey(newKey)
        currentKeybind = newKey
        notify("Keybind Diubah", "Keybind baru: " .. newKey.Name, 3, Theme.Green)
    end

    function WindowHandler:GetToggleKey()
        return currentKeybind
    end

    function WindowHandler:Notify(titleText, msgText, duration, color)
        notify(titleText, msgText, duration, color)
    end

    function WindowHandler:ToggleFloatButton(visible)
        FloatBtn.Visible = visible
    end

    function WindowHandler:Toggle()
        toggleWindowVisibility()
    end

    function WindowHandler:Minimize(bool)
        setMinimized(bool)
    end

    function WindowHandler:AddHeaderButton(iconText, callback, color, tooltipText)
        local btn = createHeaderButton(iconText, color or Theme.Secondary, Color3.fromRGB(110, 225, 218), callback, 50)
        if tooltipText then
            attachTooltip(btn, tooltipText)
        end
        return btn
    end

    function WindowHandler:AttachTooltip(guiObject, tooltipText)
        attachTooltip(guiObject, tooltipText)
    end

    function WindowHandler:SetCursor(cursorConfig)
        return CartoonUI.SetCursor(cursorConfig)
    end

    function WindowHandler:Destroy()
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end

    -- ========================================================================
    -- POP-UP UI: ACTIVE CARDS SCANNER & STEALER
    -- ========================================================================
    function WindowHandler:CreateCardsPopup(popupConfig)
        popupConfig = popupConfig or {}
        local popupTitle = popupConfig.Title or "Active Cards Stealer"
        local cardsFolder = popupConfig.CardsFolder or workspace:FindFirstChild("ActiveCards") or workspace
        local onStealCallback = popupConfig.OnSteal or function(card, isStealing, data) end
        local onCardClick = popupConfig.OnCardClick or function(card, data) end
        local customRarities = popupConfig.Rarities or {"All", "Divine", "Mythic", "Legendary", "Epic", "Rare", "Common"}

        local RarityInfo = {
            ["Divine"] = { Color = Color3.fromRGB(255, 215, 0), Dark = Color3.fromRGB(210, 165, 0), Icon = "👑" },
            ["Mythic"] = { Color = Color3.fromRGB(255, 65, 115), Dark = Color3.fromRGB(200, 40, 85), Icon = "🔥" },
            ["Legendary"] = { Color = Color3.fromRGB(255, 155, 45), Dark = Color3.fromRGB(210, 115, 20), Icon = "⚡" },
            ["Epic"] = { Color = Color3.fromRGB(165, 95, 255), Dark = Color3.fromRGB(125, 60, 210), Icon = "🔮" },
            ["Rare"] = { Color = Color3.fromRGB(50, 195, 255), Dark = Color3.fromRGB(25, 150, 210), Icon = "💎" },
            ["Common"] = { Color = Color3.fromRGB(160, 175, 195), Dark = Color3.fromRGB(120, 135, 155), Icon = "⚪" },
            ["Default"] = { Color = Color3.fromRGB(142, 108, 239), Dark = Color3.fromRGB(114, 82, 204), Icon = "★" }
        }

        local function getRarity(rarityName)
            if not rarityName then return RarityInfo["Default"] end
            for k, v in pairs(RarityInfo) do
                if string.lower(k) == string.lower(tostring(rarityName)) then
                    return v
                end
            end
            return RarityInfo["Default"]
        end

        local popupSize = UDim2.new(0, 520, 0, 440)
        local isPopupOpen = false
        local activeRarityFilter = "All"
        local searchKeyword = ""
        local activeStealMap = {} -- [cardInstance] = boolean

        -- Bayangan Pop-up
        local PopupShadow = Instance.new("Frame")
        PopupShadow.Name = "CardsPopupShadow"
        PopupShadow.Size = popupSize
        PopupShadow.Position = UDim2.new(0.5, -popupSize.X.Offset / 2 + 6, 0.5, -popupSize.Y.Offset / 2 + 8)
        PopupShadow.BackgroundColor3 = Theme.Outline
        PopupShadow.BorderSizePixel = 0
        PopupShadow.Visible = false
        addCorner(PopupShadow, 20)
        PopupShadow.Parent = ScreenGui

        -- Frame Pop-up Utama
        local PopupFrame = Instance.new("Frame")
        PopupFrame.Name = "CardsPopupFrame"
        PopupFrame.Size = popupSize
        PopupFrame.Position = UDim2.new(0.5, -popupSize.X.Offset / 2, 0.5, -popupSize.Y.Offset / 2)
        PopupFrame.BackgroundColor3 = Theme.Background
        PopupFrame.BorderSizePixel = 0
        PopupFrame.Visible = false
        PopupFrame.ClipsDescendants = false
        addCorner(PopupFrame, 18)
        addCartoonStroke(PopupFrame, 3.5, Theme.Outline)
        PopupFrame.Parent = ScreenGui

        PopupFrame:GetPropertyChangedSignal("Position"):Connect(function()
            PopupShadow.Position = UDim2.new(
                PopupFrame.Position.X.Scale,
                PopupFrame.Position.X.Offset + 6,
                PopupFrame.Position.Y.Scale,
                PopupFrame.Position.Y.Offset + 8
            )
        end)
        PopupFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            PopupShadow.Visible = PopupFrame.Visible
        end)

        makeDraggable(PopupFrame)

        -- Header Pop-up
        local PopHeader = Instance.new("Frame")
        PopHeader.Size = UDim2.new(1, 0, 0, 52)
        PopHeader.BackgroundColor3 = Theme.Sidebar
        PopHeader.BorderSizePixel = 0
        addCorner(PopHeader, 18)
        PopHeader.Parent = PopupFrame

        local PopHeaderFix = Instance.new("Frame")
        PopHeaderFix.Size = UDim2.new(1, 0, 0, 14)
        PopHeaderFix.Position = UDim2.new(0, 0, 1, -14)
        PopHeaderFix.BackgroundColor3 = Theme.Sidebar
        PopHeaderFix.BorderSizePixel = 0
        PopHeaderFix.Parent = PopHeader

        local PopHeaderLine = Instance.new("Frame")
        PopHeaderLine.Size = UDim2.new(1, 0, 0, 3)
        PopHeaderLine.Position = UDim2.new(0, 0, 1, 0)
        PopHeaderLine.BackgroundColor3 = Theme.Outline
        PopHeaderLine.BorderSizePixel = 0
        PopHeaderLine.Parent = PopHeader

        local PopLogoBadge = Instance.new("Frame")
        PopLogoBadge.Size = UDim2.new(0, 34, 0, 34)
        PopLogoBadge.Position = UDim2.new(0, 12, 0.5, -17)
        PopLogoBadge.BackgroundColor3 = Theme.Purple
        PopLogoBadge.BorderSizePixel = 0
        addCorner(PopLogoBadge, 10)
        addCartoonStroke(PopLogoBadge, 2, Theme.Outline)
        PopLogoBadge.Parent = PopHeader

        local PopLogoEmoji = Instance.new("TextLabel")
        PopLogoEmoji.Size = UDim2.new(1, 0, 1, 0)
        PopLogoEmoji.BackgroundTransparency = 1
        PopLogoEmoji.Font = Theme.FontBold
        PopLogoEmoji.Text = "🃏"
        PopLogoEmoji.TextSize = 20
        PopLogoEmoji.Parent = PopLogoBadge

        local PopTitle = Instance.new("TextLabel")
        PopTitle.Size = UDim2.new(0, 220, 0, 20)
        PopTitle.Position = UDim2.new(0, 54, 0, 8)
        PopTitle.BackgroundTransparency = 1
        PopTitle.Font = Theme.FontBold
        PopTitle.Text = popupTitle
        PopTitle.TextColor3 = Theme.TextDark
        PopTitle.TextSize = 16
        PopTitle.TextXAlignment = Enum.TextXAlignment.Left
        PopTitle.Parent = PopHeader

        local PopCardCount = Instance.new("TextLabel")
        PopCardCount.Size = UDim2.new(0, 220, 0, 16)
        PopCardCount.Position = UDim2.new(0, 54, 0, 28)
        PopCardCount.BackgroundTransparency = 1
        PopCardCount.Font = Theme.FontRegular
        PopCardCount.Text = "0 Cards Active"
        PopCardCount.TextColor3 = Theme.TextMuted
        PopCardCount.TextSize = 11
        PopCardCount.TextXAlignment = Enum.TextXAlignment.Left
        PopCardCount.Parent = PopHeader

        -- Tombol Refresh & Close di Header Pop-up
        local PopControls = Instance.new("Frame")
        PopControls.Size = UDim2.new(0, 80, 0, 32)
        PopControls.Position = UDim2.new(1, -90, 0.5, -16)
        PopControls.BackgroundTransparency = 1
        PopControls.Parent = PopHeader

        local PopControlsLayout = Instance.new("UIListLayout")
        PopControlsLayout.FillDirection = Enum.FillDirection.Horizontal
        PopControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        PopControlsLayout.Padding = UDim.new(0, 6)
        PopControlsLayout.Parent = PopControls

        local RefreshBtn = Instance.new("TextButton")
        RefreshBtn.Size = UDim2.new(0, 32, 0, 32)
        RefreshBtn.BackgroundColor3 = Theme.Secondary
        RefreshBtn.Font = Theme.FontBold
        RefreshBtn.Text = "🔄"
        RefreshBtn.TextSize = 16
        RefreshBtn.AutoButtonColor = false
        addCorner(RefreshBtn, 10)
        addCartoonStroke(RefreshBtn, 2, Theme.Outline)
        RefreshBtn.Parent = PopControls

        local PopCloseBtn = Instance.new("TextButton")
        PopCloseBtn.Size = UDim2.new(0, 32, 0, 32)
        PopCloseBtn.BackgroundColor3 = Theme.Primary
        PopCloseBtn.Font = Theme.FontBold
        PopCloseBtn.Text = "✕"
        PopCloseBtn.TextColor3 = Color3.new(1, 1, 1)
        PopCloseBtn.TextSize = 16
        PopCloseBtn.AutoButtonColor = false
        addCorner(PopCloseBtn, 10)
        addCartoonStroke(PopCloseBtn, 2, Theme.Outline)
        PopCloseBtn.Parent = PopControls

        -- Filter & Search Area
        local FilterSection = Instance.new("Frame")
        FilterSection.Size = UDim2.new(1, -24, 0, 72)
        FilterSection.Position = UDim2.new(0, 12, 0, 60)
        FilterSection.BackgroundTransparency = 1
        FilterSection.Parent = PopupFrame

        -- Row 1: Rarity Filter Pills (Scrollable)
        local RarityScroll = Instance.new("ScrollingFrame")
        RarityScroll.Size = UDim2.new(1, 0, 0, 32)
        RarityScroll.Position = UDim2.new(0, 0, 0, 0)
        RarityScroll.BackgroundTransparency = 1
        RarityScroll.ScrollBarThickness = 0
        RarityScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        RarityScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
        RarityScroll.Parent = FilterSection

        local RarityLayout = Instance.new("UIListLayout")
        RarityLayout.FillDirection = Enum.FillDirection.Horizontal
        RarityLayout.Padding = UDim.new(0, 6)
        RarityLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RarityLayout.Parent = RarityScroll

        -- Row 2: Search Input
        local SearchBox = Instance.new("TextBox")
        SearchBox.Size = UDim2.new(1, 0, 0, 32)
        SearchBox.Position = UDim2.new(0, 0, 0, 38)
        SearchBox.BackgroundColor3 = Theme.CardBg
        SearchBox.BorderSizePixel = 0
        SearchBox.Font = Theme.FontRegular
        SearchBox.PlaceholderText = "🔍 Cari nama kartu (contoh: Puskas)..."
        SearchBox.PlaceholderColor3 = Theme.TextMuted
        SearchBox.Text = ""
        SearchBox.TextColor3 = Theme.TextDark
        SearchBox.TextSize = 12
        SearchBox.ClearTextOnFocus = false
        addCorner(SearchBox, 10)
        local searchStroke = addCartoonStroke(SearchBox, 2, Theme.Outline)
        SearchBox.Parent = FilterSection

        SearchBox.Focused:Connect(function()
            tween(searchStroke, TweenInfo.new(0.2), { Color = Theme.Primary, Thickness = 2.5 })
        end)
        SearchBox.FocusLost:Connect(function()
            tween(searchStroke, TweenInfo.new(0.2), { Color = Theme.Outline, Thickness = 2 })
        end)

        -- Container List Kartu (Cards Scroll)
        local CardsScroll = Instance.new("ScrollingFrame")
        CardsScroll.Name = "CardsScroll"
        CardsScroll.Size = UDim2.new(1, -24, 1, -144)
        CardsScroll.Position = UDim2.new(0, 12, 0, 136)
        CardsScroll.BackgroundTransparency = 1
        CardsScroll.BorderSizePixel = 0
        CardsScroll.ScrollBarThickness = 5
        CardsScroll.ScrollBarImageColor3 = Theme.Outline
        CardsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        CardsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        CardsScroll.Parent = PopupFrame

        local CardsLayout = Instance.new("UIListLayout")
        CardsLayout.Padding = UDim.new(0, 8)
        CardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        CardsLayout.Parent = CardsScroll

        local CardsPadding = Instance.new("UIPadding")
        CardsPadding.PaddingBottom = UDim.new(0, 10)
        CardsPadding.Parent = CardsScroll

        local filterButtons = {}
        local renderCardsList

        -- Inisialisasi Filter Pills
        for i, rarityName in ipairs(customRarities) do
            local rInfo = getRarity(rarityName)
            local pill = Instance.new("TextButton")
            pill.Size = UDim2.new(0, 80, 0, 30)
            pill.BackgroundColor3 = (rarityName == "All") and Theme.Yellow or Theme.CardBg
            pill.BorderSizePixel = 0
            pill.AutoButtonColor = false
            pill.Font = Theme.FontBold
            pill.Text = (rarityName == "All" and "🌈 All" or (rInfo.Icon .. " " .. rarityName))
            pill.TextColor3 = Theme.TextDark
            pill.TextSize = 11
            pill.LayoutOrder = i
            addCorner(pill, 8)
            local pillStroke = addCartoonStroke(pill, 1.8, Theme.Outline)
            pill.Parent = RarityScroll

            filterButtons[rarityName] = { Button = pill, Stroke = pillStroke, Info = rInfo }

            pill.MouseButton1Click:Connect(function()
                activeRarityFilter = rarityName
                for name, data in pairs(filterButtons) do
                    if name == activeRarityFilter then
                        tween(data.Button, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Yellow })
                        data.Stroke.Thickness = 2.5
                    else
                        tween(data.Button, TweenInfo.new(0.2), { BackgroundColor3 = Theme.CardBg })
                        data.Stroke.Thickness = 1.8
                    end
                end
                renderCardsList()
            end)
        end

        -- Fungsi Render Card Item
        renderCardsList = function()
            for _, child in pairs(CardsScroll:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            local children = {}
            if cardsFolder and cardsFolder.Parent then
                local success, items = pcall(function() return cardsFolder:GetChildren() end)
                if success and items then
                    children = items
                end
            end

            local matchCount = 0
            local totalCount = #children

            for _, card in ipairs(children) do
                local displayName = card:GetAttribute("DisplayName") or card.Name
                local originalName = card:GetAttribute("OriginalName") or displayName
                local rarity = card:GetAttribute("Rarity") or "Common"
                local level = card:GetAttribute("Level") or 1
                local mutation = card:GetAttribute("Mutation") or "Normal"

                local passRarity = (activeRarityFilter == "All") or (string.lower(rarity) == string.lower(activeRarityFilter))
                local passKeyword = true
                if searchKeyword ~= "" then
                    local kw = string.lower(searchKeyword)
                    passKeyword = string.find(string.lower(displayName), kw) or string.find(string.lower(originalName), kw) or string.find(string.lower(rarity), kw)
                end

                if passRarity and passKeyword then
                    matchCount = matchCount + 1
                    local rInfo = getRarity(rarity)

                    local CardRow = Instance.new("Frame")
                    CardRow.Name = "Card_" .. displayName
                    CardRow.Size = UDim2.new(1, 0, 0, 60)
                    CardRow.BackgroundColor3 = Theme.CardBg
                    CardRow.BorderSizePixel = 0
                    addCorner(CardRow, 12)
                    addCartoonStroke(CardRow, 2, Theme.Outline)
                    CardRow.Parent = CardsScroll

                    local rowShadow = Instance.new("Frame")
                    rowShadow.Size = UDim2.new(1, 0, 0, 4)
                    rowShadow.Position = UDim2.new(0, 0, 1, -4)
                    rowShadow.BackgroundColor3 = Theme.CardDark
                    rowShadow.BorderSizePixel = 0
                    addCorner(rowShadow, 12)
                    rowShadow.Parent = CardRow

                    local IconBox = Instance.new("Frame")
                    IconBox.Size = UDim2.new(0, 42, 0, 42)
                    IconBox.Position = UDim2.new(0, 8, 0.5, -21)
                    IconBox.BackgroundColor3 = rInfo.Color
                    IconBox.BorderSizePixel = 0
                    addCorner(IconBox, 10)
                    addCartoonStroke(IconBox, 1.8, Theme.Outline)
                    IconBox.Parent = CardRow

                    local IconText = Instance.new("TextLabel")
                    IconText.Size = UDim2.new(1, 0, 0.6, 0)
                    IconText.BackgroundTransparency = 1
                    IconText.Font = Theme.FontBold
                    IconText.Text = rInfo.Icon
                    IconText.TextSize = 18
                    IconText.Parent = IconBox

                    local LvBadge = Instance.new("TextLabel")
                    LvBadge.Size = UDim2.new(1, 0, 0.4, 0)
                    LvBadge.Position = UDim2.new(0, 0, 0.6, 0)
                    LvBadge.BackgroundTransparency = 1
                    LvBadge.Font = Theme.FontBold
                    LvBadge.Text = "Lv." .. tostring(level)
                    LvBadge.TextColor3 = Theme.Outline
                    LvBadge.TextSize = 10
                    LvBadge.Parent = IconBox

                    local NameLabel = Instance.new("TextLabel")
                    NameLabel.Size = UDim2.new(0.48, 0, 0, 20)
                    NameLabel.Position = UDim2.new(0, 58, 0, 9)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Font = Theme.FontBold
                    NameLabel.Text = displayName
                    NameLabel.TextColor3 = Theme.TextDark
                    NameLabel.TextSize = 14
                    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    NameLabel.Parent = CardRow

                    local SubLabel = Instance.new("TextLabel")
                    SubLabel.Size = UDim2.new(0.48, 0, 0, 16)
                    SubLabel.Position = UDim2.new(0, 58, 0, 31)
                    SubLabel.BackgroundTransparency = 1
                    SubLabel.Font = Theme.FontRegular
                    SubLabel.Text = rarity .. " • " .. mutation
                    SubLabel.TextColor3 = Theme.TextMuted
                    SubLabel.TextSize = 11
                    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SubLabel.Parent = CardRow

                    local RarityPill = Instance.new("TextLabel")
                    RarityPill.Size = UDim2.new(0, 75, 0, 20)
                    RarityPill.Position = UDim2.new(1, -195, 0.5, -10)
                    RarityPill.BackgroundColor3 = rInfo.Color
                    RarityPill.BorderSizePixel = 0
                    RarityPill.Font = Theme.FontBold
                    RarityPill.Text = rarity
                    RarityPill.TextColor3 = Theme.Outline
                    RarityPill.TextSize = 10
                    addCorner(RarityPill, 6)
                    addCartoonStroke(RarityPill, 1.5, Theme.Outline)
                    RarityPill.Parent = CardRow

                    local isStealing = activeStealMap[card] or false

                    local StealBtnContainer = Instance.new("Frame")
                    StealBtnContainer.Size = UDim2.new(0, 105, 0, 36)
                    StealBtnContainer.Position = UDim2.new(1, -114, 0.5, -18)
                    StealBtnContainer.BackgroundTransparency = 1
                    StealBtnContainer.Parent = CardRow

                    local StealBtnShadow = Instance.new("Frame")
                    StealBtnShadow.Size = UDim2.new(1, 0, 0, 32)
                    StealBtnShadow.Position = UDim2.new(0, 0, 0, 4)
                    StealBtnShadow.BackgroundColor3 = Theme.Outline
                    StealBtnShadow.BorderSizePixel = 0
                    addCorner(StealBtnShadow, 10)
                    StealBtnShadow.Parent = StealBtnContainer

                    local StealBtn = Instance.new("TextButton")
                    StealBtn.Size = UDim2.new(1, 0, 0, 32)
                    StealBtn.BackgroundColor3 = isStealing and Theme.Primary or Theme.Secondary
                    StealBtn.BorderSizePixel = 0
                    StealBtn.AutoButtonColor = false
                    StealBtn.Font = Theme.FontBold
                    StealBtn.Text = isStealing and "STEALING..." or "STEAL"
                    StealBtn.TextColor3 = isStealing and Color3.new(1, 1, 1) or Theme.Outline
                    StealBtn.TextSize = 12
                    addCorner(StealBtn, 10)
                    addCartoonStroke(StealBtn, 2, Theme.Outline)
                    StealBtn.Parent = StealBtnContainer

                    StealBtn.MouseButton1Click:Connect(function()
                        isStealing = not isStealing
                        activeStealMap[card] = isStealing

                        if isStealing then
                            tween(StealBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Primary })
                            StealBtn.Text = "STEALING..."
                            StealBtn.TextColor3 = Color3.new(1, 1, 1)
                            notify("Steal Dimulai", "Mencuri kartu: " .. displayName, 2, Theme.Primary)
                        else
                            tween(StealBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Secondary })
                            StealBtn.Text = "STEAL"
                            StealBtn.TextColor3 = Theme.Outline
                            notify("Steal Berhenti", "Berhenti mencuri: " .. displayName, 2, Theme.Secondary)
                        end

                        pcall(onStealCallback, card, isStealing, {
                            DisplayName = displayName,
                            OriginalName = originalName,
                            Rarity = rarity,
                            Level = level,
                            Mutation = mutation
                        })
                    end)
                end
            end

            PopCardCount.Text = tostring(matchCount) .. " Cards (" .. tostring(totalCount) .. " Total di Game)"
        end

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            searchKeyword = SearchBox.Text
            renderCardsList()
        end)

        RefreshBtn.MouseButton1Click:Connect(function()
            renderCardsList()
            notify("Cards Refreshed", "Daftar kartu aktif berhasil diperbarui!", 2, Theme.Secondary)
        end)

        if cardsFolder and cardsFolder.Parent then
            cardsFolder.ChildAdded:Connect(function()
                if isPopupOpen then
                    task.delay(0.1, renderCardsList)
                end
            end)
            cardsFolder.ChildRemoved:Connect(function(removedChild)
                activeStealMap[removedChild] = nil
                if isPopupOpen then
                    task.delay(0.1, renderCardsList)
                end
            end)
        end

        local function openPopup()
            isPopupOpen = true
            PopupFrame.Visible = true
            PopupShadow.Visible = true
            PopupFrame.Size = UDim2.new(0, 0, 0, 0)
            PopupShadow.Size = UDim2.new(0, 0, 0, 0)

            tween(PopupFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = popupSize
            })
            tween(PopupShadow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = popupSize
            })
            renderCardsList()
        end

        local function closePopup()
            isPopupOpen = false
            local t = tween(PopupFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            tween(PopupShadow, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            t.Completed:Connect(function()
                if not isPopupOpen then
                    PopupFrame.Visible = false
                    PopupShadow.Visible = false
                end
            end)
        end

        PopCloseBtn.MouseButton1Click:Connect(closePopup)

        return {
            Open = openPopup,
            Close = closePopup,
            Toggle = function()
                if isPopupOpen then closePopup() else openPopup() end
            end,
            Refresh = renderCardsList,
            IsOpen = function() return isPopupOpen end,
            GetActiveSteals = function() return activeStealMap end
        }
    end

    -- ========================================================================
    -- TAB CREATION
    -- ========================================================================
    function WindowHandler:CreateTab(tabName, iconEmoji)
        tabName = tabName or "Tab"
        iconEmoji = iconEmoji or "📁"

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Size = UDim2.new(0.92, 0, 0, 40)
        TabBtn.BackgroundColor3 = Theme.CardBg
        TabBtn.BorderSizePixel = 0
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        addCorner(TabBtn, 12)
        local tabStroke = addCartoonStroke(TabBtn, 2, Theme.Outline)
        TabBtn.Parent = TabScroll

        local TabIcon = Instance.new("TextLabel")
        TabIcon.Size = UDim2.new(0, 24, 1, 0)
        TabIcon.Position = UDim2.new(0, 8, 0, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Font = Theme.FontBold
        TabIcon.Text = iconEmoji
        TabIcon.TextSize = 18
        TabIcon.TextColor3 = Theme.Outline
        TabIcon.Parent = TabBtn

        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, -38, 1, 0)
        TabText.Position = UDim2.new(0, 34, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Theme.FontBold
        TabText.Text = tabName
        TabText.TextColor3 = Theme.TextDark
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = "Page_" .. tabName
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Theme.Outline
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = PagesContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 6)
        PagePadding.PaddingBottom = UDim.new(0, 14)
        PagePadding.PaddingLeft = UDim.new(0, 6)
        PagePadding.PaddingRight = UDim.new(0, 8)
        PagePadding.Parent = Page

        local TabData = {
            Button = TabBtn,
            Page = Page
        }

        local function activateTab()
            for _, t in pairs(WindowHandler.Tabs) do
                t.Page.Visible = false
                tween(t.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.CardBg
                })
                t.Button:FindFirstChildWhichIsA("UIStroke").Color = Theme.Outline
                t.Button:FindFirstChildWhichIsA("UIStroke").Thickness = 2
            end
            Page.Visible = true
            WindowHandler.CurrentTab = TabData

            tween(TabBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundColor3 = Theme.Yellow
            })
            tabStroke.Thickness = 3
        end

        TabBtn.MouseButton1Click:Connect(activateTab)

        TabBtn.MouseEnter:Connect(function()
            if WindowHandler.CurrentTab ~= TabData then
                tween(TabBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Theme.CardDark
                })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowHandler.CurrentTab ~= TabData then
                tween(TabBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Theme.CardBg
                })
            end
        end)

        table.insert(WindowHandler.Tabs, TabData)

        if #WindowHandler.Tabs == 1 then
            activateTab()
        end

        local TabElements = {}

        -- 1. SECTION
        function TabElements:CreateSection(sectionText)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 26)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Page

            local SecLabel = Instance.new("TextLabel")
            SecLabel.Size = UDim2.new(1, 0, 1, 0)
            SecLabel.BackgroundTransparency = 1
            SecLabel.Font = Theme.FontBold
            SecLabel.Text = "★  " .. string.upper(sectionText)
            SecLabel.TextColor3 = Theme.Purple
            SecLabel.TextSize = 13
            SecLabel.TextXAlignment = Enum.TextXAlignment.Left
            SecLabel.Parent = SecFrame
            return SecFrame
        end

        -- 2. BUTTON (WITH 2D PUSH SHADOW)
        function TabElements:CreateButton(btnText, callback)
            callback = callback or function() end

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 44)
            Container.BackgroundTransparency = 1
            Container.Parent = Page

            local BtnShadow = Instance.new("Frame")
            BtnShadow.Size = UDim2.new(1, 0, 0, 40)
            BtnShadow.Position = UDim2.new(0, 0, 0, 4)
            BtnShadow.BackgroundColor3 = Theme.Outline
            BtnShadow.BorderSizePixel = 0
            addCorner(BtnShadow, 12)
            BtnShadow.Parent = Container

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.Position = UDim2.new(0, 0, 0, 0)
            Button.BackgroundColor3 = Theme.Secondary
            Button.BorderSizePixel = 0
            Button.AutoButtonColor = false
            Button.Font = Theme.FontBold
            Button.Text = btnText
            Button.TextColor3 = Theme.Outline
            Button.TextSize = 15
            addCorner(Button, 12)
            addCartoonStroke(Button, 2.5, Theme.Outline)
            Button.Parent = Container

            Button.MouseButton1Down:Connect(function()
                tween(Button, TweenInfo.new(0.06, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0, 0, 0, 3)
                })
            end)

            Button.MouseButton1Up:Connect(function()
                tween(Button, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0)
                })
            end)

            Button.MouseEnter:Connect(function()
                tween(Button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(110, 225, 218)
                })
            end)

            Button.MouseLeave:Connect(function()
                tween(Button, TweenInfo.new(0.15), {
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = Theme.Secondary
                })
            end)

            Button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)

            return {
                Button = Button,
                SetText = function(_, newText)
                    Button.Text = newText
                end
            }
        end

        -- 3. TOGGLE (BOUNCY SWITCH)
        function TabElements:CreateToggle(toggleText, defaultState, callback)
            defaultState = defaultState or false
            callback = callback or function() end

            local state = defaultState

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = toggleText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local Track = Instance.new("TextButton")
            Track.Size = UDim2.new(0, 50, 0, 26)
            Track.Position = UDim2.new(1, -62, 0.5, -13)
            Track.BackgroundColor3 = state and Theme.Green or Color3.fromRGB(215, 220, 230)
            Track.BorderSizePixel = 0
            Track.AutoButtonColor = false
            Track.Text = ""
            addCorner(Track, 13)
            addCartoonStroke(Track, 2, Theme.Outline)
            Track.Parent = Card

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 18, 0, 18)
            Knob.Position = state and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
            Knob.BackgroundColor3 = Theme.CardBg
            Knob.BorderSizePixel = 0
            addCorner(Knob, 9)
            addCartoonStroke(Knob, 2, Theme.Outline)
            Knob.Parent = Track

            local function updateToggle(val)
                state = val
                if state then
                    tween(Track, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Green })
                    tween(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -22, 0.5, -9)
                    })
                else
                    tween(Track, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(215, 220, 230) })
                    tween(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 4, 0.5, -9)
                    })
                end
                pcall(callback, state)
            end

            Track.MouseButton1Click:Connect(function()
                updateToggle(not state)
            end)

            return {
                SetValue = function(_, val)
                    updateToggle(val)
                end,
                GetValue = function()
                    return state
                end
            }
        end

        -- 4. SLIDER
        function TabElements:CreateSlider(sliderText, min, max, defaultVal, callback)
            min = min or 0
            max = max or 100
            defaultVal = math.clamp(defaultVal or min, min, max)
            callback = callback or function() end

            local currentVal = defaultVal

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 62)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 0, 20)
            Label.Position = UDim2.new(0, 14, 0, 8)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = sliderText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local ValueBadge = Instance.new("TextLabel")
            ValueBadge.Size = UDim2.new(0, 50, 0, 20)
            ValueBadge.Position = UDim2.new(1, -64, 0, 8)
            ValueBadge.BackgroundColor3 = Theme.Yellow
            ValueBadge.BorderSizePixel = 0
            ValueBadge.Font = Theme.FontBold
            ValueBadge.Text = tostring(currentVal)
            ValueBadge.TextColor3 = Theme.Outline
            ValueBadge.TextSize = 12
            addCorner(ValueBadge, 8)
            addCartoonStroke(ValueBadge, 1.8, Theme.Outline)
            ValueBadge.Parent = Card

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -28, 0, 12)
            Track.Position = UDim2.new(0, 14, 0, 38)
            Track.BackgroundColor3 = Theme.Sidebar
            Track.BorderSizePixel = 0
            addCorner(Track, 6)
            addCartoonStroke(Track, 2, Theme.Outline)
            Track.Parent = Card

            local progress = (currentVal - min) / (max - min)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(progress, 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Purple
            Fill.BorderSizePixel = 0
            addCorner(Fill, 6)
            Fill.Parent = Track

            local Knob = Instance.new("ImageButton")
            Knob.Size = UDim2.new(0, 22, 0, 22)
            Knob.Position = UDim2.new(progress, -11, 0.5, -11)
            Knob.BackgroundColor3 = Theme.CardBg
            Knob.BorderSizePixel = 0
            Knob.AutoButtonColor = false
            addCorner(Knob, 11)
            addCartoonStroke(Knob, 2.5, Theme.Outline)
            Knob.Parent = Track

            local dragging = false

            local function updateSlider(inputX)
                local trackAbsPos = Track.AbsolutePosition.X
                local trackAbsSize = Track.AbsoluteSize.X
                local relativeX = math.clamp(inputX - trackAbsPos, 0, trackAbsSize)
                local ratio = relativeX / trackAbsSize
                currentVal = math.floor(min + ((max - min) * ratio))

                ValueBadge.Text = tostring(currentVal)
                Fill.Size = UDim2.new(ratio, 0, 1, 0)
                Knob.Position = UDim2.new(ratio, -11, 0.5, -11)

                pcall(callback, currentVal)
            end

            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    tween(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 26, 0, 26),
                        Position = UDim2.new(Knob.Position.X.Scale, -13, 0.5, -13)
                    })
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        tween(Knob, TweenInfo.new(0.15), {
                            Size = UDim2.new(0, 22, 0, 22),
                            Position = UDim2.new(Knob.Position.X.Scale, -11, 0.5, -11)
                        })
                    end
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(input.Position.X)
                end
            end)

            return {
                SetValue = function(_, val)
                    val = math.clamp(val, min, max)
                    local ratio = (val - min) / (max - min)
                    currentVal = val
                    ValueBadge.Text = tostring(currentVal)
                    Fill.Size = UDim2.new(ratio, 0, 1, 0)
                    Knob.Position = UDim2.new(ratio, -11, 0.5, -11)
                    pcall(callback, currentVal)
                end,
                GetValue = function()
                    return currentVal
                end
            }
        end

        -- 5. DROPDOWN
        function TabElements:CreateDropdown(dropdownText, options, defaultSelected, callback)
            options = options or {}
            defaultSelected = defaultSelected or options[1] or "Select"
            callback = callback or function() end

            local isDropped = false
            local selectedOption = defaultSelected

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            Card.ClipsDescendants = true
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local DropHeader = Instance.new("TextButton")
            DropHeader.Size = UDim2.new(1, 0, 0, 48)
            DropHeader.BackgroundTransparency = 1
            DropHeader.Text = ""
            DropHeader.Parent = Card

            local TitleL = Instance.new("TextLabel")
            TitleL.Size = UDim2.new(0.5, 0, 1, 0)
            TitleL.Position = UDim2.new(0, 14, 0, 0)
            TitleL.BackgroundTransparency = 1
            TitleL.Font = Theme.FontBold
            TitleL.Text = dropdownText
            TitleL.TextColor3 = Theme.TextDark
            TitleL.TextSize = 14
            TitleL.TextXAlignment = Enum.TextXAlignment.Left
            TitleL.Parent = DropHeader

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.4, -30, 0, 26)
            SelectedLabel.Position = UDim2.new(0.6, -10, 0.5, -13)
            SelectedLabel.BackgroundColor3 = Theme.Sidebar
            SelectedLabel.BorderSizePixel = 0
            SelectedLabel.Font = Theme.FontRegular
            SelectedLabel.Text = selectedOption
            SelectedLabel.TextColor3 = Theme.TextDark
            SelectedLabel.TextSize = 12
            addCorner(SelectedLabel, 8)
            addCartoonStroke(SelectedLabel, 1.5, Theme.Outline)
            SelectedLabel.Parent = DropHeader

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -30, 0.5, -10)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Theme.FontBold
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.Outline
            Arrow.TextSize = 12
            Arrow.Parent = DropHeader

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, -24, 0, #options * 32)
            OptionsContainer.Position = UDim2.new(0, 12, 0, 52)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Parent = Card

            local OptionList = Instance.new("UIListLayout")
            OptionList.Padding = UDim.new(0, 4)
            OptionList.Parent = OptionsContainer

            local function toggleDropdown()
                isDropped = not isDropped
                local targetHeight = isDropped and (56 + (#options * 36)) or 48
                tween(Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                })
                tween(Arrow, TweenInfo.new(0.2), {
                    Rotation = isDropped and 180 or 0
                })
            end

            DropHeader.MouseButton1Click:Connect(toggleDropdown)

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 32)
                OptBtn.BackgroundColor3 = (opt == selectedOption) and Theme.Yellow or Theme.CardDark
                OptBtn.BorderSizePixel = 0
                OptBtn.Font = Theme.FontBold
                OptBtn.Text = opt
                OptBtn.TextColor3 = Theme.TextDark
                OptBtn.TextSize = 13
                addCorner(OptBtn, 8)
                addCartoonStroke(OptBtn, 1.5, Theme.Outline)
                OptBtn.Parent = OptionsContainer

                OptBtn.MouseButton1Click:Connect(function()
                    selectedOption = opt
                    SelectedLabel.Text = opt
                    for _, child in pairs(OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundColor3 = (child.Text == opt) and Theme.Yellow or Theme.CardDark
                        end
                    end
                    toggleDropdown()
                    pcall(callback, opt)
                end)
            end

            return {
                GetSelected = function()
                    return selectedOption
                end
            }
        end

        -- 6. TEXTBOX / INPUT
        function TabElements:CreateInput(inputText, placeholder, callback)
            placeholder = placeholder or "Tulis disini..."
            callback = callback or function() end

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.45, 0, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = inputText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(0.5, -14, 0, 30)
            Box.Position = UDim2.new(0.5, 0, 0.5, -15)
            Box.BackgroundColor3 = Theme.Sidebar
            Box.BorderSizePixel = 0
            Box.Font = Theme.FontRegular
            Box.PlaceholderText = placeholder
            Box.PlaceholderColor3 = Theme.TextMuted
            Box.Text = ""
            Box.TextColor3 = Theme.TextDark
            Box.TextSize = 12
            Box.ClearTextOnFocus = false
            addCorner(Box, 8)
            local boxStroke = addCartoonStroke(Box, 1.8, Theme.Outline)
            Box.Parent = Card

            Box.Focused:Connect(function()
                tween(boxStroke, TweenInfo.new(0.2), { Color = Theme.Primary, Thickness = 2.5 })
            end)

            Box.FocusLost:Connect(function(enterPressed)
                tween(boxStroke, TweenInfo.new(0.2), { Color = Theme.Outline, Thickness = 1.8 })
                pcall(callback, Box.Text, enterPressed)
            end)

            return {
                GetText = function()
                    return Box.Text
                end,
                SetText = function(_, newText)
                    Box.Text = newText
                end
            }
        end

        -- 7. KEYBIND PICKER
        function TabElements:CreateKeybind(keybindText, defaultKey, callback)
            defaultKey = defaultKey or Enum.KeyCode.RightControl
            callback = callback or function() end

            local currentKey = defaultKey
            local listening = false

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = keybindText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local KeyButton = Instance.new("TextButton")
            KeyButton.Size = UDim2.new(0, 95, 0, 28)
            KeyButton.Position = UDim2.new(1, -109, 0.5, -14)
            KeyButton.BackgroundColor3 = Theme.Yellow
            KeyButton.BorderSizePixel = 0
            KeyButton.Font = Theme.FontBold
            KeyButton.Text = currentKey.Name
            KeyButton.TextColor3 = Theme.Outline
            KeyButton.TextSize = 12
            addCorner(KeyButton, 8)
            addCartoonStroke(KeyButton, 2, Theme.Outline)
            KeyButton.Parent = Card

            KeyButton.MouseButton1Click:Connect(function()
                listening = true
                KeyButton.Text = "..."
                KeyButton.BackgroundColor3 = Theme.Primary
                KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and not gameProcessed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        listening = false
                        KeyButton.Text = currentKey.Name
                        KeyButton.BackgroundColor3 = Theme.Yellow
                        KeyButton.TextColor3 = Theme.Outline
                        pcall(callback, currentKey)
                    end
                end
            end)

            return {
                GetKey = function()
                    return currentKey
                end
            }
        end

        -- 8. CARTOON LABEL / BANNER
        function TabElements:CreateLabel(labelText, icon)
            icon = icon or "💡"
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 40)
            Card.BackgroundColor3 = Theme.CardDark
            Card.BorderSizePixel = 0
            addCorner(Card, 10)
            addCartoonStroke(Card, 1.8, Theme.Outline)
            Card.Parent = Page

            local IconL = Instance.new("TextLabel")
            IconL.Size = UDim2.new(0, 24, 1, 0)
            IconL.Position = UDim2.new(0, 10, 0, 0)
            IconL.BackgroundTransparency = 1
            IconL.Font = Theme.FontBold
            IconL.Text = icon
            IconL.TextSize = 16
            IconL.TextColor3 = Theme.Outline
            IconL.Parent = Card

            local TextL = Instance.new("TextLabel")
            TextL.Size = UDim2.new(1, -44, 1, 0)
            TextL.Position = UDim2.new(0, 36, 0, 0)
            TextL.BackgroundTransparency = 1
            TextL.Font = Theme.FontRegular
            TextL.Text = labelText
            TextL.TextColor3 = Theme.TextDark
            TextL.TextSize = 12
            TextL.TextXAlignment = Enum.TextXAlignment.Left
            TextL.Parent = Card

            return {
                SetText = function(_, newText)
                    TextL.Text = newText
                end
            }
        end

        -- 9. CHECKBOX (2D CARTOON STYLE TICK BOX)
        function TabElements:CreateCheckbox(checkboxText, defaultState, callback)
            defaultState = defaultState or false
            callback = callback or function() end

            local state = defaultState

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 44)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = checkboxText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Card

            local BoxBtn = Instance.new("TextButton")
            BoxBtn.Size = UDim2.new(0, 26, 0, 26)
            BoxBtn.Position = UDim2.new(1, -40, 0.5, -13)
            BoxBtn.BackgroundColor3 = state and Theme.Green or Theme.Sidebar
            BoxBtn.BorderSizePixel = 0
            BoxBtn.AutoButtonColor = false
            BoxBtn.Text = state and "✔" or ""
            BoxBtn.TextColor3 = Theme.Outline
            BoxBtn.Font = Theme.FontBold
            BoxBtn.TextSize = 15
            addCorner(BoxBtn, 8)
            addCartoonStroke(BoxBtn, 2, Theme.Outline)
            BoxBtn.Parent = Card

            local function updateCheckbox(val)
                state = val
                BoxBtn.Text = state and "✔" or ""
                tween(BoxBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundColor3 = state and Theme.Green or Theme.Sidebar,
                    Size = UDim2.new(0, 28, 0, 28),
                    Position = UDim2.new(1, -41, 0.5, -14)
                })
                task.delay(0.1, function()
                    tween(BoxBtn, TweenInfo.new(0.15), {
                        Size = UDim2.new(0, 26, 0, 26),
                        Position = UDim2.new(1, -40, 0.5, -13)
                    })
                end)
                pcall(callback, state)
            end

            BoxBtn.MouseButton1Click:Connect(function()
                updateCheckbox(not state)
            end)

            return {
                SetValue = function(_, val)
                    updateCheckbox(val)
                end,
                GetValue = function()
                    return state
                end
            }
        end

        -- 10. DIVIDER / SEPARATOR LINE
        function TabElements:CreateDivider(labelOptional)
            local DivContainer = Instance.new("Frame")
            DivContainer.Size = UDim2.new(1, 0, 0, labelOptional and 24 or 12)
            DivContainer.BackgroundTransparency = 1
            DivContainer.Parent = Page

            if labelOptional and labelOptional ~= "" then
                local LineL = Instance.new("Frame")
                LineL.Size = UDim2.new(0.3, -10, 0, 2.5)
                LineL.Position = UDim2.new(0, 6, 0.5, -1)
                LineL.BackgroundColor3 = Theme.Outline
                LineL.BorderSizePixel = 0
                addCorner(LineL, 2)
                LineL.Parent = DivContainer

                local MidLabel = Instance.new("TextLabel")
                MidLabel.Size = UDim2.new(0.4, 0, 1, 0)
                MidLabel.Position = UDim2.new(0.3, 0, 0, 0)
                MidLabel.BackgroundTransparency = 1
                MidLabel.Font = Theme.FontBold
                MidLabel.Text = labelOptional
                MidLabel.TextColor3 = Theme.TextMuted
                MidLabel.TextSize = 11
                MidLabel.Parent = DivContainer

                local LineR = Instance.new("Frame")
                LineR.Size = UDim2.new(0.3, -10, 0, 2.5)
                LineR.Position = UDim2.new(0.7, 4, 0.5, -1)
                LineR.BackgroundColor3 = Theme.Outline
                LineR.BorderSizePixel = 0
                addCorner(LineR, 2)
                LineR.Parent = DivContainer
            else
                local Line = Instance.new("Frame")
                Line.Size = UDim2.new(1, -12, 0, 2.5)
                Line.Position = UDim2.new(0, 6, 0.5, -1)
                Line.BackgroundColor3 = Theme.Outline
                Line.BorderSizePixel = 0
                addCorner(Line, 2)
                Line.Parent = DivContainer
            end

            return DivContainer
        end

        -- 11. COLOR PICKER (CARTOON POPUP WHEEL & PRESETS)
        function TabElements:CreateColorPicker(colorText, defaultColor, callback)
            defaultColor = defaultColor or Color3.fromRGB(255, 107, 107)
            callback = callback or function() end

            local currentColor = defaultColor
            local isExpanded = false

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, 0, 0, 48)
            Card.BackgroundColor3 = Theme.CardBg
            Card.BorderSizePixel = 0
            Card.ClipsDescendants = true
            addCorner(Card, 12)
            addCartoonStroke(Card, 2, Theme.Outline)
            Card.Parent = Page

            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Size = UDim2.new(1, 0, 0, 48)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            HeaderBtn.Parent = Card

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontBold
            Label.Text = colorText
            Label.TextColor3 = Theme.TextDark
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = HeaderBtn

            local ColorPreview = Instance.new("Frame")
            ColorPreview.Size = UDim2.new(0, 48, 0, 24)
            ColorPreview.Position = UDim2.new(1, -62, 0.5, -12)
            ColorPreview.BackgroundColor3 = currentColor
            ColorPreview.BorderSizePixel = 0
            addCorner(ColorPreview, 8)
            addCartoonStroke(ColorPreview, 2, Theme.Outline)
            ColorPreview.Parent = HeaderBtn

            -- Palette Box & Presets
            local PaletteContainer = Instance.new("Frame")
            PaletteContainer.Size = UDim2.new(1, -24, 0, 92)
            PaletteContainer.Position = UDim2.new(0, 12, 0, 52)
            PaletteContainer.BackgroundTransparency = 1
            PaletteContainer.Parent = Card

            local PaletteLabel = Instance.new("TextLabel")
            PaletteLabel.Size = UDim2.new(1, 0, 0, 18)
            PaletteLabel.Position = UDim2.new(0, 0, 0, 0)
            PaletteLabel.BackgroundTransparency = 1
            PaletteLabel.Font = Theme.FontRegular
            PaletteLabel.Text = "Pilih Preset Warna:"
            PaletteLabel.TextColor3 = Theme.TextMuted
            PaletteLabel.TextSize = 11
            PaletteLabel.TextXAlignment = Enum.TextXAlignment.Left
            PaletteLabel.Parent = PaletteContainer

            local SwatchList = {
                Color3.fromRGB(255, 107, 107), -- Coral Red
                Color3.fromRGB(255, 159, 67),  -- Orange
                Color3.fromRGB(254, 202, 87),  -- Yellow
                Color3.fromRGB(106, 222, 126), -- Lime Green
                Color3.fromRGB(78, 205, 196),  -- Cyan
                Color3.fromRGB(84, 160, 255),  -- Blue
                Color3.fromRGB(142, 108, 239), -- Purple
                Color3.fromRGB(255, 159, 243), -- Pink
                Color3.fromRGB(255, 255, 255), -- White
                Color3.fromRGB(40, 40, 45),    -- Dark/Black
            }

            local SwatchesFrame = Instance.new("Frame")
            SwatchesFrame.Size = UDim2.new(1, 0, 0, 28)
            SwatchesFrame.Position = UDim2.new(0, 0, 0, 20)
            SwatchesFrame.BackgroundTransparency = 1
            SwatchesFrame.Parent = PaletteContainer

            local SLayout = Instance.new("UIGridLayout")
            SLayout.CellSize = UDim2.new(0.09, 0, 0, 24)
            SLayout.CellPadding = UDim2.new(0.011, 0, 0, 4)
            SLayout.Parent = SwatchesFrame

            local function applyColor(newCol)
                currentColor = newCol
                ColorPreview.BackgroundColor3 = newCol
                pcall(callback, newCol)
            end

            for _, swatchCol in ipairs(SwatchList) do
                local SwatchBtn = Instance.new("TextButton")
                SwatchBtn.BackgroundColor3 = swatchCol
                SwatchBtn.BorderSizePixel = 0
                SwatchBtn.Text = ""
                SwatchBtn.AutoButtonColor = false
                addCorner(SwatchBtn, 6)
                addCartoonStroke(SwatchBtn, 1.8, Theme.Outline)
                SwatchBtn.Parent = SwatchesFrame

                SwatchBtn.MouseButton1Click:Connect(function()
                    applyColor(swatchCol)
                end)
            end

            -- Manual RGB Input
            local RGBBox = Instance.new("TextBox")
            RGBBox.Size = UDim2.new(1, 0, 0, 28)
            RGBBox.Position = UDim2.new(0, 0, 0, 58)
            RGBBox.BackgroundColor3 = Theme.Sidebar
            RGBBox.BorderSizePixel = 0
            RGBBox.Font = Theme.FontRegular
            RGBBox.PlaceholderText = "Format: R, G, B (cth: 255, 50, 50)"
            RGBBox.PlaceholderColor3 = Theme.TextMuted
            RGBBox.Text = string.format("%d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
            RGBBox.TextColor3 = Theme.TextDark
            RGBBox.TextSize = 12
            RGBBox.ClearTextOnFocus = false
            addCorner(RGBBox, 8)
            addCartoonStroke(RGBBox, 1.5, Theme.Outline)
            RGBBox.Parent = PaletteContainer

            RGBBox.FocusLost:Connect(function()
                local r, g, b = RGBBox.Text:match("(%d+)[%s,]+(%d+)[%s,]+(%d+)")
                if r and g and b then
                    local parsedCol = Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255))
                    applyColor(parsedCol)
                else
                    RGBBox.Text = string.format("%d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
                end
            end)

            local function toggleColorPicker()
                isExpanded = not isExpanded
                local targetHeight = isExpanded and 152 or 48
                tween(Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                })
            end

            HeaderBtn.MouseButton1Click:Connect(toggleColorPicker)

            return {
                SetColor = function(_, newColor)
                    applyColor(newColor)
                    RGBBox.Text = string.format("%d, %d, %d", math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255))
                end,
                GetColor = function()
                    return currentColor
                end
            }
        end

        return TabElements
    end

    -- Pop In Animation Pertama Kali Buka
    MainWindow.Size = UDim2.new(0, 0, 0, 0)
    MainShadow.Size = UDim2.new(0, 0, 0, 0)
    tween(MainWindow, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize
    })
    tween(MainShadow, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize
    })

    notify(Title .. " Aktif!", "Tekan " .. currentKeybind.Name .. " atau klik tombol melayang", 3.5, Theme.Yellow)

    return WindowHandler
end

return CartoonUI
