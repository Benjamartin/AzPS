# Set variables for vm
$location              = "Japan East"
$vnetName              = "MyvNet"
$SubnetName            = "Servers"
$CloudServicesName     = "MyCSName"
$StorageAccountName    = "mystorage"
$vmSize                = "Standard_A5"
$vmName                = "MyMultiNICVM"
$ipAddress1            = "192.168.1.4"
$ipAddress2            = "192.168.1.5"
$image                 = "f1179221e23b4dbb89e39d70e5bc9e72__OpenLogic-CentOS-66-20160329"
$NIC1Name              = "NIC1"
$dataDisk1Name         = "MyMultiNICVM-Disk001"
$diskSize              = 1023

# Set default storage account for current subscription
$subscription = Get-AzureSubscription `
    | where {$_.IsCurrent -eq $true}  
Set-AzureSubscription -SubscriptionName $subscription.SubscriptionName `
    -CurrentStorageAccountName $StorageAccountName

# Get credentials
$cred = Get-Credential -Message "Enter username and password for local admin account"

# create VMs Config
$vmConfig = New-AzureVMConfig -Name $vmName `
                -ImageName $image `
                -InstanceSize $vmSize `              
    
# Provision the VM
Add-AzureProvisioningConfig -VM $vmConfig -Linux `
    -LinuxUser $cred.UserName `
    -Password $cred.Password 
    
# Set deafult NIC and IP address
Set-AzureSubnet -SubnetNames $SubnetName -VM $vmConfig
Set-AzureStaticVNetIP -IPAddress $ipAddress1 -VM $vmConfig

# Add a NIC
Add-AzureNetworkInterfaceConfig -Name $NIC1Name `
    -SubnetName $SubnetName `
    -StaticVNetIPAddress $ipAddress2 `
    -VM $vmConfig 

# Create data disks
Add-AzureDataDisk -CreateNew -VM $vmConfig `
    -DiskSizeInGB $diskSize `
    -DiskLabel $dataDisk1Name `
    -LUN 0

# Create the VM
New-AzureVM -VM $vmConfig `
    -ServiceName $CloudServicesName `
    -Location $location `
    -VNetName $vnetName