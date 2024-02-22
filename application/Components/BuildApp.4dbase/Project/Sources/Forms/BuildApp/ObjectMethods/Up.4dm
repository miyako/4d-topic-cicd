If (Form event code:C388=On Clicked:K2:4)
	
	$page:=FORM Get current page:C276
	
	If ($page>1)
		FORM GOTO PAGE:C247($page-1)
	Else 
		FORM GOTO PAGE:C247(Form:C1466.pages.length)
	End if 
	
End if 