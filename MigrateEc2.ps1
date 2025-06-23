import-Module AWSPowershell 
##*=============================================================
##*   AWS Move ec2-Instance From Subnet To Another
##*=============================================================
##* Licensed by Infrastructure Consulatant\ Khaled Assasa
##* 
##* Script Steps:
##* 1-Create snapshot from volume of instance
##* 2-Create New volume from snapshot
##* 3-Create Image from the new volume
##* 4-Create new ec2-instance
##* 5-add new volume to new ec2-instance
##* 6-deattach old volume 
##* 7-set the new volume as the root volume
##*==============================================================

$UserSecretKey  = Read-Host "Enter AWS Secret Access Key"
$UserAccessKey = Read-Host "Enter AWS Access Key ID"
$ProfileName  = Read-Host "Enter AWS profile name (leave blank for temporary session)"
$region= Read-Host "Enter AWS region (e.g. us-east-1)"
$SetCredentials = Set-AWSCredential -AccessKey $UserAccessKey -SecretKey $UserSecretKey -StoreAs $ProfileName

##*=============================================================
##*   AWS Move EC2-Instance to Another VPC/Subnet
##*=============================================================
##* Licensed by Infrastructure Consulatant\ Khaled Assasa
##*=============================================================
##* Script Steps:
##* 1-Check Target Instance
##* 2-Check Target VPC and Subnet
##* 3-Create snapshot from volume of instance
##* 4-Create New volume from snapshot
##* 5-Create Image from the new volume
##* 6-Create new EC2-instance
##* 7-Add new volume to new EC2-instance
##* 8-Deattach old volume 
##* 9-Set the new volume as the root volume
##*==============================================================

$TargetRegion = Read-Host "Enter target Region (e.g. us-east-1)" 
$instanceid = Read-Host "Enter source EC2 Instance ID (e.g. i-0123456789abcdef0)"
$subnetid = Read-Host "Enter target Subnet ID (e.g. subnet-0123456789abcdef0)"
$vpcid = Read-Host "Enter target VPC ID (e.g. vpc-0123456789abcdef0)"
$AvailabilityZone = Read-Host "Enter target Availability Zone (e.g. us-east-1a)"
##*==============================================================

################################################################################################
$random=get-random(1,20)
$instance_id = $instanceid 
$target_subnet_id = $subnetid 
$imageName = "instance-$instance_id-$random"
################################################################################################
$Closer = "1"
################################################################################################




##*===============================================
##* Check VPC
##*===============================================
if($vpcid -ne "Empty")
{
                                   #Wait for the VCN Creation
                                   Write-Host "" -ForegroundColor Yellow
                                   Write-Host "CheckIng VPC $vpcid .." -ForegroundColor cyan

                                  TRY{ $VPC = Get-EC2Vpc -VpcId $vpcid } 
                                  CATCH{}

                                  IF($VPC -eq $null)
                                  {
                                    Write-Host "" -ForegroundColor Red
                                    Write-Host "===============================================" -ForegroundColor Red
                                    Write-Host VPC $vpcid does not Exsist !!!  -ForegroundColor Red        
                                    Write-Host "===============================================" -ForegroundColor Red

                                    sleep -s 5

                                    break;
                                  }
                                  else 
                                  {
                                    Write-Host "" -ForegroundColor Red
                                    Write-Host "===============================================" -ForegroundColor Green
                                    Write-Host VPC $vpcid has been verified  -ForegroundColor Green        
                                    Write-Host "===============================================" -ForegroundColor Green

                                     if($subnetid -ne "Empty")
                                     {
                                   #Wait for the VCN Creation
                                   Write-Host "" -ForegroundColor Yellow
                                   Write-Host "CheckIng VPC Subnet $subnetid .." -ForegroundColor cyan

                                  TRY{ $Subnet =  Get-EC2Subnet -SubnetId $subnetid } 
                                  CATCH{}

                                  IF($Subnet -eq $null)
                                  {
                                    Write-Host "" -ForegroundColor Red
                                    Write-Host "===============================================" -ForegroundColor Red
                                    Write-Host VPC Subnet $SubnetID does not Exsist !!!  -ForegroundColor Red        
                                    Write-Host "===============================================" -ForegroundColor Red

                                    sleep -s 5

                                    break;
                                  }
                                  else 
                                  {
                                    Write-Host "" -ForegroundColor Red
                                    Write-Host "===============================================" -ForegroundColor Green
                                    Write-Host VPC Subnet $SubnetID has been verified  -ForegroundColor Green        
                                    Write-Host "===============================================" -ForegroundColor Green
                                  }

                                     }
                                  }
}


