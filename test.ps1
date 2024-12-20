# Ensure the script stops on error
$ErrorActionPreference = "Stop"

# Define variables
$logFolder = "logs"
$logFile = "$logFolder\test_results.log"
$testTarget = "integration_test/testing.dart"

# Create the logs folder if it doesn't exist
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

# Command to run the Flutter integration test
$flutterCommand = "flutter drive --driver=integration_test/app.dart --target=$testTarget"


# Run the command and redirect output to the log file
Write-Host "Running integration test..."
try {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $flutterCommand > `"$logFile`" 2>&1" -NoNewWindow -Wait
    Write-Host "Integration test completed. Results are saved in $logFile"
} catch {
    Write-Error "An error occurred while running the test."
}
