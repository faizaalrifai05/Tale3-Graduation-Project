$profile = "c:\Users\Lenovo\Desktop\testtale3\testtale3\lib\screens\driver_profile_screen.dart"
$sched = "c:\Users\Lenovo\Desktop\testtale3\testtale3\lib\screens\pickup_schedule_screen.dart"

# Fix driver_profile_screen.dart
$pContent = Get-Content $profile -Raw
$pContent = $pContent -replace "_primaryColor", "AppStyles.primaryColor"
$pContent = $pContent -replace "    \];", "      ],`n    );"
$pContent | Set-Content $profile

# Fix pickup_schedule_screen.dart
$sContent = Get-Content $sched -Raw
$sContent = $sContent -replace "_primaryColor", "AppStyles.primaryColor"
$sContent | Set-Content $sched
