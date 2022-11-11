<#
  .SYNOPSIS
  Проверка статуса сервисов и их запуск
  .DESCRIPTION
  1. Если служба остановлена
    a. И её тип запуска автоматический или ручной, запустить её. Записать в журнал информацию о том, что такая-то служба была остановлена, но теперь запущена. 
       Также в это сообщение надо добавить какой у службы настроен тип запуска, но добавить его надо на русском языке.
    b. и она отключена, записать об этом информацию в журнал, указав имя службы, и на русском языке указать только тип запуска.
    c. Если тип запуска какой-то другой, записать в журнал информацию о том, что тип запуска неизвестный, имя службы и её тип запуска.
  2. Если служба запущена, записать в журнал информацию, что служба запущена.
  .EXAMPLE
  Check-Services -ServiceName "MyAwesomeS"
  .PARAMETER
  ServiceName имя службы, если не указано будет MyAwesomeS
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0, HelpMessage="Имя службы")]
        [ValidatePattern('\w{2}')]
        [System.String]$ServiceName = 'MyAwesomeS'
    )

    Function WriteLog {
        Param ([string]$logstring)
        $Date = Get-Date
        $Path = "C:\Windows\Temp\MyLog-$($Date.Year)-$($Date.Month)-$($Date.Day).log"
        $Value = "$($Date.ToString("[HH:mm:ss]:")) $logstring"
        Add-Content -Path $Path -value $Value
    }

    Function TranslateMode {
        Param ([string]$StartMode)
        $answer = switch ($startMode) {
            "Manual" {"Ручной"}
            "Disabled" {"Выключена"}
            "Auto" {"Автоматический"}
            Default {"Неизвестный"}
            }
        return $answer
    }
    WriteLog "Начало работы скрипта"
    try {
        $Services = Get-WmiObject Win32_Service -ErrorAction Stop | Where-Object {$_.Name -match "^$ServiceName"}
    } catch {
        WriteLog $_.Exception.Message
    }
    if (!$Services) { WriteLog "Не найдены службы начинающиеся на '$($ServiceName)'"}

    foreach ($Service in $Services) {
        if ($Service.State -eq "Running") {
            WriteLog "Служба '$($Service.name)' работает."
        } else {
            if ($Service.StartMode -eq "Auto" -or "Manual") {
                try {
                    Start-Service -Name $Service.name -ErrorAction Stop
                    WriteLog "Служба '$($Service.name)' была остановлена, но теперь запущена."
                } catch {
                    WriteLog $_.Exception.Message
                }
                $startmode = TranslateMode -StartMode $Service.StartMode
                WriteLog "Служба '$($Service.name)', тип запуска: $($startmode)."
            } elseif ($Service.StartMode -eq "Disabled") {
                $startmode = TranslateMode -StartMode $Service.StartMode
                WriteLog "Служба '$($Service.name)', тип запуска: $($startmode)."
            } else {
                $startmode = TranslateMode -StartMode $Service.StartMode
                WriteLog "Служба '$($Service.name)', тип запуска: $($startmode) ($($Service.StartMode))."
            }
        }
    }
    WriteLog "Конец работы скрипта"