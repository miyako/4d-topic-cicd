If (Form event code:C388=On Clicked:K2:4)
	
	$page:=FORM Get current page:C276
	
	If ($page<Form:C1466.pages.length)
		FORM GOTO PAGE:C247($page+1)
	Else 
		FORM GOTO PAGE:C247(1)
	End if 
	
End if 