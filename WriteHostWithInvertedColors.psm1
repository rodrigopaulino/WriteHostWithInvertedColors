function Write-Host {
    <#
    .SYNOPSIS
    Writes a string to the console with optional inverted colors.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        $Object,
        [Switch]$NoNewLine,
        [String]$Separator,
        [Alias("fg")]
        [ConsoleColor]$ForegroundColor,
        [Alias("bg")]
        [ConsoleColor]$BackgroundColor,
        [Alias("i")]
        [Switch]$InvertColors = $False
    )

    $InversionMap = @{
        Black = "White"; DarkBlue = "Yellow"; DarkGreen = "Magenta"; DarkCyan = "Red"
        DarkRed = "Cyan"; DarkMagenta = "Green"; DarkYellow = "Blue"; Gray = "Black"
        DarkGray = "White"; Blue = "DarkYellow"; Green = "DarkMagenta"; Cyan = "DarkRed"
        Red = "DarkCyan"; Magenta = "DarkGreen"; Yellow = "DarkBlue"; White = "Black"
    }

    $IsWinOS = $IsWindows -or $PSVersionTable.Platform -eq 'Win32NT'

    if ($Null -eq $ForegroundColor) {
        if ($IsWinOS) {
            $ForegroundColor = [ConsoleColor]::ForegroundColor
        } else {
            $ForegroundColor = [ConsoleColor]::White
        }
    }

    if ($Null -eq $BackgroundColor) {
        if ($IsWinOS) {
            $BackgroundColor = [ConsoleColor]::BackgroundColor
        } else {
            $BackgroundColor = [ConsoleColor]::Black
        }
    }

    if ($InvertColors) {
        if ($InversionMap.ContainsKey($ForegroundColor.ToString())) { $ForegroundColor = $InversionMap[$ForegroundColor.ToString()] }
        if ($InversionMap.ContainsKey($BackgroundColor.ToString())) { $BackgroundColor = $InversionMap[$BackgroundColor.ToString()] }
    }

    $Arguments = @{}

    if ($Null -ne $Object) { $Arguments['Object'] = $Object }
    if ($ForegroundColor) { $Arguments['ForegroundColor'] = $ForegroundColor }
    if ($BackgroundColor) { $Arguments['BackgroundColor'] = $BackgroundColor }
    if ($NoNewLine.IsPresent) { $Arguments['NoNewLine'] = $NoNewLine }
    if ($Separator -ne $Null) { $Arguments['Separator'] = $Separator }

    Microsoft.PowerShell.Utility\Write-Host @Arguments
}

Export-ModuleMember -Function Write-Host