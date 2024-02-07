Class constructor
	
Function getRepo($url : Text) : Object
	
	var $request; $response : Object
	var $status : Integer
	
	$calledmth:=Method called on error:C704
	ON ERR CALL:C155("onErrorMth")
	$status:=HTTP Request:C1158(HTTP GET method:K71:1; $url; $request; $response)
	ON ERR CALL:C155($calledmth)
	
	return $status=200 ? $response : {}