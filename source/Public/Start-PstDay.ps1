<#
.SYNOPSIS
Starts the day.

.DESCRIPTION
Starts the day.

Restore the day so far from the json file in the local appdata folder if it exists.

.EXAMPLE
PS> Start-PstDay

This will start the day and restore the day so far from the json file in the local appdata folder if it exists.

#>
function Start-PstDay {

    [Array]$TodaysWork = Restore-PstDay

}
