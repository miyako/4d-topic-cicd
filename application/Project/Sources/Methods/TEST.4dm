//%attributes = {"invisible":true}
#DECLARE($mode : Text)

If (Get application info:C1599.headless)
	
/*
	
this method is designed to be executed in utility mode
https://developer.4d.com/docs/Admin/cli/#tool4d
	
*/
	
	var $CLI : cs:C1710.CLI
	$CLI:=cs:C1710.CLI.new()
	$CLI.logo().version()
	
	var $UTest : cs:C1710.UTest
	
	$UTest:=cs:C1710.UTest.new()
	
	$resultText:=$UTest.runAllTests().resultText()
	
	TEXT TO DOCUMENT:C1237("UTestResult.txt"; $resultText)
	
End if 