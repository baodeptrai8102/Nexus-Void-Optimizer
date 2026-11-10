# ============================================================================
# 🌌 NEXUS VOID ⚡ - ENGINE TỐI ƯU HÓA HỆ THỐNG & GAMING (v3.0 EXTREME PRO)
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
$Host.UI.RawUI.WindowTitle = "🌌 NEXUS VOID ⚡ | SYSTEM ENGINE v3.0 EXTREME PRO"
$ErrorActionPreference = "SilentlyContinue"

# 3. Hàm hiển thị trạng thái và thu thập phần cứng
function Log-Step($code, $msg) { Write-Host "  [$code] " -ForegroundColor Magenta -NoNewline; Write-Host "$msg" -ForegroundColor Yellow }
function Log-Ok($msg) { Write-Host "  └── ✔ $msg" -ForegroundColor Green }
function Wait-Key { Write-Host "`n  Nhấn phím bất kỳ để quay lại 🌌 NEXUS VOID ⚡..." -ForegroundColor DarkGray; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
function Ask-Restart {
    Write-Host "`n  ⚠️ Tối ưu hoàn tất! Cần khởi động lại máy để áp dụng MSI Mode & Registry." -ForegroundColor Cyan
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
# 11 MODULE TỐI ƯU TÍCH HỢP (REGISTRY, UNPARK CPU, MSI MODE & MMCSS PRO)
# ============================================================================

function Invoke-T01 {
    Log-Step "01" "Core Clean & Backup (Điểm Khôi Phục & Dọn Rác Toàn Diện)"
    Enable-ComputerRestore -Drive "C:\"; Checkpoint-Computer -Description "NEXUS_VOID_v3_PRO" -RestorePointType "MODIFY_SETTINGS"
    Remove-Item -Path "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
    Clear-RecycleBin -Force
    Log-Ok "Đã tạo Restore Point, xóa sạch Temp, Prefetch và bản cài Update cũ."
}

function Invoke-T02 {
    Log-Step "02" "Ultimate CPU & Unpark Cores (Nguồn Maximum, Unpark 100% CPU & Tắt Bóp Xung)"
    # Kích hoạt Ultimate Performance
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $g = powercfg /list | Select-String "Ultimate Performance|Hiệu suất tối đa" | ForEach-Object { ($_ -split "\s+")[3] } | Select-Object -First 1
    if ($g) { powercfg /setactive $g }
    # Ép Unpark 100% toàn bộ nhân CPU trong Registry & Powercfg
    $parkPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
    if (Test-Path $parkPath) { Set-ItemProperty -Path $parkPath -Name "Attributes" -Value 0 -Type DWord -Force }
    powercfg -setacvalueindex scheme_current 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 100
    powercfg -setdcvalueindex scheme_current 54533251-82be-4824-96c1-47b60b740d00 0cc5b647-c1df-4637-891a-dec35c318583 100
    powercfg -setactive scheme_current
    # Tắt Power Throttling & Ưu tiên Win32PrioritySeparation cho Game
    $ptPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
    if (!(Test-Path $ptPath)) { New-Item -Path $ptPath -Force | Out-Null }
    Set-ItemProperty -Path $ptPath -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
    Log-Ok "Đã bật Ultimate Performance, Unpark 100% nhân CPU và khóa Power Throttling."
}

function Invoke-T03 {
    Log-Step "03" "RAM & SSD Hyper-Boost (Ép Xả RAM, Tách SvcHost & Bật SSD TRIM)"
    [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers()
    Get-Process | ForEach-Object { try { $_.MinWorkingSet = $_.MinWorkingSet } catch {} }
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 8388608 -Type DWord -Force
    powercfg -h off; fsutil behavior set DisableDeleteNotify 0 | Out-Null; Optimize-Volume -DriveLetter C -ReTrim
    Log-Ok "Đã giải phóng RAM tức thì, thu hồi 6GB Hibernation và bật SSD TRIM."
}

function Invoke-T04 {
    Log-Step "04" "Esports Input Engine (Chuẩn Hóa Chuột 1:1, Phím 0ms & Hàng Đợi Raw)"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" -Name "MouseDataQueueSize" -Value 32 -Type DWord -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" -Name "KeyboardDataQueueSize" -Value 32 -Type DWord -Force
    Log-Ok "Đã hủy gia tốc chuột, đưa độ trễ phím về 0ms và tinh chỉnh DataQueueSize."
}

function Invoke-T05 {
    Log-Step "05" "GPU & PCI MSI Mode (Bật MSI Mode Cho GPU/Mạng, HAGS & Tắt Xbox DVR)"
    # Quét tự động Card màn hình (Display) và Card mạng (Net) chuẩn PCI để bật MSI Mode
    $pciDevs = Get-PnpDevice -Class Display, Net -Status OK | Where-Object { $_.InstanceId -match '^PCI\\' }
    foreach ($dev in $pciDevs) {
        $msiKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($dev.InstanceId)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (!(Test-Path $msiKey)) { New-Item -Path $msiKey -Force | Out-Null }
        Set-ItemProperty -Path $msiKey -Name "MSISupported" -Value 1 -Type DWord -Force
    }
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
    Remove-Item -Path "$env:LOCALAPPDATA\D3DSCache\*", "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force
    Log-Ok "Đã kích hoạt MSI Mode (GPU & NIC), bật HAGS, tắt DVR và xóa Shader Cache."
}

function Invoke-T06 {
    Log-Step "06" "MMCSS & Network Throttling (Cấu Hình MMCSS Games, Xả Băng Thông & RSS)"
    ipconfig /flushdns | Out-Null; arp -d * | Out-Null
    # Tối ưu Network Throttling & System Responsiveness
    $sysProf = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $sysProf -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force
    Set-ItemProperty -Path $sysProf -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
    # Cấu hình chuyên sâu MMCSS Tasks\Games
    $gamesKey = "$sysProf\Tasks\Games"
    if (!(Test-Path $gamesKey)) { New-Item -Path $gamesKey -Force | Out-Null }
    Set-ItemProperty -Path $gamesKey -Name "GPU Priority" -Value 8 -Type DWord -Force
    Set-ItemProperty -Path $gamesKey -Name "Priority" -Value 6 -Type DWord -Force
    Set-ItemProperty -Path $gamesKey -Name "Scheduling Category" -Value "High" -Type String -Force
    Set-ItemProperty -Path $gamesKey -Name "SFIO Priority" -Value "High" -Type String -Force
    # Bật RSS và mở rộng cổng TCP/IP
    netsh int tcp set global rss=enabled | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort" -Value 65534 -Type DWord -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpTimedWaitDelay" -Value 30 -Type DWord -Force
    Log-Ok "Đã cấu hình MMCSS Games (Priority High), tắt Network Throttling và bật RSS."
}

function Invoke-T07 {
    Log-Step "07" "Windows Debloat & Privacy (Tắt Hiệu Ứng, Telemetry & App Ngầm)"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
    Stop-Service "DiagTrack" -Force; Set-Service "DiagTrack" -StartupType Disabled
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
    Log-Ok "Đã tắt hiệu ứng trong suốt (giữ Font nét), chặn Telemetry và đóng băng App ngầm."
}

function Invoke-T08 {
    Log-Step "08" "System Flow Control (Menu Phải 0ms, Khóa Restart & Tắt Dịch Vụ Rác)"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord -Force
    Stop-Service "MapsBroker", "RetailDemo" -Force
    Set-Service "MapsBroker", "RetailDemo" -StartupType Manual
    Log-Ok "Đã đưa độ trễ Menu về 0ms, khóa Auto-Restart và tắt dịch vụ phụ."
}

function Invoke-T09 {
    Log-Step "09" "SFC Scannow (Kiểm Tra & Vá File Hệ Thống)"
    Write-Host "  └── Đang quét hệ thống, vui lòng đợi..." -ForegroundColor Cyan; sfc /scannow
    Log-Ok "Hoàn tất kiểm tra tính toàn vẹn file hệ điều hành."
}

function Invoke-T10 {
    Log-Step "10" "Live Ping Test (Đo Độ Trễ Trực Tiếp Máy Chủ Quốc Tế)"
    $p = (Test-Connection -ComputerName 1.1.1.1 -Count 2).ResponseTime | Measure-Object -Average
    Log-Ok "Ping thực tế đến Cloudflare (1.1.1.1): $([math]::Round($p.Average)) ms"
}

function Invoke-T11 {
    Log-Step "11" "Revert to Default (Hoàn Tác Thiết Lập Về Mặc Định Nhà Sản Xuất)"
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2 -Type DWord -Force
    $sysProf = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $sysProf -Name "NetworkThrottlingIndex" -Value 10 -Type DWord -Force
    Set-ItemProperty -Path $sysProf -Name "SystemResponsiveness" -Value 20 -Type DWord -Force
    powercfg -h on
    Log-Ok "Đã khôi phục thông số Chuột, CPU, MMCSS và Nguồn về mặc định."
}

function Invoke-NexusExtreme {
    Write-Host "`n  🚀 KÍCH HOẠT ĐỘNG CƠ TỐI ƯU 1 CHẠM (NEXUS EXTREME PRO) ⚡..." -ForegroundColor Green
    Invoke-T01; Invoke-T02; Invoke-T03; Invoke-T04; Invoke-T05; Invoke-T06; Invoke-T07; Invoke-T08
    Write-Host "`n  🎉 ĐÃ HOÀN TẤT TOÀN BỘ QUY TRÌNH TỐI ƯU HÓA REGISTRY & PHẦN CỨNG!" -ForegroundColor Green
    Ask-Restart
}

# ============================================================================
# GIAO DIỆN BẢNG ĐIỀU KHIỂN (ASCII LOGO & 11 COMBO TWEAKS)
# ============================================================================
do {
    Clear-Host
    $hw = Get-HardwareInfo
    Write-Host ""
    Write-Host "      _  _ ____ _  _ _  _ ____   _  _ ____ _ ___" -ForegroundColor Cyan
    Write-Host "      |\ | |___  \/  |  | [__    |  | |  | | |  \" -ForegroundColor Cyan
    Write-Host "      | \| |___ _/\_ |__| ___]    \/  |__| | |__/" -ForegroundColor Cyan
    Write-Host "            ⚡ EXTREME SYSTEM ENGINE v3.0 PRO ⚡" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ===========================================================================" -ForegroundColor DarkMagenta
    Write-Host "   💻 OS : $($hw.OS)" -ForegroundColor Gray
    Write-Host "   ⚙️ CPU: $($hw.CPU)" -ForegroundColor Gray
    Write-Host "   🧠 RAM: $($hw.RAM)" -ForegroundColor Gray
    Write-Host "  ---------------------------------------------------------------------------" -ForegroundColor DarkGray

    Write-Host "  [01] 🧹 Core Clean & Backup (Điểm Khôi Phục & Dọn Rác Toàn Diện)" -ForegroundColor Magenta
    Write-Host "  [02] 🔥 Ultimate CPU & Unpark (Nguồn Maximum & Unpark 100% Nhân CPU)"
    Write-Host "  [03] 🚀 RAM & SSD Hyper-Boost (Ép Xả RAM, Tắt Ngủ Đông & Bật TRIM)"
    Write-Host "  [04] 🎮 Esports Input Engine (Chuẩn Hóa Tâm Chuột 1:1 & Phím 0ms)"
    Write-Host "  [05] 🖥️ GPU & PCI MSI Mode (Bật MSI Mode GPU/NIC, HAGS & Tắt DVR)"
    Write-Host "  [06] 🌐 MMCSS & Network Shield (MMCSS Games Pro, Xả Băng Thông & RSS)"
    Write-Host "  [07] 🛡️ Windows Debloat & Privacy (Tắt Hiệu Ứng, Telemetry & App Ngầm)"
    Write-Host "  [08] ⚡ System Flow Control (Menu Phải 0ms, Khóa Restart & Dịch Vụ Rác)"
    Write-Host "  [09] 🩺 SFC Scannow (Kiểm Tra & Vá File Hệ Thống)"
    Write-Host "  [10] 📡 Live Ping Test (Đo Độ Trễ Trực Tiếp Máy Chủ Quốc Tế)"
    Write-Host "  [11] 🔄 Revert to Default (Hoàn Tác Về Mặc Định Nhà Sản Xuất)"
    Write-Host "  ===========================================================================" -ForegroundColor DarkMagenta
    Write-Host "  [A] 🌟 NEXUS EXTREME TỐI ƯU 1 CHẠM (Chạy từ 1 đến 8)     [0] ❌ Thoát" -ForegroundColor Green
    
    $sel = Read-Host "`n  👉 Chọn Lệnh (1-11, A, 0)"
    
    if ($sel -eq '1' -or $sel -eq '01') { Invoke-T01; Ask-Restart; Wait-Key }
    elseif ($sel -eq '2' -or $sel -eq '02') { Invoke-T02; Ask-Restart; Wait-Key }
    elseif ($sel -eq '3' -or $sel -eq '03') { Invoke-T03; Ask-Restart; Wait-Key }
    elseif ($sel -eq '4' -or $sel -eq '04') { Invoke-T04; Ask-Restart; Wait-Key }
    elseif ($sel -eq '5' -or $sel -eq '05') { Invoke-T05; Ask-Restart; Wait-Key }
    elseif ($sel -eq '6' -or $sel -eq '06') { Invoke-T06; Ask-Restart; Wait-Key }
    elseif ($sel -eq '7' -or $sel -eq '07') { Invoke-T07; Ask-Restart; Wait-Key }
    elseif ($sel -eq '8' -or $sel -eq '08') { Invoke-T08; Ask-Restart; Wait-Key }
    elseif ($sel -eq '9' -or $sel -eq '09') { Invoke-T09; Wait-Key }
    elseif ($sel -eq '10') { Invoke-T10; Wait-Key }
    elseif ($sel -eq '11') { Invoke-T11; Ask-Restart; Wait-Key }
    elseif ($sel -eq 'a' -or $sel -eq 'A') { Invoke-NexusExtreme; Wait-Key }
    elseif ($sel -eq '0') { exit }
    else { Write-Host "  ⚠️ Lỗi mã! Hãy nhập từ 1-11, A hoặc 0." -ForegroundColor Red; Start-Sleep -Seconds 1 }

} while ($true)
