'SuperStrict

'Import bmx.json
'Import "system.bmx"
'Import "TPlatform.bmx"
'Import "TPackage.bmx"
'Import "TRepository.bmx"

'Include "TModserver.bmx"
'Import "config.bmx"

'Import "TRelease.bmx"

Function cmd_update( key:String, force:Int )
	
		
	'DebugStop
	Local modserver:TModserver
	If key
		' Update a specific modserver
		modserver = TModserver.forkey( Lower(key) )
		If Not modserver; die( key + " is invalid" )
		Print( "Updating modserver "+modserver.GetName() )
		update_modserver( modserver, force )
		' Update packages on given modserver
		update_packages( Lower(key) )
	Else
		'Print( "Updating modservers" )
		' Update all modservers
		For Local key:String = EachIn TModserver.keys()
			modserver = TModserver.forkey( key )
			If Not modserver
				fail( key + " is invalid" )
				Continue
			End If
			Print( "Updating modserver "+modserver.GetName() )
			update_modserver( modserver, force )
		Next
		' Update packages on all modservers
		update_packages()
	End If

End Function

' Updates modserver
Function update_modserver:Int( modserver:TModserver, force:Int )
	' Show the modserver name
	'If modserver.name
	Print( modserver.GetName() )
	'Else
	'	Print( "("+modserver.key+")" )
	'End If
	
	' Update the modserver
	If force Or modserver.expired(); modserver.Update()
End Function

Rem
	Return

' OLD FROM HERE

	Local J:JSON
	
	Print( "Updating modservers." )
	J = SYS.DB.get( "modservers" )
	If Not J Or J.isInvalid(); J = New JSON()

	For Local key:String = EachIn J.keys()
		DebugStop
		Local J:JSON = SYS.DB.get( "modservers|"+key )
		If Not J Or J.isInvalid()
			fail( "Modserver '"+key+"' is corrupt" )
			Continue
		End If
		Local modserver:TModserver = TModserver.Transpose( J )
		'Local modserver:TModserver = New TModserver( J )
	
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
	
	
EndRem

Function update_packages( modserver_key:String = "" )
	' Update packages on specific modserver
	For Local key:String = EachIn TPackage.keys()
		Local package:TPackage = TPackage.forkey( key )
		' Do not update if modserver mismatch
		If modserver_key And package.modserver_key <> modserver_key; Continue
		Print( "-"+package.name )
		package.Update()
	Next
End Function

