$connectTestResult = 

# test hul igennem til azure storage account
Test-NetConnection -ComputerName storageacc20220620.file.core.windows.net -Port 445


if ($connectTestResult.TcpTestSucceeded) {


    # vi bruger en af de to nøgler som giver sysadmin adgang til storage accounten
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"storageacc20220620.file.core.windows.net`" /user:`"localhost\storageacc20220620`" /pass:`"SZfNC7npojE7uj44q/bVhpiMFHz85CDwLFFOK0jIQDULVcisiWUukoJMO3OoQdWt6QQyUUTbPhOH+AStqN7lrg==`""
    # Mount the drive
    
    New-PSDrive -Name T -PSProvider FileSystem -Root "\\storageacc20220620.file.core.windows.net\filesharedk" -Persist


} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

# på forhånd har vi installeret az modulet til powershell
Install-Module az

# script

Connect-AzAccount

# vi skal lave en storage account

get-command -noun AzStorageAccount

Get-AzStorageAccount

$ressourceGroup='dk'
$location='westeurope'
$dato = Get-Date -Format "yyyyMMdd"
        
#New-AzResourceGroup -location $location -Name $ressourceGroup

#max 24 tegn
$storageAccountName="storageaccountsu$dato"
New-AzStorageAccount -ResourceGroupName $ressourceGroup -Name $storageAccountName -Location $location -Kind StorageV2 -SkuName Standard_GRS -AccessTier Cool

# EnableHierarchicalNamespace
$DataLakeName="datalakesu$dato"
New-AzStorageAccount -Name $DataLakeName -SkuName Standard_LRS -ResourceGroupName $ressourceGroup -Location $location -Kind StorageV2 -AccessTier Cool -EnableHierarchicalNamespace $true

$name='premium20220620'
New-AzStorageAccount -Name $name -SkuName Premium_LRS -ResourceGroupName $ressourceGroup -Location $location -Kind StorageV2 -AccessTier Cool -EnableHierarchicalNamespace $true


# upload some data 
$storageAccount=Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $ressourceGroup

$blobcontainerName='blobcontainer'
New-AzStorageContainer -Name $blobcontainerName -Context $storageAccount.Context -Permission Container

# upload some files
$folder="C:\DP203Kursus\data\images"
Set-Location $folder

$year=(Get-Date).Year
$month=Get-date -Format "MMMM"

Set-AzStorageBlobContent -File .\mtb.jpg -Container $blobcontainerName -BlobType Block -Context $storageAccount.Context -blob "images\products\$year\$month\mtb.jpg"
Set-AzStorageBlobContent -File .\forgaffel.jpg -Container $blobcontainerName -BlobType Block -Context $storageAccount.Context -StandardBlobTier hot -Blob "images\products\$year\$month\forgaffel.jpg"


# upload some data 
$storageAccount=Get-AzStorageAccount -Name $DataLakeName -ResourceGroupName $ressourceGroup

$datalakecontainerName='datalakecontainer'
New-AzStorageContainer -Name $datalakecontainerName -Context $storageAccount.Context -Permission Container

# upload some files
$folder="C:\DP203Kursus\data\aidata"
Set-Location $folder

$year=(Get-Date).Year
$month=Get-date -Format "MMMM"

$files= dir -File
foreach ($file in $files){
    $fileName=$file.Name
    Set-AzStorageBlobContent -File $fileName -Container $datalakecontainerName -BlobType Block -Context $storageAccount.Context -blob "aidata\information\$year\$month\$fileName"
}


# list blobcontainer content
$storageAccount=Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $ressourceGroup
Get-AzStorageBlob -Container $blobcontainerName -Context $storageAccount.Context | select name


# az cli kommando:
# az storage account list --query '[].{Name:name}' --output table

# list datalake container content

$storageAccount=Get-AzStorageAccount -Name $DataLakeName -ResourceGroupName $ressourceGroup
Get-AzStorageBlob -Container $datalakecontainerName -Context $storageAccount.Context |select name

# rasp
$datalakecontainerName='raspberry'
Get-AzStorageBlob -Container $datalakecontainerName -Context $storageAccount.Context |where name -like *csv | measure


# Oprettelse af brugere og grupper i Azure AD

# vi skal have nogle brugere i Azure

$pn=Get-AzDomain | select -ExpandProperty domains


$password="Pa55w.rd"
$passwordSecure=ConvertTo-SecureString -AsPlainText $password -Force

$username="otto"
$Name="Otto Pilfinger"
$upn = "$username@$pn"
$mailnickname="ottoregnskab"
$otto=New-AzADUser -DisplayName $Name -UserPrincipalName $upn -Password $passwordSecure -MailNickname $mailnickname

$username="ottoline"
$Name="Ottoline Pilfinger"
$upn = "$username@$pn"
$mailnickname="ottolinemarketing"
$ottoline=New-AzADUser -DisplayName $Name -UserPrincipalName $upn -Password $passwordSecure -MailNickname $mailnickname



$groupName="BI group"
$mailnickname="bigruppen"
$bigroup=New-AzADGroup -DisplayName $groupName -MailNickname $mailnickname 

Add-AzADGroupMember -TargetGroupDisplayName $groupName -MemberUserPrincipalName $otto.UserPrincipalName,$ottoline.UserPrincipalName

# IT folk:

$username="ivan"
$Name="Ivan IT"
$upn = "$username@$pn"
$mailnickname="ivanit"
$ivan=New-AzADUser -DisplayName $Name -UserPrincipalName $upn -Password $passwordSecure -MailNickname $mailnickname

$username="frode"
$Name="Frode Pilfinger"
$upn = "$username@$pn"
$mailnickname="frodeit"
$frode=New-AzADUser -DisplayName $Name -UserPrincipalName $upn -Password $passwordSecure -MailNickname $mailnickname

# Opret sikkerhedsgruppe til vores to IT folk
$groupName="IT group"
$mailnickname="itgruppen"
$itgroup=New-AzADGroup -DisplayName $groupName -MailNickname $mailnickname 

Add-AzADGroupMember -TargetGroupDisplayName $groupName -MemberUserPrincipalName $ivan.UserPrincipalName,$frode.UserPrincipalName


$storageAccount=Get-AzStorageAccount -Name $DataLakeName -ResourceGroupName $ressourceGroup
$datalakecontainerName='raspberry'
$expiryDate=(get-date).AddDays(4)
New-AzStorageContainerSASToken -Context $storageAccount.Context -Name $datalakecontainerName -Permission racwdl -ExpiryTime $expiryDate
# output: ?sv=2021-04-10&se=2022-06-24T13%3A54%3A44Z&sr=c&sp=racwdl&sig=LJch4QDukeXcI5x2EZ3ZQYRS65KIK5au%2FJODMFvr59M%3D


# I PowerShell kan vi deploye til Azure direkte ved at skrive

New-AzSqlServer ...

New-AzSqlDatabase ...
# ARM template deployment (via filer vi fik fra script i azure portal fra wizard)
New-AzResourceGroupDeployment -TemplateParameterFile  C:\DP203Kursus\sqlserverdeployment\parameters.json  -TemplateFile C:\DP203Kursus\sqlserverdeployment\template.json

