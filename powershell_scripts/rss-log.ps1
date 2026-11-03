Write-Host "RSS_to_Raindrop"

curl.exe --no-progress-meter -L "https://script.google.com/macros/s/AKfycbyJpKKdRDXX7eFmGFHUOdnKTwAgl3tp7d2qOeEgcQPo636C2A77J6h-KePPTx5OdmWa/exec" |
    ConvertFrom-Json |
    Select-Object -Last 3 |
    Format-Table -AutoSize

Write-Host "RSS_Youtube"

curl.exe --no-progress-meter -L "https://script.google.com/macros/s/AKfycbxnlTm4NTRGf7LQRKo_j8YGYmZSXFInXmxTKzowfhuQABEQc5YaR97vgoSUrEo3K27-/exec" |
    ConvertFrom-Json |
    Select-Object -Last 3 |
    Format-Table -AutoSize
