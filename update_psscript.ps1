# Parameters
param (
    [string]$jsonFilePath = "staging/nsi.json",
    [string]$encryptedJsonFilePath = "staging/nsinew_encrypted.json",
    [string]$encryptionKeyFilePath = "staging/encryption_key.txt",
    [string]$encryptionIvFilePath = "staging/encryption_iv.txt"
)
 
# Update nsi.json with secrets
echo "Updating nsi.json with secrets"
$json = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
$json.Sphere.DockerUsername = "$env:DOCKER_USERNAME"
$json.Sphere.DockerPassword = "$env:DOCKER_PASSWORD"
$json.Sphere.APIkey = "$env:prod_API_KEY"
$json | ConvertTo-Json | Set-Content -Path $jsonFilePath
 
# Generate encryption key, encrypt, and save nsi.json
echo "Generating encryption key and encrypting nsi.json file"
$Key = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$KeyString = [Convert]::ToBase64String($Key)
 
$Aes = [System.Security.Cryptography.Aes]::Create()
$Aes.Key = $Key
$Aes.GenerateIV()
$IVString = [Convert]::ToBase64String($Aes.IV)
 
$JsonContent = Get-Content -Path $jsonFilePath -Raw
$Stream = New-Object System.IO.MemoryStream
$CryptoStream = New-Object System.Security.Cryptography.CryptoStream($Stream, $Aes.CreateEncryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)
$Writer = New-Object System.IO.StreamWriter -ArgumentList $CryptoStream
$Writer.Write($JsonContent)
$Writer.Close()
$CryptoStream.Close()
 
$EncryptedContent = [Convert]::ToBase64String($Stream.ToArray())
Set-Content -Path $encryptedJsonFilePath -Value $EncryptedContent
Set-Content -Path $encryptionKeyFilePath -Value $KeyString
Set-Content -Path $encryptionIvFilePath -Value $IVString
 
echo "Encrypted nsi.json content:"
Get-Content -Path $encryptedJsonFilePath
 
echo "Encryption key:"
Get-Content -Path $encryptionKeyFilePath
 
echo "Encryption IV:"
Get-Content -Path $encryptionIvFilePath
