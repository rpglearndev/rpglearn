Add-Type -AssemblyName System.Drawing
$path = Join-Path $PSScriptRoot "..\assets\mixel\Nature v1.5\Topdown RPG 32x32 - Ground Tileset 1.2.PNG"
$img = [System.Drawing.Bitmap]::new($path)
for ($y = 0; $y -lt 12; $y++) {
    $line = ""
    for ($x = 0; $x -lt 12; $x++) {
        $g = 0; $b = 0; $k = 0; $t = 0
        for ($py = 0; $py -lt 32; $py++) {
            for ($px = 0; $px -lt 32; $px++) {
                $c = $img.GetPixel($x * 32 + $px, $y * 32 + $py)
                if ($c.A -lt 128) { continue }
                $t++
                if ($c.R -lt 40 -and $c.G -lt 40 -and $c.B -lt 40) { $k++ }
                elseif ($c.G -gt $c.R -and $c.G -gt $c.B -and $c.G -gt 80) { $g++ }
                elseif ($c.R -gt $c.G -and $c.R -gt $c.B -and $c.R -gt 60) { $b++ }
            }
        }
        $kind = if ($k -gt $t * 0.25) { "R" } elseif ($g -gt $b * 1.15) { "G" } elseif ($b -gt $g * 1.15) { "D" } else { "M" }
        $line += $kind
    }
    Write-Host ("y{0,2}: {1}" -f $y, $line)
}
$img.Dispose()
