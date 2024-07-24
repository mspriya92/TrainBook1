# Define the paths
$fileToEncrypt = "E:/nsi.json"
$encryptedFile = "E:/nsi_encrypted.json"
 
# Generate a secure key (replace 'MySuperSecretKey!' with a valid 256-bit key in Base64 encoding)
$keyBase64 = "EtQ8V5KHb5d//DsjSklYVIJi8xmfDOYNwKHmgVI2Ix3JahiQNJZZRLO1jWOuwDwa"  # Example key, replace with your own
 
# Convert Base64 key to byte array
$keyBytes = [Convert]::FromBase64String($keyBase64)
 
# Ensure key is 32 bytes (256 bits)
$key = New-Object byte[] 32
[Array]::Copy($keyBytes, $key, [Math]::Min($keyBytes.Length, $key.Length))
 
# Read the file content as bytes
$plaintext = Get-Content -Path $fileToEncrypt -Encoding Byte
 
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
