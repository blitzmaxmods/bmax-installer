'SuperStrict
'Import "system.bmx"
'Import "utils.bmx"

' Shows details for a specific module
Function cmd_show( target:String, modid:String )
	'Const COL_KEY:Int = 0
	'Const COL_VALUE:Int = 1
	'Local table:String[][]
	DebugStop
	Select target
	Case "apps","applications"  ; show_packages("application")
	Case "modservers"           ; show_modservers()
	Case "modules"  			; show_packages("module")
	Case "packages" 			; show_packages()
	Case "repos","repositories" ; show_repos()
	Default                     ; die( "Unexpected argument:", AppTitle+" !" )
	EndSelect
	
End Function

Rem
	' Scan the source file for information
	Local scanner:TScanner = New TScanner()
	scanner.fullScan( modid )
	
	table :+ [ [ "NAME:",			modid ] ]
	table :+ [ [ "VERSION:", 		scanner["version"] ] ]
	table :+ [ [ "AUTHOR:", 		scanner["author"] ] ]
	table :+ [ [ "COPYRIGHT:", 		scanner["copyright"] ] ]
	table :+ [ [ "LICENSE:", 		scanner["license"] ] ]
	table :+ [ [ "TITLE:", 			scanner["title"] ] ]
	table :+ [ [ "SUBJECT:", 		scanner["subject"] ] ]
	table :+ [ [ "PATH:",			ModulePath( modid ) ] ]
	table :+ [ [ "SOURCE:",			Modulesource( modid ) ] ]
	table :+ [ [ "HOME:", 			scanner["url"] ] ]	' URL for download
	table :+ [ [ "FRAMEWORK:", 		scanner["framework"] ] ]
	table :+ [ [ "MODSERVER:", 		scanner["modserver"] ] ]
	table :+ [ [ "FILESIZE:", 		scanner["filesize"] ] ]
	table :+ [ [ "FILEDATE:", 		scanner["filedate"] ] ]
	table :+ [ [ "CHECKSUM:", 		scanner["full-checksum"] ] ]
	table :+ [ [ "DEPENDENCIES:", 	"" ] ]
	 
	ShowTable( table, False )
	
	For Local modname:String = EachIn scanner.dependencies
		Print " - "+modname
	Next
EndRem	

Function show_modservers()
	'DebugStop
	If AppArgs.Length<>3; die( "Invalid command" )
	Local table:String[][] '=[[]]
	table :+ [[ "NAME", "REPOSITORY" ]]
	
	Local list:JSON = SYS.DB.get( "modservers" )
	If Not list Or list.isinvalid()
		Print( "No modservers are defined" )
		Return
	End If
	
	For Local key:String = EachIn list.keys()
		
		Local J:JSON = SYS.DB.get( "modservers|"+key )
		
		Local name:String    = J.find( "name" ).ToString()
		If name=""; name = "*none*"
		
		Local line:String[]  = [name,key]
		table :+ [line]
		
	Next
	showtable( table, True )
	
End Function

Function show_packages( filter:String="" )
	If AppArgs.Length<>3; die( "Invalid command" )
	Local table:String[][] '=[[]]
	table :+ [[ "PACKAGE", "TYPE", "VER", "REPOSITORY" ]]
	
	Local list:JSON = SYS.DB.get( "packages" )
	If Not list Or list.isinvalid()
		Print( "No packages are defined" )
		Return
	End If
	
	For Local key:String = EachIn list.keys()
		
		Local J:JSON = SYS.DB.get( "packages|"+key )
		
		Local ptype:String      = J.find( "type" ).ToString()

		If filter And filter <> ptype; Continue
		
		Local name:String       = J.find( "name" ).ToString()
		Local version:String    = J.find( "revision" ).ToString()
		Local repository:String = J.find( "repository" ).ToString()
		
		Local line:String[]  = [name,ptype,version,repository]
		table :+ [line]
		
	Next
	showtable( table, True )
End Function

Function show_repos()
	If AppArgs.Length<>3; die( "Invalid command" )
	Local table:String[][] '=[[]]
	table :+ [[ "REPOSITORY" ]]
	
	Local list:JSON = SYS.DB.get( "repositories" )
	If Not list Or list.isinvalid()
		Print( "No repositories are defined" )
		Return
	End If
	
	For Local key:String = EachIn list.keys()
		
		Local line:String[]  = [key]
		table :+ [line]
		
	Next
	showtable( table, True )
End Function

' Show a single variable
Function cmd_show_variable( args:String[] )
	Print( "ARGS: "+args.Length )
	'Local table:String[][] '=[[]]
	'
	If args.Length <> 1; die( "Invalid request" )
	'
	Local key:String = Lower( args[0] )
	Local value:String = SYS.Config[ key ]
	If Not key; die( "Unknown variable: "+key )
	'
	Local line:String[] = [ key, "= "+value ]
	'table :+ [line]
	showtable( [line], False, 1 )
End Function

' Show all variables
Function cmd_show_variables( args:String[] )
	Print( "ARGS: "+args.Length )
	Local table:String[][] '=[[]]
	'
	If args.Length > 0; die( "Invalid request" )
	
	' All variables
	For Local key:String = EachIn SYS.Config.settings.keys()
		Local value:String = SYS.Config[ key ]
		'
		Local line:String[] = [ key, "= "+value ]
		table :+ [line]

	Next
	'Print table.Length
	If table.Length = 0
		Print( "No variables are defined" )
		Return
	End If
	'
	showtable( table, False, 1 )
End Function
