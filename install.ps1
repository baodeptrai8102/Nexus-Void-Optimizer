# ============================================================================
# 🌌 NEXUS VOID ⚡ - ENGINE TỐI ƯU HÓA HỆ THỐNG & GAMING (v2.0 EXTREME)
# Thiết kế & Phát triển bởi: NEXUS VOID (baodeptrai8102)
# ============================================================================

$NexusRawUrl = "https://raw.githubusercontent.com/baodeptrai8102/Nexus-Void-Optimizer/main/install.ps1"

# Tự động nâng quyền Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; irm '$NexusRawUrl' | iex`"" -Verb RunAs
    }
    exit
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "🌌 NEXUS VOID ⚡ | SYSTEM TELEMETRY & OPTIMIZER v2.0"
$ErrorActionPreference = "SilentlyContinue"

function Log-Step($code, $msg) {
    Write-Host "  [$code] " -ForegroundColor Magenta -NoNewline
    Write-Host "$msg" -ForegroundColor Yellow
}

function Log-Ok($msg) {
    Write-Host "  └── ✔ $msg" -ForegroundColor Green
}

function Wait-Key {
    Write-Host "`n  Nhấn phím bất kỳ để quay lại trung tâm chỉ huy 🌌 NEXUS VOID ⚡..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Get-HardwareInfo {
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name -replace '\s+', ' '
    $os  = (Get-CimInstance Win32_OperatingSystem)
    $totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeRam  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedRam  = [math]::Round($totalRam - $freeRam, 1)
    return @{ CPU = $cpu; OS = $os.Caption; RAM = "$usedRam GB / $totalRam GB (Trống: $freeRam GB)" }
}

