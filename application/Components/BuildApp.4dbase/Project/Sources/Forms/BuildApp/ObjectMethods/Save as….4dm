If (Form event code:C388=On Clicked:K2:4)
	
	var $buildSettingsFile : 4D:C1709.File
	$buildSettingsFile:=File:C1566(Build application settings file:K5:60; *)
	
	$fileName:=Select document:C905($buildSettingsFile.platformPath; ".4DSettings;.xml"; "Save build project…"; File name entry:K24:17 | Package open:K24:8)
	
	If (OK=1)
		
		$buildProject:=File:C1566(DOCUMENT; fk platform path:K87:2)
		
		Form:C1466.BuildApp.toFile($buildProject)
		
	End if 
	
End if 