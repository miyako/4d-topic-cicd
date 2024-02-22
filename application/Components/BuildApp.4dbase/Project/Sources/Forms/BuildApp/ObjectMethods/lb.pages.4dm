If (Form event code:C388=On Clicked:K2:4)
	
	var $col; $row : Integer
	
	LISTBOX GET CELL POSITION:C971(*; OBJECT Get name:C1087; $col; $row)
	
	If ($row>0)
		LISTBOX SELECT ROW:C912(*; "lb.pages"; $row; lk replace selection:K53:1)
		FORM GOTO PAGE:C247($row)
	Else 
		LISTBOX SELECT ROW:C912(*; "lb.pages"; FORM Get current page:C276; lk replace selection:K53:1)
	End if 
	
End if 