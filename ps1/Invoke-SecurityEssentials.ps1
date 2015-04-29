<#
  .Synopsis
    Runs Microsoft Security Essentials to scan or update anti-virus pattern 
   .Example
    Invoke-SecurityEssentials.ps1 -UpdateSignature
    Updates antivirus and malicious software pattern
   .Example
    Invoke-SecurityEssentials.ps1 -DefaultScan
    Updates antivirus and malicious software pattern and performs default scan
   .Example
    Invoke-SecurityEssentials.ps1 -quickScan
    Updates antivirus and malicious software pattern and performs a quick scan
   .Example
    Invoke-SecurityEssentials.ps1 -fullScan
    Updates antivirus and malicious software pattern and performs a full scan
   .Notes
    NAME:  Invoke-SecurityEssentials.ps1
    AUTHOR: Ed Wilson
    LASTEDIT: 4/30/2010
    KEYWORDS: Windows PowerShell, Scripting Guy, security, antivirus, WES-5-16-10
   .Link
     http://www.ScriptingGuys.com
     http://bit.ly/hsgblog
     http://bit.ly/WeekendScripter
 #Requires -Version 2.0
 #>
Param(
 [switch]$updateSignature,
 [switch]$defaultScan,
 [switch]$quickScan,
 [switch]$fullScan
)

Function Invoke-SecurityEssentials
{
 Param($action)
 $path = "c:\program files\microsoft security essentials\MPCMDRUN.EXE"
 Switch ($action)
  {
   $updateSignature { &$path -signatureUpdate }
   $defaultScan { &$path -scan }
   $quickScan { &$path -scan -scantype 1 }
   $fullScan { &$path -scan -scantype 2 }
  } #end switch
} #end function Invoke-SecurityEssentials

Function Get-Results
{
 Get-EventLog -LogName system -Source "Microsoft Anti-Malware" -Newest 2 | 
 Format-Table -Property timewritten, message -Wrap -auto
} # end function Get-Results

# *** entry point to script ***
$quickScan = $true

If($updateSignature)
 { Invoke-SecurityEssentials -action $updateSignature ;  Exit }
If($defaultScan)
 { Invoke-SecurityEssentials -action $defaultScan ; Get-Results ; Exit }
If($quickScan)
 { Invoke-SecurityEssentials -action $quickScan ; Get-Results ; Exit }
If($fullScan)
 { Invoke-SecurityEssentials -action $fullScan ; Get-Results ; Exit }
