$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		If (OB Instance of:C1731(Form:C1466; cs:C1710._BuildAppUI))
			
			LISTBOX SELECT ROW:C912(*; "lb.pages"; 1; lk replace selection:K53:1)
			GOTO OBJECT:C206(*; "BuildApp.BuildApplicationName")
			
			//platform specific
			
			OBJECT SET VISIBLE:C603(*; "BuildApp.BuildMacDestFolder"; Is macOS:C1572)
			OBJECT SET VISIBLE:C603(*; "BuildApp.BuildWinDestFolder"; Is Windows:C1573)
			
			OBJECT SET ENABLED:C1123(*; "BuildApp.SourcesFiles.RuntimeVL.IsOEM"; False:C215)
			OBJECT SET ENABLED:C1123(*; "BuildApp.SourcesFiles.CS.IsOEM"; False:C215)
			
			Form:C1466.BuildApp.SignApplication.AdHocSign:=Not:C34(Bool:C1537(Form:C1466.BuildApp.SignApplication.MacSignature))
			
			//mutually exclusive
			
			OBJECT SET ENABLED:C1123(*; "BuildApp.UseStandardZipFormat"; Bool:C1537(Form:C1466.BuildApp.PackProject))
			OBJECT SET ENABLED:C1123(*; "BuildApp.SignApplication.MacSignature"; Not:C34(Bool:C1537(Form:C1466.BuildApp.SignApplication.AdHocSign)))
			OBJECT SET ENABLED:C1123(*; "BuildApp.SignApplication.AdHocSign"; Not:C34(Bool:C1537(Form:C1466.BuildApp.SignApplication.MacSignature)))
			OBJECT SET ENTERABLE:C238(*; "BuildApp.SignApplication.MacCertificate"; Bool:C1537(Form:C1466.BuildApp.SignApplication.MacSignature))
			
			//numeric
			
			OBJECT SET FILTER:C235(*; "BuildApp.CS.PortNumber"; "&\"0-9\"")
			OBJECT SET FILTER:C235(*; "BuildApp.CS.CurrentVers"; "&\"0-9\"")
			OBJECT SET FILTER:C235(*; "BuildApp.CS.RangeVersMin"; "&\"0-9\"")
			OBJECT SET FILTER:C235(*; "BuildApp.CS.RangeVersMax"; "&\"0-9\"")
			
			OBJECT SET HELP TIP:C1181(*; "Show JSON…"; Is macOS:C1572 ? "⌘⌥J" : "⌃⎇J")
			OBJECT SET HELP TIP:C1181(*; "Show XML…"; Is macOS:C1572 ? "⌘⌥X" : "⌃⎇X")
			OBJECT SET HELP TIP:C1181(*; "Build CLI…"; Is macOS:C1572 ? "⌘⌥T" : "⌃⎇T")
			OBJECT SET HELP TIP:C1181(*; "Save as…"; Is macOS:C1572 ? "⌘⌥S" : "⌃⎇S")
			
			OBJECT SET ENABLED:C1123(*; "Build CLI…"; False:C215)
			
			Form:C1466.CLI:=cs:C1710._Terminal.new()
			
		Else 
			OBJECT SET VISIBLE:C603(*; "@"; False:C215)
		End if 
		
	: ($event.code=On Page Change:K2:54)
		
		LISTBOX SELECT ROW:C912(*; "lb.pages"; FORM Get current page:C276; lk replace selection:K53:1)
		
End case 