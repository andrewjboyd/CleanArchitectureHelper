param ($projectName)

$source = "Source"
$tests = "Tests"
$domain = "Domain"
$application = "Application"
$infrastructure = "Infrastructure"
$api = "WebApi"
$unitTests = "UnitTests"

# Stop if projectName already exists

New-Item -Name $projectName -ItemType "directory"
Set-Location $projectName
New-Item -Name $source -ItemType "directory"
New-Item -Name $tests -ItemType "directory"

Set-Location Source

New-Item -Name "$projectName.$domain" -ItemType "directory"
New-Item -Name "$projectName.$application" -ItemType "directory"
New-Item -Name "$projectName.$infrastructure" -ItemType "directory"
New-Item -Name "$projectName.$api" -ItemType "directory"

Write-Output "Setting up Domain Layer"

Set-Location "$projectName.Domain"
dotnet new classlib
Remove-Item Class1.cs
New-Item -Name "Entities" -ItemType "directory"

Write-Output "Setting up Application Layer"

Set-Location "..\$projectName.$application"
dotnet new classlib
dotnet add package "AutoMapper.Extensions.Microsoft.DependencyInjection"
dotnet add package "FluentValidation"
dotnet add package "FluentValidation.DependencyInjectionExtensions"
dotnet add package "MediatR.Extensions.Microsoft.DependencyInjection"
dotnet add reference "../$projectName.$domain/$projectName.$domain.csproj"
Remove-Item Class1.cs
New-Item -Name "Common\Interfaces" -ItemType "directory"

Write-Output "Setting up Infrastructure Layer"
Set-Location "..\$projectName.$infrastructure"
dotnet new classlib
dotnet add reference "../$projectName.$application/$projectName.$application.csproj"
Remove-Item Class1.cs

Write-Output "Setting up the WebApi"
Set-Location "..\$projectName.$api"
dotnet new webapi --no-openapi
dotnet add reference "../$projectName.$application/$projectName.$application.csproj"
dotnet add reference "../$projectName.$infrastructure/$projectName.$infrastructure.csproj"
Get-ChildItem .\WeatherForecast*.cs -Recurse | Remove-Item

Write-Output "Setting up tests"
Set-Location ..\..\Tests

New-Item -Name "$projectName.$domain.$unitTests" -ItemType "directory"
New-Item -Name "$projectName.$application.$unitTests" -ItemType "directory"
Set-Location "$projectName.$domain.$unitTests"
dotnet new xunit
dotnet add reference "../../$source/$projectName.$domain/$projectName.$domain.csproj"

Set-Location ..\"$projectName.$application.$unitTests"
dotnet new xunit
dotnet add reference "../../$source/$projectName.$application/$projectName.$application.csproj"

Set-Location ..\..\

Write-Output "Setting up Solution"
dotnet new sln
dotnet sln add "$source/$projectName.$domain/$projectName.$domain.csproj"
dotnet sln add "$source/$projectName.$application/$projectName.$application.csproj"
dotnet sln add "$source/$projectName.$infrastructure/$projectName.$infrastructure.csproj"
dotnet sln add "$source/$projectName.$api/$projectName.$api.csproj"
dotnet sln add "$tests/$projectName.$domain.$unitTests/$projectName.$domain.$unitTests.csproj"
dotnet sln add "$tests/$projectName.$application.$unitTests/$projectName.$application.$unitTests.csproj"