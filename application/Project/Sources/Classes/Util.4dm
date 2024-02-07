Class constructor
	
	This:C1470.GitHub:=cs:C1710.GitHub.new()
	
Function fact($value : Integer)
	
	If ($value=0)
		return 1
	End if 
	
	return $value*This:C1470.fact($value-1)
	
Function isRedFlag() : Boolean
	
	$account:=This:C1470.GitHub.getRepo("https://api.github.com/repos/miyako/4d-topic-cicd")
	
	If ($account.open_issues_count#Null:C1517) && ($account.open_issues_count>14)
		return True:C214
	End if 
	
	return False:C215
	