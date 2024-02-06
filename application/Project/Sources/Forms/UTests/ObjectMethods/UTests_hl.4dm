

Case of 
	: (FORM Event:C1606.code=On Double Clicked:K2:5)
		
		GET LIST ITEM PARAMETER:C985(Self:C308->; *; "UUID"; $uuid)
		If ($uuid#"")
			$tests:=Form:C1466.UTest.UTest_result.query("UUID == :1"; $uuid)
			If ($tests.length>0)
				$test:=$tests[0]
				METHOD OPEN PATH:C1213(\
					"[class]/"+Replace string:C233($test.testMethod; "."; "/"); \
					Num:C11($test.line))
			End if 
		End if 
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		GET LIST ITEM PARAMETER:C985(Self:C308->; *; "UUID"; $uuid)
		If ($uuid#"")
			$tests:=Form:C1466.UTest.UTest_result.query("UUID == :1"; $uuid)
			If ($tests.length>0)
				Form:C1466.test:=$tests[0]
			End if 
		Else 
			Form:C1466.test:={message: Form:C1466.UTest.resultText()}
		End if 
		
End case 