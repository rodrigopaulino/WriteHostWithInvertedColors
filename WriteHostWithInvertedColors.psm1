function global::Write-Host {
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
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::ForegroundColor,
        [Alias("bg")]
        [ConsoleColor]$BackgroundColor = [ConsoleColor]::BackgroundColor,
        [Alias("i")]
        [Switch]$InvertColors = $False
    )

    $InversionMap = @{
        Black = "White"
        DarkBlue = "Yellow"
        DarkGreen = "Magenta"
        DarkCyan = "Red"
        DarkRed = "Cyan"
        DarkMagenta = "Green"
        DarkYellow = "Blue"
        Gray = "Black"
        DarkGray = "White"
        Blue = "DarkYellow"
        Green = "DarkMagenta"
        Cyan = "DarkRed"
        Red = "DarkCyan"
        Magenta = "DarkGreen"
        Yellow = "DarkBlue"
        White = "Black"
    }

    if ($InvertColors) {
        if ($InversionMap.ContainsKey($ForegroundColor.ToString())) {
            $ForegroundColor = $InversionMap[$ForegroundColor.ToString()]
        }

        if ($InversionMap.ContainsKey($BackgroundColor.ToString())) {
            $BackgroundColor = $InversionMap[$BackgroundColor.ToString()]
        }
    }

    $Args = @{}
    
    if ($Object -ne $Null) { $Args['Object'] = $Object }
    $Args['ForegroundColor'] = $ForegroundColor
    $Args['BackgroundColor'] = $BackgroundColor
    if ($NoNewLine.IsPresent) { $Args['NoNewLine'] = $NoNewLine }
    if ($Separator -ne $null) { $Args['Separator'] = $Separator }
    
    Microsoft.PowerShell.Utility\Write-Host @Args
}

Export-ModuleMember -Function Write-Host