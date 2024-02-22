If (Form event code:C388=On Clicked:K2:4)
	
	$JSON:=Form:C1466.BuildApp.toObject()
	SET TEXT TO PASTEBOARD:C523($JSON)
	
End if 