# bootstrap DNVM into this session.
&{$Branch='dev';iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.ps1'))}

# load up the global.json so we can find the DNX version
$globalJson = Get-Content -Path $PSScriptRoot\global.json -Raw -ErrorAction Ignore | ConvertFrom-Json -ErrorAction Ignore

if($globalJson)
{
    $dnxVersion = $globalJson.sdk.version
}
else
{
    Write-Warning "Unable to locate global.json to determine using 'latest'"
    $dnxVersion = "latest"
}

# install DNX
& $env:USERPROFILE\.dnx\bin\dnvm install $dnxVersion -Persistent
& $env:USERPROFILE\.dnx\bin\dnvm upgrade

$env:Path += “;$env:USERPROFILE\AppData\Roaming\npm”

# install some other prerequisites
& npm install -g gulp

 # run DNU restore on all project.json files in the src folder including 2>1 to redirect stderr to stdout for badly behaved tools
Get-ChildItem -Path $PSScriptRoot -Filter project.json -Recurse | ForEach-Object { & dnu restore $_.FullName 2>1 }