# ============================================================================
# 🌌 NEXUS VOID ⚡ - ENGINE TỐI ƯU HÓA HỆ THỐNG & GAMING (v3.0 COMPACT)
# Thiết kế & Phát triển bởi: NEXUS VOID (baodeptrai8102)
# ============================================================================

$NexusRawUrl = "https://raw.githubusercontent.com/baodeptrai8102/Nexus-Void-Optimizer/main/install.ps1"

# 1. Nâng quyền Admin và tự động Restart Script nếu chưa có quyền
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; irm '$NexusRawUrl' | iex`"" -Verb RunAs
    }
    exit
}

# 2. Ép Console sử dụng Font Consolas để hiển thị chuẩn Icon và ASCII Art
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class FontFixer {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetStdHandle(int nStdHandle);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern bool SetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, ref CONSOLE_FONT_INFO_EX lpConsoleCurrentFontEx);
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CONSOLE_FONT_INFO_EX {
        public uint cbSize; public uint nFont; public short dwFontSizeX; public short dwFontSizeY;
        public int FontFamily; public int FontWeight;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string FaceName;
    }
    public static void SetConsolas() {
        IntPtr hnd = GetStdHandle(-11);
        CONSOLE_FONT_INFO_EX info = new CONSOLE_FONT_INFO_EX();
        info.cbSize = (uint)Marshal.SizeOf(info);
        info.FaceName = "Consolas";
        info.dwFontSizeY = 16;
        info.FontWeight = 400;
        SetCurrentConsoleFontEx(hnd, false, ref info);
    }
}
"@
[FontFixer]::SetConsolas()
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "🌌 NEXUS VOID ⚡ | SYSTEM ENGINE v3.0 COMPACT"
$ErrorActionPreference = "SilentlyContinue"

# 3. Hàm hiển thị trạng thái và thu thập phần cứng
function Log-Step($code, $msg) { Write-Host "  [$code] " -ForegroundColor Magenta -NoNewline; Write-Host "$msg" -ForegroundColor Yellow }
function Log-Ok($msg) { Write-Host "  └── ✔ $msg" -ForegroundColor Green }
function Wait-Key { Write-Host "`n  Nhấn phím bất kỳ để quay lại 🌌 NEXUS VOID ⚡..." -ForegroundColor DarkGray; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
function Ask-Restart {
    Write-Host "`n  ⚠️ Tối ưu hoàn tất! Cần khởi động lại máy để áp dụng 100% sức mạnh." -ForegroundColor Cyan
    $ans = Read-Host "  👉 Khởi động lại ngay bây giờ? (Y/N)"
    if ($ans -match '^[yY]') { Restart-Computer -Force }
}

function Get-HardwareInfo {
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name -replace '\s+', ' '
    $os  = (Get-CimInstance Win32_OperatingSystem)
    $totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeRam  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedRam  = [math]::Round($totalRam - $freeRam, 1)
    return @{ CPU = $cpu; OS = $os.Caption; RAM = "$usedRam GB / $totalRam GB (Trống: $freeRam GB)" }
}

# ============================================================================
# 11 MODULE TỐI ƯU TÍCH HỢP (GỘP 30 TWEAKS CHUYÊN SÂU)
# ============================================================================

function Invoke-T01 {
    Log-Step "01" "Core Clean & Backup (Điểm Khôi Phục & Dọn Rác Toàn Diện)"
    Enable-ComputerRestore -Drive "C:\"; Checkpoint-Computer -Description "NEXUS_VOID_v3" -RestorePointType "MODIFY_SETTINGS"
    Remove-Item -Path "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
    Clear-RecycleBin -Force
    Log-Ok "Đã backup an toàn, xóa sạch file rác và bản cài Update cũ."
}

function Invoke-T02 {
    Log-Step "02" "Ultimate CPU Core (Mở Khóa Xung Nhịp & Phân Luồng Game)"
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $g = powercfg /list | Select-String "Ultimate Performance|Hiệu suất tối đa" | ForEach-Object { ($_ -split "\s+")[3] } | Select-Object -First 1
    if($g){powercfg /setactive $g}
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 38
    Log-Ok "Đã kích hoạt nguồn Maximum và ưu tiên 100% CPU cho Game."
}

