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
	
	Local table:String[][] '=[[]]
	'Local width:Int[] = []
	table :+ [[ "NAME", "REPOSITORY" ]]
	For Local key:String = EachIn SYS.DB.get( "modservers" ).keys()
		
		Local J:JSON = SYS.DB.get( "modservers|"+key )
		
		Local name:String    = J.find( "name" ).ToString()
		If name=""; name = "*none*"
		
		Local line:String[]  = [name,key]
		table :+ [line]
		
	Next
	showtable( table, True )
	
End Function

Function show_packages( filter:String="" )
	Local table:String[][] '=[[]]
	'Local width:Int[] = []
	table :+ [[ "PACKAGE", "TYPE", "VER", "REPOSITORY" ]]
	For Local key:String = EachIn SYS.DB.get( "packages" ).keys()
		
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
	Local table:String[][] '=[[]]
	'Local width:Int[] = []
	table :+ [[ "REPOSITORY" ]]
	For Local key:String = EachIn SYS.DB.get( "repositories" ).keys()
		
		Local line:String[]  = [key]
		table :+ [line]
		
	Next
	showtable( table, True )
End Function
