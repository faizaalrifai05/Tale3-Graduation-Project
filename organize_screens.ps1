$ErrorActionPreference = "Stop"
$targetDir = "c:\Users\Lenovo\Desktop\testtale3\testtale3\lib"
$screensDir = "$targetDir\screens"
$driverDir = "$screensDir\driver"
$passengerDir = "$screensDir\passenger"

New-Item -ItemType Directory -Force -Path $driverDir | Out-Null
New-Item -ItemType Directory -Force -Path $passengerDir | Out-Null

$driverFiles = @(
    "driver_create_ride_screen.dart",
    "driver_home_screen.dart",
    "driver_id_verification_screen.dart",
    "driver_login_screen.dart",
    "driver_profile_screen.dart",
    "driver_registration_screen.dart",
    "driver_ride_details_screen.dart",
    "driver_ride_live_screen.dart",
    "driver_vehicle_details_screen.dart",
    "driver_verification_status_screen.dart",
    "ride_posted_screen.dart",
    "pickup_schedule_screen.dart"
)

$passengerFiles = @(
    "passenger_home_screen.dart",
    "passenger_login_screen.dart",
    "passenger_registration_screen.dart",
    "booking_status_screen.dart",
    "cancel_trip_screen.dart",
    "ride_details_screen.dart",
    "ride_results_screen.dart",
    "select_seat_screen.dart",
    "my_trips_screen.dart"
)

$sharedFiles = @(
    "chat_screen.dart",
    "choose_role_screen.dart",
    "community_guidelines_screen.dart",
    "email_verification_screen.dart",
    "notes_and_rules_screen.dart",
    "password_reset_screen.dart",
    "profile_photo_screen.dart",
    "ratings_reviews_screen.dart",
    "splash_screen.dart",
    "verification_success_screen.dart",
    "welcome_screen.dart"
)

function Fix-Imports {
    param($filePath)
    $content = Get-Content $filePath -Raw
    
    foreach ($file in $driverFiles) {
        $content = $content -replace "import\s+['`"]([^'`"]*)$file['`"];", "import 'package:testtale3/screens/driver/$file';"
    }
    foreach ($file in $passengerFiles) {
        $content = $content -replace "import\s+['`"]([^'`"]*)$file['`"];", "import 'package:testtale3/screens/passenger/$file';"
    }
    foreach ($file in $sharedFiles) {
        $content = $content -replace "import\s+['`"]([^'`"]*)$file['`"];", "import 'package:testtale3/screens/$file';"
    }
    
    $content | Set-Content $filePath
}

$allDartFiles = Get-ChildItem -Path $targetDir -Filter *.dart -Recurse
foreach ($file in $allDartFiles) {
    Fix-Imports $file.FullName
}

foreach ($file in $driverFiles) {
    $src = "$screensDir\$file"
    if (Test-Path $src) {
        Move-Item -Path $src -Destination $driverDir
        $dest = "$driverDir\$file"
        $content = Get-Content $dest -Raw
        $content = $content -replace "import\s+['`"]\.\./theme/", "import '../../theme/"
        $content = $content -replace "import\s+['`"]\.\./widgets/", "import '../../widgets/"
        $content | Set-Content $dest
    }
}

foreach ($file in $passengerFiles) {
    $src = "$screensDir\$file"
    if (Test-Path $src) {
        Move-Item -Path $src -Destination $passengerDir
        $dest = "$passengerDir\$file"
        $content = Get-Content $dest -Raw
        $content = $content -replace "import\s+['`"]\.\./theme/", "import '../../theme/"
        $content = $content -replace "import\s+['`"]\.\./widgets/", "import '../../widgets/"
        $content | Set-Content $dest
    }
}

Write-Output "Done"
