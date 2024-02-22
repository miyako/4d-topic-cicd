Class constructor($buildApp : cs:C1710.BuildApp; $compileProject : 4D:C1709.File))
	
	This:C1470.BuildApp:=$buildApp
	This:C1470.compileProject:=$compileProject
	
	This:C1470._setupPluginsList()
	This:C1470._setupComponentsList()
	This:C1470._setupModulesList()
	
	This:C1470._setupDataPathLookup("RuntimeVL")
	This:C1470._setupDataPathLookup("CS")
	
	This:C1470._setupDestinationPath("BuildDest")
	
	This:C1470.RuntimeVLIcon:=This:C1470._setupIconPath("RuntimeVL")
	This:C1470.RuntimeVLApplicationIcon:=This:C1470._setupApplicationPath("RuntimeVL")
	
	This:C1470.Server:={}
	This:C1470.ServerIcon:=This:C1470._setupIconPath("Server")
	This:C1470.ServerApplicationIcon:=This:C1470._setupApplicationPath("Server")
	
	This:C1470.ClientMac:={}
	This:C1470.ClientMacIcon:=This:C1470._setupIconPath("ClientMac")
	
	This:C1470.ClientWin:={}
	This:C1470.ClientWinIcon:=This:C1470._setupIconPath("ClientWin")
	
	This:C1470.DatabaseToEmbedInClientMac:={}
	This:C1470.DatabaseToEmbedInClientMacApplicationIcon:=This:C1470._setupApplicationPath("DatabaseToEmbedInClientMac")
	
	This:C1470.DatabaseToEmbedInClientWin:={}
	This:C1470.DatabaseToEmbedInClientWinApplicationIcon:=This:C1470._setupApplicationPath("DatabaseToEmbedInClientWin")
	
	This:C1470.MacCompiledDatabaseToWin:={}
	This:C1470.MacCompiledDatabaseToWinApplicationIcon:=This:C1470._setupApplicationPath("MacCompiledDatabaseToWin")
	
Function showOnDisk($name : Text; $suffix : Text)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$index:=$form[$name][$name+$suffix].index
	$length:=$form[$name][$name+$suffix].values.length
	$path:=$form[$name][$name+$suffix].values.reverse().slice(0; $length-$index).join(Folder separator:K24:12)
	$form[$name][$name+$suffix].index:=0
	
	SHOW ON DISK:C922($path)
	
Function updateApplicationPath($name : Text)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$path:=Get file from pasteboard:C976(1)
	
	Case of 
		: ($name="DatabaseToEmbedInClientMac") || ($name="DatabaseToEmbedInClientWin")
			$form.BuildApp.SourcesFiles.CS[$name+"Folder"]:=$path
		: ($name="MacCompiledDatabaseToWin")
			$form.BuildApp.CS[$name]:=$path
		: ($name="Server")
			$form.BuildApp.SourcesFiles.CS[$name+(Is macOS:C1572 ? "Mac" : "Win")+"Folder"]:=$path
		Else 
			$form.BuildApp.SourcesFiles[$name][$name+(Is macOS:C1572 ? "Mac" : "Win")+"Folder"]:=$path
			If ($name="RuntimeVL")
				If (Is macOS:C1572)
					$form.BuildApp.SourcesFiles.CS.ClientMacFolderToMac:=$path
				Else 
					$form.BuildApp.SourcesFiles.CS.ClientWinFolderToWin:=$path
				End if 
			End if 
	End case 
	
	$form[$name+"ApplicationIcon"]:=This:C1470._setupApplicationPath($name)
	
Function updateComponentsList($item : Object)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$components:=New collection:C1472
	
	For each ($component; Form:C1466.components)
		If (Not:C34($component.selected))
			$components.push($component.name)
		End if 
	End for each 
	
	$form.BuildApp.ArrayExcludedComponentName.Item:=$components
	
Function updateDestinationPath($name : Text)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$path:=Get file from pasteboard:C976(1)
	
	$buildApp["Build"+(Is macOS:C1572 ? "Mac" : "Win")+"DestFolder"]:=$path
	
	This:C1470._setupDestinationPath("BuildDest")
	
