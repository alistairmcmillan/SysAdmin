param(
    [Parameter(Mandatory=$True)]
    [string]$username
)

Import-Module ActiveDirectory

function Get-ADUsersLastLogon() {
    $dcs = Get-ADDomainController -Filter {Name -like "*"}
    $MyArrayList = New-Object -TypeName "System.Collections.ArrayList"

    foreach($dc in $dcs) {
        $time = 0
        $hostname = $dc.HostName
        if (Test-Connection -Computer $hostname -Count 2 -Quiet) {
            $currentUser = Get-ADUser -Identity $username -Server $hostname -Properties Name, LastLogon, LockedOut
            if($currentUser.LastLogon -gt $time){
                $time = $currentUser.LastLogon
                $dt = [DateTime]::FromFileTime($time)
                $lastLogon = $dt
            } else {
                $lastLogon = $time
            }
        } else {
            $lastLogon = "server did not respond"
        }
        $row = [PSCustomObject]@{
                                Host = $hostname;
                                User = $currentUser.Name;
                                LastLogon = $lastLogon;
                                Locked = $currentUser.LockedOut
                                }
        $MyArrayList += $row
        $row
    }

    $MyArrayList | Out-GridView
}

Get-ADUsersLastLogon
