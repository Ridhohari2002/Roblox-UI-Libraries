================================================================================
                  🎨 PANDUAN PENGGUNAAN 2D CARTOON UI LIBRARY
                       (Dibuat Khusus untuk Roblox Script)
================================================================================

Daftar Isi:
1. Pengenalan & Fitur Unggulan
2. Cara Upload ke GitHub & Mengambil Link Raw
3. Cara Memanggil Library di Script Baru
4. Konfigurasi Awal Window (Tampilan Pertama)
5. Tombol Header & Right Side Buttons
6. Floating Button (Tombol Melayang) & Minimize System
7. Daftar Lengkap Komponen UI (Buttons, Toggles, Sliders, dll)
8. Panduan Khusus: Pop-Up Cards Stealer & Filter Rarity
9. Contoh Kode Script Siap Pakai (Full Example)

================================================================================
1. PENGENALAN & FITUR UNGGULAN
================================================================================
Library ini memiliki estetika 2D Cartoon modern dengan:
- Line-Art tebal (UIStroke 2.5 - 3.5px) khas game kartun (Brawl Stars, Pet Sim).
- Hard block drop shadow di belakang window dan tombol.
- Animasi membal (Squash, Stretch & Bouncy Tween dengan EasingStyle.Back).
- Bawaan Minimize (—/＋), Close (✕), dan Floating Button bulat (🎮).
- Custom Keybind yang bisa diubah pemain kapan saja melalui UI.
- Pop-Up Cards Scanner/Stealer dengan filter Rarity otomatis.