Function updateIconPath($name : Text)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$path:=Get file from pasteboard:C976(1)
	
	Case of 
		: ($name="ClientMac") || ($name="ClientWin")
			$form.BuildApp.SourcesFiles.CS[$name+"IconForMacPath"]:=$path
			$form.BuildApp.SourcesFiles.CS[$name+"IconForWinPath"]:=$path
		: ($name="Server")
			$form.BuildApp.SourcesFiles.CS[$name+"Icon"+(Is macOS:C1572 ? "Mac" : "Win")+"Path"]:=$path
		Else 
			$form.BuildApp.SourcesFiles[$name][$name+"Icon"+(Is macOS:C1572 ? "Mac" : "Win")+"Path"]:=$path
	End case 
	
	$form[$name+"Icon"]:=This:C1470._setupIconPath($name)
	
Function updatePluginsList($item : Object)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$names:=New collection:C1472
	$excludes:=New collection:C1472
	$includes:=New collection:C1472
	
	For each ($plugin; Form:C1466.plugins)
		If (Not:C34($plugin.selected))
			$names.push($plugin.name)
			$excludes.push($plugin.id)
		Else 
			$includes.push($plugin.id)
		End if 
	End for each 
	
	$ids:=New collection:C1472
	For each ($id; $excludes)
		If ($includes.includes($id))
			$ids.push($id)
		End if 
	End for each 
	
	$form.BuildApp.ArrayExcludedPluginName.Item:=$names
	$form.BuildApp.ArrayExcludedPluginID.Item:=$ids
	
Function updateModulesList($item : Object)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$modules:=New collection:C1472
	
	For each ($module; Form:C1466.modules)
		If (Not:C34($module.selected))
			$modules.push($module.name)
		End if 
	End for each 
	
	$form.BuildApp.ArrayExcludedModuleName.Item:=$modules
	
