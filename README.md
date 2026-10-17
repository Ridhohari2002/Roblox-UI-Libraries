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
local myToggle = Tab:CreateToggle("Auto Sprint", false, function(state)
    print("Toggle State:", state)
end)
-- myToggle:SetValue(true)
-- local val = myToggle:GetValue()

-- D. Slider (Pengatur Angka dengan Badge Nilai Real-time)
local mySlider = Tab:CreateSlider("WalkSpeed", 16, 150, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
-- mySlider:SetValue(50)
-- local val = mySlider:GetValue()

-- E. Dropdown (Pilihan Menu)
local myDrop = Tab:CreateDropdown("Pilih Target", {"All", "Nearest", "Lowest HP"}, "Nearest", function(selected)
    print("Pilihan:", selected)
end)

-- F. Input / TextBox (Kolom Teks)
local myInput = Tab:CreateInput("Nama Pemain", "Ketik nama...", function(text, enterPressed)
    print("Input:", text)
end)

-- G. Keybind Selector (Pemilih Tombol Keyboard)
Tab:CreateKeybind("Keybind Toggle UI", Enum.KeyCode.RightControl, function(newKey)
    Window:SetToggleKey(newKey)
end)

-- H. Label Info
Tab:CreateLabel("Script aman & terproteksi!", "💡")
```

---

## 🔔 4. Notifikasi Bawaan

```lua
Window:Notify("Judul Notifikasi", "Pesan notifikasi kartun pop-in!", 3, Color3.fromRGB(255, 217, 61))
```
