$cpu=(Get-CimInstance Win32_Processor |
Measure-Object LoadPercentage -Average).Average

$os=Get-CimInstance Win32_OperatingSystem

$used=[math]::Round(
($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/1MB
,1)

$total=[math]::Round(
$os.TotalVisibleMemorySize/1MB
,1)

$disk=[math]::Round(
(Get-PSDrive C).Free/1GB
)

$net="OFFLINE"

if(Test-Connection 8.8.8.8 -Count 1 -Quiet){
    $net="ONLINE"
}

$uptime=(Get-Date)-$os.LastBootUpTime
$up="$($uptime.Days)d $($uptime.Hours)h"

"$cpu;$used;$total;$disk;$net;$up"
