$fortiClientGUID = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
                    Where-Object { $_.DisplayName -like "*FortiClient*" } | 
                    Select-Object -ExpandProperty PSChildName

if ($fortiClientGUID) {
    Write-Output "GUID encontrado: $fortiClientGUID"
} else {
    Write-Output "No se encontró GUID para FortiClient."
}
