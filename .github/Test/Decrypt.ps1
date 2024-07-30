Param(
    [string]$encryptedFilePath = "staging/nsi_encrypted.json",
    [string]$decryptedFilePath = "staging/nsi_decrypted.json",
    [string]$encryptedKeyBase64 = "EtQ8V5KHb5d//DsjSklYVIJi8xmfDOYNwKHmgVI2Ix3JahiQNJZZRLO1jWOuwDwa"
)
 
try {
    # Load encrypted data from file
    $encryptedBytes = [System.IO.File]::ReadAllBytes($encryptedFilePath)
    
    # Extract IV (Initialization Vector)
    $iv = $encryptedBytes[0..15]
    $encryptedContent = $encryptedBytes[16..($encryptedBytes.Length - 1)]
    
    # Convert Base64 encrypted key to byte array
    $keyBytes = [Convert]::FromBase64String($encryptedKeyBase64)
    
    # Ensure key is 32 bytes (256 bits)
    $key = New-Object byte[] 32
    [Array]::Copy($keyBytes, $key, [Math]::Min($keyBytes.Length, $key.Length))
    
    # Create AES decryption provider
    $AESProvider = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $AESProvider.KeySize = 256
    $AESProvider.Key = $key
    $AESProvider.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $AESProvider.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $AESProvider.IV = $iv
    
    # Decrypt the content
    $decryptor = $AESProvider.CreateDecryptor($AESProvider.Key, $AESProvider.IV)
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedContent, 0, $encryptedContent.Length)
    
    # Write decrypted data to file
    [System.IO.File]::WriteAllBytes($decryptedFilePath, $decryptedBytes)
    
    Write-Output "Decryption successful. Decrypted file saved to: $decryptedFilePath"
}
catch {
    Write-Error "Error during decryption: $_.Exception.Message"
    throw  # Rethrow the exception for NSIS to capture
}