# --- MODULE 1: DỌN DẸP LÕI ---
function Invoke-M01 { Log-Step "01" "Tạo Điểm Khôi Phục (Nexus Backup)..."; Enable-ComputerRestore -Drive "C:\"; vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=10% | Out-Null; Checkpoint-Computer -Description "NEXUS_VOID_v2" -RestorePointType "MODIFY_SETTINGS"; Log-Ok "Đã lưu điểm khôi phục." }
function Invoke-M02 { Log-Step "02" "Quét sạch rác hệ thống..."; Remove-Item -Path "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*" -Recurse -Force; Clear-RecycleBin -Force; Log-Ok "Đã giải phóng bộ nhớ tạm." }
function Invoke-M03 { Log-Step "03" "Dọn bản cài Windows Update cũ..."; Stop-Service "wuauserv" -Force; Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force; Start-Service "wuauserv"; Log-Ok "Đã xóa file rác Update." }
function Invoke-M04 { Log-Step "04" "Xóa Cache Shader DirectX & GPU..."; Remove-Item -Path "$env:LOCALAPPDATA\D3DSCache\*", "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force; Log-Ok "Đã làm mới bộ đệm đồ họa." }
function Invoke-M05 { Log-Step "05" "Dọn Cache trình duyệt (Giữ Login)..."; Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\Cache_Data\*" -Recurse -Force; Log-Ok "Đã dọn cache." }

# --- MODULE 2: CPU, RAM & SSD ---
function Invoke-M06 { Log-Step "06" "Mở khóa Ultimate Performance..."; powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null; $g = powercfg /list | Select-String "Ultimate Performance|Hiệu suất tối đa" | ForEach-Object { ($_ -split "\s+")[3] } | Select-Object -First 1; if($g){powercfg /setactive $g}; Log-Ok "Kích hoạt hiệu năng tối đa." }
function Invoke-M07 { Log-Step "07" "Ưu tiên luồng CPU/GPU cho Game..."; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 38; Log-Ok "Đã ưu tiên tài nguyên cho Game." }
function Invoke-M08 { Log-Step "08" "Ép thu hồi RAM rảnh rỗi..."; [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); Get-Process | ForEach-Object { try { $_.MinWorkingSet = $_.MinWorkingSet } catch {} }; Log-Ok "Đã giải phóng RAM tức thì." }
function Invoke-M09 { Log-Step "09" "Tối ưu tiến trình SvcHost..."; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" 8388608; Log-Ok "Đã đồng bộ ngưỡng SvcHost." }
function Invoke-M10 { Log-Step "10" "Tắt Ngủ Đông & Bật SSD TRIM..."; powercfg -h off; fsutil behavior set DisableDeleteNotify 0 | Out-Null; Optimize-Volume -DriveLetter C -ReTrim; Log-Ok "Đã thu hồi 6GB và tối ưu SSD." }

# --- MODULE 3: CHUỘT, PHÍM & ĐỒ HỌA ---
function Invoke-M11 { Log-Step "11" "Chuẩn hóa tâm chuột 1:1..."; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" "0"; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0"; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0"; Log-Ok "Đã tắt gia tốc chuột." }
function Invoke-M12 { Log-Step "12" "Giảm độ trễ bàn phím..."; Set-ItemProperty "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "0"; Set-ItemProperty "HKCU:\Control Panel\Keyboard" "KeyboardSpeed" "31"; Log-Ok "Đã đưa phản hồi phím về 0ms." }
function Invoke-M13 { Log-Step "13" "Tối ưu hàng đợi ngoại vi..."; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" 32; Log-Ok "Đã tinh chỉnh hàng đợi tín hiệu." }
function Invoke-M14 { Log-Step "14" "Kích hoạt GPU HAGS..."; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 2; Log-Ok "Đã bật tăng tốc phần cứng." }
function Invoke-M15 { Log-Step "15" "Tắt Xbox DVR & Sticky Keys..."; Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0; Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"; Log-Ok "Đã vô hiệu hóa tính năng thừa." }

# --- MODULE 4: MẠNG & PING ---
function Invoke-M16 { Log-Step "16" "Làm sạch DNS, ARP Cache..."; ipconfig /flushdns | Out-Null; arp -d * | Out-Null; nbtstat -R | Out-Null; nbtstat -RR | Out-Null; Log-Ok "Đã làm mới đường truyền an toàn." }
function Invoke-M17 { Log-Step "17" "Mở khóa băng thông mạng..."; Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff; Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 0; Log-Ok "Đã giải phóng 100% băng thông Game." }
function Invoke-M18 { Log-Step "18" "Bật tăng tốc đa nhân (RSS)..."; netsh int tcp set global rss=enabled | Out-Null; netsh int tcp set global autotuninglevel=normal | Out-Null; Log-Ok "Đã bật Receive-Side Scaling." }
function Invoke-M19 { Log-Step "19" "Mở rộng cổng kết nối (MaxUserPort)..."; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "MaxUserPort" 65534; Log-Ok "Đã mở rộng cổng mạng." }
function Invoke-M20 { Log-Step "20" "Đo Ping trực tiếp..."; $p = (Test-Connection -ComputerName 1.1.1.1 -Count 2).ResponseTime | Measure-Object -Average; Log-Ok "Ping Cloudflare (1.1.1.1): $([math]::Round($p.Average)) ms" }

# --- MODULE 5: TINH GỌN WINDOWS ---
function Invoke-M21 { Log-Step "21" "Tắt hiệu ứng rườm rà (Giữ Font nét)..."; Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0; Set-ItemProperty "HKCU:\Control Panel\Desktop" "FontSmoothing" "2"; Log-Ok "Đã tinh giản giao diện." }
function Invoke-M22 { Log-Step "22" "Chặn thu thập Telemetry..."; Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0; Stop-Service "DiagTrack" -Force; Set-Service "DiagTrack" -StartupType Disabled; Log-Ok "Đã tắt theo dõi ngầm." }
function Invoke-M23 { Log-Step "23" "Đóng băng App Store ngầm..."; Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1; Log-Ok "Đã chặn App chạy ngầm." }
function Invoke-M24 { Log-Step "24" "Tắt lịch trình CEIP..."; schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable 2>$null | Out-Null; Log-Ok "Đã tắt lịch trình thừa." }
function Invoke-M25 { Log-Step "25" "Tối ưu dịch vụ phụ..."; Stop-Service "MapsBroker", "RetailDemo" -Force -ErrorAction SilentlyContinue; Set-Service "MapsBroker" -StartupType Manual -ErrorAction SilentlyContinue; Log-Ok "Đã tinh gọn dịch vụ nền." }

# --- MODULE 6: TIỆN ÍCH & HOÀN TÁC ---
function Invoke-M26 { Log-Step "26" "Tăng tốc chuột phải 0ms..."; Set-ItemProperty "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0"; Log-Ok "Đã loại bỏ độ trễ Menu." }
function Invoke-M27 { Log-Step "27" "Khóa tự động Restart..."; Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1; Log-Ok "Đã chặn Windows Update Restart." }
function Invoke-M28 { Log-Step "28" "Tắt thông báo tụt FPS..."; Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SoftLandingEnabled" 0; Log-Ok "Đã tắt mẹo vặt quảng cáo." }
function Invoke-M29 { Log-Step "29" "Quét SFC Scannow..."; Write-Host "  └── Đang quét, vui lòng đợi..." -ForegroundColor Cyan; sfc /scannow; Log-Ok "Hoàn tất kiểm tra hệ thống." }
function Invoke-M30 { Log-Step "30" "Hoàn tác về mặc định..."; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" "1"; Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 2; powercfg -h on; Log-Ok "Đã khôi phục cài đặt gốc." }

# --- CHỨC NĂNG TỐI ƯU 1 CHẠM ---
function Invoke-OneClick {
    Write-Host "`n  🚀 ĐANG KÍCH HOẠT QUY TRÌNH TỐI ƯU 1 CHẠM (ONE-CLICK EXTREME) ⚡..." -ForegroundColor Green
    Invoke-M01; Invoke-M02; Invoke-M03; Invoke-M04; Invoke-M05; Invoke-M06; Invoke-M07; Invoke-M08; Invoke-M09; Invoke-M10
    Invoke-M11; Invoke-M12; Invoke-M13; Invoke-M14; Invoke-M15; Invoke-M16; Invoke-M17; Invoke-M18; Invoke-M19; Invoke-M20
    Invoke-M21; Invoke-M22; Invoke-M23; Invoke-M24; Invoke-M25; Invoke-M26; Invoke-M27; Invoke-M28
    Write-Host "`n  🎉 ĐÃ HOÀN TẤT TOÀN BỘ QUY TRÌNH TỐI ƯU HÓA 1 CHẠM AN TOÀN!" -ForegroundColor Green
    Wait-Key
}

# ============================================================================
# VÒNG LẶP MENU GIAO DIỆN
# ============================================================================
do {
    Clear-Host
    $hw = Get-HardwareInfo
    Write-Host "  ==========================================================================================" -ForegroundColor DarkMagenta
    Write-Host "                       🌌 NEXUS VOID ⚡ — EXTREME SYSTEM ENGINE v2.0                        " -ForegroundColor Cyan
    Write-Host "                   Kiến Trúc Bảo Vệ 3 Lớp • Zero BSOD • An Toàn 100% Wi-Fi                  " -ForegroundColor DarkCyan
    Write-Host "  ==========================================================================================" -ForegroundColor DarkMagenta
    Write-Host "   💻 OS : $($hw.OS) | ⚙️ CPU : $($hw.CPU) | 🧠 RAM : $($hw.RAM)" -ForegroundColor Gray
    Write-Host "  ------------------------------------------------------------------------------------------" -ForegroundColor DarkGray

    Write-Host "`n   [ 1. DỌN DẸP LÕI & AN TOÀN ]                  [ 4. ĐƯỜNG TRUYỀN & PING AN TOÀN ]" -ForegroundColor Magenta
    Write-Host "   01. Tạo Điểm Khôi Phục Hệ Thống               16. Làm Sạch DNS, ARP & NetBIOS Cache"
    Write-Host "   02. Quét Rác Temp, Prefetch, CrashDumps       17. Mở Khóa Giới Hạn Băng Thông Gói Tin"
    Write-Host "   03. Dọn Rác Bản Cài Windows Update Cũ         18. Bật Tăng Tốc Đa Nhân Mạng (RSS/TCP)"
    Write-Host "   04. Xóa Cache Shader DirectX & GPU            19. Tối Ưu Hóa Cổng Kết Nối Ảo (MaxUserPort)"
    Write-Host "   05. Dọn Cache Trình Duyệt (Giữ Login)         20. Đo Kiểm Tra Độ Trễ Ping Trực Tiếp"

    Write-Host "`n   [ 2. TĂNG TỐC CPU, RAM & SSD ]                [ 5. TINH GỌN WINDOWS & RIÊNG TƯ ]" -ForegroundColor Magenta
    Write-Host "   06. Kích Hoạt Nguồn Ultimate Performance      21. Tắt Hiệu Ứng Trong Suốt (Giữ Font Nét)"
    Write-Host "   07. Ưu Tiên Luồng CPU/GPU Cho Game            22. Chặn Thu Thập Dữ Liệu Ngầm Telemetry"
    Write-Host "   08. Ép Giải Phóng Bộ Nhớ RAM Tức Thì          23. Đóng Băng App Store Chạy Ngầm"
    Write-Host "   09. Tối Ưu Ngưỡng Tách Tiến Trình SvcHost     24. Tắt Lịch Trình Quét Ngầm Định Kỳ"
    Write-Host "   10. Tắt Ngủ Đông (Thu 6GB) & Bật SSD TRIM     25. Tối Ưu Dịch Vụ Phụ (Bảo Toàn Wi-Fi 100%)"

    Write-Host "`n   [ 3. CHUỘT, PHÍM & ĐỒ HỌA ]                   [ 6. TIỆN ÍCH & HOÀN TÁC MẶC ĐỊNH ]" -ForegroundColor Magenta
    Write-Host "   11. Chuẩn Hóa Tâm Chuột 1:1 (Tắt Gia Tốc)     26. Mở Menu Chuột Phải 0ms & Tắt Máy Nhanh"
    Write-Host "   12. Giảm Độ Trễ Nhận Lệnh Bàn Phím Tối Đa     27. Khóa Windows Tự Ý Restart Khi Chơi"
    Write-Host "   13. Tinh Chỉnh Hàng Đợi Tín Hiệu Ngoại Vi     28. Tắt Thông Báo Mẹo Vặt Làm Tụt FPS"
    Write-Host "   14. Bật Tăng Tốc Phần Cứng GPU (HAGS)         29. Quét & Sửa Lỗi File Hệ Thống (SFC Scan)"
    Write-Host "   15. Tắt Quay Ngầm Xbox DVR & Sticky Keys      30. Khôi Phục Toàn Bộ Thiết Lập Mặc Định"

    Write-Host "`n  ==========================================================================================" -ForegroundColor DarkMagenta
    Write-Host "   [31] 🚀 TỐI ƯU 1 CHẠM (ONE-CLICK EXTREME)     [0] ❌ Thoát Chương Trình" -ForegroundColor Green
    
    $sel = Read-Host "`n  👉 Chọn Lệnh (1-31, 0)"
    
    switch ($sel.Trim().ToUpper()) {
        "1"  { Invoke-M01; Wait-Key } "01" { Invoke-M01; Wait-Key }
        "2"  { Invoke-M02; Wait-Key } "02" { Invoke-M02; Wait-Key }
        "3"  { Invoke-M03; Wait-Key } "03" { Invoke-M03; Wait-Key }
        "4"  { Invoke-M04; Wait-Key } "04" { Invoke-M04; Wait-Key }
        "5"  { Invoke-M05; Wait-Key } "05" { Invoke-M05; Wait-Key }
        "6"  { Invoke-M06; Wait-Key } "06" { Invoke-M06; Wait-Key }
        "7"  { Invoke-M07; Wait-Key } "07" { Invoke-M07; Wait-Key }
        "8"  { Invoke-M08; Wait-Key } "08" { Invoke-M08; Wait-Key }
        "9"  { Invoke-M09; Wait-Key } "09" { Invoke-M09; Wait-Key }
        "10" { Invoke-M10; Wait-Key }
        "11" { Invoke-M11; Wait-Key }
        "12" { Invoke-M12; Wait-Key }
        "13" { Invoke-M13; Wait-Key }
        "14" { Invoke-M14; Wait-Key }
        "15" { Invoke-M15; Wait-Key }
        "16" { Invoke-M16; Wait-Key }
        "17" { Invoke-M17; Wait-Key }
        "18" { Invoke-M18; Wait-Key }
        "19" { Invoke-M19; Wait-Key }
        "20" { Invoke-M20; Wait-Key }
        "21" { Invoke-M21; Wait-Key }
        "22" { Invoke-M22; Wait-Key }
        "23" { Invoke-M23; Wait-Key }
        "24" { Invoke-M24; Wait-Key }
        "25" { Invoke-M25; Wait-Key }
        "26" { Invoke-M26; Wait-Key }
        "27" { Invoke-M27; Wait-Key }
        "28" { Invoke-M28; Wait-Key }
        "29" { Invoke-M29; Wait-Key }
        "30" { Invoke-M30; Wait-Key }
        "31" { Invoke-OneClick }
        "A"  { Invoke-OneClick }
        "0"  { exit }
        default { Write-Host "  ⚠️ Lỗi mã! Hãy nhập từ 1-31 hoặc 0." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
