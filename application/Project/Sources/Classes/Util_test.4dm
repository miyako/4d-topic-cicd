Class extends SUT

Class constructor
	
	Super:C1705(cs:C1710.Util)
	
Function fact()
	
	$result:=This:C1470.sut.fact(1)
	This:C1470.UTest\
		.describe("test with parameter 1")\
		.expect($result)\
		.toBe(1)
	
	$result:=This:C1470.sut.fact(2)
	This:C1470.UTest\
		.describe("test with parameter 2")\
		.expect($result)\
		.toBe(2)
	
	$result:=This:C1470.sut.fact(5)
	This:C1470.UTest\
		.describe("test with parameter 5")\
		.expect($result)\
		.toBe(120)