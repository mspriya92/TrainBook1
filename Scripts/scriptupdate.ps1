param (
  [string]$fileToEncrypt = "staging/nsi.json",
  [string]$encryptedFile = "staging/nsi_encrypted.json"
)

# Update nsi.json with secrets
echo "Updating nsi.json with secrets"
$json = Get-Content -Path $fileToEncrypt -Raw | ConvertFrom-Json

# Update specific properties with secrets from environment variables
$json.Sphere.DockerUsername = "$env:DOCKER_USERNAME"
$json.Sphere.DockerPassword = "$env:DOCKER_PASSWORD"
$json.Sphere.APIkey = "$env:prod_API_KEY"

# Convert the updated JSON object back to a string
$updatedJsonString = $json | ConvertTo-Json

# Write the updated JSON string to the file (no need for encryption here)
Set-Content -Path $fileToEncrypt -Value $updatedJsonString

# Generate a secure key (replace 'MySuperSecretKey!' with a valid 256-bit key in Base64 encoding)
$keyBase64 = "EtQ8V5KHb5d//DsjSklYVIJi8xmfDOYNwKHmgVI2Ix3JahiQNJZZRLO1jWOuwDwa"  # Example key, replace with your own
 
# Convert Base64 key to byte array
$keyBytes = [Convert]::FromBase64String($keyBase64)
 
# Ensure key is 32 bytes (256 bits)
$key = New-Object byte[] 32
[Array]::Copy($keyBytes, $key, [Math]::Min($keyBytes.Length, $key.Length))
 
# Read the file content as bytes
$plaintext = Get-Content -Path $fileToEncrypt -Encoding UTF8
 
# Create AES encryption provider
$AESProvider = New-Object System.Security.Cryptography.AesCryptoServiceProvider
$AESProvider.KeySize = 256
$AESProvider.Key = $key
$AESProvider.Mode = [System.Security.Cryptography.CipherMode]::CBC
$AESProvider.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
 
# Generate IV (Initialization Vector)
$AESProvider.GenerateIV()
$iv = $AESProvider.IV
 
# Encrypt the content
$encryptor = $AESProvider.CreateEncryptor($AESProvider.Key, $iv)
$encryptedBytes = $encryptor.TransformFinalBlock($plaintext, 0, $plaintext.Length)
 
# Combine IV and encrypted data
$combinedBytes = $iv + $encryptedBytes
 
# Write encrypted data to file
[System.IO.File]::WriteAllBytes($encryptedFile, $combinedBytes)
 
Write-Output "File encrypted successfully."
