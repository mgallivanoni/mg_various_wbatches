#this is an modded version of https://github.com/nosalan/powershell-mtp-file-transfer/blob/master/phone_backup.ps1

$ErrorActionPreference = [string]"Stop"
$Summary = [Hashtable]@{NewFilesCount=0; ExistingFilesCount=0}

function Get-SubFolder($parentDir, $subPath)
{
  $result = $parentDir
  foreach($pathSegment in ($subPath -split "\\"))
  {
    $result = $result.GetFolder.Items() | Where-Object {$_.Name -eq $pathSegment} | select -First 1
    if($result -eq $null)
    {
      throw "Not found $subPath folder"
    }
  }
  return $result;
}


function Get-PhoneMainDir($phoneName)
{
  $o = New-Object -com Shell.Application
  $rootComputerDirectory = $o.NameSpace(0x11)
  $phoneDirectory = $rootComputerDirectory.Items() | Where-Object {$_.Name -eq $phoneName} | select -First 1
    
  if($phoneDirectory -eq $null)
  {
    throw "Not found '$phoneName' folder in This computer. Connect your phone."
  }
  
  return $phoneDirectory;
}


function Get-FullPathOfMtpDir($mtpDir)
{
 $fullDirPath = ""
 $directory = $mtpDir.GetFolder
 while($directory -ne $null)
 {
   $fullDirPath =  -join($directory.Title, '\', $fullDirPath)
   $directory = $directory.ParentFolder;
 }
 return $fullDirPath
}


function Get-List-FromPhoneSource($sourceMtpDir)
{
 $fullSourceDirPath = Get-FullPathOfMtpDir $sourceMtpDir

 
 Write-Host "Listing: '" $fullSourceDirPath "'"
 
  $listedCount
 
 foreach ($item in ( $sourceMtpDir.GetFolder.Items() | Sort-Object -Property 'Name' -CaseSensitive ) )
 
  {
   $itemName = ($item.Name)

   if($item.IsFolder)
   {
      Write-Host $item.Name " is folder, stepping into"
      Get-List-FromPhoneSource  $item
   }
   else
   {
     $listedCount++;

  	 Write-Host ("{0}{1}" -f $fullSourceDirPath, $item.Name)
   }
  }
  $script:Summary.NewFilesCount += $listedCount 
  $script:Summary.ExistingFilesCount += $existingCount 
  Write-Host "Listed '$listedCount' elements from '$fullSourceDirPath'"
}


# $phoneName = "MyPhoneName" #Phone name as it appears in This PC
#
$phoneName = "Galaxy A32"

$phoneRootDir = Get-PhoneMainDir $phoneName

# "This PC\Galaxy A32\Scheda SD\some_dir\some_subdir"
# arg for my sub is Get-SubFolder $phoneRootDir "Scheda SD\some_dir\some_subdir") 

Get-List-FromPhoneSource (Get-SubFolder $phoneRootDir "Scheda SD\some_dir\some_subdir")

write-host ($Summary | out-string)
