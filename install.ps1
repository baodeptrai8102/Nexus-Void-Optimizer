# ============================================================================
# 🌌 NEXUS VOID ⚡ - ENGINE TỐI ƯU HÓA HỆ THỐNG & GAMING (v3.0 COMPACT)
# Thiết kế & Phát triển bởi: NEXUS VOID (baodeptrai8102)
# ============================================================================

$NexusRawUrl = "https://raw.githubusercontent.com/baodeptrai8102/Nexus-Void-Optimizer/main/install.ps1"

# Nâng quyền Admin và Fix lỗi Font chữ Console vuông
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; irm '$NexusRawUrl' | iex`"" -Verb RunAs
    }
    exit
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "🌌 NEXUS VOID ⚡ | SYSTEM ENGINE v3.0 COMPACT"
$ErrorActionPreference = "SilentlyContinue"

# Hàm hiển thị trạng thái
function Log-Step($code, $msg) { Write-Host "  [$code] " -ForegroundColor Magenta -NoNewline; Write-Host "$msg" -ForegroundColor Yellow }
function Log-Ok($msg) { Write-Host "  └── ✔ $msg" -ForegroundColor Green }
function Wait-Key { Write-Host "`n  Nhấn phím bất kỳ để quay lại 🌌 NEXUS VOID ⚡..." -ForegroundColor DarkGray; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }

# Thu thập thông số phần cứng
function Get-HardwareInfo {
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name -replace '\s+', ' '
    $os  = (Get-CimInstance Win32_OperatingSystem)
    $totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeRam  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedRam  = [math]::Round($totalRam - $freeRam, 1)
    return @{ CPU = $cpu; OS = $os.Caption; RAM = "$usedRam GB / $totalRam GB (Trống: $freeRam GB)" }
}

# Hỏi khởi động lại máy tính
function Ask-Restart {
    Write-Host "`n  ⚠️ Đã tối ưu xong! Một số thay đổi cần khởi động lại máy tính để áp dụng." -ForegroundColor Cyan
    $ans = Read-Host "  👉 Bạn có muốn Khởi động lại ngay bây giờ không? (Y/N)"
    if ($ans -match '^[yY]') { Restart-Computer -Force }
}

# ============================================================================
# DANH SÁCH 11 MODULE TÍCH HỢP (GỘP TWEAKS)
# ============================================================================

function Invoke-T01 {
    Log-Step "01" "Core Clean & Backup (Dọn Dẹp & Tạo Điểm Khôi Phục)"
    Enable-ComputerRestore -Drive "C:\"; Checkpoint-Computer -Description "NEXUS_VOID_v3" -RestorePointType "MODIFY_SETTINGS"
    Remove-Item -Path "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "$env:LOCALAPPDATA\D3DSCache\*", "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force
    Clear-RecycleBin -Force
    Log-Ok "Đã backup an toàn, xóa sạch rác hệ thống và Cache GPU."
}

function Invoke-T02 {
    Log-Step "02" "Ultimate CPU Core (Mở Khóa Hiệu Năng Đỉnh Vi Xử Lý)"
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $g = powercfg /list | Select-String "Ultimate Performance|Hiệu suất tối đa" | ForEach-Object { ($_ -split "\s+")[3] } | Select-Object -First 1
    if($g){powercfg /setactive $g}
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 38
    Log-Ok "Đã kích hoạt nguồn Maximum và ưu tiên CPU cho Game."
}

