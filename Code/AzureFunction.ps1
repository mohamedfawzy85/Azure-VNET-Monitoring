# Assign values to the remaining variables
$appId = ""
$appSecret = ""
$tenantId = ""
$DceURI = ""
$DcrImmutableId = ""
$Table = ""
$OutputFilePath = ""


# Authenticate to Azure using Managed Identity
Connect-AzAccount -Identity

# Define the date and time for this data collection
$timestamp = Get-Date -Format "yyyyMMddHHmmss"


# Initialize an array to store subnet data
$subnetInfo = @()

# Get all virtual networks in the resource group
$vnetData = Get-AzVirtualNetwork

# Loop through each virtual network
foreach ($vnet in $vnetData) {
    # Get the address space of the VNet
    $addressSpace = $vnet.AddressSpace.AddressPrefixes

    # Loop through each subnet in the virtual network
    foreach ($subnet in $vnet.Subnets) {
        # Initialize variables to store total, used, and available IP counts for the subnet
        $totalIPsInSubnet = 0
        $usedIPsInSubnet = 0
        $availableIPsInSubnet = 0

        # Get the subnet address prefix and split it by "/"
        $subnetPrefix = $subnet.AddressPrefix.Split("/")
        # Calculate the total number of IP addresses in the subnet
        $totalIPsInSubnet = [Math]::Pow(2, 32 - [int]$subnetPrefix[1]) - 5
        # Calculate the number of available IP addresses in the subnet
        $availableIPsInSubnet = $totalIPsInSubnet - $subnet.IpConfigurations.Count
        # Calculate the used IP count in the subnet
        $usedIPsInSubnet = $totalIPsInSubnet - $availableIPsInSubnet
        # Determine if the condition is met (used IP count >= 80% of total IP count)
        $used80 = if ($usedIPsInSubnet -ge ($totalIPsInSubnet * 0.8)) { 1 } else { 0 }

        # Create an object with subnet information
        $subnetInfoObj = [PSCustomObject]@{
            VirtualNetworkName = $vnet.Name
            SubnetName = $subnet.Name
            AddressSpace = $addressSpace
            SubnetRange = $subnet.AddressPrefix  
            TotalIPsInSubnet = $totalIPsInSubnet
            UsedIPsInSubnet = $usedIPsInSubnet
            AvailableIPsInSubnet = $availableIPsInSubnet
            Used80 = $used80
        }

        # Add the subnet information to the array
        $subnetInfo += $subnetInfoObj
    }
}


# Convert the subnetInfo array to a PowerShell data table
$jsonData = $subnetInfo | ConvertTo-Json 

# Save JSON data to the output file (Optional)
$jsonData | Out-File -FilePath $OutputFilePath -Encoding UTF8

# Obtain a bearer token used to authenticate against the data collection endpoint
$scope = [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
$body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
$headers = @{"Content-Type" = "application/x-www-form-urlencoded" };
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token
Write-Host "Bearer Token is: $bearerToken"

# Loop through each JSON object in $jsonData and send it to Log Analytics
foreach ($logEntry in $jsonData) {
    # Sending the data to Log Analytics via the DCR!
    $body = $logEntry;
    $headers = @{"Authorization" = "Bearer $bearerToken"; "Content-Type" = "application/json" };
    $uri = "$DceURI/dataCollectionRules/$dcrImmutableId/streams/Custom-$Table"+"?api-version=2021-11-01-preview";
    
    try {
        $uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers;

        # Log the response or perform any other actions
        Write-Output "Log entry sent successfully. Response: $uploadResponse"
    } catch {
        # Handle any errors that occur during the request
        Write-Error "Error sending log entry: $_"
    }
}
