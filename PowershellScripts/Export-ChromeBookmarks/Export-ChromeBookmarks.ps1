$isodate = Get-Date -Format yyyymmmdd_hhmmss
$logFilePath = ".\PowerShell_$isodate.log"
# ############################
Start-Transcript -Path $logFilePath -Append
#########################################


#Declare Variables

$pathToJsonFile = "$env:localappdata\Google\Chrome\User Data\Default\Bookmarks"
#$JsonFilePath = "D:\04. PowerShell\BookMarks\ChromeBookMarx.json"
#$OutputFilePath = "D:\BookMarx.csv" 

$data = Get-content $pathToJsonFile | out-string | ConvertFrom-Json

Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"


#A nested function to enumerate bookmark folders
Function Get-BookmarkFolder {
[cmdletbinding()]
Param(
[Parameter(Position=0,ValueFromPipeline=$True)]
$Node
)

Process 
{

 foreach ($child in $node.children) 
 {
   #get parent folder name
   $parent = $node.Name
   if ($child.type -eq 'Folder') 
   {
     Write-Verbose "Processing $($child.Name)"
     Get-BookmarkFolder $child
   }
   else 
   {
        $hash= [ordered]@{
          Folder = $parent
          Name = $child.name
          URL = $child.url
          Added = [datetime]::FromFileTime(([double]$child.Date_Added)*10)
         
        }
      #write custom object
        New-Object -TypeName PSobject -Property $hash
  } #else url
 } #foreach
 } #process
} #end function

#create a new JSON file
$text | Set-Content '.\file.json'
#$test1 = '{"markers":' | Add-Content 'file.json'

#these should be the top level "folders"
$data.roots.bookmark_bar | Get-BookmarkFolder |ConvertTo-Json |Add-Content '.\\file.json'
$data.roots.other | Get-BookmarkFolder  |ConvertTo-Json |Add-Content '.\file.json'
$data.roots.synced | Get-BookmarkFolder  |ConvertTo-Json |Add-Content '.\file.json'

#$EndBraceClose = ']}' | Add-Content 'file.json'

Get-Content '.\file.json' |
ConvertFrom-Json | Select-Object -ExpandProperty markers |
Export-CSV .\ChromeBookMarx_$isodate.csv -NoTypeInformation

    # end logging 
    ###########################
    Stop-Transcript
    ###########################