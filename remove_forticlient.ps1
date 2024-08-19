# Eliminar entrada del registro para FortiClient
$fortiClientGUID = "{01CDBF14-709C-4840-B813-DC49A18A943C}"
$uninstallKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$fortiClientGUID"
$uninstallKeyPathWOW64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$fortiClientGUID"

# Elimina la entrada del registro
if (Test-Path $uninstallKeyPath) {
    Remove-Item -Path $uninstallKeyPath -Recurse -Force
    Write-Output "Entrada de registro en $uninstallKeyPath eliminada."
} elseif (Test-Path $uninstallKeyPathWOW64) {
    Remove-Item -Path $uninstallKeyPathWOW64 -Recurse -Force
    Write-Output "Entrada de registro en $uninstallKeyPathWOW64 eliminada."
} else {
    Write-Output "No se encontró la entrada de registro para FortiClient."
}

# Eliminar carpetas residuales
$pathsToRemove = @(
    "C:\Program Files\Fortinet",
    "C:\Program Files (x86)\Fortinet",
    "C:\ProgramData\Fortinet",
    "$env:LOCALAPPDATA\Fortinet"
)

foreach ($path in $pathsToRemove) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Output "Carpeta eliminada: $path"
    } else {
        Write-Output "Carpeta no encontrada: $path"
    }
}

# Detener y eliminar servicios relacionados con FortiClient
$fortiServices = Get-Service | Where-Object { $_.DisplayName -like "*Forti*" }

foreach ($service in $fortiServices) {
    Stop-Service -Name $service.Name -Force -ErrorAction SilentlyContinue
    Write-Output "Servicio detenido: $($service.DisplayName)"
}

# Eliminar servicios usando sc.exe (para asegurarse de que estén completamente eliminados)
foreach ($service in $fortiServices) {
    sc.exe delete $service.Name
    Write-Output "Servicio eliminado: $($service.DisplayName)"
}

# Eliminar controladores relacionados con FortiClient
$drivers = Get-WmiObject Win32_SystemDriver | Where-Object { $_.DisplayName -like "*Forti*" }

foreach ($driver in $drivers) {
    Stop-Service -Name $driver.Name -Force -ErrorAction SilentlyContinue
    sc.exe delete $driver.Name
    Write-Output "Controlador eliminado: $($driver.DisplayName)"
}

# Eliminar tareas programadas relacionadas con FortiClient
$fortiTasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Forti*" }
foreach ($task in $fortiTasks) {
    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
    Write-Output "Tarea programada eliminada: $($task.TaskName)"
}

# Eliminar controladores relacionados usando Autoruns (requiere Sysinternals Autoruns)
$autorunsExePath = "C:\Path\To\Autoruns.exe"  # Actualiza esta ruta según donde esté ubicado Autoruns.exe
if (Test-Path $autorunsExePath) {
    Start-Process $autorunsExePath -ArgumentList "/Delete /HideMicrosoft /accepteula" -Wait
    Write-Output "Autoruns ejecutado para eliminar entradas residuales."
} else {
    Write-Output "No se encontró Autoruns en la ruta especificada."
}

# Reiniciar el sistema para completar la limpieza
Write-Output "Reiniciando el sistema para completar la limpieza."
Restart-Computer -Force
