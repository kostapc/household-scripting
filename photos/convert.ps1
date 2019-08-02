#first - install ImageMagick! 
$dir = $args[0]
Write-Host "DIR: $dir"
Get-ChildItem -File -Recurse -Path $dir -Filter *.heic | 
Foreach-Object {
    $name = $_.FullName
    #Write-Host "path: $name"
    $folders = $name.Split('\')    
    $file_dir = $name.Substring(0,$name.LastIndexOf('\')+1)
    $root = "";
    for($i=0; $i -lt $folders.Length-2; $i++) {
        $root = $root + $folders[$i] + "\"
    }
    $target_dir = $root + "jpg\" + $folders[$folders.Length-2] + "\"
    $file_name = $name.Substring($name.LastIndexOf('\')+1)
    $target_file = $target_dir + $file_name.Substring(0,$file_name.LastIndexOf('.')+1)+"jpg"

    if (-not (Test-Path -LiteralPath $target_dir)) {
        New-Item -Path $target_dir -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }

    Write-Host $name
    Write-Host $target_file    
    
    $exec_args = "convert", $name, "-quality", "100", $target_file
    $cmd = "magick.exe"
    &$cmd $exec_args
    
}