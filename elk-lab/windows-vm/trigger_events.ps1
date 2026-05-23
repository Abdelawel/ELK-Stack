Write-Host "Triggering Failed Logon Attempts..."
for ($i=1; $i -le 5; $i++) {
    net use \\localhost /user:FakeUser_$i WrongPass 2>$null
}
Write-Host "Triggering Successful Logon (Event ID 4624)..."
whoami
