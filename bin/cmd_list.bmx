
'SuperStrict

' Shows a list of all modules
Function cmd_list()
Rem
	Const COL_MODID:Int = 0
	Const COL_CHECKSUM:Int = 1
	Const COL_VERSION:Int = 2
	'Const COL_PATH:Int = 2
	'Const COL_SOURCE:Int = 3
	Local table:String[][] = [["ID","CHECKSUM","VERSION"]]
	'data :+ [["ID","PATH","SOURCE","VERSION"]]
	
	Local modules:TList = EnumModules()	
	For Local modid:String = EachIn modules

		' Scan the source file for information
		Local scanner:TScanner = New TScanner()
		scanner.fullScan( modid )
		
		Local row:String[3]
		row[COL_MODID]   = modid
		'row[COL_PATH]   = ModulePath( modid )
		'row[COL_SOURCE] = Modulesource( modid )
		row[COL_CHECKSUM] = "-"
		' get version
		row[COL_VERSION] = scanner["version"]
		table :+ [row]
	Next
	
	ShowTable( table )
EndRem
End Function