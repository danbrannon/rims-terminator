$SleepTime = 600 #Sleep Duration in MS

$PWDStateAPIKey = $env:PWDStateAPIkey
$DBCred = Invoke-Restmethod -Method GET -Uri 'https://pwdstate.riponpd.org:9119/api/passwords/574' -Header @{ "APIKey" = $PWDStateAPIKey }

$DBServer = $DBCred.URL.Split("=")[1].Replace(" ","")
$databasename = $DBCred.Description.Split("=")[1].Replace(" ", "")

$Connection = new-object system.data.sqlclient.sqlconnection #Set new object to connect to sql database
$Connection.ConnectionString ="server=$DBServer;database=$databasename;user=$($DBCred.Username);password=$($DBCred.password)"

# Connect to Database and Run Query
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand #setting object to use sql commands
$Connection.open()

$Query = "SELECT CRTNUM from TERMINAL WHERE DESCX = '$($env:UserName)1'"

#Create the SQL Command to be run
$SqlCmd.CommandText = $Query

#Object to hold SQL Data
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter

#Run the SQL
$SqlAdapter.SelectCommand = $SqlCmd
$SqlCmd.Connection = $Connection
$DataSet = New-Object System.Data.DataSet

$SqlAdapter.Fill($Dataset) | Out-Null

If ($Dataset.Tables[0].CRTNUM -match '^[0-9]+$') {
    Write-Host "Found terminal match"
}
Else {
    Write-Host "Failed to find terminal number!"
    Exit
}

$RegistryPath = "HKLM:\Software\WOW6432Node\DAI\RIMS"
$RegistryKey = "TerminalNumber"

If (!(Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath
}
$CurrKey = Get-ItemProperty -Path $RegistryPath -Name $RegistryKey

If ($CurrKey -eq $NULL) {
    Write-Host "Womp womp...."
    New-ItemProperty -Path $RegistryPath -Name $RegistryKey -PropertyType String -Value $($Dataset.Tables[0].CRTNUM)
}
Else {
    Set-ItemProperty -Path $RegistryPath -Name $RegistryKey -Value $($Dataset.Tables[0].CRTNUM)
}