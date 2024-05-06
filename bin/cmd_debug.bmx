
' Shows a list of all modules
Function cmd_debug( output:String )

	Local table:String[][] = [[ ..
		"ID", "FULL-CHECKSUM", "PART-CHECKSUM", "VERSION", ..
		"AUTHOR",	"COPYRIGHT", "CREDIT", "LICENSE",	  "TITLE",    "SUBJECT", ..
		"URL", 	"FRAMEWORK", "MODSERVER", "FILESIZE", "FILEDATE", ..
		"DEPENDENCIES" ..
		]]
	
	DebugStop
	Local modules:TList = EnumModules()	
	For Local modid:String = EachIn modules

		' Scan the source file for information
		Local scanner:TScanner = New TScanner()
		scanner.fullScan( modid )
		
		Local row:String[16]
		row[ 0]  = modid
		row[ 1]  = scanner["full-checksum"]
		row[ 2]  = scanner["part-checksum"]
		row[ 3]  = scanner["version"]
		row[ 4]  = scanner["author"]
		row[ 5]  = scanner["copyright"]
		row[ 6]  = scanner["credit"]
		row[ 7]  = scanner["license"]
		row[ 8]  = scanner["title"]
		row[ 9]  = scanner["subject"]
		row[10]  = scanner["url"]
		row[11]  = scanner["framework"]
		row[12]  = scanner["modserver"]
		row[13]  = scanner["filesize"]
		row[14]  = scanner["filedate"]

		Local dependencies:String[]
		For Local dependency:String = EachIn scanner.dependencies
			dependencies :+ [dependency]
		Next
		row[15]  = ";".join(dependencies)

		table :+ [row]
	Next
	
	' Display available ModuleInfo fields
	Print( "~nAVAILABLE MODULEINFO FIELDS:" )
	For Local info:String = EachIn ModInfo.keys()
		Print "ModuleInfo: "+info
	Next
	
	' WRITE TO CSV FILE
	Local file:TStream = WriteFile( output )
	If Not file RuntimeError "could not open debug file '"+output+"'"

	' Loop through rows showing data
	For Local row:Int = 0 Until table.Length
		' Add quotes to all fields
		For Local col:Int = 0 Until table[row].Length
			table[row][col] = Chr(34)+(table[row][col]).Trim()+Chr(34)
		Next
		Local line:String = ",".join( table[row] )
		WriteLine( file, line )
	Next
	CloseStream file
	Print "~nData written to '"+output+"'"

End Function