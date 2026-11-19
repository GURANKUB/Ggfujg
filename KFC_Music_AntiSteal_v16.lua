--[[
    KFC MUSIC — Anti-Steal v16
    เป้าหมาย: ทำให้ stage1 / Tiw ถอดรหัสยากขึ้น (เข้าใกล้ UNDECODABLE)
    ยังคง UI + Boombox + Skateboard เดิม
    ข้อจำกัด: ถ้า Server ใส่ SoundId สะอาดลง PlayersChoice ยังอ่านได้
]]

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local gethui = gethui or function() return game:GetService("CoreGui") end
local GuiParent = (function()
    local ok, res = pcall(gethui)
    if ok and res then return res end
    ok, res = pcall(function() return game:GetService("CoreGui") end)
    if ok and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end)()

for _, name in ipairs({
    "KFC_LOLASSR5_Root","KFC_LOLASSR5_Toggle",
    "KFC_Stage1Trap_Root","KFC_Stage1Trap_Toggle",
    "KFC_AntiSteal_Root","KFC_AntiSteal_Toggle"
}) do
    local c = GuiParent:FindFirstChild(name)
    if c then c:Destroy() end
end

local T = {
    Glass = Color3.fromRGB(14,16,22), GlassT = 0.18,
    Card  = Color3.fromRGB(22,26,36), CardT  = 0.26,
    Border = Color3.fromRGB(255,255,255), BorderT = 0.45,
    Btn = Color3.fromRGB(30,36,50), BtnT = 0.28, BtnHov = Color3.fromRGB(46,54,74),
    White = Color3.fromRGB(255,255,255), Muted = Color3.fromRGB(142,154,176),
    Accent = Color3.fromRGB(195,255,30), Red = Color3.fromRGB(244,67,54),
    Green = Color3.fromRGB(46,204,113), Amber = Color3.fromRGB(245,158,11),
    Blue = Color3.fromRGB(66,165,245),
}
local Font = Enum.Font.GothamBold
local FontNorm = Enum.Font.Gotham

local function playClickSound()
    pcall(function()
        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://6895079853"
        s.Volume = 0.4
        s:Play()
        game:GetService("Debris"):AddItem(s, 2)
    end)
end

local function newFrame(parent, size, pos, color, trans)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or T.Glass
    f.BackgroundTransparency = trans or T.GlassT
    f.BorderSizePixel = 0
    if parent then f.Parent = parent end
    return f
end

local function newLabel(parent, text, size, pos, fs, color, font)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1,0,0,22)
    l.Position = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextSize = fs or 13
    l.TextColor3 = color or T.White
    l.Font = font or FontNorm
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    if parent then l.Parent = parent end
    return l
end

local function newButton(parent, text, size, pos, fs, color)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(1,-8,0,40)
    b.Position = pos or UDim2.new(0,4,0,0)
    b.BackgroundColor3 = T.Btn
    b.BackgroundTransparency = T.BtnT
    b.BorderSizePixel = 0
    b.Text = text or "Button"
    b.TextSize = fs or 13
    b.TextColor3 = color or T.White
    b.Font = Font
    b.AutoButtonColor = false
    if parent then b.Parent = parent end
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = b
    local s = Instance.new("UIStroke")
    s.Color = T.Border
    s.Transparency = T.BorderT
    s.Thickness = 1
    s.Parent = b
    b.MouseEnter:Connect(function() b.BackgroundColor3 = T.BtnHov end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = T.Btn end)
    return b
end

local function addCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
end

local function addStroke(p, col, tr, th)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Border
    s.Transparency = tr or T.BorderT
    s.Thickness = th or 1
    s.Parent = p
end

local function addListLayout(p, pad)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, pad or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = p
end

local function addPadding(p, h, v)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, h or 8)
    pad.PaddingRight = UDim.new(0, h or 8)
    pad.PaddingTop = UDim.new(0, v or 6)
    pad.PaddingBottom = UDim.new(0, v or 6)
    pad.Parent = p
end

-- ══════════════════════════════════════════════════════════════
-- STRONG ANTI-STEAL PAYLOAD (v16)
-- ออกแบบให้ parser แบบ match("%d+") / &id= หลงง่าย
-- และทำให้สตริงยาว + ไม่มีตัวเลขนำหน้าชัดเจน
-- ══════════════════════════════════════════════════════════════
local BAIT_POOL = {
    "122657934666702", "120232514292241", "1848354536", "9043887091",
    "1837879082", "1845756489", "1843404009", "1836842899",
    "7029024726", "5410086218", "1846458016", "1839841807"
}

