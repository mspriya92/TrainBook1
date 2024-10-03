# Create a temporary file to store output
$tempFile = "tempFile.txt"
#$TEMP_FILE = [System.IO.Path]::GetTempFileName()

# Add headers to the result file
"Phase`tcode-repository`tBranch`tcode" | Out-File -FilePath $tempFile -Encoding utf8

# Load the JSON content from component.json
$components = Get-Content -Raw -Path 'component.json' | ConvertFrom-Json

# Loop through each component in the JSON array
foreach ($component in $components) {
    $PHASE = $component.Phase
    $CODE_REPOSITORY = $component.'code-repository'
    $BRANCH = $component.Branch
    $CODE = $component.code

# Output results to temp file in tab-separated format
"$PHASE`t $CODE_REPOSITORY`t $BRANCH`t $CODE`t" | Out-File -FilePath $tempFile -Append -Encoding utf8
}
$header = @"
+----------------------+-------------------------+--------------------+---------------------+
| Phase                | code-repository         | Branch             | code                |
+----------------------+-------------------------+--------------------+---------------------+
"@

# Print table header to output.txt
$header | Out-File -FilePath "output.txt" -Encoding utf8

# Read the temporary file and format each line as a table row
Get-Content -Path $tempFile | ForEach-Object {
    if ($_ -ne "Phase`tcode-repository`tBranch`tcode`t") {
        # Split columns by tab and trim whitespace
        $columns = $_ -split "`t" | ForEach-Object { $_.Trim() }

         # Format each column with appropriate width
        $formattedRow = "| {0,-29} | {1,-29} | {2,-45} | {3,-45} |" -f $columns[0], $columns[1], $columns[2], $columns[3]

         # Add row to output file
         $formattedRow | Out-File -FilePath "output.txt" -Append -Encoding utf8
   } 
 }

# Define the table footer (not used in this example)
$footer = "+-----------------+--------------------+-----------------+---------------------+"

$footer | Out-File -FilePath "output.txt" -Append -Encoding utf8
