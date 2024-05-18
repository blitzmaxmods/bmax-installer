
Function cmd_set_variable( args:String[] )

	If args.Length = 0; die( "Invalid argument" )

	' Two options are available:
	'	set variable=value
	'	set variable value
	
	Local key:String
	Local value:String
	DebugStop
	' Check if we are dealing with VARIABLE=VALUE
	If Instr( args[0], "=" )
		' VARIABLE=VALUE
		Local data:String[] = args[0].split( "=" )
		If data.Length<2; die( "Invalid argument" )
		'
		key   = Lower(Trim( data[0] ))
		value = Trim( data[1] )
		' Check if there are more arguments
		' If there are, this may be due to spaces in the value
		If args.Length > 1; value :+ " " + (" ".join( args[1..] ))
	Else
		If args.Length < 2; die( "Invalid argument" )
		key = Lower(args[0])
		value :+ " ".join( args[1..] )
	End If
	value = Trim( value )
	
	SYS.Config.settings[key] = Trim(value)
	Print "Variable "+key+" = " + value
	DebugStop
End Function

Function cmd_clear_variable( args:String[] )
	DebugStop
	If args.Length = 0; die( "Invalid argument" )
	Local key:String = Trim(Lower(args[0]))
	SYS.Config.unset(key)
End Function