local function rnd(n)
    return tostring(math.random(10^(n-1), 10^n - 1))
end

local function junk(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    for i = 1, len do
        local r = math.random(1, #chars)
        t[i] = chars:sub(r, r)
    end
    return table.concat(t)
end

local function buildPayload(realId)
    local id = tostring(realId):match("%d+") or tostring(realId)
    if id == "" then return "" end

    local parts = {}

    -- 1) ขึ้นต้นด้วยข้อความที่ไม่ใช่ตัวเลข + bait หลายชั้น
    table.insert(parts, "title=" .. junk(8) .. "&")
    table.insert(parts, "src=stream&")
    table.insert(parts, "rbxassetid://" .. BAIT_POOL[math.random(1, #BAIT_POOL)] .. "&")
    table.insert(parts, "rbxassetid://" .. BAIT_POOL[math.random(1, #BAIT_POOL)] .. "&")

    -- 2) ไอดีปลอมจำนวนมาก (ไม่มี &id=)
    for i = 1, 10 do
        table.insert(parts, rnd(10) .. "&")
    end

    -- 3) &id= ปลอมหลายตัว
    for i = 1, 6 do
        table.insert(parts, "&id=" .. rnd(10) .. "&")
    end

    -- 4) ฝัง real กลาง ๆ (ซ้ำ) — เกมส่วนใหญ่ยัง parse ได้
    table.insert(parts, "&id=" .. id .. "&")
    table.insert(parts, "ref=" .. junk(6) .. "&id=" .. id .. "&")

    -- 5) &id= ปลอมต่อท้ายอีก
    for i = 1, 5 do
        table.insert(parts, "&id=" .. rnd(10) .. "&")
    end

    -- 6) ขยะยาว ๆ (ทำให้สตริงยาว > 60 เพื่อหลอก logic บางตัว)
    for i = 1, 35 do
        local chunk = junk(math.random(8, 16))
        if math.random() > 0.45 then
            chunk = chunk .. rnd(math.random(6, 10))
        end
        table.insert(parts, chunk)
    end

    return table.concat(parts, "")
end

-- ══════════════════════════════════════════════════════════════
-- MUSIC
-- ══════════════════════════════════════════════════════════════
local function getRemote(name)
    local RE = ReplicatedStorage:FindFirstChild("RE")
    return RE and RE:FindFirstChild(name)
end

local function PlayMusic(audioId, useVehicle)
    local id = tostring(audioId):match("%d+") or tostring(audioId)
    if id == "" then
        warn("[KFC] ไม่มี Audio ID")
        return
    end

    local payload = buildPayload(id)
    print("[KFC v16] เล่น:", id)
    print("[KFC] Payload length:", #payload)

    local ToolEv = getRemote("PlayerToolEvent")
    local ScooterEv = getRemote("1NoMoto1rVehicle1s")
        or getRemote("1NoMo1torVeh1icle1s")
        or getRemote("PlayerScooterEvent")

    if not ToolEv then
        warn("[KFC] ไม่พบ PlayerToolEvent")
        return
    end

    -- ส่ง payload หนัก ๆ ก่อน แล้วค่อยส่ง id (จำเป็นสำหรับเกมส่วนใหญ่)
    pcall(function()
        ToolEv:FireServer("ToolMusicStop", "", nil)
        task.wait(0.1)
        ToolEv:FireServer("ToolMusicText", payload, nil, true)
        task.wait(0.06)
        ToolEv:FireServer("ToolMusic", id, 1)
        task.wait(0.03)
        ToolEv:FireServer("ToolMusicPlay", "", nil)
    end)

    if useVehicle and ScooterEv then
        pcall(function()
            ScooterEv:FireServer("PickingScooterMusicStop", "", nil)
            task.wait(0.1)
            ScooterEv:FireServer("PickingScooterMusicText", payload, nil, true)
            task.wait(0.06)
            ScooterEv:FireServer("PickingScooterMusic", id, 1)
            task.wait(0.03)
            ScooterEv:FireServer("PickingScooterMusicPlay", "", nil)
        end)
    end
end

local function StopMusic()
    local ToolEv = getRemote("PlayerToolEvent")
    local ScooterEv = getRemote("1NoMoto1rVehicle1s")
        or getRemote("1NoMo1torVeh1icle1s")
        or getRemote("PlayerScooterEvent")

    if ToolEv then
        pcall(function()
            ToolEv:FireServer("ToolMusicStop", "", nil)
            ToolEv:FireServer("ToolMusicText", "")
        end)
    end
    if ScooterEv then
        pcall(function()
            ScooterEv:FireServer("PickingScooterMusicStop", "", nil)
            ScooterEv:FireServer("PickingScooterMusicText", "")
        end)
    end
end

_G.KFC_PlayMusic = PlayMusic
_G.KFC_StopMusic = StopMusic

-- ══════════════════════════════════════════════════════════════
-- UI (คงสไตล์เดิม)
-- ══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KFC_AntiSteal_Root"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = GuiParent

local uiScale = Instance.new("UIScale")
uiScale.Parent = ScreenGui
local function updateUIScale()
    if not Camera then return end
    local vp = Camera.ViewportSize
    uiScale.Scale = math.clamp(math.min(vp.X / 400, vp.Y / 600), 0.65, 1.0)
end
updateUIScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)

local safeTop = isMobile and 44 or 0
local safeBot = isMobile and 34 or 0
local panelW  = isMobile and 310 or 340
local panelH  = isMobile and 400 or 440
local btnH    = isMobile and 42 or 36
local fontSize  = isMobile and 14 or 13
local fontSizeS = isMobile and 12 or 11

local ToggleSG = Instance.new("ScreenGui")
ToggleSG.Name = "KFC_AntiSteal_Toggle"
ToggleSG.ResetOnSpawn = false
ToggleSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleSG.IgnoreGuiInset = true
ToggleSG.DisplayOrder = 99999
ToggleSG.Parent = GuiParent

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 24
ToggleBtn.TextColor3 = T.Accent
ToggleBtn.Font = Font
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ToggleSG
addCorner(ToggleBtn, 25)
addStroke(ToggleBtn, T.Accent, 0.3, 2)

local toggleDragging, toggleDidDrag = false, false
local toggleStartPos, toggleStartMouse

ToggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = true
        toggleDidDrag = false
        toggleStartPos = ToggleBtn.Position
        toggleStartMouse = inp.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if toggleDragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = inp.Position - toggleStartMouse
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
            toggleDidDrag = true
            local vp = Camera.ViewportSize
            ToggleBtn.Position = UDim2.new(0,
                math.clamp(toggleStartPos.X.Offset + delta.X, 0, vp.X - 50),
                0,
                math.clamp(toggleStartPos.Y.Offset + delta.Y, 0, vp.Y - 50))
        end
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = false
    end
end)

local PanelOpen = false
local Panel = newFrame(ScreenGui, UDim2.new(0, panelW, 0, panelH), UDim2.new(0.5, -panelW/2, 0.5, -panelH/2), T.Glass, T.GlassT)
Panel.Visible = false
addCorner(Panel, 14)
addStroke(Panel, T.Border, T.BorderT, 1)

local draggingPanel = false
local panelDragStart, panelStartPos

UserInputService.InputChanged:Connect(function(inp)
    if draggingPanel and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = inp.Position - panelDragStart
        local vp = Camera.ViewportSize
        Panel.Position = UDim2.new(0,
            math.clamp(panelStartPos.X.Scale * vp.X + panelStartPos.X.Offset + delta.X, 0, vp.X - panelW),
            0,
            math.clamp(panelStartPos.Y.Scale * vp.Y + panelStartPos.Y.Offset + delta.Y, safeTop, vp.Y - panelH - safeBot))
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = false
    end
end)

local Header = newFrame(Panel, UDim2.new(1, 0, 0, isMobile and 54 or 46), UDim2.new(0, 0, 0, 0), Color3.fromRGB(10, 12, 18), 0.1)
addCorner(Header, 14)
Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = true
        panelDragStart = inp.Position
        panelStartPos = Panel.Position
    end
end)