##*===============================================
##* Check instance
##*===============================================
if($instanceid -ne "Empty")
{

                                       #Wait for the VCN Creation
                                       Write-Host "" -ForegroundColor Yellow
                                       Write-Host "CheckIng Instance $instanceid .." -ForegroundColor cyan
    
                                      TRY{ $instance = Get-EC2Instance -InstanceIds $instance_id } 
                                      CATCH{}
    
                                      IF($instance -eq $null)
                                      {
                                        Write-Host "" -ForegroundColor Red
                                        Write-Host "===============================================" -ForegroundColor Red
                                        Write-Host Instance $instance_id does not Exsist !!!  -ForegroundColor Red        
                                        Write-Host "===============================================" -ForegroundColor Red
    
                                        sleep -s 5
    
                                        break;
                                      }
                                      else 
                                      {
                                        Write-Host "" -ForegroundColor Red
                                        Write-Host "===============================================" -ForegroundColor Green
                                        Write-Host Instance $instance_id has been verified  -ForegroundColor Green        
                                        Write-Host "===============================================" -ForegroundColor GreeN

                                        Sleep -s 2

                                        Write-Host "" -ForegroundColor Red
                                        Write-Host "===============================================" -ForegroundColor Green
                                        Write-Host Instance $instance_id has been discovered  -ForegroundColor Green    
                                        Write-Host as follows:  -ForegroundColor Green      
                                        Write-Host "===============================================" -ForegroundColor GreeN
                                        Write-Host InstanceID =  $instance_id   -ForegroundColor yellow
                                        Write-Host Instance VpcId = ($instance).Instances.VpcId    -ForegroundColor yellow
                                        Write-Host Instance SubnetId = ($instance).Instances.SubnetId    -ForegroundColor yellow
                                        Write-Host Instance Type = ($instance).Instances.InstanceType   -ForegroundColor yellow
                                        Write-Host Instance Platform = ($instance).Instances.PlatformDetails   -ForegroundColor yellow
                                        Write-Host "===============================================" -ForegroundColor yellow

                                       
                                    }
}


