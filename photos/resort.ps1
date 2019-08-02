
$hash = @{
    'Camera model' = 30;
    'Date taken' = 12; 
}
$shell = New-Object -ComObject Shell.Application

Function Get-FileMetaData {
    Param([string]$path)
            
    $folder = Split-Path $path
    $file = Split-Path $path -Leaf
    $objShell = $shell.Namespace($folder)
    $shellfile = $objShell.ParseName($file)
    
    $meta = @{}

    $hash.Keys | ForEach-Object {
        $property = $_
        $value = $objShell.GetDetailsOf($shellfile, $hash.$property).Trim()
        #Write-Host "META  $property is $value"
        $meta.Add($property, $value)
    }
    return $meta
}

Function ParseDirtyDate {
    Param([string]$date_src)

    #Write-Host "date string:" 
    #Write-Host ($date_src | Format-Hex)

    $date_str = $date_src -replace "[^0-9\.\-\:APM ]"
    
    #Write-Host ($date_str | Format-Hex)

    $date = New-Object DateTime
    if(![datetime]::tryparseexact($date_str, "yyyy-MM-dd hh:mm tt",[System.Globalization.CultureInfo]::InvariantCulture,[System.Globalization.DateTimestyles]::None, [ref]$date)) {
        if(![datetime]::tryparseexact($date_str, "dd.MM.yyyy HH:mm",[System.Globalization.CultureInfo]::InvariantCulture,[System.Globalization.DateTimestyles]::None, [ref]$date)) {
            Write-Host "pizdez... i'm quit"
            return null;
        }
    }
    return $date

}
$location = Get-Location
$sorted = "$location\..\sorted"
Write-Host "target directory: " $sorted
if (-not (Test-Path -LiteralPath $sorted)) {   
    try {
        New-Item -Path $sorted -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    } catch {
        Write-Error -Message "Unable to create directory '$sorted'. Error was: $_" -ErrorAction Stop
    }
    Write-Host "created directory '$sorted'"
}


Get-ChildItem -File -Recurse -Path . -Filter *.jpg | 
Foreach-Object {
    Write-Host
    <#
    $folder = Split-Path $_.FullName
    $folder = $folder.Substring($folder.LastIndexOf('\')+1)
    Write-Host "folder " $folder
    if($folder -eq $sorted) {
        return
    }
    #>


    $name = $_.Name
    $meta = Get-FileMetaData $_.FullName
    $camera = $meta['Camera model'];

    $date = ParseDirtyDate $meta['Date taken']
    Write-Host    
    Write-Host "camera-model: $camera " #$camera.GetType().fullname
    Write-Host "date taken  : $date   " #$date.GetType().fullname
   
    #$date = $_.LastWriteTime
    $just_date = $date.ToString("yyyy-MM-dd")
    $date_dir = $sorted+"\"+$just_date
    Write-Host "$name created at $just_date"
    if (-not (Test-Path -LiteralPath $date_dir)) {   
        try {
            New-Item -Path $date_dir -ItemType Directory -ErrorAction Stop | Out-Null #-Force
        } catch {
            Write-Error -Message "Unable to create directory '$date_dir'. Error was: $_" -ErrorAction Stop
        }
        Write-Host "created directory '$date_dir'."
    }
    $new_name = $date.ToString("yyyyMMdd_hhmm");
    $new_name = $new_name + "_" + $name.Substring($name.LastIndexOf('\')+1)

    $target_file = "$sorted\" + $just_date + "\" + $new_name
    Write-Host "source: " $_.FullName -ForegroundColor Green
    Write-Host "target: $target_file" -ForegroundColor Cyan
    if (Test-Path -LiteralPath $target_file) {
        Write-Host "file $target_file exists, skipping"
    } else {
        copy-item -path $_.FullName -destination $target_file #–whatif
    }
    #Write-Host "moving file $name to $just_date"

}