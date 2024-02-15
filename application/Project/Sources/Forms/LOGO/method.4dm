$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		var $logo : Picture
		READ PICTURE FILE:C678(File:C1566("/RESOURCES/Images/4d-logo.svg").platformPath; $logo)
		Form:C1466.logo:=$logo
		Form:C1466.colors:=["#34568B"; "#FF6F61"; "#6B5B95"; "#88B04B"; "#F7CAC9"; "#92A8D1"]
		Form:C1466.i:=Form:C1466.colors.length-1
		
		SET TIMER:C645(-1)
		
	: ($event.code=On Timer:K2:25)
		
		Form:C1466.i:=Form:C1466.i=0 ? Form:C1466.colors.length-1 : Form:C1466.i-1
		
		$fill:=Form:C1466.colors[Form:C1466.i]
		SVG SET ATTRIBUTE:C1055(*; "Logo"; "blue-rect"; "fill"; $fill)
		
		SET TIMER:C645(6)
		
	: ($event.code=On Unload:K2:2)
		
		SET TIMER:C645(0)
		
		If (Version type:C495 ?? Merged application:K5:28) && (Is Windows:C1573) && (Get application info:C1599.SDIMode)
			QUIT 4D:C291
		End if 
		
End case 