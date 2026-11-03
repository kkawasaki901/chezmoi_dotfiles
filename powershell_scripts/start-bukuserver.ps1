param(
    [string]$BindHost = "127.0.0.1",
    [int]$Port = 5001
)

$ErrorActionPreference = 'Stop'

Start-Process "http://$($BindHost):$Port/"
bukuserver run --host $BindHost --port $Port
