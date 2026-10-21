# 🎨 2D Cartoon Roblox UI Library

Library antarmuka grafis (**UI Library**) Roblox bertema **2D Cartoon** dengan estetika *chunky line-art*, warna ceria, animasi *bouncy* (membal), sistem *minimize*, tombol melayang (*floating button*), custom keybind, dan **Pop-Up Cards Scanner / Stealer** dengan filter Rarity otomatis.

---

## 🚀 Cara Import Library dari GitHub

Cukup panggil link *Raw* GitHub di baris awal script kamu:

```lua
local CartoonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ridhohari2002/Roblox-UI-Libraries/refs/heads/main/2DCartoon.lua"))()
```

---

## 🖥️ 1. Membuat Tampilan Utama (Window)

```lua
local Window = CartoonUI.CreateWindow({
    Title = "Boyfinity HUB",                 -- Judul utama script
    Subtitle = "by ridho hari",              -- Nama pembuat / teks di bawah judul
    Icon = "⚡",                             -- Logo (Bisa emoji "⚡" atau "rbxassetid://123456")
    ToggleKey = Enum.KeyCode.RightControl,   -- Keybind keyboard untuk buka/tutup
    Size = UDim2.new(0, 560, 0, 390),        -- Ukuran window
    
    -- 🎈 Floating Button (Tombol Bulat Melayang Draggable)
    FloatButton = {
        Enabled = true,                      -- true = aktif, false = disembunyikan
        Icon = "🎮",                         -- Emoji pada tombol melayang
        Position = UDim2.new(0, 25, 0.5, -27)
    },

    -- 🔘 Right Side Buttons (Tombol Tambahan di Kanan Header)
    RightButtons = {
        {
            Icon = "🃏",
            Tooltip = "Cards Stealer",
            Color = Color3.fromRGB(142, 108, 239),
            Callback = function()
                CardsPopup:Toggle()
            end
        },
        {
            Icon = "💬",
            Tooltip = "Discord",
            Color = Color3.fromRGB(114, 137, 218),
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/boyfinity")
                end
                Window:Notify("Discord", "Link discord berhasil disalin! 📋", 3)
            end
        }
    }
})
```

---

## 🃏 2. Menggunakan Pop-Up Cards Scanner & Stealer

Fitur khusus untuk memindai kartu di `workspace.ActiveCards` secara *real-time*:

```lua
local CardsPopup = Window:CreateCardsPopup({
    Title = "Active Cards Stealer",
    CardsFolder = workspace:FindFirstChild("ActiveCards") or workspace,
    Rarities = {"All", "Divine", "Mythic", "Legendary", "Epic", "Rare", "Common"},
    
    -- Callback saat tombol "STEAL" pada suatu kartu ditekan (ON/OFF)
    OnSteal = function(cardObject, isStealing, cardData)
        print("Status Steal :", isStealing and "AKTIF" or "NONAKTIF")
        print("Nama Kartu   :", cardData.DisplayName)
        print("Rarity       :", cardData.Rarity)
        print("Level        :", cardData.Level)
        print("Mutation     :", cardData.Mutation)

        if isStealing then
            -- Contoh aksi steal: Teleport ke posisi kartu
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetPart = cardObject:IsA("BasePart") and cardObject or cardObject:FindFirstChildWhichIsA("BasePart")
            if hrp and targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

-- Kontrol Pop-up dari script:
CardsPopup:Open()    -- Membuka pop-up
CardsPopup:Close()   -- Menutup pop-up
CardsPopup:Toggle()  -- Toggle buka / tutup
CardsPopup:Refresh() -- Refresh daftar kartu
```

### ✨ Fitur di dalam Pop-up:
* **Filter Rarity Pills**: Tombol filter atas (`All`, `👑 Divine`, `🔥 Mythic`, `⚡ Legendary`, `🔮 Epic`, `💎 Rare`, `⚪ Common`).
* **Search Input**: Kolom pencarian instan berdasarkan nama kartu (misal: `"Puskas"`).
* **Badge Rarity**: Indikator warna kartun cerah untuk setiap rarity kartu.
* **Tombol Steal per Kartu**: Tombol kartun `STEAL` (Mint Cyan) berubah menjadi `STEALING...` (Merah/Coral) saat aktif.
* **Auto Update**: Mendeteksi kartu baru yang *spawn* atau hilang secara *real-time*.

---

## 📦 3. Daftar Komponen di Tab

