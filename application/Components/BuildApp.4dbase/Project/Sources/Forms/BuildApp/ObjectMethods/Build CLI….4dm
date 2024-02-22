If (Form event code:C388=On Clicked:K2:4)
	
	$name:="BuildApp-"+Replace string:C233(String:C10(Current date:C33; ISO date:K1:8; Current time:C178); ":"; "-"; *)
	
	$buildProject:=File:C1566(File:C1566("/LOGS/"+$name+".4DSettings").platformPath; fk platform path:K87:2)
	
	Form:C1466.BuildApp.toFile($buildProject)
	
	Form:C1466.CLI.launch($buildProject; Form:C1466.compileProject)
	
End if 