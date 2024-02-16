//%attributes = {}
var $buildSettingsFile : 4D:C1709.File
$buildSettingsFile:=File:C1566(Build application settings file:K5:60)

var $buildApp : cs:C1710.BuildApp.BuildApp
$buildApp:=cs:C1710.BuildApp.BuildApp.new($buildSettingsFile)

//customise path
var $destinationFolder : 4D:C1709.Folder
$destinationFolder:=Folder:C1567(fk desktop folder:K87:19).folder($buildApp.BuildApplicationName)
$destinationFolder.create()
$buildApp.BuildMacDestFolder:=$destinationFolder.platformPath

If (Is macOS:C1572)
	//to find licenses in keychain
	$buildApp.findCertificates("name == :1 and kind == :2"; "@miyako@"; "Developer ID Application")
	$BuildApp.SignApplication.MacSignature:=True:C214
	$BuildApp.AdHocSign:=False:C215
End if 

//customise key
$BuildApp.Versioning.Common.CommonVersion:="1.0.0"
$BuildApp.Versioning.Common.CommonCopyright:="©︎K.MIYAKO"
$BuildApp.Versioning.Common.CommonCompanyName:="com.4d.miyako"

$buildApp.editor()