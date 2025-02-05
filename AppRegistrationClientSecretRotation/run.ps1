param($eventGridEvent, $TriggerMetadata)

function RoatateSecret($keyVaultName,$secretName){
    #Retrieve Secret
    $secret = (Get-AzKeyVaultSecret -VaultName $keyVAultName -Name $secretName)
    Write-Host "Secret Retrieved"
    
    #Retrieve Secret Info
    $validityPeriodDays = $secret.Tags["ValidityPeriodDays"]
    $credentialId=  $secret.Tags["CredentialId"]
    $providerAddress = $secret.Tags["ProviderAddress"]
    
    Write-Host "Secret Info Retrieved"
    Write-Host "Validity Period: $validityPeriodDays"
    Write-Host "Credential Id: $credentialId"
    Write-Host "Provider Address: Application Client ID $providerAddress"

    #Get Credential Id to rotate - alternate credential
    $alternateCredentialId = GetAlternateCredentialId $credentialId
    Write-Host "Alternate credential id: $alternateCredentialId"

    #Rotating client secret in the application client id
    ManageClientSecrets $alternateCredentialId $providerAddress
    # Write-Host "Access key regenerated. Access Key Id: $alternateCredentialId Resource Id: $providerAddress"

    # #Add new access key to Key Vault
    # $newSecretVersionTags = @{}
    # $newSecretVersionTags.ValidityPeriodDays = $validityPeriodDays
    # $newSecretVersionTags.CredentialId=$alternateCredentialId
    # $newSecretVersionTags.ProviderAddress = $providerAddress

    # $expiryDate = (Get-Date).AddDays([int]$validityPeriodDays).ToUniversalTime()
    # AddSecretToKeyVault $keyVAultName $secretName $newAccessKeyValue $expiryDate $newSecretVersionTags

    # Write-Host "New access key added to Key Vault. Secret Name: $secretName"
}

function GetAlternateCredentialId($keyId){
    $validCredentialIdsRegEx = '.*[1-2]'
    
    If($keyId -Match $validCredentialIdsRegEx){
        $baseKeyId = $keyId.TrimEnd('1|2')
    }
    Else{
        $baseKeyId = $keyId
    }
    If($keyId -eq "${baseKeyId}1"){
        return "${baseKeyId}2"
    }
    Else{
        return "${baseKeyId}1"
    }
}

function ManageClientSecrets($keyId, $providerAddress){

    Write-Host "Check existing ${keyId} on ${providerAddress}"
    $clientSecrets = (Get-AzADAppCredential -DisplayName ${keyId} | ConvertFrom-Json)
    $clientSecrets | ForEach-Object -Process {
        Write-Host "Deleting existing client secret display name ${keyId}: $_.keyId on ${providerAddress}"
    }    
}

# Make sure to pass hashtables to Out-String so they're logged correctly
$eventGridEvent | ConvertTo-Json | Write-Host

$secretName = $eventGridEvent.subject
$keyVaultName = $eventGridEvent.data.VaultName
Write-Host "Key Vault Name: $keyVAultName"
Write-Host "Secret Name: $secretName"

#Rotate secret
Write-Host "Rotation started."
RoatateSecret $keyVAultName $secretName
Write-Host "Secret Rotated Successfully"