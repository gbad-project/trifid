# Define your variables (adjust these values as needed)
$WorkingDirUnix = "$PSScriptRoot" -replace 'C:\\', '/mnt/c/' -replace '\\', '/'
$RunScript = "./run.sh"

# Build the WSL command that bash will run:
$Command = "source ~/.bashrc && cd '$WorkingDirUnix' && '$RunScript'"

# Start the second Python script in a new WSL window
Start-Process -FilePath "cmd.exe" -ArgumentList "/c wsl.exe bash -ic `"$Command`""

# Run Python directly using the Windows interpreter
Write-Host "Starting the reverse proxy server..."
$ReverseProxyScript = Join-Path -Path $PSScriptRoot -ChildPath "data\socketserver\reverse_proxy.py"
Invoke-Expression "python $($ReverseProxyScript)"
