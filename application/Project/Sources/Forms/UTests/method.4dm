$pUTests_hl:=OBJECT Get pointer:C1124(Object named:K67:5; "UTests_hl")

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		$pUTests_hl->:=New list:C375
		Form:C1466.UTest.build_HL($pUTests_hl->)
		Form:C1466.test:={message: Form:C1466.UTest.resultText()}
		
	: (FORM Event:C1606.code=On Unload:K2:2)
		
		CLEAR LIST:C377($pUTests_hl->; *)
		
End case 