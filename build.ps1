Write-Output 'Deleting Cache'

$projectDir = '"typescript"'

npm build $projectDir

Write-Output 'Done building np-vehicles!'