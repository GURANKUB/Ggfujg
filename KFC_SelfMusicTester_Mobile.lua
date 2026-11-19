--[[
    KFC Self Music Tester (Mobile UI)
    แสดงผลการดักเพลงของตัวเองบนหน้าจอ ไม่ต้องเปิด console
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gethui = gethui or function() return game:GetService("CoreGui") end
local GuiParent = (function()
    local ok, res = pcall(gethui)
    if ok and res then return res end
    return game:GetService("CoreGui")
end)()

for _, n in ipairs({"KFC_Tester_UI", "KFC_Tester_Toggle"}) do
    local o = GuiParent:FindFirstChild(n)
    if o then o:Destroy() end
end

local isMobile = UserInputService.TouchEnabled

-- ═══════════════════════════════════════
-- LOGIC
-- ═══════════════════════════════════════
local function cleanId(sid)
    if not sid or sid == "" then return nil, "empty" end
    local str = tostring(sid)

    if #str > 60 then
        local first = str:match("%d+")
        if first and #first >= 8 then
            return first, "long→first"
        end
        return nil, "UNDECODABLE"
    end

    local num = str:match("%d+")
    if num and #num >= 8 then
        return num, "direct"
    end

    local fromId = str:match("&id=(%d+)")
    if fromId then
        return fromId, "&id="
    end

    if str:find("%d") then
        return str:match("%d+"), "partial"
    end

    return nil, "UNDECODABLE"
end

local function scanAll()
    local results = {}
    local char = LocalPlayer.Character

    local function add(obj)
        local sid = obj.SoundId or ""
        local id, method = cleanId(sid)
        table.insert(results, {
            name = obj.Name,
            raw = sid,
            id = id,
            method = method,
            playing = obj.Playing or obj.IsPlaying or false
        })
    end

    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Sound") then add(obj) end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Sound") and (obj.Name == "PlayersChoice" or obj.Playing or obj.IsPlaying) then
            local already = false
            for _, r in ipairs(results) do
                if r.name == obj.Name and r.raw == (obj.SoundId or "") then
                    already = true break
                end
            end
            if not already then add(obj) end
        end
    end

    return results
end

-- ═══════════════════════════════════════
-- UI
-- ═══════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "KFC_Tester_UI"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.DisplayOrder = 99999
SG.Parent = GuiParent

local TG = Instance.new("ScreenGui")
TG.Name = "KFC_Tester_Toggle"
TG.ResetOnSpawn = false
TG.IgnoreGuiInset = true
TG.DisplayOrder = 100000
TG.Parent = GuiParent

local W = isMobile and 300 or 320
local H = isMobile and 380 or 400

-- Toggle
local Tog = Instance.new("TextButton")
Tog.Size = UDim2.fromOffset(48, 48)
Tog.Position = UDim2.new(1, -60, 0.35, 0)
Tog.BackgroundColor3 = Color3.fromRGB(20, 18, 30)
Tog.Text = "T"
Tog.TextSize = 20
Tog.TextColor3 = Color3.fromRGB(195, 255, 30)
Tog.Font = Enum.Font.GothamBold
Tog.AutoButtonColor = false
Tog.Parent = TG
Instance.new("UICorner", Tog).CornerRadius = UDim.new(1, 0)
local ts = Instance.new("UIStroke", Tog)
ts.Color = Color3.fromRGB(195, 255, 30)
ts.Thickness = 2

-- Panel
local Panel = Instance.new("Frame")
Panel.Size = UDim2.fromOffset(W, H)
Panel.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Panel.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
Panel.BackgroundTransparency = 0.05
Panel.Visible = false
Panel.Parent = SG
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)
local ps = Instance.new("UIStroke", Panel)
ps.Color = Color3.fromRGB(80, 80, 100)
ps.Thickness = 1

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Header.Parent = Panel
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "Music Tester (Self)"
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(195, 255, 30)
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(36, 36)
Close.Position = UDim2.new(1, -40, 0.5, -18)
Close.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
Close.BackgroundTransparency = 0.3
Close.Text = "✕"
Close.TextSize = 14
Close.TextColor3 = Color3.new(1,1,1)
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -16, 0, 22)
Status.Position = UDim2.fromOffset(8, 48)
Status.BackgroundTransparency = 1
Status.Text = "กดสแกน หรือรอ auto..."
Status.TextSize = 12
Status.TextColor3 = Color3.fromRGB(160, 160, 180)
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Panel

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -16, 0, 40)
ScanBtn.Position = UDim2.fromOffset(8, 74)
ScanBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
ScanBtn.Text = "🔍 สแกนเพลงตอนนี้"
ScanBtn.TextSize = 14
ScanBtn.TextColor3 = Color3.new(1,1,1)
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.AutoButtonColor = false
ScanBtn.Parent = Panel
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -130)
Scroll.Position = UDim2.fromOffset(8, 122)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
Scroll.BackgroundTransparency = 0.3
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(195, 255, 30)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 8)

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 6)
List.SortOrder = Enum.SortOrder.LayoutOrder
List.Parent = Scroll