##*===============================================
##* New volume from Snapshot
##*===============================================
if($instance -ne $null)
{
    Write-Host "" -Foreground Yellow
    $close5= Read-Host "Please confirm to create a new the new EC2 Instance volume from the Created Snapshot(Y/N)"
    if($close5 -EQ "Y")
    {
    $volumes = (Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $instanceId }).VolumeId

                                           #Wait for the VCN Creation
                                           Write-Host "" -ForegroundColor Yellow
                                           Write-Host "CheckIng Instance $instanceid EBS.." -ForegroundColor cyan
if($volumes -eq $null)
{
    Write-Host "" -ForegroundColor Red
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host Instance $instance_id Volume can not be discovered !!!  -ForegroundColor Red        
    Write-Host "===============================================" -ForegroundColor Red

    sleep -s 5

    break;
}
else 
{
    Write-Host "" -ForegroundColor Red
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host Instance $instance_id Volume has been discovered  -ForegroundColor Green        
    Write-Host "===============================================" -ForegroundColor Green

    sleep -s 5   <# Action when all if and elseif conditions are false #>
}

                                           #Wait for the VCN Creation
                                           Write-Host "" -ForegroundColor Yellow
                                           Write-Host "Creating EC2 Snapshot .." -ForegroundColor cyan
                                            $snapshot = @() 
                                            foreach($c in $volumes){
                                            $snapshot += New-EC2Snapshot -volumeid $c
                                            }

                                            
                                            for($i = 0; $i -lt $snapshot.Length; $i++)
                                            {
                                            while ((( Get-EC2Snapshot -SnapshotIds $snapshot[$i].snapshotId).State) -ne "Completed") 
                                            {
                                                Write-Host "" -ForegroundColor Yellow
                                                Write-Host "Waiting for Snapshots Completion..."  -Foreground cyan

                                                sleep -s 3
                                            }
                                        }

                                            Write-Host "" -ForegroundColor Yellow
                                            Write-Host "===============================================" -ForegroundColor green
                                            Write-Host "New Snapshot from volume has been Created" -Foreground green
                                            Write-Host "===============================================" -ForegroundColor green

                                           #Wait for the VCN Creation
                                           Write-Host "" -ForegroundColor Yellow
                                           Write-Host "Creating EC2 Volume from Snapshot .." -ForegroundColor cyan
                                        $volume = @()
                                           for($i = 0; $i -lt $snapshot.length; $i++){
                                        $volume += New-EC2Volume -SnapshotId $snapshot[$i].snapshotId -AvailabilityZone $AvailabilityZone

                                        }

                                        while ((( Get-EC2Volume -VolumeId $volume[$volume.length-1].VolumeId).State) -ne "available") 
                                        {
                                            Write-Host "" -ForegroundColor Yellow
                                            Write-Host "Waiting for Volumes Completion..."  -Foreground cyan
                                            sleep -s 3
                                        }

                                        Write-Host "" -ForegroundColor Yellow    
                                        Write-Host "===============================================" -ForegroundColor green                                    
                                        Write-Host "New volume from snapshot has been Created" -Foreground green
                                        Write-Host "===============================================" -ForegroundColor green

                                        $volumeId = $volume.VolumeId

                                        #Wait for the VCN Creation
                                        Write-Host "" -ForegroundColor Yellow
                                        Write-Host "Creating EC2 Image from the new volume .." -ForegroundColor cyan

                                        $image = New-EC2Image -InstanceId $instance_id -Name $imageName

                                        while ((( Get-EC2Image -ImageId $image ).State) -ne "available") 
                                        {
                                            Write-Host "" -ForegroundColor Yellow
                                            Write-Host "Waiting for EC2 Image Completion..."  -Foreground cyan
                                            sleep -s 3
                                        }

                                        Write-Host "" -ForegroundColor Yellow
                                        Write-Host "===============================================" -ForegroundColor green
                                        Write-Host "New Image from the new volume has been Created" -Foreground green
                                        Write-Host "===============================================" -ForegroundColor green


}
}

