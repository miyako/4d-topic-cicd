Class extends SUT

Class constructor
	
	Super:C1705(cs:C1710.Util)
	
Function fact()
	
	$result:=This:C1470.sut.fact(1)
	This:C1470.UTest\
		.describe("test with 1")\
		.expect($result)\
		.toBe(1)
	
	$result:=This:C1470.sut.fact(2)
	This:C1470.UTest\
		.describe("test with 2")\
		.expect($result)\
		.toBe(2)
	
	$result:=This:C1470.sut.fact(5)
	This:C1470.UTest\
		.describe("test with 5")\
		.expect($result)\
		.toBe(120)
	
Function isRedFlag()
	
	$GitHub:=This:C1470.UTest\
		.createMock("getRepo"; {open_issues_count: 20})
	
	This:C1470.sut.GitHub:=$GitHub
	
	$result:=This:C1470.sut.isRedFlag()
	This:C1470.UTest.describe("test with open_issues_count: 20")\
		.expect($result)\
		.toBe(True:C214)
	
	$GitHub:=This:C1470.UTest\
		.createMock("getRepo"; {open_issues_count: 0})
	
	This:C1470.sut.GitHub:=$GitHub
	
	$result:=This:C1470.sut.isRedFlag()
	This:C1470.UTest.describe("test with open_issues_count: 0")\
		.expect($result)\
		.toBe(False:C215)