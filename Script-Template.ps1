<#
.SYNOPSIS
    Korte omschrijving

.DESCRIPTION
    Uitgebreide beschrijving van wat het script doet. Beschrijf ook de benodigde rechten.

.EXAMPLE
    Dit is een voorbeeldcommando van hoe het script moet worden uitgevoerd.
    .\Get-ExampleScript.ps1 -Switch1 -Waarde1 -Param1

.LINK
    https://github.com/EverybodyGetsHurt/Benemortasia/new/master

.NOTES

    Versions:
    - 0.1 klad opmaak
    - 1.0 eerste versie

    Author:
    Ivo Mertens
    Valid IT Infrastructures BV
    
    Based on the script "PowerShell Script Boiler Template.ps1"
    from Author : Reinout Seegers, Valid IT Infrastructures BV.
#>
[CmdletBinding()]
param (
    # Inhoud van deze parameter wordt teruggegeven aan de console
    [ValidateNotNullOrEmpty()]
    [string]$Parameter1 = 'defaultValue',
    
    # Voorbeeld switch param
    [Switch]$Switch1
)

#Requires -Version 4.0
#Requires -RunAsAdministrator

######
#region Variables
######

# Deze variabele doet x
$variabele1     = 'Waarde1'
#Deze variabele doet Y
$variabeleJaja1 = 'Waarde2'

# Non-terminating errors omzetten naar terminating tbv foutafhandeling
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

#endregion Variables



######
#region Functions
######

# Deze functie geeft output door aan de console
Function Get-ExampleFunction {
    Param (
        [Parameter(Mandatory)]
        [string]$Param1,

        [int]$Param2
    )
    
    # De input naar de console schrijven
    Write-Output $Param1
} 

#endregion Functions



######
#region Logic
######

try {
    
    Get-ExampleFunction -Param1 $Parameter1
    
} catch {
    

} 

#region Logic
