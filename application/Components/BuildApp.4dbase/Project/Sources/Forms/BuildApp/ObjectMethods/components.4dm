var $component : Object

If (FORM Event:C1606.row#Null:C1517)
	
	$component:=Form:C1466.components[FORM Event:C1606.row-1]
	
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			//click on checkbox
			
			Form:C1466.updateComponentsList($component)
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			
			//click elsewhere
			
			$component.selected:=Not:C34($component.selected)
			
			Form:C1466.updateComponentsList($component)
			
			Form:C1466.components:=Form:C1466.components  //redraw
			
	End case 
	
End if 