//%attributes = {"invisible":true,"preemptive":"incapable"}
#DECLARE($params : Object)

If (Count parameters:C259=0)
	
	CALL WORKER:C1389(1; Current method name:C684; New object:C1471)
	
Else 
	
	$window:=Open form window:C675("Logo")
	DIALOG:C40("Logo"; *)
	
End if 