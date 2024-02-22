property _settingsFile : 4D:C1709.File
property _templateFile : 4D:C1709.File
property _settings : Object

Class constructor($settingsFile : 4D:C1709.File)
	
	This:C1470._settingsFile:=Null:C1517
	This:C1470._templateFile:=Folder:C1567(fk resources folder:K87:11).file("BuildApp-Template.4DSettings")
	
	This:C1470._refresh($settingsFile)
	
Function get settings()->$settings : Object
	
	$settings:=This:C1470._settings
	
	For each ($setting; $settings)
		$settings[$setting]:=This:C1470[$setting]
	End for each 
	
	//MARK:-public methods
	
Function _dialog($buildApp : cs:C1710.BuildApp; $compileProject : 4D:C1709.File)
	
	var $form : cs:C1710._BuildAppUI
	
	$form:=cs:C1710._BuildAppUI.new($buildApp; $compileProject)
	
	$form.pages:=[]
	$form.pages.push({page: 1; title: "Application"})
	$form.pages.push({page: 2; title: "Runtime"})
	$form.pages.push({page: 3; title: "Server"})
	$form.pages.push({page: 4; title: "Client"})
	$form.pages.push({page: 5; title: "Sign"})
	$form.pages.push({page: 6; title: "Version/Common"})
	$form.pages.push({page: 7; title: "Version/RuntimeVL"})
	$form.pages.push({page: 8; title: "Version/Server"})
	$form.pages.push({page: 9; title: "Version/Client"})
	$form.pages.push({page: 10; title: "Deprecated"})
	
	$window:=Open form window:C675("BuildApp")
	DIALOG:C40("BuildApp"; $form; *)
	
Function editor($compileProject : 4D:C1709.File)
	
	If (Application type:C494#4D Remote mode:K5:5)
		
		If (Not:C34(OB Instance of:C1731($compileProject; 4D:C1709.File)))
			$compileProject:=This:C1470._getCurrentProject()
		End if 
		
		CALL WORKER:C1389(1; This:C1470._dialog; This:C1470; $compileProject)
		
	End if 
	
Function findComponents($compileProject : 4D:C1709.File; $asFiles : Boolean)->$components : Collection
	
	$projectComponentsFolder:=$compileProject.parent.parent.folder("Components")
	
	If (Is macOS:C1572)
		$applicationComponentsFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).folder("Contents").folder("Components")
	Else 
		$applicationComponentsFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.folder("Components")
	End if 
	
	$projectComponentFolders:=$projectComponentsFolder.folders(fk ignore invisible:K87:22).query("extension in :1"; [".4dbase"])
	$projectComponentFiles:=$projectComponentsFolder.files(fk ignore invisible:K87:22).query("extension in :1"; [".4DC"; ".4DZ"])
	
	$applicationComponentFolders:=$applicationComponentsFolder.folders(fk ignore invisible:K87:22).query("extension in :1"; [".4dbase"])
	$applicationComponentFiles:=$applicationComponentsFolder.files(fk ignore invisible:K87:22).query("extension in :1"; [".4DC"; ".4DZ"])
	
	$paths:=$projectComponentFolders.combine($projectComponentFiles).extract("path")
	
	//project > application
	
	$folders:=[]
	For each ($folder; $applicationComponentFolders)
		If (Not:C34($paths.includes($folder.path)))
			$folders.push($folder)
		End if 
	End for each 
	
	$files:=[]
	For each ($file; $applicationComponentFiles)
		If (Not:C34($paths.includes($file.path)))
			$files.push($path)
		End if 
	End for each 
	
	$components:=[]
	
	For each ($file; $files)
		$components.push($file)
	End for each 
	
	For each ($folder; $folders)
		If ($asFiles)
			For each ($file; $folder.files().query("extension in :1"; [".4DC"; ".4DZ"]))
				$components.push($file)
			End for each 
		Else 
			$components.push($folder)
		End if 
	End for each 
	
