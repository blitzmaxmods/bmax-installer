SuperStrict

' SYS is a singleton that acts like a namespace holding system
' specific information in one place

Import bmx.json

Import "../default-data.bmx"

Import "config.bmx"
Import "utils.bmx"

Import "TResponse.bmx"

Include "database.bmx"
Include "TModserver.bmx"
Include "TRepository.bmx"
Include "TPackage.bmx"

Type SYS

	Global config:TConfig
	Global DB:TDatabase
	
?Win32x86
	Global DIRSLASH:String = "\"
?Win32x64
	Global DIRSLASH:String = "\"
?linux
	Global DIRSLASH:String = "/"
?MacOSX64
	Global DIRSLASH:String = "/"
?raspberrypiARM
	Global DIRSLASH:String = "/"
?
	' Folder Paths
	Global HOMEPATH:String
	Global BLITZMAX_RELEASE:String		' Blitzmax release string
	Global BLITZMAX_PATH:String
	Global CERTPATH:String
	Global DATAPATH:String
	Global CACHEPATH:String
	
	' File Paths
	Global DBFILE:String
	Global CERTFILE:String
	Global CONFIGFILE:String
	' File Names
	Global CERTIFICATE:String = "cacert.pem"
	Global USERAGENT:String = "BlitzMax Installer"
	
	Function initialise()
	
		' USER HOME DIRECTORY

		HOMEPATH = fix( GetUserHomeDir() )
		'If Not HOMEPATH.endswith( "/" ); HOMEPATH :+ "/"

		'USERDESKTOP = fixpath( GetUserDesktopDir() )
		'USERDOCS    = fixpath( GetUserDocumentsDir() )

		' DATA PATH
		' The data path is used for downloads

		DATAPATH = fix( GetUserAppDir() )
		'If Not DATAPATH.endswith( "/" ); DATAPATH :+ "/"
		DATAPATH :+ ".blitzmax/"

		' BLITZMAX PATH
		' (Can be overridden by configuration)
		'BLITZMAX_PATH = HOMEPATH + "BlitzMax/"
		
		' BLITZMAX RELEASE STRINGS
?Win32x86
		BLITZMAX_RELEASE = "win32_x86"
?Win32x64
		BLITZMAX_RELEASE = "win32_x64"
?linux
		BLITZMAX_RELEASE = "linux_x64"
?MacOSX64
		BLITZMAX_RELEASE = "macos_x64"
?raspberrypiARM
		BLITZMAX_RELEASE = "rpi_arm"
?

'?Win32
'		BMX_BCC   = "bin" + DIRSLASH + "bcc.exe"
'		BMX_BMK   = "bin" + DIRSLASH + "bmk.exe"
'?Win64
'		BMX_BCC   = "bin" + DIRSLASH + "bcc.exe"
'		BMX_BMK   = "bin" + DIRSLASH + "bmk.exe"
'?linux
'		BMX_BCC   = "bin" + DIRSLASH + "bcc"
'		BMX_BMK   = "bin" + DIRSLASH + "bmk"
'?macos
'		BMX_BCC   = "bin" + DIRSLASH + "bcc"
'		BMX_BMK   = "bin" + DIRSLASH + "bmk"
'?

		' UPDATE PATHS
		CERTPATH  = DATAPATH + "setup/"
		CACHEPATH  = DATAPATH + "cache/"

		' UPDATE FILEPATHS
		CERTFILE   = CERTPATH + CERTIFICATE
		CONFIGFILE = DATAPATH + "config/bmax.cfg"	
		DBFILE     = DATAPATH + "setup/setup.db"
		
		' CREATE FOLDERS
		MakeDirectory( DATAPATH, True )
		BuildFolders( DATAPATH, [ "setup","config","cache" ], True )	', "official", "releases" ]
		
		' COPY CERTIFICATE IF IT DOESN'T EXIST
		If Not FileType( CERTFILE )
			Local src:String = AppDir+"/certificate/"+CERTIFICATE
			Local dst:String = CERTFILE
			If Not CopyFile( src, dst ); Throw( "Failed to copy certificate" )
		End If
		
		' INITIALISE DATABASE
		DB = New TDatabase( DBFILE )
		
		' LOAD CONFIG
		config = New TConfig( CONFIGFILE )
		'config.load()
		
		' UPDATE SYSTEM
		BLITZMAX_PATH = config.get( "blitzmax.path", HOMEPATH + "BlitzMax/" )
		
		' Set exit procedure to save database files
		OnEnd( ExitProcedure )	
		
	End Function

	Function fix:String( original:String )
		Local path:String = original.Replace( "\", "/" )
		If path.endswith( "/" ); Return path
		Return path + "/"
	End Function

	Function buildfolders( parent:String, folders:String[], verbose:Int = False )
		For Local folder:String = EachIn folders
			makedirectory( parent + folder, verbose )
		Next
	End Function 

	' Exit procedure to save database
	Function ExitProcedure()
		' Save data
		TModserver.Save()
		TPackage.Save()
		TRepository.Save()
		'
		Print "- System Exit Procedure / Saving database"
		DB.save()
	End Function
	
End Type


