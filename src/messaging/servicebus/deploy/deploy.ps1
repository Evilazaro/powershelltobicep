function Measure-ScriptExecutionTime {
    param(
        [scriptblock]$ScriptToMeasure
    )

    # Start the timer
    $startTime = Get-Date

    # Execute the script block
    & $ScriptToMeasure

    # End the timer
    $endTime = Get-Date

    # Calculate the execution time
    $executionTime = $endTime - $startTime

    Clear-Host

    # Output the total time taken
    Write-Host "The script took $($executionTime.TotalSeconds) seconds to execute."
    # Output the total time taken
    Write-Host "The script took $($executionTime.TotalMinutes) minutes to execute."
    # Output the total time taken
    Write-Host "The script took $($executionTime.TotalHours) hours to execute."
}

# Example usage:
Measure-ScriptExecutionTime {
    # Place the code you want to measure here
    #.\deployAzCLI.ps1
    .\deployPowerShellCmdlets.ps1
    #.\deployBicep.ps1
}
