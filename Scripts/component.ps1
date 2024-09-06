# Define the URL to the raw JSON file on GitHub
$rawFileUrl = "https://raw.githubusercontent.com/username/repository/main/path/to/component.json"
 
# Download the JSON file content
$jsonContent = Invoke-RestMethod -Uri $rawFileUrl
 
# Parse the JSON content
$jsonData = $jsonContent | ConvertFrom-Json
 
# Define the output file path
$outputFilePath = "component-data.txt"
 
# Select the desired properties and export them as CSV
$jsonData | Select-Object Phase, Branch | Export-Csv -Path $outputFilePath -NoTypeInformation
 
Write-Output "Data exported to $outputFilePath"