================================================================================
2. CARA UPLOAD KE GITHUB & MENGAMBIL LINK RAW
================================================================================
Agar library ini bisa dipanggil dari script mana saja:
1. Buka akun GitHub kamu di browser (https://github.com).
2. Buat repository baru (misal: "Roblox-UI-Libraries").
3. Upload file "UI 2D Cartoon.lua" ke repository tersebut.
   (Kamu bisa menamainya menjadi "2DCartoon.lua").
4. Klik file tersebut di GitHub, lalu klik tombol "Raw" di pojok kanan atas file.
5. Salin URL dari address bar browser.
   Contoh format URL yang benar:
   https://raw.githubusercontent.com/Ridhohari2002/Roblox-UI-Libraries/refs/heads/main/2DCartoon.lua

================================================================================
3. CARA MEMANGGIL LIBRARY DI SCRIPT BARU
================================================================================
Di awal script executor kamu, gunakan kode berikut:

local CartoonUI = loadstring(game:HttpGet("URL_RAW_GITHUB_KAMU"))()

-- Atau jika sedang testing offline di Roblox Studio:
-- local CartoonUI = loadfile("UI 2D Cartoon.lua")()

================================================================================
4. KONFIGURASI AWAL WINDOW (TAMPILAN PERTAMA)
================================================================================
Gunakan fungsi `CartoonUI.CreateWindow({...})` untuk membuat window:

local Window = CartoonUI.CreateWindow({
    Title = "Boyfinity HUB",                 -- Judul besar utama
    Subtitle = "by ridho hari",              -- Tulisan kecil di bawah judul
    Icon = "⚡",                             -- Logo (Bisa emoji "⚡" atau "rbxassetid://123456")
    ToggleKey = Enum.KeyCode.RightControl,   -- Tombol keyboard untuk buka/tutup UI
    Size = UDim2.new(0, 560, 0, 390),        -- Ukuran window (Lebar x Tinggi)
    
    -- Konfigurasi Tombol Melayang (Floating Button)
    FloatButton = {
        Enabled = true,                      -- true = aktif, false = disembunyikan
        Icon = "🎮",                         -- Emoji icon pada tombol melayang
        Position = UDim2.new(0, 25, 0.5, -27)
    },

    -- Tombol Tambahan di Kanan Atas Header (Right Side Buttons)
    RightButtons = {
        {
            Icon = "🃏",
            Tooltip = "Cards Stealer",
            Color = Color3.fromRGB(142, 108, 239),
            Callback = function()
                -- Aksi saat tombol ditekan (misal buka pop up)
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

================================================================================
5. FUNGSI BAWAAN WINDOW (WINDOW METHODS)
================================================================================
Objek `Window` memiliki fungsi praktis berikut:

- Window:SetTitle("Nama Baru")        --> Mengubah judul window
- Window:SetSubtitle("Subtitle Baru") --> Mengubah teks pembuat di bawah judul
- Window:SetToggleKey(Enum.KeyCode.Z) --> Mengubah tombol toggle UI
- Window:GetToggleKey()               --> Mendapatkan keybind aktif saat ini
- Window:Toggle()                     --> Membuka / Menutup window (fade in/out)
- Window:Minimize(true/false)         --> Mengecilkan / Membesarkan window
- Window:ToggleFloatButton(true/false)--> Memunculkan / Menyembunyikan tombol floating
- Window:Notify(title, msg, durasi, color) --> Menampilkan notifikasi kartun pop-in
- Window:Destroy()                    --> Menghapus ScreenGui dari game

================================================================================
6. CARA MEMBUAT TAB & KOMPONEN UI
================================================================================

-- A. MEMBUAT TAB BARU
local Tab = Window:CreateTab("Nama Tab", "🔥") -- (Nama, Emoji Icon)

-- B. SECTION LABEL (Pemisah Kategori)
Tab:CreateSection("Kategori Fitur")

-- C. BUTTON (Tombol 2D Kartun dengan Efek Tekan 3D)
Tab:CreateButton("Speed Boost 32", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 32
    Window:Notify("Speed", "WalkSpeed diubah ke 32!", 2.5)
end)

-- D. TOGGLE (Switch Kartun Bouncy ON / OFF)
local myToggle = Tab:CreateToggle("Auto Sprint", false, function(state)
    print("Status Toggle:", state) -- true atau false
end)
-- Mengubah nilai toggle dari script: myToggle:SetValue(true)
-- Mengambil nilai toggle: myToggle:GetValue()

-- E. SLIDER (Pengatur Angka Kartun dengan Badge Real-time)
local mySlider = Tab:CreateSlider("WalkSpeed", 16, 150, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
-- Mengubah slider dari script: mySlider:SetValue(50)
-- Mengambil angka slider: mySlider:GetValue()

-- F. DROPDOWN (Menu Pilihan Kartun)
local myDropdown = Tab:CreateDropdown("Pilih Target", {"All", "Nearest", "Lowest HP"}, "Nearest", function(selected)
    print("Pilihan:", selected)
end)

-- G. INPUT / TEXTBOX (Kolom Tulis Teks Kartun)
local myInput = Tab:CreateInput("Nama Pemain", "Ketik disini...", function(text, enterPressed)
    print("Teks diinput:", text)
end)

-- H. KEYBIND PICKER (Pemilih Tombol Keyboard)
Tab:CreateKeybind("Ganti Keybind Toggle", Enum.KeyCode.RightControl, function(newKey)
    Window:SetToggleKey(newKey)
end)

-- I. INFO LABEL (Kartu Informasi Bergambar)
Tab:CreateLabel("Script ini aman dari deteksi!", "💡")

================================================================================
7. PANDUAN POP-UP CARDS SCANNER & STEALER (FITUR BARU)
================================================================================
Fitur ini dirancang khusus untuk memindai kartu di `workspace.ActiveCards`:

Attributes yang dibaca otomatis per kartu:
- DisplayName  (contoh: Puskas)
- OriginalName (contoh: Puskas)
- Rarity       (contoh: Divine, Mythic, Legendary, Epic, Rare, Common)
- Level        (contoh: 1)
- Mutation     (contoh: Normal)

CARA MEMBUAT POP-UP:
-------------------------------------------------------------------------------
local CardsPopup = Window:CreateCardsPopup({
    Title = "Active Cards Stealer",
    CardsFolder = workspace:FindFirstChild("ActiveCards") or workspace,
    Rarities = {"All", "Divine", "Mythic", "Legendary", "Epic", "Rare", "Common"},
    
    -- Callback saat tombol "STEAL" pada kartu ditekan:
    OnSteal = function(cardObject, isStealing, cardData)
        print("Status Steal :", isStealing and "AKTIF" or "NONAKTIF")
        print("Nama Kartu   :", cardData.DisplayName)
        print("Rarity       :", cardData.Rarity)
        print("Level        :", cardData.Level)
        print("Mutation     :", cardData.Mutation)

        if isStealing then
            -- CONTOH: Teleport ke posisi kartu saat tombol STEAL ditekan
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetPart = cardObject:IsA("BasePart") and cardObject or cardObject:FindFirstChildWhichIsA("BasePart")
            if hrp and targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
            end
        else
            -- Logika saat tombol steal dimatikan
            print("Berhenti mencuri:", cardData.DisplayName)
        end
    end
})

CARA MENGONTROL POP-UP:
- CardsPopup:Open()    --> Membuka pop up
- CardsPopup:Close()   --> Menutup pop up
- CardsPopup:Toggle()  --> Buka jika tutup, tutup jika buka
- CardsPopup:Refresh() --> Memperbarui data list kartu

FITUR DI DALAM POP-UP:
1. Filter Rarity Pills di atas: Klik tombol All, Divine, Mythic, dll. untuk menyaring.
2. Search Bar: Ketik nama kartu untuk pencarian cepat.
3. Warna Rarity Kartun:
   - 👑 Divine    : Emas Mengkilap
   - 🔥 Mythic    : Merah Api
   - ⚡ Legendary : Oranye Terang
   - 🔮 Epic      : Ungu
   - 💎 Rare      : Cyan Biru
   - ⚪ Common    : Abu-abu
4. Real-time Auto Update: Otomatis mendeteksi kartu baru yang muncul atau kartu yang hilang.
5. Tombol STEAL (Hijau/Mint) berubah menjadi STEALING... (Merah) saat aktif.

================================================================================
8. CONTOH KODE SCRIPT PENUH (TINGGAL COPY-PASTE)
================================================================================

-- 1. Load library dari GitHub kamu:
local CartoonUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ridhohari2002/Roblox-UI-Libraries/refs/heads/main/2DCartoon.lua"))()

-- 2. Variabel penampung popup:
local CardsPopup

-- 3. Buat Window Tampilan Utama:
local Window = CartoonUI.CreateWindow({
    Title = "Boyfinity HUB",
    Subtitle = "by ridho hari",
    Icon = "⚡",
    ToggleKey = Enum.KeyCode.RightControl,
    Size = UDim2.new(0, 560, 0, 390),
    FloatButton = { Enabled = true, Icon = "🎮" },
    RightButtons = {
        {
            Icon = "🃏",
            Tooltip = "Cards Stealer",
            Color = Color3.fromRGB(142, 108, 239),
            Callback = function()
                if CardsPopup then CardsPopup:Toggle() end
            end
        }
    }
})

-- 4. Inisialisasi Pop-Up Cards:
CardsPopup = Window:CreateCardsPopup({
    Title = "Active Cards Stealer",
    CardsFolder = workspace:FindFirstChild("ActiveCards") or workspace,
    OnSteal = function(card, isStealing, data)
        if isStealing then
            Window:Notify("Mencuri", "Target: " .. data.DisplayName .. " [" .. data.Rarity .. "]", 2)
        end
    end
})

-- 5. Tambahkan Tab:
local MainTab = Window:CreateTab("Main", "🔥")

MainTab:CreateSection("Cards Stealer")
MainTab:CreateButton("Buka Pop-Up Cards (🃏)", function()
    CardsPopup:Open()
end)

MainTab:CreateSection("Fitur Karakter")
MainTab:CreateSlider("WalkSpeed", 16, 120, 16, function(v)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
    end
end)

local SettingsTab = Window:CreateTab("Settings", "⚙️")
SettingsTab:CreateKeybind("Keybind Toggle UI", Enum.KeyCode.RightControl, function(k)
    Window:SetToggleKey(k)
end)

SettingsTab:CreateToggle("Tampilkan Float Button", true, function(s)
    Window:ToggleFloatButton(s)
end)

-- Selesai! Script siap dijalankan di executor.
================================================================================
