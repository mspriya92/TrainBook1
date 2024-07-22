# Update nsi.json with secrets 
echo "Updating nsi.json with secrets"
$json = Get-Content nsi.json -Raw | ConvertFrom-Json
$json.Sphere.DockerUsername = "$env:DOCKER_USERNAME"
$json.Sphere.DockerPassword = "$env:DOCKER_PASSWORD"
$json.Sphere.APIkey = "$env:prod_API_KEY"
$json | ConvertTo-Json | Set-Content -Path nsi.json
 
# Generate encryption key, encrypt, and save nsi.json
echo "Generating encryption key and encrypting nsi.json file"
$Key = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$KeyString = [Convert]::ToBase64String($Key)
$Aes = [System.Security.Cryptography.Aes]::Create()
$Aes.Key = $Key
$Aes.GenerateIV()
$IVString = [Convert]::ToBase64String($Aes.IV)
 
$JsonContent = Get-Content -Path "nsi.json" -Raw
$Stream = New-Object System.IO.MemoryStream
$CryptoStream = New-Object System.Security.Cryptography.CryptoStream($Stream, $Aes.CreateEncryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)
$Writer = New-Object System.IO.StreamWriter -ArgumentList $CryptoStream
$Writer.Write($JsonContent)
$Writer.Close()
$CryptoStream.Close()
$EncryptedContent = [Convert]::ToBase64String($Stream.ToArray())
 
Set-Content -Path "nsinew_encrypted.json" -Value $EncryptedContent
Set-Content -Path "encryption_key.txt" -Value $KeyString
Set-Content -Path "encryption_iv.txt" -Value $IVString
 
echo "Encrypted nsi.json content:"
Get-Content -Path "nsinew_encrypted.json"
 
echo "Encryption key:"
Get-Content -Path "encryption_key.txt"
 
echo "Encryption IV:"
Get-Content -Path "encryption_iv.txt"
