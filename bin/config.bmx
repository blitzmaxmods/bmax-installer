'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

SuperStrict
Import bmx.json

Type TConfig
	
	'Global instance:TConfig
	'Global Update:Int = False	' Will self-update occur?
	
	Field filename:String
	
	' Get the BlitzMax release platform
'?Win32x86
'	Global BLITZMAX_RELEASE:String = "win32_x86"
'?Win32x64
'	Global BLITZMAX_RELEASE:String = "win32_x64"
'?linux
'	Global BLITZMAX_RELEASE:String = "linux_x64"
'?MacOSX64
'	Global BLITZMAX_RELEASE:String = "macos_x64"
'?raspberrypiARM
'	Global BLITZMAX_RELEASE:String = "rpi_arm"
'?
'	Global BMX_ROOT:String		' <BLITZMAX_ROOT>
'	Global BMX_BIN:String		' <BLITZMAX_ROOT>/bin
'	Global BMX_CFG:String		' <BLITZMAX_ROOT>/cfg
'	Global BMX_MOD:String		' <BLITZMAX_ROOT>/mod
'	Global BMX_SRC:String		' <BLITZMAX_ROOT>/src
'	Global BMX_BCC:String		' Location and filename for BCC
'	Global BMX_BMK:String		' Location and filename for BMK
'	Global DATAPATH:String		' Locations where installer keeps data
'	Global CERTPATH:String
'	Global CERTIFICATE:String  = "cacert.pem"
'	Global CONFIGFILE:String   = "setup.cfg"
'	Global DATABASE:String     = "setup.db"
	'Global SHAREDDATA:String
	'Global USERDATA:String
	'Global USERDESKTOP:String
	'Global USERDOCS:String
'	Global USERHOME:String		' Location of users home directory

	Field settings:JSON			' Configuration
	
	' Command line arguments
	'Field command:String
	
	Method New( filename:String )
		'DebugStop
		Self.filename = filename
		'instance = Self
		
		' Get User folders
		'USERDATA    = GetUserDesktopDir()
'		'USERDESKTOP = GetUserDesktopDir()
'		'USERDOCS    = GetUserDocumentsDir()
'		USERHOME    = GetUserHomeDir()
'		If DIRSLASH="\"
'			USERHOME = USERHOME.Replace("/",DIRSLASH)
'		Else
'			USERHOME = USERHOME.Replace("\",DIRSLASH)
'		EndIf
		'SHAREDDATA  = GetCustomDir( DT_SHAREDUSERDATA )
'		If Not USERHOME.endswith(DIRSLASH); USERHOME :+ DIRSLASH

		' Set the Blitzmax root to existing or default
'		Try
'			' Attempt to set root to existing BlitzMax path
'			BMX_ROOT = BlitzMaxPath()
'		Catch Exception:String
'			Print Exception
'			SetRoot()		' Sets root to default
'		EndTry
'		If Not BMX_ROOT.endswith(DIRSLASH); BMX_ROOT :+ DIRSLASH
		
'		ResetFolderNames()
		load()				' Load config (If it exists)
		
	End Method

	' Reset folder variables
Rem
	Function ResetFolderNames()
		Print "BMX_ROOT: "+ BMX_ROOT
		BMX_BIN   = BMX_ROOT+"bin"+DIRSLASH
		BMX_CFG   = BMX_ROOT+"cfg"+DIRSLASH
		BMX_MOD   = BMX_ROOT+"mod"+DIRSLASH
		BMX_SRC   = BMX_ROOT+"src"+DIRSLASH
		
		DATAPATH  = BMX_ROOT+"setup"+DIRSLASH
		CERTPATH  = BMX_ROOT+"setup"+DIRSLASH
?Win32
		BMX_BCC   = BMX_BIN+"bcc.exe"
		BMX_BMK   = BMX_BIN+"bmk.exe"
?Win64
		BMX_BCC   = BMX_BIN+"bcc.exe"
		BMX_BMK   = BMX_BIN+"bmk.exe"
?linux
		BMX_BCC   = BMX_BIN+"bcc"
		BMX_BMK   = BMX_BIN+"bmk"
?macos
		BMX_BCC   = BMX_BIN+"bcc"
		BMX_BMK   = BMX_BIN+"bmk"
?
		
	End Function


	' Change the installation folder
	Function SetRoot( root:String = "" )
		If root = ""	' Set to default
			BMX_ROOT = USERHOME+"BlitzMax"
		Else			' Specific path
			BMX_ROOT = USERHOME+root
		End If
		If Not BMX_ROOT.endswith("/"); BMX_ROOT :+"/"
		ResetFolderNames()
	End Function
	
	' Check all folders exist
	Function CreateFolders()
		For Local folder:String = EachIn [ BMX_ROOT, BMX_BIN, BMX_CFG, BMX_MOD, BMX_SRC, CERTPATH, DATAPATH ]
			MakeDirectory( folder )
		Next
		'DebugStop
		' We will also copy our certificate
		Local src:String = AppDir+DIRSLASH+"certificate"+DIRSLASH+CERTIFICATE
		Local dst:String = CERTPATH+CERTIFICATE
		If Not CopyFile( src, dst ); Throw( "Failed to copy certificate" )
	End Function
EndRem

	Method Operator[]:String( key:String )
		'DebugStop
		Return settings[ key ]
	End Method
	
	Method Operator[]=( key:String, value:String )
		DebugStop
		settings[key] = value
	End Method

	Method get:String( key:String, otherwise:String="")
		Local result:String = settings[key]
		If result = ""; Return otherwise
		Return result
	End Method

	Method load()
	
		Local tmp:String
		
		'DebugStop
		Local config:String
		
		If FileType( filename ) = FILETYPE_FILE
			config = LoadString( filename )
		Else
'			'DebugStop
'			'Local test:String = "incbin::default-database.json"
'			'DebugStop
			config = ""
			settings = New JSON()
			Return
		End If
		
		settings = JSON.parse( config )
		If settings.isInvalid()
			Print( "Failed to load settings: "+settings.error() )
			settings = New JSON()
		End If

		' Defaults
		'tmp = settings[ "blitzmax.path" ]
		'If tmp <> ""; SYS.BLITZMAX_PATH = tmp
		'tmp = settings[ "certificate.name" ]
		'If tmp <> ""; SYS.CERTIFICATE = tmp
		
	End Method
	
	Method save()
		DebugStop
		If FileType( filename ) = FILETYPE_DIR; Return
		Local config:String = settings.prettify()
		SaveString( config, filename )
	End Method
	
	
End Type
