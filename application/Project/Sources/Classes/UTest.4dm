Class constructor
	This:C1470.UTest_result:=[]
	
Function runAllTests() : cs:C1710.UTest
	$start:=Milliseconds:C459
	$testClasses:=OB Entries:C1720(cs:C1710).query("key == :1"; "@_test")
	For each ($testClass; $testClasses)
		$class_test:=cs:C1710[$testClass.key].new()
		
		If ($class_test.testMethods#Null:C1517)
			For each ($testMethod; $class_test.testMethods)
				If ($testMethod#"")
					$class_test[$testMethod]()
				End if 
			End for each 
		End if 
		This:C1470.UTest_result:=This:C1470.UTest_result.concat($class_test.UTest.UTest_result)
	End for each 
	
	This:C1470.time:=Milliseconds:C459-$start
	return This:C1470
	
Function resultText()->$resultText : Text
	$testsFailed:=This:C1470.UTest_result.query("success == :1"; False:C215)
	
	$resultText:=$testsFailed.length>0 ? "Unit tests failed" : "Unit tests passed"
	$resultText+="\r"
	$resultText+="Tests: "+String:C10(This:C1470.UTest_result.length)+"\r"+\
		String:C10($testsFailed.length)+" failed\r"+\
		String:C10(This:C1470.UTest_result.length-$testsFailed.length)+" passed\r"+\
		"Time: "+String:C10(This:C1470.time)+" ms\r\r"
	
	$resultText+="------------------------------\r"
	$resultText+=$testsFailed.extract("message").join("------------------------------\r")
	
Function _build_result($testResult : Boolean; $callChain : Collection; $description : Text; $excpected : Variant; $received : Variant; $msg : Text)->$result : Object
	$objTest:=Position:C15("."; $callChain[1].name)>0 ? \
		{class: Split string:C1554($callChain[1].name; ".")[0]; function: Split string:C1554($callChain[1].name; ".")[1]} : \
		{class: Null:C1517; function: $callChain[1].name}
	
	$result:={}
	$result.UUID:=Generate UUID:C1066
	$result.success:=$testResult
	$result.testMethod:=$callChain[1].name
	$result.class:=$objTest.class
	$result.function:=$objTest.function
	$result.description:=$description
	$result.line:=$callChain[1].line
	
	$result.message:="--> "+$description+"\r"
	$result.message+="Function: "+$callChain[1].name+" - Line: "+String:C10($callChain[1].line)+"\r"+\
		"Expected: "+String:C10($excpected)+"\r"+\
		"Recevied: "+String:C10($received)+"\r"+\
		$msg+"\r"
	
Function describe($description : Text) : cs:C1710.UTest
	This:C1470.description:=$description
	return This:C1470
	
Function expect($receivedValue : Variant) : cs:C1710.UTest
	This:C1470.receivedValue:=$receivedValue
	return This:C1470
	
Function toBe($expectedValue : Variant) : cs:C1710.UTest
	var errorMessage : Text
	errorMessage:=""
	If (True:C214)
		$calledmth:=Method called on error:C704
		ON ERR CALL:C155("onErrorMth")
		ASSERT:C1129($expectedValue=This:C1470.receivedValue)
		ON ERR CALL:C155($calledmth)
		This:C1470.UTest_result.push(This:C1470._build_result(errorMessage="" ? True:C214 : False:C215; Get call chain:C1662; This:C1470.description; $expectedValue; This:C1470.receivedValue; errorMessage))
		This:C1470._clearTmp()
		return This:C1470
		
	Else 
		If (Value type:C1509(This:C1470.receivedValue)=Value type:C1509($expectedValue)) && (This:C1470.receivedValue=$expectedValue)
			This:C1470.UTest_result.push(This:C1470._build_result(True:C214; Get call chain:C1662; This:C1470.description))
			This:C1470._clearTmp()
			return This:C1470
		End if 
		$message:=Choose:C955(Value type:C1509(This:C1470.receivedValue)#Value type:C1509($expectedValue); "Value types are different"; "Values are not equals")
		This:C1470.UTest_result.push(This:C1470._build_result(False:C215; Get call chain:C1662; This:C1470.description; $expectedValue; This:C1470.receivedValue; $message))
		This:C1470._clearTmp()
		return This:C1470
	End if 
	
Function show()
	$form:={UTest: This:C1470}
	$ref:=Open form window:C675("UTests")
	DIALOG:C40("UTests"; $form)
	CLOSE WINDOW:C154($ref)
	
Function createMock($formula; $resultToRestur)
	return New object:C1471($formula; Formula:C1597($resultToRestur))
	
Function _clearTmp()
	This:C1470.receivedValue:=Null:C1517
	This:C1470.description:=""
	
Function build_HL($list : Integer)
	$imgPath:=Folder:C1567("/RESOURCES/Images").platformPath
	READ PICTURE FILE:C678($imgPath+"fail.svg"; $failPict)
	READ PICTURE FILE:C678($imgPath+"success.svg"; $successPict)
	
	$classes:=Form:C1466.UTest.UTest_result.distinct("class")
	
	$index:=0
	For each ($class; $classes)
		$tests:=Form:C1466.UTest.UTest_result.query("class == :1"; $class)
		$sublist:=New list:C375
		For each ($test; $tests)
			APPEND TO LIST:C376($sublist; $test.function+" --> "+$test.description; 0)
			SET LIST ITEM PARAMETER:C986($sublist; 0; "UUID"; $test.UUID)
			If ($test.success)
				SET LIST ITEM ICON:C950($sublist; 0; $successPict)
			Else 
				SET LIST ITEM ICON:C950($sublist; 0; $failPict)
			End if 
			$index+=1
		End for each 
		APPEND TO LIST:C376($list; $class; 0; $sublist; True:C214)
	End for each 