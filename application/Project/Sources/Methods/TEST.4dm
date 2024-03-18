//%attributes = {"invisible":true}
#DECLARE($mode : Text)

If (Get application info:C1599.headless)
	
	var $CLI : cs:C1710.CLI
	$CLI:=cs:C1710.CLI.new()
	$CLI.logo().version()
	
	var $UTest : cs:C1710.UTest
	
	$UTest:=cs:C1710.UTest.new()
	
	$UTest.runAllTests()
	
	$stdErr:="Unit tests "+($UTest.UTest_result.length#$UTest.UTest_result.count("success"; True:C214) ? "failed" : "passed")
	
	LOG EVENT:C667(Into system standard outputs:K38:9; $stdErr; Error message:K38:3)
	
End if 