local Pad = Instance.new("UIPadding")
Pad.PaddingTop = UDim.new(0, 6)
Pad.PaddingBottom = UDim.new(0, 6)
Pad.PaddingLeft = UDim.new(0, 6)
Pad.PaddingRight = UDim.new(0, 6)
Pad.Parent = Scroll

local function clearResults()
    for _, c in ipairs(Scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
end

local function addResultCard(r)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
    card.Parent = Scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = card

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 3)
    lay.Parent = card

    local function line(text, color, size)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, size or 16)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextSize = size or 12
        l.TextColor3 = color or Color3.fromRGB(220, 220, 230)
        l.Font = Enum.Font.Gotham
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextWrapped = true
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.Parent = card
    end

    line(r.name .. (r.playing and "  [PLAYING]" or ""), Color3.fromRGB(200, 200, 220), 13)

    if r.id then
        line("ID: " .. r.id, Color3.fromRGB(255, 80, 80), 14)
        line("วิธี: " .. r.method, Color3.fromRGB(255, 160, 100), 11)
        line("⚠ รั่ว — ดักได้", Color3.fromRGB(255, 80, 80), 12)
    else
        line("ผล: " .. tostring(r.method), Color3.fromRGB(80, 220, 120), 14)
        line("✓ กันได้ดี", Color3.fromRGB(80, 220, 120), 12)
    end

    local rawShow = tostring(r.raw):sub(1, 70)
    if #tostring(r.raw) > 70 then rawShow = rawShow .. "..." end
    line("Raw: " .. rawShow, Color3.fromRGB(120, 120, 140), 10)
end

local function doScan()
    clearResults()
    Status.Text = "กำลังสแกน..."
    local results = scanAll()

    if #results == 0 then
        Status.Text = "ไม่พบ Sound — ลองเล่นเพลงก่อน"
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Text = "ไม่พบเพลง\nเล่นเพลงด้วย KFC แล้วกดสแกน"
        empty.TextSize = 13
        empty.TextColor3 = Color3.fromRGB(140, 140, 160)
        empty.Font = Enum.Font.Gotham
        empty.TextWrapped = true
        empty.Parent = Scroll
        return
    end

    local leaked = 0
    for _, r in ipairs(results) do
        addResultCard(r)
        if r.id then leaked += 1 end
    end

    if leaked > 0 then
        Status.Text = "พบ " .. #results .. " รายการ — รั่ว " .. leaked .. " รายการ"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        Status.Text = "พบ " .. #results .. " รายการ — กันได้ทั้งหมด"
        Status.TextColor3 = Color3.fromRGB(80, 220, 120)
    end
end

ScanBtn.MouseButton1Click:Connect(doScan)

-- Auto scan ทุก 4 วินาที ตอนเปิดแผง
local auto = false
local autoConn
local function setAuto(on)
    auto = on
    if autoConn then autoConn:Disconnect() autoConn = nil end
    if on then
        autoConn = RunService.Heartbeat:Connect(function()
            -- ใช้ flag แทน
        end)
        task.spawn(function()
            while auto and Panel.Visible do
                doScan()
                task.wait(4)
            end
        end)
    end
end

-- Open / Close
local open = false
local function openPanel()
    open = true
    Panel.Visible = true
    doScan()
    setAuto(true)
end
local function closePanel()
    open = false
    Panel.Visible = false
    setAuto(false)
end

Close.MouseButton1Click:Connect(closePanel)
Tog.MouseButton1Click:Connect(function()
    if open then closePanel() else openPanel() end
end)

-- Drag toggle
local td, tdd, ts0, tm = false, false
Tog.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        td = true tdd = false ts0 = Tog.Position tm = i.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if td and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - tm
        if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then
            tdd = true
            local vp = Camera.ViewportSize
            Tog.Position = UDim2.fromOffset(
                math.clamp(ts0.X.Offset + d.X, 0, vp.X - 48),
                math.clamp(ts0.Y.Offset + d.Y, 0, vp.Y - 48))
        end
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        td = false
    end
end)

-- ป้องกันคลิกตอนลาก
local oldClick = Tog.MouseButton1Click
Tog.MouseButton1Click:Connect(function()
    if tdd then return end
end)

print("[KFC Tester Mobile] พร้อม — กดปุ่ม T เพื่อเปิด")