```lua
local Tab = Window:CreateTab("Main", "🔥")

-- A. Section (Pemisah Kategori)
Tab:CreateSection("Fitur Karakter")

-- B. Button (Tombol dengan Efek Tekan 3D Balok)
Tab:CreateButton("Speed Boost 32", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 32
end)

-- C. Toggle (Switch Bouncy ON/OFF)
-- 1. Toggle Standar
local myToggle = Tab:CreateToggle("Auto Sprint", false, function(state)
    print("Toggle State:", state)
end)
-- myToggle:SetValue(true)
-- local val = myToggle:GetValue()

-- 2. Toggle dengan Inline Color Picker (Hemat Tempat, ada tombol swatch di kanan switch)
Tab:CreateToggle("Tampilkan FOV Circle", true, function(state)
    print("FOV Active:", state)
end, {
    Color = {
        Default = Color3.fromRGB(0, 255, 255),
        Callback = function(newCol)
            print("Warna FOV dipilih:", newCol)
        end
    }
})

-- 3. Toggle dengan Inline Keybinds (Bisa memanggil 1 atau beberapa Keybind sekaligus di dalam kartu toggle!)
Tab:CreateToggle("Underground Active", false, function(state)
    print("Underground Active:", state)
end, {
    Keybinds = {
        {
            Label = "Toggle",
            Default = Enum.KeyCode.V,
            Callback = function(newKey)
                print("Keybind Toggle diubah ke:", newKey.Name)
            end
        },
        {
            Label = "Turun",
            Default = Enum.KeyCode.Z,
            Callback = function(newKey)
                print("Keybind Turun diubah ke:", newKey.Name)
            end
        },
        {
            Label = "Naik",
            Default = Enum.KeyCode.X,
            Callback = function(newKey)
                print("Keybind Naik diubah ke:", newKey.Name)
            end
        }
    }
})

-- D. Checkbox (Kotak Centang 2D Cartoon)
local myCheckbox = Tab:CreateCheckbox("Auto Collect Drops", true, function(state)
    print("Checkbox State:", state)
end)
-- myCheckbox:SetValue(false)
-- local isChecked = myCheckbox:GetValue()

-- E. Slider (Pengatur Angka dengan Badge Nilai Real-time)
local mySlider = Tab:CreateSlider("WalkSpeed", 16, 150, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
-- mySlider:SetValue(50)
-- local val = mySlider:GetValue()

-- F. Dropdown (Pilihan Menu Kartun)
local myDrop = Tab:CreateDropdown("Pilih Target", {"All", "Nearest", "Lowest HP"}, "Nearest", function(selected)
    print("Pilihan:", selected)
end)

-- G. Input / TextBox (Kolom Teks)
local myInput = Tab:CreateInput("Nama Pemain", "Ketik nama...", function(text, enterPressed)
    print("Input:", text)
end)

-- H. Keybind Selector (Pemilih Tombol Keyboard)
Tab:CreateKeybind("Keybind Menu", Enum.KeyCode.RightControl, function(newKey)
    Window:SetToggleKey(newKey)
end)

-- I. Color Picker (Palet Warna Kartun & Input RGB)
local myColor = Tab:CreateColorPicker("ESP Color", Color3.fromRGB(255, 107, 107), function(color)
    print("Warna dipilih:", color)
end)
-- myColor:SetColor(Color3.fromRGB(0, 255, 120))
-- local curColor = myColor:GetColor()

-- J. Divider (Garis Pemisah Kartun)
Tab:CreateDivider() -- Garis pemisah polos
Tab:CreateDivider("PENGATURAN TAMBAHAN") -- Garis pemisah dengan teks tengah

-- K. Label Info / Banner
local myLabel = Tab:CreateLabel("Script aman & terproteksi!", "💡")
-- myLabel:SetText("Teks baru!")
```

---

## 🎯 4. Custom Cursor & Tooltips

### 🖱️ Custom Cursor (Emoji / Icon Kartun)
Ganti cursor mouse bawaan Roblox dengan ikon kartun kustom:
```lua
-- Menggunakan Emoji / Icon kustom
CartoonUI.SetCursor({
    Icon = "🎯",                           -- Emoji atau karakter cursor ("🎯", "⚔️", "✨")
    Size = 24,                             -- Ukuran cursor
    Color = Color3.fromRGB(255, 217, 61)   -- Warna cursor
})

-- Reset kembali ke cursor bawaan Roblox:
CartoonUI.SetCursor(nil)
-- atau: Window:SetCursor(nil)
```

### 💬 Tooltips (Hover Bubble Kartun)
Bisa dipasang pada tombol header atau elemen GUI mana pun:
```lua
-- Pasang tooltip pada tombol header:
Window:AddHeaderButton("⚙️", function()
    print("Settings clicked!")
end, Color3.fromRGB(142, 108, 239), "Buka Pengaturan Cepat")

-- Pasang tooltip pada elemen GUI apa saja:
local myButton = Tab:CreateButton("Hapus Sampah", function() end)
Window:AttachTooltip(myButton.Button, "Klik untuk menghapus part yang tidak digunakan")
```

---

## 🔔 5. Notifikasi Bawaan

```lua
Window:Notify("Judul Notifikasi", "Pesan notifikasi kartun pop-in!", 3, Color3.fromRGB(255, 217, 61))
```