##*===============================================
##* Create New EC2 Instance 
##*===============================================
if($image -ne $null)
{
    Write-Host "" -Foreground Yellow
    $close5= Read-Host "Please confirm to create a new the new EC2 Instance (Y/N)"
    if($close5 -EQ "Y")
    {
$random=get-random
$NewGroup = @{
    GroupName   = "All traffic $random"
    Description = "Security Group to allow all traffic "
    VpcId             = $VPCID
    Force             = $true
}
$GroupId=New-EC2SecurityGroup @NewGroup
Grant-EC2SecurityGroupIngress -GroupId $GroupId -IpPermission @{
    IpProtocol="tcp"; FromPort="0"; ToPort="65535"; IpRanges="0.0.0.0/0"
}

###*============================================================================================#
    Write-Host "" -ForegroundColor Yellow
    $keyFound= Read-Host "Pleae confirm to create new key pair Y or N to use an existing Key Pair (Y/N)"

if($keyFound -EQ "Y")
{
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Checking exisiting EC2 KeyPair..." -ForegroundColor cyan

    Write-Host "" -ForegroundColor Yellow
    $keyname= Read-Host "Please type in the Key Name"


try{
    $keyvalidation = Get-EC2KeyPair -KeyName $keyname -Region $TargetRegion -ErrorAction SilentlyContinue
}
catch{}

    while($keyvalidation)
    {
     Write-Host "" -ForegroundColor Yellow
     Write-Host "EC2 KeyPair Already Exists!!" -ForegroundColor Red

     Write-Host "" -ForegroundColor Yellow
     $keyname = Read-Host "Enter a new key Pair Name"
     $keyvalidation =""
     try{
     $keyvalidation = Get-EC2KeyPair -KeyName $keyname -ErrorAction SilentlyContinue
     }
     catch{}
    }

    $newsshdir = New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\" -Name ".ssh" -Force -ErrorAction SilentlyContinue
   
    $path = "C:\Users\$env:USERNAME\.ssh\"
    $Userpath = $path + $keyname + ".pem"
    $Userpathpublic = $path + $keyname + ".pub"
    $remove1 = Remove-Item -Path $Userpath -Force -confirm:$false -ErrorAction SilentlyContinue
    $remove1 = Remove-Item -Path $Userpathpublic -Force -confirm:$false -ErrorAction SilentlyContinue

         #Wait for the VCN Creation
         Write-Host "" -ForegroundColor Yellow
         Write-Host "Creating new EC2 Key Pair..." -ForegroundColor cyan

            
            $myPSKeyPair = (New-EC2KeyPair -KeyName $keyname -KeyType "rsa" -KeyFormat "pem").KeyMaterial | Out-File -Encoding ascii -FilePath $path\$keyname.pem
            Write-Host "" -ForegroundColor Yellow
            Write-Host "Key Pair will be downloaded in Path $path$keyname.pem" -Foreground Green


         }

else
{
    Write-Host "" -ForegroundColor Yellow
 $keyname=Read-Host "Enter your Existing key Pair Name"
 try{
 $keyvalidation = Get-EC2KeyPair -KeyName $keyname -Region $TargetRegion
 }
 catch{}

   while($keyvalidation -eq  $null)
   {
    Write-Host "" -ForegroundColor Yellow
    Write-Host "EC2 KeyPair Canot be Found !!" -ForegroundColor Red

    Write-Host "" -ForegroundColor Yellow
    $keyname= Read-Host "Enter your Existing Key Pair Name"
    $keyvalidation = Get-EC2KeyPair -KeyName $keyname -ErrorAction SilentlyContinue
   }
}


###*============================================================================================#
###*============================================================================================#
Write-Host "" -ForegroundColor Yellow
$oldtype = ($instance).Instances.InstanceType
$typevalidation= Read-Host "Pleae confirm to use the Original Instance Type $oldtype Y or N to use a new Type (Y/N)"


if($typevalidation -eq "Y")
{
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Original EC2 Type $oldtype has been confirmed" -Foreground Green

    $InstanceType = $oldtype
}
else 
{
    
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Example : t2.micro " -Foreground yellow

    Write-Host "" -ForegroundColor Yellow
    $InstanceType= Read-Host "Pleae type in the required Instance Type "

    $InstanceType = $InstanceType.ToLower();

    Write-Host "" -ForegroundColor Yellow
    Write-Host "Selected EC2 Type is $newtype" -Foreground Green

    Write-Host "" -ForegroundColor Yellow
    $newtypevalidation= Read-Host "Pleae confirm to use the Instance Type $InstanceType Y or N to use a new Type (Y/N)"

    while($newtypevalidation -eq "N")
    {
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Example : t2.micro " -Foreground yellow

    Write-Host "" -ForegroundColor Yellow
    $InstanceType= Read-Host "Pleae type in the required Instance Type "

    $InstanceType = $InstanceType.ToLower();
    
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Selected EC2 Type is $InstanceType" -Foreground Green

    Write-Host "" -ForegroundColor Yellow
    $newtypevalidation= Read-Host "Pleae confirm to use the Instance Type $InstanceType Y or N to use a new Type (Y/N)"

    }

}

Write-Host "" -ForegroundColor Yellow
$true_False_read= Read-Host "Pleae confirm to Assign the new Instance a Public IP(Y/N)"
  
if($true_False_read -EQ "Y"){
    $trueFalse= $true
}
else{
    $trueFalse =$false
}



while(((Get-EC2Image -Owner self).state) -ne "available")
{
Write-Host "" -ForegroundColor Yellow
Write-Host "Waiting for Image Availablity --------" -ForegroundColor cyan

sleep -s 3
}


                                       #Wait for the VCN Creation
                                       Write-Host "" -ForegroundColor Yellow
                                       Write-Host "Creating the new EC2 Instance.." -ForegroundColor cyan

$new_Instance = New-EC2Instance -AssociatePublicIp $trueFalse -ImageId $image -SubnetId $target_subnet_id `
-InstanceType $InstanceType -KeyName $keyname -SecurityGroupId $GroupId


while ((Get-EC2InstanceStatus -InstanceId $new_Instance.Instances.InstanceId) -eq $null)
{
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Waiting for the new Instance Creation..." -ForegroundColor cyan

    sleep -s 3
}


Write-Host "" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor Green
Write-Host New EC2 Instance has been Created  -ForegroundColor Green        
Write-Host "===============================================" -ForegroundColor GreeN

Sleep -s 2

Write-Host "" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor Green
Write-Host Instance has been discovered  -ForegroundColor Green    
Write-Host as follows:  -ForegroundColor Green      
Write-Host "===============================================" -ForegroundColor GreeN
Write-Host InstanceID =  ($new_Instance).Instances.InstanceId    -ForegroundColor yellow
Write-Host Instance VpcId = ($new_Instance).Instances.VpcId    -ForegroundColor yellow
Write-Host Instance SubnetId = ($new_Instance).Instances.SubnetId    -ForegroundColor yellow
Write-Host Instance Type = ($new_Instance).Instances.InstanceType   -ForegroundColor yellow
Write-Host Instance Platform = ($new_Instance).Instances.PlatformDetails   -ForegroundColor yellow
Write-Host "===============================================" -ForegroundColor yellow

sleep -s 4


    }

}

$vol_will_delete = (Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $new_Instance.Instances.InstanceId }).VolumeId

##*===============================================
##* EC2 Instance Root Volume
##*===============================================
if($new_Instance -ne $null)
{
    Write-Host "" -Foreground Yellow
    $close5= Read-Host "Please confirm to deattach the primary volume from the new EC2 Instance and replace it with the Root Volume (Y/N)"
    if($close5 -EQ "Y")
    {

# List of possible device names (adapt as needed)
$possibleDevices = @("/dev/sdf", "/dev/sdg", "/dev/sdh", "/dev/sdi", "/dev/sdj", "/dev/sdk", "/dev/sdl", "/dev/sdm", "/dev/sdb", "/dev/sdc", "/dev/sdd", "/dev/sde", "/dev/sdn". "/dev/sdo", "/dev/sdp", "/dev/sdq", "/dev/sdr", "/dev/sds", "/dev/sdt", "/dev/sdu", "/dev/sdv", "/dev/sdw", "/dev/sdx", "/dev/sdy", "/dev/sdz", "/dev/xvdbb", "/dev/xvdbc", "/dev/xvdbd", "/dev/xvdbe", "/dev/xvdbf", "/dev/xvdbg", "/dev/xvdbh", "/dev/xvdbi", "/dev/xvdbj", "/dev/xvdbk", "/dev/xvdbl", "/dev/xvdbm", "/dev/xvdbn", "/dev/xvdbo", "/dev/xvdbp", "/dev/xvdbq", "/dev/xvdbr", "/dev/xvdbs", "/dev/xvdbt", "/dev/xvdbu", "/dev/xvdbv", "/dev/xvdbw", "/dev/xvdbx", "/dev/xvdby", "/dev/xvdbz")
$deviceused = (Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $new_Instance.Instances.InstanceId }).attachments.device

$new_volumes = (Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $new_Instance.Instances.InstanceId }).VolumeId
for($i = 0; $i -lt $new_volumes.length; $i++){
    $devname = (Get-EC2Volume -VolumeId $new_volumes[$i]).Attachments | Select-Object -ExpandProperty Device
    if($devname -ne "/dev/xvda"){
    $deattach_volume = Dismount-EC2Volume -InstanceId $new_Instance.Instances.InstanceId -VolumeId $new_volumes[$i] -Force
    }
}
    $count = 0
    for($i = 0; $i -lt $volumeId.length; $i++){
        $deviceused = (Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $new_Instance.Instances.InstanceId }).attachments.device
        $count = 0
        while($possibleDevices[$count] -in $deviceused){
            $count +=1
        }
        $deviceName = $possibleDevices[$count]
        $addVolume = Add-EC2Volume -InstanceId $new_Instance.Instances.InstanceId -VolumeId $volumeId[$i] -Device $deviceName    
    }

    Write-Host "" -ForegroundColor Yellow
Write-Host "Adding a new volumes to the new Instance..." -Foreground cyan

$state = (Get-EC2Instance -InstanceId $new_Instance.Instances.InstanceId).Instances.State.Name
$stopInstance = Stop-EC2Instance -InstanceId $new_Instance.Instances.InstanceId

    do {
        $state = (Get-EC2Instance -InstanceId $new_Instance.Instances.InstanceId).Instances.State.Name
        Start-Sleep -Seconds 10
        Write-Host "" -ForegroundColor Yellow
        Write-Host "Stopping the new EC2 Instance..." -ForegroundColor cyan
        
        
        
       } while ($state -ne 'stopped')
       Write-Host "" -ForegroundColor Red
        Write-Host "===============================================" -ForegroundColor Green
        Write-Host New EC2 Instance has been Stopped  -ForegroundColor Green        
        Write-Host "===============================================" -ForegroundColor GreeN



$x = Get-EC2Instance -InstanceIds $new_Instance.Instances.InstanceId
$v = $x.Instances.BlockDeviceMappings.Ebs.VolumeId


Write-Host "" -ForegroundColor Yellow
Write-Host "Deattaching the new EC2 Instance Primary Volume..." -ForegroundColor cyan

$new_volumes = (Get-EC2Volume -Filter @{ Name = "attachment.instance-id"; Values = $new_Instance.Instances.InstanceId }).VolumeId
for($i = 0; $i -lt $new_volumes.length; $i++){
    $devname = (Get-EC2Volume -VolumeId $new_volumes[$i]).Attachments | Select-Object -ExpandProperty Device
    if($devname -eq "/dev/xvda"){
        $deattach_volume = Dismount-EC2Volume -InstanceId $new_Instance.Instances.InstanceId -VolumeId $new_volumes[$i] -Force
    }
}

Write-Host "" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor GreeN
Write-Host "Deattaching the new EC2 Instance Primary Volumes Completed" -Foreground green
Write-Host "===============================================" -ForegroundColor GreeN




$deattach_old_volume = Dismount-EC2Volume -InstanceId $new_Instance.Instances.InstanceId -VolumeId $volumeId[0] -Force


Write-Host "" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor GreeN
Write-Host "Deattaching the new EC2 Instance new Volume Completed" -Foreground green
Write-Host "===============================================" -ForegroundColor GreeN



$deviceName = "/dev/xvda"
$addVolume = Add-EC2Volume -InstanceId $new_Instance.Instances.InstanceId -VolumeId $volumeId[0] -Device $deviceName

Write-Host "" -ForegroundColor Yellow
Write-Host "Attaching the new volume again to the new instance
 with the root device name Completed" -ForegroundColor green

 Write-Host "" -ForegroundColor Yellow
 Write-Host "Removing the Old Primary volume..." -ForegroundColor cyan


for($i = 0; $i -lt $vol_will_delete.length; $i++){
    if($vol_will_delete[$i] -in (Get-EC2Volume | Select-Object -ExpandProperty VolumeId)){
        $remove_vol = Remove-EC2Volume -VolumeId $vol_will_delete[$i] -Force
    }

}
Write-Host "" -ForegroundColor Yellow
Write-Host "Removing the Old Primary volumes Completed" -ForegroundColor green
$startInstance = Start-EC2Instance -InstanceId $new_Instance.Instances.InstanceId
Write-Host "new ec2 instance has been started" -Foreground green

    }
}



##*===============================================
##* EC2 Instance Data Blocks
##*===============================================
if($new_Instance -ne $null)
{


}


##*===============================================
##*  Stop the Original EC2 Instance
##*===============================================
if($new_Instance -ne $null)
{
    Write-Host "" -ForegroundColor Yellow
$ques2 = read-host "Please confirm to Stop the Original EC2 Instance (Y/N)"
if($ques2 -eq "Y")
{
    Write-Host "" -ForegroundColor Yellow
Write-Host "Stopping the Original EC2 Instance..." -ForegroundColor cyan

    $stop_Instance = Stop-EC2Instance -InstanceId $instance.Instances.InstanceId
    Write-Host "" -ForegroundColor Yellow
    Write-Host "The Original EC2 instance has been Stopped" -Foreground green
}



##*===============================================
##* Delete the Image & Snapshot
##*===============================================
if($new_Instance -ne $null)
{
$ques2 = read-host "Do you want to delete the image & snapshot ? (Y/N)"
if($ques2 -eq "Y")
{
    
$deregister_ami = Unregister-EC2Image -ImageId $image
for($i = 0; $i -lt $volumes.length; $i++){
$remov_snapshot = Remove-EC2Snapshot -SnapshotId $snapshot[$i].snapshotId -Force
    }

    Write-Host "Image has been deleted" -Foreground green
    Write-Host "Snapshot has been deleted" -Foreground green

}
}


##*===============================================
##* Terminate the old EC2 instance
##*===============================================
if($new_Instance -ne $null)
{
$term_instance = read-host "Do You want to Terminate the old EC2 instance?(Y/N)"
if($term_instance -eq "Y")
{
    $term = Remove-EC2Instance -InstanceId $instance_id -Force
    Write-Host "The old EC2 instance has been terminated" -Foreground green
}
}

}

##*===============================================
##*  Start the new EC2 Instance
##*===============================================
if($new_Instance -ne $null)
{
    Write-Host "" -ForegroundColor Yellow
$ques2 = read-host "Please confirm to Start the new EC2 Instance (Y/N)"
if($ques2 -eq "Y")
{

    Write-Host "" -ForegroundColor Yellow
    Write-Host "Starting the New EC2 Instance..." -ForegroundColor cyan

    $startInstance = Start-EC2Instance -InstanceId $new_Instance.Instances.InstanceId
    Write-Host "" -ForegroundColor Yellow
    Write-Host "The New EC2 instance has been Started" -Foreground green
}

}





##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------#
#-------- Script Clousure -------------------------------------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------#
If($closer -eq "1")
{

Write-Host "" -ForegroundColor Yellow

Write-Host " " -ForegroundColor Yellow
Write-Host " " -ForegroundColor Yellow
Write-Host "###############################################################"-ForegroundColor Blue
Write-Host "       AWS Move EC2-Instance to Another VPC/Subnet " -ForegroundColor Yellow
Write-Host "###############################################################" -ForegroundColor Blue
Write-Host "###############################################################" -ForegroundColor Blue
Write-Host "   Licensed by Infrastructure Consulatant\ Khaled Assasa" -ForegroundColor White
Write-Host "###############################################################
###############################################################
############################################################### " -ForegroundColor Blue
Write-Host "                      Thank You !!!" -ForegroundColor White
Write-Host "############################################################### " -ForegroundColor Blue
}


##*===============================================
##*===============================================
##*===============================================
Write-Host " " -ForegroundColor Yellow
$YesOrNoBegin = Read-Host "Please enter your response to Exit (Y/N)"
while("y","n" -notcontains $YesOrNoBegin )
{
  $YesOrNoBegin = Read-Host "Please enter your response to Exit (Y/N)"
}
##*===============================================
##*===============================================
##*===============================================
