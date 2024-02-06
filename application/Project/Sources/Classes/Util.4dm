Class constructor
	
Function fact($value : Integer)
	If ($value=0)
		return 1
	End if 
	return $value*This:C1470.fact($value-1)
	