var $component : Object

If (FORM Event:C1606.row#Null:C1517)
	
	$module:=Form:C1466.modules[FORM Event:C1606.row-1]
	
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			//click on checkbox
			
			Form:C1466.updateModulesList($module)
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			
			//click elsewhere
			
			$module.selected:=Not:C34($module.selected)
			
			Form:C1466.updateModulesList($module)
			
			Form:C1466.modules:=Form:C1466.modules  //redraw
			
	End case 
	
End if 