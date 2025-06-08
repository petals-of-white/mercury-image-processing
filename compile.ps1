$assemblyPath = "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\6.0.36"

$onlyAssemblies = @("mscorlib.dll", "netstandard.dll")

$assemblies = Get-ChildItem -Path $assemblyPath -Filter "System*.dll" | ForEach-Object { "-reference:""$($_.FullName)""" }
$assemblies2 = Get-ChildItem -Path $assemblyPath | Where-Object { $onlyAssemblies -contains $_.Name } | ForEach-Object { "-reference:""$($_.FullName)""" }
$assembliesString = ($assemblies -join " ") + " -reference:test.dll " + $assemblies2

$sourceFiles = "main.cs"  # Add more source files as needed
$outputFile = "main.exe"

$command = "csc $assembliesString -out:$outputFile $sourceFiles"
Write-Host $command
Invoke-Expression $command