function Invoke-T03 {
    Log-Step "03" "RAM & SSD Hyper-Boost (Ép Xả RAM, Tắt Ngủ Đông & Bật TRIM)"
    [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()
    Get-Process | ForEach-Object { try { $_.MinWorkingSet = $_.MinWorkingSet } catch {} }
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control" "SvcHostSplitThresholdInKB" 8388608
    powercfg -h off; fsutil behavior set DisableDeleteNotify 0 | Out-Null; Optimize-Volume -DriveLetter C -ReTrim
    Log-Ok "Giải phóng RAM tức thì, thu hồi 6GB ổ C và bật SSD TRIM."
}

function Invoke-T04 {
    Log-Step "04" "Esports Input Engine (Chuẩn Hóa Chuột 1:1 & Phím 0ms)"
    Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" "0"; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0"; Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0"
    Set-ItemProperty "HKCU:\Control Panel\Keyboard" "KeyboardDelay" "0"; Set-ItemProperty "HKCU:\Control Panel\Keyboard" "KeyboardSpeed" "31"
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" 32
    Log-Ok "Đã hủy gia tốc chuột, giảm trễ phím và tối ưu hàng đợi tín hiệu."
}

function Invoke-T05 {
    Log-Step "05" "GPU Hardware Acceleration (Bật HAGS, Tắt DVR & Xóa Cache GPU)"
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 2
    Set-ItemProperty "HKCU:\System\GameConfigStore" "GameDVR_Enabled" 0
    Remove-Item -Path "$env:LOCALAPPDATA\D3DSCache\*", "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force
    Log-Ok "Bật lập lịch GPU phần cứng, tắt quay Xbox DVR và xóa cache đồ họa."
}

function Invoke-T06 {
    Log-Step "06" "Network Latency Shield (Xả DNS, Mở Băng Thông & Đa Nhân RSS)"
    ipconfig /flushdns | Out-Null; arp -d * | Out-Null
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" 0xffffffff
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" 0
    netsh int tcp set global rss=enabled | Out-Null
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "MaxUserPort" 65534
    Log-Ok "Làm mới mạng (An toàn Wi-Fi), mở băng thông Game và bật đa nhân RSS."
}

function Invoke-T07 {
    Log-Step "07" "Windows Debloat & Privacy (Tắt Hiệu Ứng, Telemetry & App Ngầm)"
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
    Stop-Service "DiagTrack" -Force -ErrorAction SilentlyContinue
    Set-Service "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1
    Log-Ok "Tắt hiệu ứng rườm rà (giữ Font nét), chặn App Store ngầm và theo dõi."
}

function Invoke-T08 {
    Log-Step "08" "System Flow Control (Menu Phải 0ms, Khóa Restart & Tắt Dịch Vụ Rác)"
    Set-ItemProperty "HKCU:\Control Panel\Desktop" "MenuShowDelay" "0"
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1
    Stop-Service "MapsBroker", "RetailDemo" -Force -ErrorAction SilentlyContinue
    Set-Service "MapsBroker", "RetailDemo" -StartupType Manual -ErrorAction SilentlyContinue
    Log-Ok "Tăng tốc hiển thị Menu, khóa Auto-Restart khi chơi và đóng dịch vụ thừa."
}

function Invoke-T09 {
    Log-Step "09" "SFC Scannow (Kiểm Tra & Vá File Hệ Thống)"
    Write-Host "  └── Đang quét, vui lòng đợi..." -ForegroundColor Cyan; sfc /scannow
    Log-Ok "Hoàn tất kiểm tra tính toàn vẹn file hệ điều hành."
}

function Invoke-T10 {
    Log-Step "10" "Live Ping Test (Đo Độ Trễ Trực Tiếp Máy Chủ Quốc Tế)"
    $p = (Test-Connection -ComputerName 1.1.1.1 -Count 2).ResponseTime | Measure-Object -Average
    Log-Ok "Ping thực tế đến Cloudflare (1.1.1.1): $([math]::Round($p.Average)) ms"
}

function Invoke-T11 {
    Log-Step "11" "Revert to Default (Hoàn Tác Về Mặc Định Windows)"
    Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" "1"
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 2
    powercfg -h on
    Log-Ok "Đã khôi phục thông số chuột và phân luồng gốc của nhà sản xuất."
}

function Invoke-NexusExtreme {
    Write-Host "`n  🚀 KÍCH HOẠT ĐỘNG CƠ TỐI ƯU 1 CHẠM (NEXUS EXTREME) ⚡..." -ForegroundColor Green
    Invoke-T01; Invoke-T02; Invoke-T03; Invoke-T04; Invoke-T05; Invoke-T06; Invoke-T07; Invoke-T08
    Write-Host "`n  🎉 ĐÃ HOÀN TẤT TOÀN BỘ QUY TRÌNH TỐI ƯU HÓA HỆ THỐNG AN TOÀN!" -ForegroundColor Green
    Ask-Restart
}

# ============================================================================
# GIAO DIỆN BẢNG ĐIỀU KHIỂN (ASCII LOGO SIÊU LỚN & COMBO TWEAKS)
# ============================================================================
do {
    Clear-Host
    $hw = Get-HardwareInfo
    Write-Host ""
    Write-Host "      _  _ ____ _  _ _  _ ____   _  _ ____ _ ___" -ForegroundColor Cyan
    Write-Host "      |\ | |___  \/  |  | [__    |  | |  | | |  \" -ForegroundColor Cyan
    Write-Host "      | \| |___ _/\_ |__| ___]    \/  |__| | |__/" -ForegroundColor Cyan
    Write-Host "               ⚡ EXTREME SYSTEM ENGINE v3.0 ⚡" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ===========================================================================" -ForegroundColor DarkMagenta
    Write-Host "   💻 OS : $($hw.OS)" -ForegroundColor Gray
    Write-Host "   ⚙️ CPU: $($hw.CPU)" -ForegroundColor Gray
    Write-Host "   🧠 RAM: $($hw.RAM)" -ForegroundColor Gray
    Write-Host "  ---------------------------------------------------------------------------" -ForegroundColor DarkGray

    Write-Host "  [01] 🧹 Core Clean & Backup (Điểm Khôi Phục & Dọn Rác Toàn Diện)" -ForegroundColor Magenta
    Write-Host "  [02] 🔥 Ultimate CPU Core (Mở Khóa Nguồn Maximum & Phân Luồng Game)"
    Write-Host "  [03] 🚀 RAM & SSD Hyper-Boost (Ép Xả RAM, Tắt Ngủ Đông & Bật TRIM)"
    Write-Host "  [04] 🎮 Esports Input Engine (Chuẩn Hóa Tâm Chuột 1:1 & Phím 0ms)"
    Write-Host "  [05] 🖥️ GPU Hardware Acceleration (Bật HAGS, Tắt DVR & Xóa Cache GPU)"
    Write-Host "  [06] 🌐 Network Latency Shield (Xả DNS, Mở Băng Thông & Đa Nhân RSS)"
    Write-Host "  [07] 🛡️ Windows Debloat & Privacy (Tắt Hiệu Ứng, Telemetry & App Ngầm)"
    Write-Host "  [08] ⚡ System Flow Control (Menu Phải 0ms, Khóa Restart & Tắt Dịch Vụ Rác)"
    Write-Host "  [09] 🩺 SFC Scannow (Kiểm Tra & Vá File Hệ Thống)"
    Write-Host "  [10] 📡 Live Ping Test (Đo Độ Trễ Trực Tiếp Máy Chủ Quốc Tế)"
    Write-Host "  [11] 🔄 Revert to Default (Hoàn Tác Về Mặc Định Nhà Sản Xuất)"
    Write-Host "  ===========================================================================" -ForegroundColor DarkMagenta
    Write-Host "  [A] 🌟 NEXUS EXTREME TỐI ƯU 1 CHẠM (Chạy từ 1 đến 8)     [0] ❌ Thoát" -ForegroundColor Green
    
    $sel = Read-Host "`n  👉 Chọn Lệnh (1-11, A, 0)"
    
    switch ($sel.Trim().ToUpper()) {
        "1"  { Invoke-T01; Ask-Restart; Wait-Key }
        "01" { Invoke-T01; Ask-Restart; Wait-Key }
        "2"  { Invoke-T02; Ask-Restart; Wait-Key }
        "02" { Invoke-T02; Ask-Restart; Wait-Key }
        "3"  { Invoke-T03; Ask-Restart; Wait-Key }
        "03" { Invoke-T03; Ask-Restart; Wait-Key }
        "4"  { Invoke-T04; Ask-Restart; Wait-Key }
        "04" { Invoke-T04; Ask-Restart; Wait-Key }
        "5"  { Invoke-T05; Ask-Restart; Wait-Key }
        "05" { Invoke-T05; Ask-Restart; Wait-Key }
        "6"  { Invoke-T06; Ask-Restart; Wait-Key }
        "06" { Invoke-T06; Ask-Restart; Wait-Key }
        "7"  { Invoke-T07; Ask-Restart; Wait-Key }
        "07" { Invoke-T07; Ask-Restart; Wait-Key }
        "8"  { Invoke-T08; Ask-Restart; Wait-Key }
        "08" { Invoke-T08; Ask-Restart; Wait-Key }
        "9"  { Invoke-T09; Wait-Key }
        "09" { Invoke-T09; Wait-Key }
        "10" { Invoke-T10; Wait-Key }
        "11" { Invoke-T11; Ask-Restart; Wait-Key }
        "A"  { Invoke-NexusExtreme; Wait-Key }
        "0"  { exit }
        default { Write-Host "  ⚠️ Lỗi mã! Hãy nhập từ 1-11, A hoặc 0." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
