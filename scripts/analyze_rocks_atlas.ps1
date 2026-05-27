Add-Type -AssemblyName System.Drawing
$path = Join-Path $PSScriptRoot "..\assets\mixel\Nature v1.5\Topdown RPG 32x32 - Rocks 1.2.PNG"
$img = [System.Drawing.Bitmap]::new($path)
$cols = [int]($img.Width / 32)
$rows = [int]($img.Height / 32)
Write-Host "Size $($img.Width)x$($img.Height) grid ${cols}x${rows}"
for ($y = 0; $y -lt $rows; $y++) {
    $line = ""
    for ($x = 0; $x -lt $cols; $x++) {
        $t = 0; $k = 0
        for ($py = 0; $py -lt 32; $py++) {
            for ($px = 0; $px -lt 32; $px++) {
                $c = $img.GetPixel($x * 32 + $px, $y * 32 + $py)
                if ($c.A -lt 128) { continue }
                $t++
                if ($c.R -lt 40 -and $c.G -lt 40 -and $c.B -lt 40) { $k++ }
            }
        }
        $line += if ($k -lt $t * 0.15) { "." } else { "#" }
    }
    Write-Host ("y{0,2}: {1}" -f $y, $line)
}
$img.Dispose()
