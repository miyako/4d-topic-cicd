If (Form event code:C388=On Clicked:K2:4)
	
	Form:C1466.BuildApp.SignApplication.AdHocSign:=Not:C34(Bool:C1537(Form:C1466.BuildApp.SignApplication.MacSignature))
	
	OBJECT SET ENTERABLE:C238(*; "BuildApp.SignApplication.MacCertificate"; Form:C1466.BuildApp.SignApplication.MacSignature)
	OBJECT SET ENABLED:C1123(*; "BuildApp.SignApplication.AdHocSign"; Form:C1466.BuildApp.SignApplication.AdHocSign)
	
End if 