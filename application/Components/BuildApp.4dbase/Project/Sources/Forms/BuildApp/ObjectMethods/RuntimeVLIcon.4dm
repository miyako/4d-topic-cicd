$event:=FORM Event:C1606

Case of 
	: ($event.code=On Drag Over:K2:13)
		
		$0:=-1
		
		$path:=Get file from pasteboard:C976(1)
		
		Case of 
			: ($path="")
				//
			: (Is macOS:C1572) && (Path to object:C1547($path).extension=".icns")
				$0:=0
			: (Is Windows:C1573) && (Path to object:C1547($path).extension=".ico")
				$0:=0
		End case 
		
	: ($event.code=On Drop:K2:12)
		
		Form:C1466.updateIconPath("RuntimeVL")
		
End case 