########################################################################################################################################################################################################################################
########################################################################################################################################################################################################################################
#
# INFORMATIE:
# - AD Attribute : lastLogonTimestamp - Deze repliceert tussen Domain Controllers elke 9 tot 14 dagen.
# - AD Attribute : lastLogon - Er zijn scenario's waar dit veld niet niet up-to-date is weergegeven.
# - AD Attribute : msTSExpireDate - 
# - AD Attribute : pwdLastSet - Dit geeft aan wanneer dit account voor het laatst een geldig wachtwoord kreeg toegedeeld.
# - AD Attribute : whenCreated - 
# - AD Attribute : whenChanged - 
# - AD Attribute : userAccountControl - Geeft de status van het account weer. 
#  \_______________________________________________________________________________________________________________________________
#        Flag(s) : Property flag                   Value in hexadecimal	          Value in decimal
#                  ACCOUNTDISABLE	               0x0002	                      2
#                  LOCKOUT	                       0x0010	                      16
#                  NORMAL_ACCOUNT	               0x0200	                      512
#                  DONT_EXPIRE_PASSWORD	           0x10000	                      65536
#                  PASSWORD_EXPIRED	               0x800000	                      8388608
#          Note1 : The flags are cumulative. To disable a user's account, set the UserAccountControl attribute
#                  to 0x0202 (0x002 + 0x0200). In decimal, this is 514 (2 + 512). 
#          Note2 : In a Windows Server 2003-based domain, LOCK_OUT and PASSWORD_EXPIRED have been replaced with a new attribute called ms-DS-User-Account-Control-Computed.
#                  For more information about this new attribute, see ms-DS-User-Account-Control-Computed attribute](/windows/win32/adschema/a-msds-user-account-control-computed).
#           Bron : https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/useraccountcontrol-manipulate-account-properties
#
#
#
# - AD Organizational Unit : DisabledUsers / DeletedUsers - Tijdelijke (klantspecifieke) AD locatie voor de uitgeschakelde accounts.
#  \_______________________________________________________________________________________________________________________________
#   +      KLANT : distinguishedName Attribute OU
#   +        VOM : OU=DeletedUsers,OU=Users,OU=VOM,DC=valid-outsourcing,DC=loc
#   +        SOL :             
#   +        NOC : OU=DeletedUsers,OU=Accounts,OU=Beheer,OU=Datacenter,DC=validnoc,DC=nl
#   +        
#   +        
#   +        
#   +        
#   +        
#   +        
#
#
# AUTOMATED AANPAK:
# - Optie1a: Als een account opgeruimd mag worden, dan slepen we het actief naar de Deleted/Disabled-Users OU.
# - Optie1b: Er draait x keer per dag een script dat de Actieve Users in die OU checked en Disabled, daarbij zetten we een Attribute met een Tag/Datum
# - Optie1c: Tegelijk checken we de Tag/Datum op de Inactive Accounts. Als een treshhold bereikt  is dan deleten we die specifieke accounts.
#
# - Optie2a: Er draait dagelijks een script met een X aantal quota zoals een userAccountControl based Disabled 
#            check met DontExpirePwd naast PwdExpired en dan een "double check" via LastLogon met LastChange.
# - Optie2b: Accounts die aan de quota voldoen worden Disabled met een Tag/Datum attribuut en naar de OU verplaatst.
# - Optie2c: Hetzelfde scheduled script controleerd ook de huidige accounts in de disabled/deleted-accounst OU en
#            de bijbehorende Tag/Datum om te zien of het account verwijderd mag worden.
#
#
# SCRIPTED AANPAK 1:
# - We vragen alle Disabled UserAccounts op uit de Deleted/Disabled-Accounts OU van de klant.
# - We  controleren hoe lang een account al Disabled staat in de Deleted/Disabled-Users OU.
# - Accounts die langer dan 1 maand Disabled staan doen we (via eenSheduledTask) deleten.
#
# SCRIPTED AANPAK 2:
# -Check of er accounts in de DeletedUsers OU staan die enabled zijn.
# -Zet een timestamp in de description van die accounts.
# -Disable deze accounts.
#
# -Check welke account Disabled staat en lees de description uit.
# -Gebaseerd op de Disabled datum in de Description verwijderen we een account na 30 dagen.
#
########################################################################################################################################################################################################################################
########################################################################################################################################################################################################################################


<#
.SYNOPSIS
    Disable user accounts in een OU en Delete die users na 30 dagen disabled.

.DESCRIPTION
    Wanneer een account opgeruimd mag worden verslepen we dit account naar de Deleted/Disabled -Users OU van die specifieke klant.
    We schedulen dit script om elke x aantal uur te draaien. Het script zal dan eerst in de OU zoeken naar actieve user accounts.
    Indien er een nieuw account bij gekomen is, zal het script dit account Disablen en de huidige datum in de Description zetten.
    Daarna controleerd  het script of er Disabled accounts in de OU staan. Daarvan controleren we de Description voor de datum,
    wanneer deze datum langer dan 30 dagen geleden is, zal het Disabled account Deleted worden.


.EXAMPLE
    Dit is een voorbeeldcommando van hoe het script moet worden uitgevoerd.
    .\Get-ExampleScript.ps1 -Switch1 -Param1

.LINK
    https://github.com/EverybodyGetsHurt/Benemortasia/new/master

.NOTES

    Versions:
    - 0.1 klad opmaak
    - 1.0 eerste versie

    Author:
    Ivo Mertens
    Valid IT Infrastructures BV


#>

# Check voor actieve user-accounts in de DeletedUsers OU, zet een Timestamp in de Description en Disable het account.
Get-ADuser -SearchBase 'OU=Test,OU=DeletedUsers,OU=Users,OU=VOM,DC=valid-outsourcing,DC=loc' -Filter {enabled -eq $True} -Properties enabled | 
Set-ADuser -Description (Get-Date -f dd-MM-yyyy) –passthru | 
Disable-ADaccount


# Gebaseerd op de Disabled datum in de Description verwijderen we een account na 30 dagen.
$30days = (get-date).adddays(-30)

Get-Aduser -SearchBase 'OU=Test,OU=DeletedUsers,OU=Users,OU=VOM,DC=valid-outsourcing,DC=loc' -Filter {enabled -eq $False} -Properties description | 
Where { (get-date $_.Description) -le $30Days} | 
Remove-ADobject

