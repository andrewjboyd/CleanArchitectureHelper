param ($projectName)

$source = "Source"
$tests = "Tests"
$domain = "Domain"
$application = "Application"
$infrastructure = "Infrastructure"
$api = "WebApi"
$unitTests = "UnitTests"

# Stop if projectName already exists

mkdir $projectName
cd $projectName
mkdir $source
mkdir $tests

cd Source
mkdir "$projectName.$domain"
mkdir "$projectName.$application"
mkdir "$projectName.$infrastructure"
mkdir "$projectName.$api"

Write-Output "Setting up Domain Layer"

cd "$projectName.Domain"
dotnet new classlib
Remove-Item Class1.cs

Write-Output "Setting up Application Layer"

cd "..\$projectName.$application"
dotnet new classlib
Remove-Item Class1.cs
dotnet add package "AutoMapper.Extensions.Microsoft.DependencyInjection"
dotnet add package "FluentValidation"
dotnet add package "FluentValidation.DependencyInjectionExtensions"
dotnet add package "MediatR.Extensions.Microsoft.DependencyInjection"
dotnet add reference "../$projectName.$domain/$projectName.$domain.csproj"

Write-Output "Setting up Infrastructure Layer"
cd "..\$projectName.$infrastructure"
dotnet new classlib
Remove-Item Class1.cs
dotnet add reference "../$projectName.$application/$projectName.$application.csproj"

Write-Output "Setting up the WebApi"
cd "..\$projectName.$api"
dotnet new webapi --no-openapi
Get-ChildItem .\WeatherForecast*.cs -Recurse | Remove-Item
dotnet add reference "../$projectName.$application/$projectName.$application.csproj"
dotnet add reference "../$projectName.$infrastructure/$projectName.$infrastructure.csproj"

Write-Output "Setting up tests"
cd ..\..\Tests

mkdir "$projectName.$domain.$unitTests"
mkdir "$projectName.$application.$unitTests"
cd "$projectName.$domain.$unitTests"
dotnet new xunit
dotnet add reference "../../$source/$projectName.$domain/$projectName.$domain.csproj"

cd ..\"$projectName.$application.$unitTests"
dotnet new xunit
dotnet add reference "../../$source/$projectName.$application/$projectName.$application.csproj"

cd ..\..\

Write-Output "Setting up Solution"
dotnet new sln
dotnet sln add "$source/$projectName.$domain/$projectName.$domain.csproj"
dotnet sln add "$source/$projectName.$application/$projectName.$application.csproj"
dotnet sln add "$source/$projectName.$infrastructure/$projectName.$infrastructure.csproj"
dotnet sln add "$source/$projectName.$api/$projectName.$api.csproj"
dotnet sln add "$tests/$projectName.$domain.$unitTests/$projectName.$domain.$unitTests.csproj"
dotnet sln add "$tests/$projectName.$application.$unitTests/$projectName.$application.$unitTests.csproj"