Function _setupApplicationPath($name : Text)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	var $path : Variant
	
	Case of 
		: ($name="MacCompiledDatabaseToWin")
			$path:=$buildApp.CS[$name]
		: ($name="DatabaseToEmbedInClientMac") || ($name="DatabaseToEmbedInClientWin")
			$path:=$buildApp.SourcesFiles.CS[$name+"Folder"]
		: ($name="Server")
			$path:=$buildApp.SourcesFiles.CS[$name+(Is macOS:C1572 ? "Mac" : "Win")+"Folder"]
		Else 
			$path:=$buildApp.SourcesFiles[$name][$name+(Is macOS:C1572 ? "Mac" : "Win")+"Folder"]
			If ($name="RuntimeVL")
				If (Is macOS:C1572)
					$buildApp.SourcesFiles.CS.ClientMacFolderToMac:=$path
				Else 
					$buildApp.SourcesFiles.CS.ClientWinFolderToWin:=$path
				End if 
			End if 
	End case 
	
	$form[$name][$name+"Folder"]:=New object:C1471
	
	If (Value type:C1509($path)=Is text:K8:3) && ($path#"") && (Test path name:C476($path)=Is a folder:K24:2)
		$icon:=Folder:C1567($path; fk platform path:K87:2).getIcon()
		$form[$name][$name+"Folder"].values:=Split string:C1554($path; Folder separator:K24:12; sk ignore empty strings:K86:1).reverse()
	Else 
		$form[$name][$name+"Folder"].values:=New collection:C1472
	End if 
	
	$form[$name][$name+"Folder"].currentValue:=$form[$name][$name+"Folder"].values.length=0 ? "" : $form[$name][$name+"Folder"].values[0]
	$form[$name][$name+"Folder"].index:=-1
	
Function _setupComponentsList()->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$components:=New collection:C1472
	
	For each ($item; $buildApp.findComponents($form.compileProject))
		$name:=$item.name
		$component:=New object:C1471("name"; $name; "selected"; Null:C1517)
		If (Not:C34($buildApp.ArrayExcludedComponentName.Item.includes($name)))
			$component.selected:=True:C214
		Else 
			$component.selected:=False:C215
		End if 
		$components.push($component)
	End for each 
	
	$form.components:=$components
	
Function _setupDataPathLookup($name : Text)
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$form[$name]:=New object:C1471
	$form[$name].LastDataPathLookup:=New object:C1471
	$form[$name].LastDataPathLookup.values:=New collection:C1472("InDbStruct"; "ByAppName"; "ByAppPath")
	$form[$name].LastDataPathLookup.currentValue:=$buildApp[$name].LastDataPathLookup
	$form[$name].LastDataPathLookup.index:=$form[$name].LastDataPathLookup.values.indexOf($buildApp[$name].LastDataPathLookup)
	
Function _setupDestinationPath($name : Text)
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$form[$name]:=New object:C1471
	$form[$name][$name+"Folder"]:=New object:C1471
	
	var $path : Variant
	
	$path:=$buildApp["Build"+(Is macOS:C1572 ? "Mac" : "Win")+"DestFolder"]
	
	var $icon : Picture
	$form[$name][$name+"Folder"]:=New object:C1471
	
	If (Value type:C1509($path)=Is text:K8:3) && ($path#"")
		$icon:=Folder:C1567($path; fk platform path:K87:2).getIcon()
		$form[$name][$name+"Folder"].values:=Split string:C1554($path; Folder separator:K24:12; sk ignore empty strings:K86:1).reverse()
	Else 
		$form[$name][$name+"Folder"].values:=New collection:C1472
	End if 
	
	$form[$name][$name+"Folder"].currentValue:=$form[$name][$name+"Folder"].values.length=0 ? "" : $form[$name][$name+"Folder"].values[0]
	$form[$name][$name+"Folder"].index:=-1
	
	$form[$name+"Icon"]:=$icon
	
Function _setupIconPath($name : Text)->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	var $path : Variant
	
	Case of 
		: ($name="ClientMac") || ($name="ClientWin")
			$path:=($buildApp.SourcesFiles.CS[$name+"IconForMacPath"]) || ($buildApp.SourcesFiles.CS[$name+"IconForWinPath"])
		: ($name="Server")
			$path:=$buildApp.SourcesFiles.CS[$name+"Icon"+(Is macOS:C1572 ? "Mac" : "Win")+"Path"]
		Else 
			$path:=$buildApp.SourcesFiles[$name][$name+"Icon"+(Is macOS:C1572 ? "Mac" : "Win")+"Path"]
	End case 
	
	$form[$name][$name+"IconPath"]:=New object:C1471
	
	If (Value type:C1509($path)=Is text:K8:3) && ($path#"")
		READ PICTURE FILE:C678($path; $icon)
		If (Is Windows:C1573)
			PICTURE PROPERTIES:C457($icon; $width; $height)
			TRANSFORM PICTURE:C988($icon; Scale:K61:2; 32/$width; 32/$height)
		End if 
		$form[$name][$name+"IconPath"].values:=Split string:C1554($path; Folder separator:K24:12; sk ignore empty strings:K86:1).reverse()
		$form[$name][$name+"IconPath"].currentValue:=$form[$name][$name+"IconPath"].values.length=0 ? "" : $form[$name][$name+"IconPath"].values[0]
		$form[$name][$name+"IconPath"].index:=-1
	Else 
		$form[$name][$name+"IconPath"].values:=New collection:C1472
	End if 
	
Function _setupPluginsList()->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$plugins:=New collection:C1472
	
	For each ($item; $buildApp.findPlugins($form.compileProject))
		
		$name:=$item.folder.name
		$id:=$item.manifest.id
		
		$plugin:=New object:C1471("name"; $name; "id"; $id; "selected"; Null:C1517)
		
		If (Not:C34($buildApp.ArrayExcludedPluginName.Item.includes($name)))
			$plugin.selected:=True:C214
		Else 
			If (Not:C34($buildApp.ArrayExcludedPluginID.Item.includes($id)))
				$plugin.selected:=True:C214
			Else 
				$plugin.selected:=False:C215
			End if 
		End if 
		$plugins.push($plugin)
	End for each 
	
	$form.plugins:=$plugins
	
Function _setupModulesList()->$icon : Picture
	
	$form:=This:C1470
	$buildApp:=This:C1470.BuildApp
	
	$modules:=New collection:C1472
	
	For each ($name; New collection:C1472("CEF"; "MeCab"; "PHP"; "SpellChecker"; "4D Updater"))
		$module:=New object:C1471("name"; $name; "selected"; Null:C1517)
		If (Not:C34($buildApp.ArrayExcludedModuleName.Item.includes($name)))
			$module.selected:=True:C214
		Else 
			$module.selected:=False:C215
		End if 
		$modules.push($module)
	End for each 
	
	$form.modules:=$modules