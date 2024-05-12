'   BLITZMAX INSTALLER
'   (c) Copyright Si Dunford, May 2023, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   14 MAY 2023  Initial Creation
'

'SuperStrict

'Import "datetime.bmx"		'TODO: Move to Blitzmax own version

Const ONE_DAY:Int = 60*60*24

Function Die( title:String, subtitle:String="" )

	'Print "## BMAX ERROR"
	'Print "##"
	Print "## "+title
	If subtitle Print "##   "+subtitle
	exit_( 1 )
	
EndFunction

' Fail is like Die, but is not perminent!
Function Fail:Int( title:String, subtitle:String="" )

	'Print "## BMAX ERROR"
	'Print "##"
	Print "## "+title
	If subtitle Print "##   "+subtitle
	Return False
EndFunction

' Shows a block of strings
' You must set restoredata before calling
Function showdata( terminator:String="\\" )
	Local line:String
	ReadData( line )
	While line<>terminator
		Print line
		ReadData( line )
	Wend
	exit_(1)
End Function

' Show data in a table
Function ShowTable( data:String[][], header:Int = True, gap:Int=2 )

	' Create column width array
	Local width:Int[] = New Int[ data[0].Length ]
	
	' Loop through rows finding column widths
	For Local row:String[] = EachIn data
		For Local col:Int = 0 Until row.Length
			width[col] = Max( width[col], row[col].Length )
		Next
	Next
	
	' Loop through rows showing data
	For Local row:Int = 0 Until data.Length
		Local line:String
		For Local col:Int = 0 Until data[row].Length
			line:+(data[row][col])[..width[col]]+" "[..gap]
		Next
		Print line
		If header And row = 0; Print " "[..line.Length].Replace(" ","-")
	Next
	
End Function

' Creates a folder if it doesn't exist
Function MakeDirectory:Int( folder:String, verbose:Int=False )
	'DebugStop

	Select FileType(folder)
	Case FILETYPE_DIR	' Already exists
		Return True
	Case 0				' Does not exist
		If CreateDir( folder, True )
			If verbose; Print( "Created folder "+folder )
			Return True
		Else
			Print( "Unable to create '"+folder+"', please check your permissions" )
		End If
	Default				' A File of error condition
		Print( "Unable to create '"+folder+"'." )
	End Select
	Return False
End Function

Function GetEnv:String( variable:String )
	Return getenv_( variable )
End Function

' Checks a cache file is valid (Within duration)
Function validCache:Int( cachefile:String, duration:Int )
	'DebugStop
	Local path:String = ExtractDir( cachefile )
	If FileType( path ) <> FILETYPE_DIR; CreateDir( path, True )
	'Print FileTime( cachefile )
	'Print DateTime.time()
	'Print duration
	
	'If FileType( cachefile ) = FILETYPE_FILE And FileTime( cachefile ) > DateTime.time() - duration; Return True
	If FileType( cachefile ) = FILETYPE_FILE And FileTime( cachefile ) > TimestampNow() - duration; Return True
	Return False
End Function

Rem Incorporated into TRepository
Struct SArgData
	Field platformname:String
	Field project:String
	Field folder:String
	
	Method New( name:String, project:String, folder:String )
		Self.platformname = name
		Self.project = project
		Self.folder = folder
	End Method
	
	Method path:String()
		Local result:String = project
		If folder; result :+ "/"+folder
		Return result
	End Method
	
End Struct
End Rem

' Takes an argument string and extracts platform, project and optional folder
'Function GetArgData:SArgData( args:String )
'	'Local data:SArgData = 
'	Return New SArgData( args )
'End Function


' Defdata is required in a file that contains ReadData even if not used.
DefData 0