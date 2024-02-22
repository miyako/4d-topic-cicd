If (Form event code:C388=On Clicked:K2:4)
	
	If (Bool:C1537(Form:C1466.BuildApp.PackProject))
		OBJECT SET ENABLED:C1123(*; "BuildApp.UseStandardZipFormat"; True:C214)
	Else 
		OBJECT SET ENABLED:C1123(*; "BuildApp.UseStandardZipFormat"; False:C215)
	End if 
	
End if 