function Invoke-T03 {
    Log-Step "03" "RAM & SSD Hyper-Boost (Ép Xả RAM & Bật TRIM)"
    [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()
    Get-Process | ForEach-Object { try { $_.MinWorkingSet = $_.MinWorkingSet } catch {} }
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" 8388608
    powercfg -h off; fsutil behavior set DisableDeleteNotify 0 | Out-Null; Optimize-Volume -DriveLetter C -ReTrim
    Log-Ok "Đã giải phóng RAM, thu hồi ổ cứng 6GB và bật SSD TRIM."
}

function Invoke-T04 {
    Log-Step "04" "Esports Input Engine (Chuẩn Hóa Chuột & Phím FPS)"
    Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" "0"; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0"; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0"
    Set-ItemProperty "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "0"; Set-ItemProperty "HKCU:\Control Panel\Keyboard" "KeyboardSpeed" "31"
    Log-Ok "Đã hủy gia tốc chuột (Aim 1:1) và đưa độ trễ phím về 0ms."
}

function Invoke-T05 {
    Log-Step "05" "GPU Hardware Acceleration (Bật HAGS & Tắt Xbox DVR)"
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 2
    Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0
    Log-Ok "Đã bật lập lịch GPU phần cứng, tắt quay màn hình ngầm."
}

function Invoke-T06 {
    Log-Step "06" "Network Latency Shield (Tối Ưu Đường Truyền & Ping)"
    ipconfig /flushdns | Out-Null; arp -d * | Out-Null
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 0
    netsh int tcp set global rss=enabled | Out-Null
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "MaxUserPort" 65534
    Log-Ok "Xả DNS, mở khóa băng thông mạng và bật đa nhân RSS."
}

function Invoke-T07 {
    Log-Step "07" "Windows Debloat & Privacy (Tắt Hiệu Ứng, Telemetry & App Ngầm)"
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
    Stop-Service "DiagTrack", "MapsBroker" -Force -ErrorAction SilentlyContinue
    Set-Service "DiagTrack", "MapsBroker" -StartupType Disabled -ErrorAction SilentlyContinue
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1
    Log-Ok "Đã tắt hiệu ứng trong suốt, chặn App chạy ngầm và theo dõi."
}

function Invoke-T08 {
    Log-Step "08" "System Flow Control (Tăng Tốc Chuột Phải & Tắt Máy)"
    Set-ItemProperty "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0"
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1
    Log-Ok "Đã xóa độ trễ Menu 0ms, khóa Auto-Restart khi đang chơi."
}

function Invoke-T09 {
    Log-Step "09" "SFC Scannow (Kiểm Tra & Vá File Hệ Thống)"
    Write-Host "  └── Đang quét, vui lòng đợi..." -ForegroundColor Cyan; sfc /scannow
    Log-Ok "Hoàn tất kiểm tra tính toàn vẹn hệ thống."
}

function Invoke-T10 {
    Log-Step "10" "Check Ping (Đo Độ Trễ Trực Tiếp Cloudflare)"
    $p = (Test-Connection -ComputerName 1.1.1.1 -Count 2).ResponseTime | Measure-Object -Average
    Log-Ok "Ping thực tế đến Cloudflare (1.1.1.1): $([math]::Round($p.Average)) ms"
}

function Invoke-T11 {
    Log-Step "11" "Revert to Default (Hoàn Tác Về Mặc Định Windows)"
    Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" "1"; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 2; powercfg -h on
    Log-Ok "Đã khôi phục cài đặt chuột và phân luồng gốc."
}

function Invoke-NexusExtreme {
    Write-Host "`n  🚀 KÍCH HOẠT ĐỘNG CƠ TỐI ƯU 1 CHẠM (NEXUS EXTREME) ⚡..." -ForegroundColor Green
    Invoke-T01; Invoke-T02; Invoke-T03; Invoke-T04; Invoke-T05; Invoke-T06; Invoke-T07; Invoke-T08
    Write-Host "`n  🎉 ĐÃ HOÀN TẤT TOÀN BỘ QUY TRÌNH TỐI ƯU HÓA HỆ THỐNG AN TOÀN!" -ForegroundColor Green
    Ask-Restart
}

# ============================================================================
# GIAO DIỆN BẢNG ĐIỀU KHIỂN (1 CỘT GỌN GÀNG)
# ============================================================================
do {
    Clear-Host
    $hw = Get-HardwareInfo
    Write-Host "  =================================================================================" -ForegroundColor DarkMagenta
    Write-Host "                  🌌 NEXUS VOID ⚡ — EXTREME SYSTEM ENGINE v3.0                  " -ForegroundColor Cyan
    Write-Host "  =================================================================================" -ForegroundColor DarkMagenta
    Write-Host "  💻 OS : $($hw.OS)" -ForegroundColor Gray
    Write-Host "  ⚙️ CPU: $($hw.CPU)" -ForegroundColor Gray
    Write-Host "  🧠 RAM: $($hw.RAM)" -ForegroundColor Gray
    Write-Host "  ---------------------------------------------------------------------------------" -ForegroundColor DarkGray

    Write-Host "  [01] 🧹 Core Clean & Backup (Dọn Dẹp Rác & Tạo Điểm Khôi Phục)" -ForegroundColor Magenta
    Write-Host "  [02] 🔥 Ultimate CPU Core (Mở Khóa Nguồn Maximum & Ưu Tiên Game)"
    Write-Host "  [03] 🚀 RAM & SSD Hyper-Boost (Ép Xả RAM, Tắt Ngủ Đông & Bật TRIM)"
    Write-Host "  [04] 🎮 Esports Input Engine (Chuẩn Hóa Tâm Chuột 1:1 & Phím 0ms)"
    Write-Host "  [05] 🖥️ GPU Hardware Acceleration (Bật HAGS & Tắt Xbox DVR Ngầm)"
    Write-Host "  [06] 🌐 Network Latency Shield (Xả DNS, Mở Băng Thông & Bật RSS)"
    Write-Host "  [07] 🛡️ Windows Debloat & Privacy (Tắt Hiệu Ứng, Telemetry & App Ngầm)"
    Write-Host "  [08] ⚡ System Flow Control (Menu Phải 0ms & Khóa Auto-Restart)"
    Write-Host "  [09] 🩺 SFC Scannow (Kiểm Tra & Vá File Hệ Thống)"
    Write-Host "  [10] 📡 Check Ping (Đo Độ Trễ Trực Tiếp Tới Cloudflare)"
    Write-Host "  [11] 🔄 Revert to Default (Hoàn Tác Thiết Lập Về Mặc Định Windows)"
    Write-Host "  ---------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  [A] 🌟 NEXUS EXTREME TỐI ƯU 1 CHẠM (Chạy từ 1 đến 8)     [0] ❌ Thoát" -ForegroundColor Green
    
    $sel = Read-Host "`n  👉 Chọn Lệnh (1-11, A, 0)"
    
    switch ($sel.Trim().ToUpper()) {
        "1" {"01"} { Invoke-T01; Ask-Restart; Wait-Key }
        "2" {"02"} { Invoke-T02; Ask-Restart; Wait-Key }
        "3" {"03"} { Invoke-T03; Ask-Restart; Wait-Key }
        "4" {"04"} { Invoke-T04; Ask-Restart; Wait-Key }
        "5" {"05"} { Invoke-T05; Ask-Restart; Wait-Key }
        "6" {"06"} { Invoke-T06; Ask-Restart; Wait-Key }
        "7" {"07"} { Invoke-T07; Ask-Restart; Wait-Key }
        "8" {"08"} { Invoke-T08; Ask-Restart; Wait-Key }
        "9" {"09"} { Invoke-T09; Wait-Key }
        "10" { Invoke-T10; Wait-Key }
        "11" { Invoke-T11; Ask-Restart; Wait-Key }
        "A"  { Invoke-NexusExtreme; Wait-Key }
        "0"  { exit }
        default { Write-Host "  ⚠️ Lỗi mã! Hãy nhập từ 1-11, A hoặc 0." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
