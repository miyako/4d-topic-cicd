Class constructor($sut : 4D:C1709.Class)
	
	This:C1470.UTest:=cs:C1710.UTest.new()
	
	This:C1470.testMethods:=[]
	
	var $class : 4D:C1709.Class
	$class:=OB Class:C1730(This:C1470)
	$__prototype:=$class.__prototype
	
	var $property : Text
	For each ($property; $__prototype)
		
		If (OB Instance of:C1731($__prototype[$property]; 4D:C1709.Function))
			This:C1470.testMethods.push($property)
		End if 
		
	End for each 
	
	This:C1470.sut:=$sut.new()