//%attributes = {"invisible":true}
var errorMessage : Text

GET LAST ERROR STACK:C1015($_codesArray; $_intCompArray; $_textArray)

$colText:=New collection:C1472()
ARRAY TO COLLECTION:C1563($colText; $_textArray)
errorMessage:=$colText.join(". ")