property tool4d : 4D:C1709.File
property compiler : 4D:C1709.Folder

Class constructor
	
	If (Is macOS:C1572)
		This:C1470.tool4d:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.folder("tool4d.app").folder("Contents").folder("MacOS").file("tool4d")
	Else 
		This:C1470.tool4d:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.parent.folder("tool4d").file("tool4d.exe")
	End if 
	
	This:C1470.compiler:=File:C1566("/RESOURCES/4d-class-compiler/Project/compiler.4DProject")
	This:C1470.compilerFolderName:=This:C1470.compiler.parent.parent.fullName
	This:C1470.assetUrl:="https://github.com/miyako/4d-class-compiler/releases/latest/download/4d-class-compiler.zip"
	This:C1470.form:=$form
	
	If (Not:C34(This:C1470.compiler.exists))
		
		$options:=This:C1470
		$options.method:="GET"
		$options.dataType:="blob"
		$options.automaticRedirections:=True:C214
		
		4D:C1709.HTTPRequest.new(This:C1470.assetUrl; $options)
		
	Else 
		OBJECT SET ENABLED:C1123(*; "Build CLI…"; True:C214)
	End if 
	
	//MARK:-public methods
	
Function onResponse($request : 4D:C1709.HTTPRequest; $event : Object)
	
	If ($request.response.status=200) && ($request.dataType="blob")
		
		var $tempFolder : 4D:C1709.Folder
		$tempFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
		$tempFolder.create()
		
		var $tempFile : 4D:C1709.File
		$tempFile:=$tempFolder.file(This:C1470.compilerFolderName+".zip")
		$tempFile.setContent($request.response.body)
		
		$zip:=ZIP Read archive:C1637($tempFile)
		$zip.root.copyTo($tempFolder)
		$tempFolder.folder(This:C1470.compilerFolderName).moveTo(Folder:C1567(fk resources folder:K87:11))
		
		OBJECT SET ENABLED:C1123(*; "Build CLI…"; This:C1470.compiler.exists)
		
	End if 
	
Function onError($request : 4D:C1709.HTTPRequest; $event : Object)
	
Function escape($in : Text)->$out : Text
	
	$out:=$in
	
	var $i; $len : Integer
	
	Case of 
		: (Is Windows:C1573)
			
/*
argument escape for cmd.exe; other programs may be incompatible
*/
			
			$shoudQuote:=False:C215
			
			$metacharacters:="&|<>()%^\" "
			
			$len:=Length:C16($metacharacters)
			
			For ($i; 1; $len)
				$metacharacter:=Substring:C12($metacharacters; $i; 1)
				$shoudQuote:=$shoudQuote | (Position:C15($metacharacter; $out; *)#0)
				If ($shoudQuote)
					$i:=$len
				End if 
			End for 
			
			If ($shoudQuote)
				If (Substring:C12($out; Length:C16($out))="\\")
					$out:="\""+$out+"\\\""
				Else 
					$out:="\""+$out+"\""
				End if 
			End if 
			
		: (Is macOS:C1572)
			
/*
argument escape for bash or zsh; other programs may be incompatible
*/
			
			$metacharacters:="\\!\"#$%&'()=~|<>?;*`[] "
			
			For ($i; 1; Length:C16($metacharacters))
				$metacharacter:=Substring:C12($metacharacters; $i; 1)
				$out:=Replace string:C233($out; $metacharacter; "\\"+$metacharacter; *)
			End for 
			
	End case 
	
Function quote($in : Text)->$out : Text
	
	$out:="\""+$in+"\""
	
	//MARK:-private methods
	
Function _chmod($file : 4D:C1709.File)
	
	If (Is macOS:C1572)
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $file.parent.platformPath)
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "true")
		LAUNCH EXTERNAL PROCESS:C811("chmod +x "+This:C1470.escape($file.fullName))
	End if 
	
Function launch($buildProject : 4D:C1709.File; $compileProject : 4D:C1709.File)
	
	$tool4d:=This:C1470.tool4d
	
	$project:=File:C1566(This:C1470.compiler.platformPath; fk platform path:K87:2)
	
	$folder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
	$folder.create()
	
	If (Is macOS:C1572)
		
		$command:=This:C1470.escape($tool4d.path)
		$command:=$command+" "+This:C1470.escape($project.path)
		$command:=$command+" --startup-method=build"
		$command:=$command+" --user-param="+This:C1470.escape($buildProject.path)+","+This:C1470.escape($compileProject.path)
		$command:=$command+" --dataless"
		
		$command:="osascript"+" -e 'tell application \"Terminal\" to activate\r' -e 'tell application \"Terminal\" to do script \""+Replace string:C233($command; "\\"; "\\\\"; *)+"\"'"
		
		$file:=$folder.file("tool4d.sh")
		$file.setText($command)
		
		LAUNCH EXTERNAL PROCESS:C811("/bin/sh "+This:C1470.escape($file.path))
		
	Else 
		
		$folder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
		$folder.create()
		
		$command:=This:C1470.escape($tool4d.platformPath)
		$command:=$command+" "+This:C1470.escape($project.platformPath)
		$command:=$command+" --startup-method=build"
		$command:=$command+" --user-param="+This:C1470.escape($buildProject.path+","+$compileProject.path)
		$command:=$command+" --dataless"
		
		$file:=$folder.file("tool4d.bat")
		$file.setText($command)
		
/*
VirtualTerminalLevel:1 is enabled for this demo
Adminstration Language is set to UTF-8 for this demo 
*/
		
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "false")
		LAUNCH EXTERNAL PROCESS:C811("cmd.exe /k "+This:C1470.escape($file.platformPath))
		
	End if 