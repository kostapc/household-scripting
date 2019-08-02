# http://web.archive.org/web/20160201231836/http://powershell.com/cs/blogs/tobias/archive/2011/01/07/organizing-videos-and-music.aspx

$path = 'c:\tmp\some_pic_from_camera.jpg'

$shell = New-Object -COMObject Shell.Application
$folder = Split-Path $path
$file = Split-Path $path -Leaf
$objShell = $shell.Namespace($folder)
$shellfile = $objShell.ParseName($file)
#0..287 | Foreach-Object { '{0} = {1}' -f $_, $objShell.GetDetailsOf($null, $_) }

$hash = @{
    'Camera model' = 30; 
    'Date taken' = 12; 
}

$meta = @{}

$hash.Keys | ForEach-Object {
    $property = $_
    $value = $objShell.GetDetailsOf($shellfile, $hash.$property)
    Write-Host "$property is $value"
    $meta.Add($property, $value);
}

Write-Host
Write-Host "camera: " $meta['Camera model']
Write-Host "date  : " $meta['Date taken']

$date_str = $meta['Date taken'] -replace "[^0-9\.\-\:APM ]"

$pattern = "yyyy-MM-dd hh:mm tt"
$pattern_en = "dd.MM.yyyy HH:mm"

Write-Host "date string:" 
Write-Host ($date_str | Format-Hex)

$date = New-Object DateTime
if(![datetime]::tryparseexact($date_str, $pattern,[System.Globalization.CultureInfo]::InvariantCulture,[System.Globalization.DateTimestyles]::None, [ref]$date)) {
    if(![datetime]::tryparseexact($date_str, $pattern_en,[System.Globalization.CultureInfo]::InvariantCulture,[System.Globalization.DateTimestyles]::None, [ref]$date)) {
        Write-Host "pizdez... i'm quit"
        exit
    }
}
Write-Host "date as date:" $date