newLabel(Header, "⚡ KFC — AntiSteal v16", UDim2.new(1, -110, 1, 0), UDim2.new(0, 12, 0, 0), 14, T.Accent, Font)

local CloseBtn = newButton(Header, "✕", UDim2.new(0, isMobile and 42 or 34, 0, isMobile and 42 or 34),
    UDim2.new(1, -(isMobile and 46 or 38), 0.5, -(isMobile and 21 or 17)), fontSize, T.White)
CloseBtn.BackgroundColor3 = T.Red
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.MouseButton1Click:Connect(function()
    playClickSound()
    PanelOpen = false
    Panel.Visible = false
end)

local MinBtn = newButton(Header, "─", UDim2.new(0, isMobile and 42 or 34, 0, isMobile and 42 or 34),
    UDim2.new(1, -(isMobile and 92 or 76), 0.5, -(isMobile and 21 or 17)), fontSize, T.White)
MinBtn.BackgroundColor3 = T.Amber
MinBtn.BackgroundTransparency = 0.3

local Content = newFrame(Panel, UDim2.new(1, 0, 1, -(isMobile and 54 or 46)), UDim2.new(0, 0, 0, isMobile and 54 or 46), Color3.fromRGB(0, 0, 0), 0.95)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = isMobile and 3 or 4
scroll.ScrollBarImageColor3 = T.Accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = Content
addListLayout(scroll, 8)
addPadding(scroll, 10, 10)

