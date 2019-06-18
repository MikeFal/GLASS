function Get-HelloWorld{
    param([string]$name)

    "Hello world from $name!" | Out-Host
}