var $plugin : Object

If (FORM Event:C1606.row#Null:C1517)
	
	$plugin:=Form:C1466.plugins[FORM Event:C1606.row-1]
	
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			//click on checkbox
			
			Form:C1466.updatePluginsList($plugin)
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			
			//click elsewhere
			
			$plugin.selected:=Not:C34($plugin.selected)
			
			Form:C1466.updatePluginsList($plugin)
			
			Form:C1466.plugins:=Form:C1466.plugins  //redraw
			
	End case 
	
End if 