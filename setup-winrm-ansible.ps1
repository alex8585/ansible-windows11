# === Скрипт для автоматической настройки WinRM для Ansible на Windows 11 ===
# Запускайте от имени администратора
Write-Host "=== Настройка WinRM для Ansible на Windows 11 ==="

# 0️⃣ Меняем тип сети Public → Private
$profiles = Get-NetConnectionProfile | Where-Object {$_.NetworkCategory -eq "Public"}
foreach ($p in $profiles) {
    Write-Host "Меняем сеть '$($p.Name)' с Public на Private..."
    Set-NetConnectionProfile -Name $p.Name -NetworkCategory Private
}

# 1️⃣ Включаем WinRM и автозапуск
Write-Host "Включаем WinRM..."
winrm quickconfig -q

# 2️⃣ Настройка Basic Auth и разрешение незашифрованного трафика
Write-Host "Настраиваем Basic Auth и AllowUnencrypted..."
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true

# 3️⃣ Создание HTTP listener на всех адресах
Write-Host "Создаём HTTP listener..."
$listener = Get-ChildItem -Path WSMan:\localhost\Listener | Where-Object {$_.Keys -like "*HTTP*"}
if (-not $listener) {
    winrm create winrm/config/Listener?Address=*+Transport=HTTP
} else {
    Write-Host "Listener уже существует."
}

# 4️⃣ Настройка лимитов
Write-Host "Настраиваем лимиты WinRM..."
Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024
Set-Item WSMan:\localhost\MaxTimeoutms 1800000

# 5️⃣ Настройка firewall
Write-Host "Добавляем правило в firewall для WinRM..."
$rule = Get-NetFirewallRule -DisplayName "Windows Remote Management (HTTP)" -ErrorAction SilentlyContinue
if (-not $rule) {
    New-NetFirewallRule `
        -Name "WinRM-HTTP" `
        -DisplayName "Windows Remote Management (HTTP)" `
        -Description "Разрешает входящие соединения WinRM на порт 5985" `
        -Enabled True `
        -Profile Domain,Private `
        -Direction Inbound `
        -Action Allow `
        -Protocol TCP `
        -LocalPort 5985
} else {
    Write-Host "Правило firewall уже существует."
}

# 6️⃣ Проверка службы WinRM
Write-Host "Проверяем службу WinRM..."
$svc = Get-Service WinRM
if ($svc.Status -ne "Running") {
    Start-Service WinRM
    Set-Service WinRM -StartupType Automatic
}

# 7️⃣ Тест WinRM локально
Write-Host "Тестируем WinRM локально..."
try {
    Test-WsMan localhost -ErrorAction Stop
    Write-Host "WinRM настроен и работает! 🚀"
} catch {
    Write-Host "Ошибка теста WinRM:" $_.Exception.Message
}

Write-Host "=== Настройка завершена ==="

