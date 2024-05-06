'SuperStrict

'Import bmx.json
'Import "system.bmx"
'Import "TPlatform.bmx"
'Import "TPackage.bmx"
'Import "TRepository.bmx"

'Include "TModserver.bmx"
'Import "config.bmx"

'Import "TRelease.bmx"

Function cmd_update()
	Local J:JSON
	
	Print( "Updating modservers." )
	J = SYS.DB.get( "modservers" )
	If Not J Or J.isInvalid(); J = New JSON()

	For Local key:String = EachIn J.keys()
		DebugStop
		Local J:JSON = SYS.DB.get( "modservers|"+key )
		Local modserver:TModserver = New TModserver( J )
	
'TODO: This should only run when expired - 
Print( "UPDATING MODSERVER IN DEBUG MODE - PLEASE FIX BEFORE RELEASE" )
		' Perform an update for this modserver
' COMMENTED THIS FOR DEBUG MODE ONLY - UNCOMMENT ON RELEASE
		'If modserver.expired()
			Print( "- Updating "+modserver.name )
			modserver.Update()
		'Else
		'	Print( "- "+modserver.name+ " is up to date" )
		'End If
	Next

	Print( "Updating Packages" )
	J = SYS.DB.get( "packages" )
	If Not J Or J.isInvalid(); J = New JSON()
	
	For Local key:String = EachIn J.keys()
		DebugStop
		Local J:JSON = SYS.DB.get( "packages|"+key )
		Local package:TPackage = TPackage.Transpose( J )
	
		' Perform an update for this package
		Print( "- Updating "+package.name )
		package.Update()
	Next

	Print( "Updating Packages" )
	J = SYS.DB.get( "packages" )
	If Not J Or J.isInvalid(); J = New JSON()
	
	
End Function

Function update_modserver( J:JSON )

End Function
