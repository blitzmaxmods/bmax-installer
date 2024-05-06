'SuperStrict

'Import "utils.bmx"
'Import "TPlatform.bmx"
'Import "TPackage.bmx"
'Import "TRepository.bmx"
'Import "config.bmx"

'Import "TRelease.bmx"

Function cmd_repository( action:String, args:String[] )
	Print "REPOSITORY SUPPORT"
	DebugStop
	Select action.toLower()
	Case "add"     ; cmd_repository_add( args )
	Case "list"    ; cmd_repository_list( args)
	Case "remove"  ; cmd_repository_remove( args )
	Case "show"    ; cmd_repository_show( args )
	Default        ; die( "Unexpected argument '"+action+"'" )
	End Select
End Function

' Add a modserver to local configuration
Function cmd_repository_add( args:String[] )
	DebugStop
	Print "args.length="+args.Length
	If args.Length < 1 die( "No repository specified" )
	'
	DebugStop
	Local repo:TRepository = TRepository.fromDefinition( args[0] )
End Function

Function cmd_repository_list( args:String[] )
	DebugStop
	Print "args.length="+args.Length
End Function

Function cmd_repository_remove( args:String[] )
	DebugStop
	Print "args.length="+args.Length
End Function

Function cmd_repository_show( args:String[] )
	DebugStop
	Print "args.length="+args.Length
End Function


