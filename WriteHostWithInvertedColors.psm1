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

    $IsWinOS = $IsWindows -or $PSVersionTable.Platform -eq 'Win32NT'

    if ($Null -eq $ForegroundColor) {
        if ($IsWinOS) {
            $ForegroundColor = [ConsoleColor]::ForegroundColor
        } else {
            $ForegroundColor = "White"
        }
    }

    if ($Null -eq $BackgroundColor) {
        if ($IsWinOS) {
            $BackgroundColor = [ConsoleColor]::BackgroundColor
        } else {
            $BackgroundColor = "Black"
        }
    }

    $InversionMap = @{
        Black = "White"; DarkBlue = "Yellow"; DarkGreen = "Magenta"; DarkCyan = "Red"
        DarkRed = "Cyan"; DarkMagenta = "Green"; DarkYellow = "Blue"; Gray = "Black"
        DarkGray = "White"; Blue = "DarkYellow"; Green = "DarkMagenta"; Cyan = "DarkRed"
        Red = "DarkCyan"; Magenta = "DarkGreen"; Yellow = "DarkBlue"; White = "Black"
    }

    if ($InvertColors) {
        if ($InversionMap.ContainsKey($ForegroundColor.ToString())) {
            $ForegroundColor = $InversionMap[$ForegroundColor.ToString()]
        }

        if ($InversionMap.ContainsKey($BackgroundColor.ToString())) {
            $BackgroundColor = $InversionMap[$BackgroundColor.ToString()]
        }
    }

    $Arguments = @{}

    $IsLegacyWin = $IsWinOS -and $PSVersionTable.PSVersion.Major -lt 6

    if ($IsLegacyWin) {
        # Windows PowerShell 5.1: Use Write-Host with color parameters
        if ($ForegroundColor) { $Arguments['ForegroundColor'] = $ForegroundColor }
        if ($BackgroundColor) { $Arguments['BackgroundColor'] = $BackgroundColor }
        if ($Null -eq $Separator) { $Arguments['Separator'] = $Separator }
    } else {
        # PowerShell 7+ or non-Windows: Use ANSI escape codes to avoid trailing background
        $AnsiForegroundColorMap = @{
            Black=30; Red=31; Green=32; Yellow=33; Blue=34; Magenta=35; Cyan=36; White=37;
            DarkGray=90; DarkRed=91; DarkGreen=92; DarkYellow=93; DarkBlue=94; DarkMagenta=95; DarkCyan=96; Gray=97
        }

        $AnsiBackgroundColorMap = @{
            Black=40; Red=41; Green=42; Yellow=43; Blue=44; Magenta=45; Cyan=46; White=47;
            DarkGray=100; DarkRed=101; DarkGreen=102; DarkYellow=103; DarkBlue=104; DarkMagenta=105; DarkCyan=106; Gray=107
        }

        $ESC = [char]27

        $AnsiForegroundColor = 37

        if ($AnsiForegroundColorMap.ContainsKey($ForegroundColor.ToString())) {
            $AnsiForegroundColor = $AnsiForegroundColorMap[$ForegroundColor.ToString()]
        }

        $AnsiBackgroundColor = 40

        if ($AnsiBackgroundColorMap.ContainsKey($BackgroundColor.ToString())) {
            $AnsiBackgroundColor = $AnsiBackgroundColorMap[$BackgroundColor.ToString()]
        }

        if ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [String])) {
            if ($Null -ne $Separator) {
                $Object = ($Object -join $Separator)
            } else {
                $Object = ($Object -join ' ')
            }
        }

        $Object = "$ESC[${AnsiForegroundColor};${AnsiBackgroundColor}m$Object$ESC[0m"
    }

    if ($Null -ne $Object) { $Arguments['Object'] = $Object }
    if ($NoNewLine.IsPresent) { $Arguments['NoNewLine'] = $NoNewLine }

    Microsoft.PowerShell.Utility\Write-Host @Arguments
}

Export-ModuleMember -Function Write-Host