local function addSection(text)
    return newLabel(scroll, text, UDim2.new(1, 0, 0, 22), nil, fontSizeS, T.Muted, FontNorm)
end

local function addBtn(text, color, fn)
    local b = newButton(scroll, text, UDim2.new(1, -16, 0, btnH), UDim2.new(0, 8, 0, 0))
    if color then b.TextColor3 = color end
    b.MouseButton1Click:Connect(function()
        playClickSound()
        if fn then fn() end
    end)
    return b
end

local function addInput(ph)
    local container = newFrame(scroll, UDim2.new(1, -16, 0, btnH + 4), UDim2.new(0, 8, 0, 0), T.Card, T.CardT)
    addCorner(container, 8)
    addStroke(container, T.Border, 0.6, 1)
    local inp = Instance.new("TextBox")
    inp.Size = UDim2.new(1, -16, 1, 0)
    inp.Position = UDim2.new(0, 8, 0, 0)
    inp.BackgroundTransparency = 1
    inp.PlaceholderText = ph or ""
    inp.PlaceholderColor3 = T.Muted
    inp.Text = ""
    inp.TextSize = fontSize
    inp.TextColor3 = T.White
    inp.Font = FontNorm
    inp.TextXAlignment = Enum.TextXAlignment.Left
    inp.ClearTextOnFocus = false
    inp.Parent = container
    return inp
end

addSection("── 🎵 PLAY MUSIC ──")
local idInp = addInput("ใส่ Audio ID เช่น 1836009206")

addBtn("▶  เล่นเพลง (Boombox)", T.Green, function()
    PlayMusic(idInp.Text, false)
end)

addBtn("🛹  เล่นเพลง (Boombox + Skateboard)", T.Blue, function()
    PlayMusic(idInp.Text, true)
end)

addBtn("⏹  หยุดเพลง", T.Red, function()
    StopMusic()
end)

addSection("── ℹ️ Anti-Steal v16 ──")
newLabel(scroll,
    "Payload แข็งขึ้นสำหรับ stage1 / Tiw\n" ..
    "ขึ้นต้นไม่ใช่ตัวเลข + หลาย &id= ปลอม\n" ..
    "สตริงยาวเพื่อหลอก parser\n" ..
    "ถ้า Server ใส่ SoundId สะอาด ยังรั่วได้",
    UDim2.new(1, -16, 0, 90), UDim2.new(0, 8, 0, 0), fontSizeS, T.Muted, FontNorm)

local isMinimized = false
local normalH = panelH
MinBtn.MouseButton1Click:Connect(function()
    playClickSound()
    isMinimized = not isMinimized
    TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
        Size = isMinimized and UDim2.new(0, panelW, 0, isMobile and 54 or 46) or UDim2.new(0, panelW, 0, normalH)
    }):Play()
    Content.Visible = not isMinimized
    MinBtn.Text = isMinimized and "□" or "─"
end)

ToggleBtn.MouseButton1Click:Connect(function()
    if toggleDidDrag then return end
    playClickSound()
    PanelOpen = not PanelOpen
    if PanelOpen then
        Panel.Visible = true
        Panel.Size = UDim2.new(0, panelW, 0, 0)
        Panel.BackgroundTransparency = 1
        TweenService:Create(Panel, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, panelW, 0, normalH),
            BackgroundTransparency = T.GlassT
        }):Play()
    else
        TweenService:Create(Panel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, panelW, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.22, function()
            Panel.Visible = false
        end)
    end
end)

print("[KFC AntiSteal v16] โหลดสำเร็จ")
print("→ เป้าหมาย: ทำให้ stage1/Tiw ถอดรหัสยากขึ้น")
print("→ ข้อจำกัด: SoundId จาก Server ยังอาจรั่วได้")
