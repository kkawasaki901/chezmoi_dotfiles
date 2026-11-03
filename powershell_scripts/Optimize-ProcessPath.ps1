# Keep first occurrences in their original order. Only this process is changed.
& {
    $seenPaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $pathEntries = foreach ($entry in ($env:Path -split ';')) {
        # Retain empty entries and drive roots; only strip a directory trailing slash for comparison.
        $key = $entry
        if ($key.Length -gt 3) { $key = $key.TrimEnd('\') }
        if ($entry -eq '' -or $seenPaths.Add($key)) { $entry }
    }
    $env:Path = $pathEntries -join ';'
}