Function findLicenses($licenseTypes : Collection) : cs:C1710.BuildApp
	
	If (Count parameters:C259=0)
		$licenseTypes:=This:C1470._serverLicenses()
	End if 
	
	var $build : Integer
	var $version; $prefix : Text
	
	$version:=Application version:C493($build)
	
	If (Substring:C12($version; 3; 1)#"0")
		$prefix:="R-"
	Else 
		$prefix:=""
	End if 
	
	$params:={parameters: {}}
	$params.parameters.licenseTypes:=[]
	$params.parameters.license4D:=".license4D"
	$versionCode:=Substring:C12($version; 1; 2)+"0"
	For each ($licenseType; $licenseTypes)
		$params.parameters.licenseTypes.push($prefix+$licenseType+$versionCode+"@")
	End for each 
	
	var $files : Collection
	var $file : Object
	
	$files:=Folder:C1567(fk licenses folder:K87:16).files(fk ignore invisible:K87:22).query("name in :licenseTypes and  extension == :license4D"; $params)
	
	Case of 
		: (Is macOS:C1572)
			
			For each ($file; $files)
				This:C1470.Licenses.ArrayLicenseMac.Item.push(Get 4D folder:C485(Licenses folder:K5:11)+$file.fullName)
			End for each 
			
		: (Is Windows:C1573)
			
			For each ($file; $files)
				This:C1470.Licenses.ArrayLicenseWin.Item.push(Get 4D folder:C485(Licenses folder:K5:11)+$file.fullName)
			End for each 
			
	End case 
	
	$isOEM:=(This:C1470.Licenses["ArrayLicense"+(Is macOS:C1572 ? "Mac" : "Win")].Item.includes("@4DOM@"))
	This:C1470.SourcesFiles.CS.IsOEM:=$isOEM
	
	$isOEM:=(This:C1470.Licenses["ArrayLicense"+(Is macOS:C1572 ? "Mac" : "Win")].Item.includes("@4UOE@"))
	This:C1470.SourcesFiles.RuntimeVL.IsOEM:=$isOEM
	
	return This:C1470
	
Function findCertificates() : cs:C1710.BuildApp
	
	$certificates:=[]
	
	If (Is macOS:C1572)
		
		C_BLOB:C604($stdIn; $stdOut; $stdErr)
		C_LONGINT:C283($pid)
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
		
		LAUNCH EXTERNAL PROCESS:C811("security find-identity -p basic -v"; $stdIn; $stdOut; $stdErr; $pid)
		
		$info:=Convert to text:C1012($stdOut; "utf-8")
		
		ARRAY LONGINT:C221($pos; 0)
		ARRAY LONGINT:C221($len; 0)
		
		C_LONGINT:C283($i)
		
		$i:=1
		
		While (Match regex:C1019("(?m)\\s+(\\d+\\))\\s+([:Hex_Digit:]+)\\s+\"([^\"]+)\"$"; $info; $i; $pos; $len))
			$id:=Substring:C12($info; $pos{2}; $len{2})
			$name:=Substring:C12($info; $pos{3}; $len{3})
			$i:=$pos{3}+$len{3}
			$certificate:={id: $id; name: $name}
			If (Match regex:C1019("([^:]+):\\s*(.+?)\\s*\\(([:ascii:]+)\\)"; $name; 1; $pos; $len))
				$certificate.kind:=Substring:C12($name; $pos{1}; $len{1})
				$certificate.account:=Substring:C12($name; $pos{2}; $len{2})
				$certificate.team:=Substring:C12($name; $pos{3}; $len{3})
			End if 
			$certificates.push($certificate)
		End while 
		
		C_TEXT:C284(${1})
		
		If (Count parameters:C259#0)
			$certificates:=$certificates.query.apply($certificates; Copy parameters:C1790)
			If ($certificates.length#0)
				This:C1470.SignApplication.MacCertificate:=$certificates[0].name
			End if 
		End if 
		
	End if 
	
	return This:C1470
	
Function findPlugins($compileProject : 4D:C1709.File)->$plugins : Collection
	
	$PluginsFolder:=$compileProject.parent.parent.folder("Plugins")
	$bundles:=$PluginsFolder.folders(fk ignore invisible:K87:22).query("extension == :1"; ".bundle")
	
	$plugins:=[]
	
	var $manifest : Object
	var $json : Text
	var $manifestFile : 4D:C1709.File
	
	For each ($bundle; $bundles)
		CLEAR VARIABLE:C89($manifest)
		$manifestFile:=$bundle.folder("Contents").folder("Resources").file("manifest.json")
		If ($manifestFile.exists)
			$json:=Document to text:C1236($manifestFile.platformPath)
			$manifest:=JSON Parse:C1218($json; Is object:K8:27)
		Else 
			$manifestFile:=$bundle.folder("Contents").file("manifest.json")  //old location
			If ($manifestFile.exists)
				$json:=Document to text:C1236($manifestFile.platformPath)
				$manifest:=JSON Parse:C1218($json; Is object:K8:27)
			End if 
		End if 
		
		If ($manifest#Null:C1517)
			$plugin:={folder: $bundle; manifest: $manifest}
			$plugins.push($plugin)
		End if 
		
	End for each 
	
Function findPluginsFolder($compileProject : 4D:C1709.File)->$plugins : 4D:C1709.Folder
	
	var $PluginsFolder : 4D:C1709.Folder
	$PluginsFolder:=$compileProject.parent.parent.folder("Plugins")
	If ($PluginsFolder.exists)
		$plugins:=$PluginsFolder
	End if 
	
Function loadFromHost() : cs:C1710.BuildApp
	
	This:C1470._refresh(This:C1470._getDefaultSettingsFile())
	
	return This:C1470
	
Function toFile($file : 4D:C1709.File) : cs:C1710.BuildApp
	
	If (OB Instance of:C1731($file; 4D:C1709.File))
		$ArrayLicenseMac:=This:C1470.Licenses.ArrayLicenseMac.Item
		$ArrayLicenseWin:=This:C1470.Licenses.ArrayLicenseWin.Item
		This:C1470.Licenses.ArrayLicenseMac.Item:=[]
		This:C1470.Licenses.ArrayLicenseWin.Item:=[]
		$file.setText(This:C1470.toString(); "utf-8"; Document with CR:K24:21)
		This:C1470.Licenses.ArrayLicenseMac.Item:=$ArrayLicenseMac
		This:C1470.Licenses.ArrayLicenseWin.Item:=$ArrayLicenseWin
	End if 
	
	return This:C1470
	
Function toObject()->$JSON : Text
	
	$JSON:=JSON Stringify:C1217(This:C1470._cajole(); *)
	
Function toString()->$XML : Text
	
	If (This:C1470._templateFile.exists)
		$template:=This:C1470._templateFile.getText("utf-8"; Document with CR:K24:21)
		PROCESS 4D TAGS:C816($template; $XML; This:C1470.settings)
	End if 
	
Function parseFile($settingsFile : 4D:C1709.File)->$BuildApp : cs:C1710.BuildApp
	
	$BuildApp:=This:C1470
	
	$_BuildApp:={\
		BuildApplicationName: ""; \
		BuildWinDestFolder: ""; \
		BuildMacDestFolder: ""; \
		DataFilePath: ""; \
		BuildApplicationSerialized: False:C215; \
		BuildApplicationLight: False:C215; \
		IncludeAssociatedFolders: False:C215; \
		BuildComponent: False:C215; \
		BuildCompiled: False:C215; \
		ArrayExcludedPluginName: {ItemsCount: Formula:C1597(This:C1470.Item.length); Item: []}; \
		ArrayExcludedPluginID: {ItemsCount: Formula:C1597(This:C1470.Item.length); Item: []}; \
		ArrayExcludedComponentName: {ItemsCount: Formula:C1597(This:C1470.Item.length); Item: []}; \
		ArrayExcludedModuleName: {ItemsCount: Formula:C1597(This:C1470.Item.length); Item: []}; \
		UseStandardZipFormat: False:C215; \
		PackProject: False:C215}
	
	$_BuildApp.AutoUpdate:={\
		CS: {\
		Client: {StartElevated: False:C215}; \
		ClientUpdateWin: {StartElevated: False:C215}; \
		Server: {StartElevated: False:C215}}; \
		RuntimeVL: {StartElevated: False:C215}\
		}
	
	$_BuildApp.CS:={\
		BuildServerApplication: False:C215; \
		BuildCSUpgradeable: False:C215; \
		BuildV13ClientUpgrades: False:C215; \
		IPAddress: ""; \
		PortNumber: 19813; \
		HardLink: ""; \
		RangeVersMin: 1; \
		RangeVersMax: 1; \
		CurrentVers: 1; \
		LastDataPathLookup: "ByAppName"; \
		ServerSelectionAllowed: False:C215; \
		ServerStructureFolderName: ""; \
		ClientWinSingleInstance: True:C214; \
		ClientServerSystemFolderName: ""; \
		ServerEmbedsProjectDirectoryFile: False:C215; \
		ServerDataCollection: False:C215; \
		HideDataExplorerMenuItem: False:C215; \
		HideRuntimeExplorerMenuItem: False:C215; \
		ClientUserPreferencesFolderByPath: False:C215; \
		ShareLocalResourcesOnWindowsClient: False:C215; \
		MacCompiledDatabaseToWin: ""; \
		MacCompiledDatabaseToWinIncludeIt: False:C215; \
		HideAdministrationMenuItem: False:C215}
	
	$_BuildApp.Licenses:={\
		ArrayLicenseWin: {ItemsCount: Formula:C1597(This:C1470.Item.length); Item: []}; \
		ArrayLicenseMac: {ItemsCount: Formula:C1597(This:C1470.Item.length); Item: []}\
		}
	
	$_BuildApp.RuntimeVL:={LastDataPathLookup: "ByAppName"}
	
	$_BuildApp.SignApplication:={MacSignature: ""; MacCertificate: ""; AdHocSign: True:C214}
	
	$_BuildApp.SourcesFiles:={\
		RuntimeVL: {\
		RuntimeVLIncludeIt: False:C215; \
		RuntimeVLWinFolder: ""; \
		RuntimeVLMacFolder: ""; \
		RuntimeVLIconWinPath: ""; \
		RuntimeVLIconMacPath: ""; \
		IsOEM: False:C215}; \
		CS: {\
		ServerIncludeIt: False:C215; \
		ServerWinFolder: ""; \
		ServerMacFolder: ""; \
		ClientWinIncludeIt: False:C215; \
		ClientWinFolderToWin: ""; \
		ClientWinFolderToMac: ""; \
		ClientMacIncludeIt: False:C215; \
		ClientMacFolderToWin: ""; \
		ClientMacFolderToMac: ""; \
		ServerIconWinPath: ""; \
		ServerIconMacPath: ""; \
		ClientMacIconForMacPath: ""; \
		ClientWinIconForMacPath: ""; \
		ClientMacIconForWinPath: ""; \
		ClientWinIconForWinPath: ""; \
		DatabaseToEmbedInClientWinFolder: ""; \
		DatabaseToEmbedInClientMacFolder: ""; \
		IsOEM: False:C215}}
	
	$_BuildApp.Versioning:={\
		Common: {\
		CommonVersion: ""; \
		CommonCopyright: ""; \
		CommonCreator: ""; \
		CommonComment: ""; \
		CommonCompanyName: ""; \
		CommonFileDescription: ""; \
		CommonInternalName: ""; \
		CommonLegalTrademark: ""; \
		CommonPrivateBuild: ""; \
		CommonSpecialBuild: ""}; \
		RuntimeVL: {\
		RuntimeVLVersion: ""; \
		RuntimeVLCopyright: ""; \
		RuntimeVLCreator: ""; \
		RuntimeVLComment: ""; \
		RuntimeVLCompanyName: ""; \
		RuntimeVLFileDescription: ""; \
		RuntimeVLInternalName: ""; \
		RuntimeVLLegalTrademark: ""; \
		RuntimeVLPrivateBuild: ""; \
		RuntimeVLSpecialBuild: ""}; \
		Server: {\
		ServerVersion: ""; \
		ServerCopyright: ""; \
		ServerCreator: ""; \
		ServerComment: ""; \
		ServerCompanyName: ""; \
		ServerFileDescription: ""; \
		ServerInternalName: ""; \
		ServerLegalTrademark: ""; \
		ServerPrivateBuild: ""; \
		ServerSpecialBuild: ""}; \
		Client: {\
		ClientVersion: ""; \
		ClientCopyright: ""; \
		ClientCreator: ""; \
		ClientComment: ""; \
		ClientCompanyName: ""; \
		ClientFileDescription: ""; \
		ClientInternalName: ""; \
		ClientLegalTrademark: ""; \
		ClientPrivateBuild: ""; \
		ClientSpecialBuild: ""}}
	
	$_BuildApp._settingsFile:=$settingsFile
	
	If ($_BuildApp._settingsFile#Null:C1517) && (OB Instance of:C1731($_BuildApp._settingsFile; 4D:C1709.File))
		
		If ($_BuildApp._settingsFile.exists)
			
			$path:=$_BuildApp._settingsFile.platformPath
			
			C_LONGINT:C283($intValue)
			C_TEXT:C284($stringValue)
			C_BOOLEAN:C305($boolValue)
			
			ARRAY TEXT:C222($linkModes; 3)
			$linkModes{1}:="InDbStruct"
			$linkModes{2}:="ByAppName"
			$linkModes{3}:="ByAppPath"
			
			$dom:=DOM Parse XML source:C719($path)
			
			If (OK=1)
				
				$BuildApplicationName:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildApplicationName")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildApplicationName; $stringValue)
					$_BuildApp.BuildApplicationName:=$stringValue
				End if 
				
				$BuildCompiled:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildCompiled")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildCompiled; $boolValue)
					$_BuildApp.BuildCompiled:=$boolValue
				End if 
				
				$IncludeAssociatedFolders:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/IncludeAssociatedFolders")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IncludeAssociatedFolders; $boolValue)
					$_BuildApp.IncludeAssociatedFolders:=$boolValue
				End if 
				
				$BuildComponent:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildComponent")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildComponent; $boolValue)
					$_BuildApp.BuildComponent:=$boolValue
				End if 
				
				$BuildApplicationSerialized:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildApplicationSerialized")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildApplicationSerialized; $boolValue)
					$_BuildApp.BuildApplicationSerialized:=$boolValue
				End if 
				
				$BuildApplicationLight:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildApplicationLight")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildApplicationLight; $boolValue)
					$_BuildApp.BuildApplicationLight:=$boolValue
				End if 
				
				$BuildMacDestFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildMacDestFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildMacDestFolder; $stringValue)
					$_BuildApp.BuildMacDestFolder:=$stringValue
				End if 
				
				$PackProject:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/PackProject")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($PackProject; $boolValue)
					$_BuildApp.PackProject:=$boolValue
				End if 
				
				$UseStandardZipFormat:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/UseStandardZipFormat")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($UseStandardZipFormat; $boolValue)
					$_BuildApp.UseStandardZipFormat:=$boolValue
				End if 
				
				$BuildWinDestFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildWinDestFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildWinDestFolder; $stringValue)
					$_BuildApp.BuildWinDestFolder:=$stringValue
				End if 
				
				$RuntimeVLIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLIncludeIt; $boolValue)
					$_BuildApp.SourcesFiles.RuntimeVL.RuntimeVLIncludeIt:=$boolValue
				End if 
				
				$RuntimeVLMacFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLMacFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLMacFolder; $stringValue)
					$_BuildApp.SourcesFiles.RuntimeVL.RuntimeVLMacFolder:=$stringValue
				End if 
				
				$RuntimeVLWinFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLWinFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLWinFolder; $stringValue)
					$_BuildApp.SourcesFiles.RuntimeVL.RuntimeVLWinFolder:=$stringValue
				End if 
				
				$RuntimeVLIconWinPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLIconWinPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLIconWinPath; $stringValue)
					$_BuildApp.SourcesFiles.RuntimeVL.RuntimeVLIconWinPath:=$stringValue
				End if 
				
				$RuntimeVLIconMacPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLIconMacPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLIconMacPath; $stringValue)
					$_BuildApp.SourcesFiles.RuntimeVL.RuntimeVLIconMacPath:=$stringValue
				End if 
				
				$IsOEM:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/IsOEM")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IsOEM; $boolValue)
					$_BuildApp.SourcesFiles.RuntimeVL.IsOEM:=$boolValue
				End if 
				
				$IsOEM:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/IsOEM")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IsOEM; $boolValue)
					$_BuildApp.SourcesFiles.RuntimeVL.IsOEM:=$boolValue
				End if 
				
				$ServerIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerIncludeIt; $boolValue)
					$_BuildApp.SourcesFiles.CS.ServerIncludeIt:=$boolValue
				End if 
				
				$ClientMacIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacIncludeIt; $boolValue)
					$_BuildApp.SourcesFiles.CS.ClientMacIncludeIt:=$boolValue
				End if 
				
				$ClientWinIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinIncludeIt; $boolValue)
					$_BuildApp.SourcesFiles.CS.ClientWinIncludeIt:=$boolValue
				End if 
				
				$ServerMacFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerMacFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerMacFolder; $stringValue)
					$_BuildApp.SourcesFiles.CS.ServerMacFolder:=$stringValue
				End if 
				
				$ServerWinFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerWinFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerWinFolder; $stringValue)
					$_BuildApp.SourcesFiles.CS.ServerWinFolder:=$stringValue
				End if 
				
				$ClientWinFolderToWin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinFolderToWin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinFolderToWin; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientWinFolderToWin:=$stringValue
				End if 
				
				$ClientWinFolderToMac:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinFolderToMac")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinFolderToMac; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientWinFolderToMac:=$stringValue
				End if 
				
				$ClientMacFolderToWin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacFolderToWin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacFolderToWin; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientMacFolderToWin:=$stringValue
				End if 
				
				$ClientMacFolderToMac:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacFolderToMac")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacFolderToMac; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientMacFolderToMac:=$stringValue
				End if 
				
				$ServerIconWinPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerIconWinPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerIconWinPath; $stringValue)
					$_BuildApp.SourcesFiles.CS.ServerIconWinPath:=$stringValue
				End if 
				
				$ServerIconMacPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerIconMacPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerIconMacPath; $stringValue)
					$_BuildApp.SourcesFiles.CS.ServerIconMacPath:=$stringValue
				End if 
				
				$ClientMacIconForMacPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacIconForMacPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacIconForMacPath; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientMacIconForMacPath:=$stringValue
				End if 
				
				$ClientWinIconForMacPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinIconForMacPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinIconForMacPath; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientWinIconForMacPath:=$stringValue
				End if 
				
				$ClientMacIconForWinPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacIconForWinPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacIconForWinPath; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientMacIconForWinPath:=$stringValue
				End if 
				
				$ClientWinIconForWinPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinIconForWinPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinIconForWinPath; $stringValue)
					$_BuildApp.SourcesFiles.CS.ClientWinIconForWinPath:=$stringValue
				End if 
				
				$ToEmbedInClientMacFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/DatabaseToEmbedInClientMacFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ToEmbedInClientMacFolder; $stringValue)
					$_BuildApp.SourcesFiles.CS.DatabaseToEmbedInClientMacFolder:=$stringValue
				End if 
				
				$ToEmbedInClientWinFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/DatabaseToEmbedInClientWinFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ToEmbedInClientWinFolder; $stringValue)
					$_BuildApp.SourcesFiles.CS.DatabaseToEmbedInClientWinFolder:=$stringValue
				End if 
				
				$IsOEM:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/IsOEM")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IsOEM; $boolValue)
					$_BuildApp.SourcesFiles.RuntimeVL.IsOEM:=$boolValue
				End if 
				
				$BuildServerApplication:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/BuildServerApplication")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildServerApplication; $boolValue)
					$_BuildApp.CS.BuildServerApplication:=$boolValue
				End if 
				
				$LastDataPathLookup:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/LastDataPathLookup")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($LastDataPathLookup; $stringValue)
					If (Find in array:C230($linkModes; $stringValue)#-1)
						$_BuildApp.CS.LastDataPathLookup:=$stringValue
					End if 
				End if 
				
				$BuildCSUpgradeable:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/BuildCSUpgradeable")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildCSUpgradeable; $boolValue)
					$_BuildApp.CS.BuildCSUpgradeable:=$boolValue
				End if 
				
				$CurrentVers:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/CurrentVers")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($CurrentVers; $intValue)
					If ($intValue>0)
						$_BuildApp.CS.CurrentVers:=$intValue
					End if 
				End if 
				
				$HardLink:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/HardLink")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($HardLink; $stringValue)
					$_BuildApp.CS.HardLink:=$stringValue
				End if 
				
				$BuildV13ClientUpgrades:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/BuildV13ClientUpgrades")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildV13ClientUpgrades; $boolValue)
					$_BuildApp.CS.BuildV13ClientUpgrades:=$boolValue
				End if 
				
				$IPAddress:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/IPAddress")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IPAddress; $stringValue)
					$_BuildApp.CS.IPAddress:=$stringValue
				End if 
				
				$PortNumber:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/PortNumber")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($PortNumber; $intValue)
					If ($intValue#0)
						$_BuildApp.CS.PortNumber:=$intValue
					End if 
				End if 
				
				$RangeVersMin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/RangeVersMin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RangeVersMin; $intValue)
					If ($intValue>0)
						$_BuildApp.CS.RangeVersMin:=$intValue
					End if 
				End if 
				
				$RangeVersMax:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/RangeVersMax")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RangeVersMax; $intValue)
					If ($intValue>0)
						$_BuildApp.CS.RangeVersMax:=$intValue
					End if 
				End if 
				
				$ServerSelectionAllowed:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ServerSelectionAllowed")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerSelectionAllowed; $boolValue)
					$_BuildApp.CS.ServerSelectionAllowed:=$boolValue
				End if 
				
				$ServerStructureFolderName:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ServerStructureFolderName")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerStructureFolderName; $stringValue)
					$_BuildApp.CS.ServerStructureFolderName:=$stringValue
				End if 
				
				$ClientServerSystemFolderName:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ClientServerSystemFolderName")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientServerSystemFolderName; $stringValue)
					$_BuildApp.CS.ClientServerSystemFolderName:=$stringValue
				End if 
				
				$MacCompiledDatabaseToWin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/MacCompiledDatabaseToWin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacCompiledDatabaseToWin; $stringValue)
					$_BuildApp.CS.MacCompiledDatabaseToWin:=$stringValue
				End if 
				
				$MacCompiledDatabaseToWinInclude:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/MacCompiledDatabaseToWinIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacCompiledDatabaseToWinInclude; $boolValue)
					$_BuildApp.CS.MacCompiledDatabaseToWinIncludeIt:=$boolValue
				End if 
				
				$HideAdministrationMenuItem:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/HideAdministrationMenuItem")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($HideAdministrationMenuItem; $boolValue)
					$_BuildApp.CS.HideAdministrationMenuItem:=$boolValue
				End if 
				
				$StartElevated:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/AutoUpdate/RuntimeVL/StartElevated")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($StartElevated; $boolValue)
					$_BuildApp.AutoUpdate.RuntimeVL.StartElevated:=$boolValue
				End if 
				
				$StartElevated:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/AutoUpdate/CS/Server/StartElevated")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($StartElevated; $boolValue)
					$_BuildApp.AutoUpdate.CS.Server.StartElevated:=$boolValue
				End if 
				
				$StartElevated:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/AutoUpdate/CS/Client/StartElevated")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($StartElevated; $boolValue)
					$_BuildApp.AutoUpdate.CS.Client.StartElevated:=$boolValue
				End if 
				
				$StartElevated:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/AutoUpdate/CS/ClientUpdateWin/StartElevated")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($StartElevated; $boolValue)
					$_BuildApp.AutoUpdate.CS.ClientUpdateWin.StartElevated:=$boolValue
				End if 
				
				$ShareLocalResourcesOnClient:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ShareLocalResourcesOnWindowsClient")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ShareLocalResourcesOnClient; $boolValue)
					$_BuildApp.CS.ShareLocalResourcesOnWindowsClient:=$boolValue
				End if 
				
				$ClientUserPreferencesFolderByPa:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ClientUserPreferencesFolderByPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientUserPreferencesFolderByPa; $boolValue)
					$_BuildApp.CS.ClientUserPreferencesFolderByPath:=$boolValue
				End if 
				
				$HideRuntimeExplorerMenuItem:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/HideRuntimeExplorerMenuItem")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($HideRuntimeExplorerMenuItem; $boolValue)
					$_BuildApp.CS.HideRuntimeExplorerMenuItem:=$boolValue
				End if 
				
				$HideDataExplorerMenuItem:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/HideDataExplorerMenuItem")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($HideDataExplorerMenuItem; $boolValue)
					$_BuildApp.CS.HideDataExplorerMenuItem:=$boolValue
				End if 
				
				$ServerDataCollection:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ServerDataCollection")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerDataCollection; $boolValue)
					$_BuildApp.CS.ServerDataCollection:=$boolValue
				End if 
				
				$ServerEmbedsProjectDirectoryFil:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ServerEmbedsProjectDirectoryFile")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerEmbedsProjectDirectoryFil; $boolValue)
					$_BuildApp.CS.ServerEmbedsProjectDirectoryFile:=$boolValue
				End if 
				
				$ClientWinSingleInstance:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ClientWinSingleInstance")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinSingleInstance; $boolValue)
					$_BuildApp.CS.ClientWinSingleInstance:=$boolValue
				End if 
				
				$MacSignature:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SignApplication/MacSignature")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacSignature; $boolValue)
					$_BuildApp.SignApplication.MacSignature:=$boolValue
				End if 
				
				$MacCertificate:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SignApplication/MacCertificate")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacCertificate; $stringValue)
					$_BuildApp.SignApplication.MacCertificate:=$stringValue
				End if 
				
				$AdHocSign:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SignApplication/AdHocSign")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($AdHocSign; $boolValue)
					$_BuildApp.SignApplication.AdHocSign:=$boolValue
				End if 
				
				$LastDataPathLookup:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/RuntimeVL/LastDataPathLookup")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($LastDataPathLookup; $stringValue)
					If (Find in array:C230($linkModes; $stringValue)#-1)
						$_BuildApp.RuntimeVL.LastDataPathLookup:=$stringValue
					End if 
				End if 
				
				ARRAY TEXT:C222($names; 0)
				OB GET PROPERTY NAMES:C1232($_BuildApp.Licenses; $names)
				
				For ($i; 1; Size of array:C274($names))
					$name:=$names{$i}
					$ItemsCount:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/Licenses/"+$name+"/ItemsCount")
					If (OK=1)
						DOM GET XML ELEMENT VALUE:C731($ItemsCount; $intValue)
						ARRAY OBJECT:C1221($DatabaseNames; $intValue)
						//$_BuildApp.Licenses[$name].ItemsCount:=$intValue
						$Item:=DOM Get next sibling XML element:C724($ItemsCount)
						For ($j; 0; $intValue-1)  //0 based index
							DOM GET XML ELEMENT VALUE:C731($Item; $stringValue)
							$_BuildApp.Licenses[$name].Item[$j]:=Choose:C955($stringValue=""; Null:C1517; $stringValue)
							$Item:=DOM Get next sibling XML element:C724($Item)
						End for 
					End if 
				End for 
				
				ARRAY TEXT:C222($names; 4)
				
				$names{1}:="ArrayExcludedPluginName"
				$names{2}:="ArrayExcludedPluginID"
				$names{3}:="ArrayExcludedComponentName"
				$names{4}:="ArrayExcludedModuleName"
				
				For ($i; 1; Size of array:C274($names))
					$name:=$names{$i}
					$ItemsCount:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/"+$name+"/ItemsCount")
					If (OK=1)
						DOM GET XML ELEMENT VALUE:C731($ItemsCount; $intValue)
						ARRAY OBJECT:C1221($DatabaseNames; $intValue)
						$Item:=DOM Get next sibling XML element:C724($ItemsCount)
						For ($j; 0; $intValue-1)  //0 based index
							DOM GET XML ELEMENT VALUE:C731($Item; $stringValue)
							$_BuildApp[$name].Item[$j]:=Choose:C955($stringValue=""; Null:C1517; $stringValue)
							$Item:=DOM Get next sibling XML element:C724($Item)
						End for 
					End if 
				End for 
				
				OB GET PROPERTY NAMES:C1232($_BuildApp.Versioning; $names)
				$Versioning:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/Versioning")
				
				If (OK=1)
					
					For ($i; 1; Size of array:C274($names))
						$name:=$names{$i}
						$parent:=DOM Find XML element:C864($Versioning; $name)
						ARRAY TEXT:C222($itemNames; 0)
						OB GET PROPERTY NAMES:C1232($_BuildApp.Versioning[$name]; $itemNames)
						For ($j; 1; Size of array:C274($itemNames))
							$itemName:=$itemNames{$j}
							$child:=DOM Find XML element:C864($parent; $itemName)
							If (OK=1)
								DOM GET XML ELEMENT VALUE:C731($child; $stringValue)
								$_BuildApp.Versioning[$name][$itemName]:=$stringValue
							End if 
							
						End for 
						
					End for 
					
				End if 
				
				DOM CLOSE XML:C722($dom)
				
			End if 
			
		End if 
		
	End if 
	
	$BuildApp._settings:=$_BuildApp
	
	For each ($setting; $BuildApp._settings)
		$BuildApp[$setting]:=$BuildApp._settings[$setting]
	End for each 
	
	//MARK:-private methods
	
Function _cajole()->$settings : Object
	
	$settings:=OB Copy:C1225(This:C1470.settings)
	
	OB REMOVE:C1226($settings; "_settingsFile")
	OB REMOVE:C1226($settings.ArrayExcludedComponentName; "ItemsCount")
	OB REMOVE:C1226($settings.ArrayExcludedModuleName; "ItemsCount")
	OB REMOVE:C1226($settings.ArrayExcludedPluginID; "ItemsCount")
	OB REMOVE:C1226($settings.ArrayExcludedPluginName; "ItemsCount")
	OB REMOVE:C1226($settings.Licenses.ArrayLicenseMac; "ItemsCount")
	OB REMOVE:C1226($settings.Licenses.ArrayLicenseWin; "ItemsCount")
	
Function _desktopLicenses()->$licenses : Collection
	
	$licenses:=["4UOE"; "4UUD"]
	
/*
4UOE:Desktop
4UOE:OEM Desktop
4DDP:Developer
4DOE:OEM Developer
*/
	
Function _getCurrentProject()->$project : 4D:C1709.File
	
	var $projectPath; $hostProjectPath : Text
	$projectPath:=Structure file:C489
	$hostProjectPath:=Structure file:C489(*)
	
	var $isComponent; $isProject : Boolean
	$isComponent:=($projectPath#$hostProjectPath)
	$isProject:=Bool:C1537(Get database parameter:C643($isComponent ? Is host database a project:K37:99 : Is current database a project:K37:98))
	
	$project:=File:C1566($isComponent ? $hostProjectPath : $projectPath; fk platform path:K87:2; *)
	
Function _getDefaultSettingsFile()->$settingsFile : 4D:C1709.File
	
	var $build_settingsFilePath : Text
	
	$build_settingsFilePath:=Get 4D file:C1418(Build application settings file:K5:60; *)
	
	If ($build_settingsFilePath#"")
		var $file : 4D:C1709.File
		$file:=File:C1566($build_settingsFilePath; fk platform path:K87:2)
		If ($file.exists)
			$settingsFile:=$file
		End if 
	End if 
	
Function _refresh($settingsFile : 4D:C1709.File)
	
	This:C1470.parseFile($settingsFile)
	
	This:C1470.findLicenses()
	
Function _serverLicenses()->$licenses : Collection
	
	$licenses:=["4UOE"; "4UUD"; "4UOS"; "4DOM"]
	
/*
4UOE:Desktop
4UOE:OEM Desktop
4DDP:Developer
4DOE:OEM Developer
4DTD:Team Developer
4DOT:OEM Team Developer
4USE:Server
4UOS:OEM Server
4DOM:OEM XML Keys
*/
	