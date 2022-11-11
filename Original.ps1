$global:ErrorActionPreference = "SilentlyContinue"
$Running = $true
$a = Get-WmiObject win32_service | where {$_.Name -match 'MyAwesomeS*'}
Add-Content -Path "C:\Windows\Temp\MyLog-$((Get-Date).Year)-$((Get-Date).Month)-$((Get-Date).Day).log"`
    -Value "[$((Get-Date).TimeOfDay)] Found servises"
    
for ($i=1;$i -lt $a.Count; $i++) {
    if ($a[$i].State -eq 'Stopped') {
        if ($a[$i].StartMode -eq "Automatic") {
            Get-Service $a[$i].Name | Start-Service
            Add-Content -Path "C:\Windows\Temp\MyLog-$((Get-Date).Year)-$((Get-Date).Month)-$((Get-Date).Day).log"`
                -Value "[$((Get-Date).TimeOfDay)] Started servise $($a[$i].Name) (Автомат)"
        } elseif ($a[$i].StartMode -eq "Manual") {
            Get-Service $a[$i].Name | Start-Service
            Add-Content -Path "C:\Windows\Temp\MyLog-$((Get-Date).Year)-$((Get-Date).Month)-$((Get-Date).Day).log"`
                -Value "[$((Get-Date).TimeOfDay)] Started servise $($a[$i].Name) (Ручной)"
        } else {
            #Get-Service $a[$i].Name | Start-Service
            Add-Content -Path "C:\Windows\Temp\MyLog-$((Get-Date).Year)-$((Get-Date).Month)-$((Get-Date).Day).log"`
                -Value "[$((Get-Date).TimeOfDay)] Servise $($a[$i].Name) (Отключена)"
        }
    } else {
        Add-Content -Path "C:\Windows\Temp\MyLog-$((Get-Date).Year)-$((Get-Date).Month)-$((Get-Date).Day).log"`
            -Value "[$((Get-Date).TimeOfDay)] Servise $($a[$i].Name) running"
    }
}
Write-Host'Successfuly Done'
