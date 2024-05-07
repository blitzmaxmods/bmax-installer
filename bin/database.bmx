


Type TDatabase 

	Global db:JSON
	
	Field changed:Int = False
	'Field updated:Int = False		' USed to flag when an update has occurred (To stop multiple)

	' Load or Create a database
	Method New( filename:String )
	
		Local dbtext:String

		If FileType( filename ) = FILETYPE_FILE
			dbtext = LoadString( filename )
			If Not dbtext 
				Print( "- Database initialised" )
				db = New JSON()
				changed = True
			Else
				db = JSON.parse( dbtext )
				If db.isInvalid()
					Print( "- Invalid database re-initialised" )
					db = New JSON()
					changed = True
				End If
			End If
		Else
			Print( "- Database created" )
			db = New JSON()
			changed = True
		End If
	
		' Add default modserver(s)
		'update_default_modservers()
		
		'add_default_packages()
		'add_default_repositories()
		'add_default_modservers()
		
	End Method
	
	' Save database to disk
	Method save( over_ride:Int = False )
		'DebugStop
		If Not changed And Not over_ride; Return
		'CreateFolders()
		If Not FileType( SYS.DBFILE ) = FILETYPE_DIR; Return
		Local dbtext:String = db.prettify()
		SaveString( dbtext, SYS.DBFILE )
		changed = False
		Print( "- Database saved." )
	End Method
	
	' Confirm if a modserver currently exists
Rem
	Method modserver_exists:Int( repo_key:String )
Print( "## DATABASE / modserver_exists() is depreciated" )
DebugStop
		'DebugStop
		'Local path:String = platform+"|modservers|"+repo
		Local record:JSON = db.search( "modservers|"+repo_key )
		If record And record.isValid(); Return True
		Return False
	End Method

	' Confirm if a repository currently exists
	Method repo_exists:Int( repo_key:String )
Print( "## DATABASE / repo_exists() is depreciated" )
DebugStop
		Local record:JSON = db.search( "repositories|"+repo_key )
		If record And record.isValid(); Return True
		Return False
	End Method

	' Confirm if a package currently exists
	Method package_exists:Int( name:String )
Print( "## DATABASE / package_exists() is depreciated" )
DebugStop
		Local record:JSON = db.search( "packages|"+name )
		If record And record.isValid(); Return True
		Return False
	End Method
EndRem			
	' Update the database with default repositories
Rem
	Method update_default_modservers()
Print( "## DATABASE / updte_default_modservers() is depreciated" )
DebugStop
Return


		'Local updated:Int = False
DebugStop
		' Read default modservers
		Local J:JSON = JSON.parse( DEFAULT_MODSERVERS )
		If Not J; die( "Failed to parse DEFAULT MODSERVERS" )
		If J.isInValid(); die( "Failed to parse DEFAULT MODSERVERS", J.error() )

		' Loop through default modservers
		Local jmodservers:JSON[] = J.toArray()
		For Local jmodserver:JSON = EachIn jmodservers
			' Get details from package
			Local repo_key:String    = jmodserver.find("repository").ToString()
			'Local description:String = jmodserver.find("description").ToString()
			'Local project:String     = jmodserver.find("project").ToString()
			'Local folder:String      = jmodserver.find("folder").ToString()
			Local name:String         = jmodserver.find("name").ToString()
			Local path:String = "modservers|"+repo_key
			' Check if record exists
			Local record:JSON = db.search( path )
			If Not( record And record.isValid() )

				' Add new modserver record
				db.set( path, jmodserver )
				Print( "- Added modserver: "+name )
				changed = True
			End If
			
			' Add new repository record
			path = "repositories|"+repo_key
			record = db.search( path )

			If record And record.isValid(); Continue
			' Add new repository record
			add_repository( repo_key, "", "" )
			changed = True
			
		Next

		' Save database
		'If updated
			'Print "- Updated default modservers"
		'	save( True )
		'End If
	End Method
EndRem	
	' Add default modservers to database
Rem
	Method add_default_modservers()
		Local updated:Int = False
		Local J:JSON = JSON.parse( DEFAULT_MODSERVERS )
		If Not J die( "Failed to parse DEFAULT MODSERVERS" )
		If J.isInValid() die( "Failed to parse DEFAULT MODSERVERS", J.error() )
	'DebugStop
		
		Local jmodservers:JSON[] = J.toArray()
		For Local jmodserver:JSON = EachIn jmodservers
			' Get details from package
			Local name:String = jmodserver.find("name").ToString()
			If Not name; Continue

			' Get details from database
			Local modservers:JSON = db.search( "modservers" )
			'DebugStop
			If Not modservers
				modservers = New JSON( )
				db.set( "modservers", modservers )
			End If
			'Print db.prettify()
			Local record:JSON = modservers.search( name )
			
			' New record?
			If record And record.isValid(); Continue
			'DebugStop
			modservers.set( name, jmodserver )
			updated = True
		Next
		'Print db.prettify()
		'DebugStop
		If updated
			Print "- Updated default modservers to database."
			changed = True
		End If
		
	End Method

	' Add default packages to database
	Method add_default_packages()
		Local updated:Int = False
		Local J:JSON = JSON.parse( DEFAULT_PACKAGES )
		If Not J die( "Failed to parse DEFAULT PACKAGES" )
		If J.isInValid() die( "Failed to parse DEFAULT PACKAGES", J.error() )
	'DebugStop
		
		Local jpackages:JSON[] = J.toArray()
		For Local jpackage:JSON = EachIn jpackages

			' Get details from package
			Local p_name:String = jpackage.find("name").ToString()
			If Not p_name; Continue

			' Get details from database
			Local packages:JSON = db.search( "packages" )
			If Not packages
				packages = New JSON()
				db.set( "packages", packages )
			End If
			'Print db.prettify()
			Local record:JSON = packages.search( p_name )
			
			' New record
			If Not record Or record.isInvalid()
				'Print "? Adding package "+p_name+" to database."
				packages.set( p_name, jpackage )
				Continue
			End If
			
			' Update existing record?	
			Local p_revision:Int = jpackage.find("revision").toInt()
			If record.find( "revision" ).toInt() < p_revision
				Print "? Updating package "+p_name+" record"
				record["revision"]   = p_revision
				record["modserver"]  = jpackage.find("modserver").ToString()
				record["repository"] = jpackage.find("repository").ToString()
				record["zippath"]    = jpackage.find("zippath").ToString()
			End If
			updated = True
			
		Next
		'Print db.prettify()
		If updated
			Print "- Updated default packages to database."
			changed = True
		End If
	End Method

	' Add default repositories to database
	Method add_default_repositories()
		Local updated:Int = False
		Local J:JSON = JSON.parse( DEFAULT_REPOSITORIES )
		If Not J die( "Failed to parse DEFAULT PACKAGES" )
		If J.isInValid() die( "Failed to parse DEFAULT PACKAGES", J.error() )
	'DebugStop
		
		Local JRepositories:JSON[] = J.toArray()
		For Local JRepo:JSON = EachIn JRepositories

			' Get details from package
			Local name:String = JRepo.find("name").ToString()
			If Not name; Continue

			' Get details from database
			Local repositories:JSON = db.search( "repositories" )
			If Not repositories
				repositories = New JSON()
				db.set( "repositories", repositories )
			End If
			'Print db.prettify()
			Local record:JSON = repositories.search( name )
			
			' New record
			If Not record Or record.isInvalid()
				'Print "? Adding package "+p_name+" to database."
				'Print JRepo.prettify()
				repositories.set( name, JRepo )
				Continue
			End If
			
			' Update existing record?	
			Local revision:Int = JRepo.find("revision").toInt()
			If record.find( "revision" ).toInt() < revision
				Print "? Updating repository "+name+" record"
				record["revision"] = revision
				record["platform"] = JRepo.find("platform").ToString()
				record["path"]     = JRepo.find("path").ToString()
				'record["zippath"] = JRepo.find("zippath").toString()
			End If
			updated = True
			
		Next
		'Print db.prettify()
		If updated
			Print "- Updated default repositories to database."
			changed = True
		End If
	End Method
EndRem	

	' Get records
	Method get:JSON( criteria:String )
		Return db.search( criteria )
	End Method
	
	' Get records
	Method get:JSON( section:String, criteria:String )
		Local JSection:JSON = db.search( section )
		If Not JSection; Return Null
		Return JSection.search( criteria )
	End Method
	
	' Set record to a string
	Method set( section:String, value:String )
		db.set( section, value )
		changed = True
		'If autosave; save( True )
	End Method	
	' Set record to JSON
	Method set( section:String, value:JSON )
		db.set( section, value )
		changed = True
		'If autosave; save( True )
	End Method	
Rem		
	' Add modserver to database
	Method add_modserver:Int( name:String, repo_key:String )
Print( "## DATABASE / add_modserver() is depreciated" )
DebugStop

		'project = Lower(project).Replace( "\", "/")

		'Local modservers:JSON = db.search( "modservers" )
		'DebugStop
		'If Not modservers
		'	modservers = New JSON()
		'	db.set( "modservers", modservers )
		'End If
		
		' Check if modserver already exists
		'Print db.prettify()
		Local record:JSON = db.search( "modservers|"+repo_key )

		' Does record exist?
		If record And record.isValid()
			Print( "! WARNING: Modserver '"+repo_key+"' already exists." )
			Return False
		End If
		
		' New modserver record
		Local jRecord:JSON = New JSON()
		jRecord.set( "name", name )
		jRecord.set( "repository", repo_key )
		'jRecord.set( "project", project )
		db.set( "modservers|"+repo_key, jRecord )

		' Add an unofficial repository for this modserver
		add_repository( repo_key, "", repo_key )

		changed = True
		'DebugStop
		Return True
	End Method
EndRem
	' Add package to database
Rem 
	Method add_package:Int( package:TPackage )
Print( "## DATABASE / add_package() is depreciated" )
DebugStop	
		'Local packages:JSON = db.search( "packages" )
		'If Not packages
		'	packages = New JSON()
		'	db.set( "packages", packages )
		'End If
		
		' Check if package already exists
		'Print db.prettify()
		Local record:JSON = db.search( "packages|"+package.name )

		' Does record exist?
		If record And record.isValid()
			' Package already exists
			
			DebugStop
			' OFFICIAL MODSERVER CAN OVERRIDE UNOFFICIAL
			'modsever == package.modserver, offical?
			'Print( "! WARNING: Package '"+package+"' already exists." )
			Return False
		End If
		
		' New record
		Local jRecord:JSON = JSON.Serialise( package )
		'DebugStop
		'Local jRecord:JSON = New JSON()
		'jRecord.set( "description", description )
		'jRecord.set( "platform", platform )
		'jRecord.set( "project", project )
		db.set( "packages|"+package.name, jRecord )

		'DebugStop
		changed = True
		Return True
	End Method
EndRem
	' Add repository to database
Rem
	Method add_repository:Int( repo_key:String, name:String="", modserver:String="" )
Print( "## DATABASE / add_repository() is depreciated" )
DebugStop	
		If name = ""; name = repo_key

		'Local list:JSON = db.search( "repositories" )
		'DebugStop
		'If Not list
		'	list = New JSON()
		'	db.set( "repositories", list )
		'End If
		
		' Check if modserver already exists
		'Print db.prettify()
		Local record:JSON = db.search( "repositories|"+repo_key )

		' Does record exist?
		If record And record.isValid()
			'Print( "! WARNING: Repository '"+repo_key+"' already exists." )
			Return False
		End If
		
		' New record
		Local jRecord:JSON = New JSON()
		'jRecord.set( "name", name )
		'jRecord.set( "platform", platform )
		'jRecord.set( "definition", repo_key )
		jRecord.set( "modserver", repo_key )	' Where we learnt about this repo
		
		db.set( "repositories|"+repo_key, jRecord )

		changed = True
		'DebugStop
		Return True
	End Method
EndRem		
	'
Rem
	Method Update()
Print( "## DATABASE / Update() is depreciated" )
DebugStop	
		'If updated; Return	' Already updated
		
		' Get array of Repositories
		
		Local JRepositories:JSON = db.search( "repositories" )
		If Not JRepositories; Die( "No repositories defined" )
		
		' Loop through each repository, updating it
		
		For Local name:String = EachIn JRepositories.keys()

			DebugStop
			
			' Get Repository
			'Local repository:TRepository = TRepository.get( name )
			'If Not repository; Continue
			
			' Download "packages.json"
			'Local packages:String = repository.downloadString( "packages.json" )

			'DebugStop
			
			'WE ARE HERE
			Print( "DATABASE.UPDATE() - IMPLEMENTATION INCOMPLETE" )

		Next
		
	End Method
EndRem

Rem
	Method filecache_add( filename:String, package:String )
Print( "## DATABASE / filecache_add() is depreciated" )
DebugStop
		Local filecache:JSON = db.find( "filecache" )
		Local file:JSON = New JSON()
		file["name"]    = filename
		file["package"] = package
		file["date"]    = FileTime( SYS.DATAPATH+filename )
		filecache[filename] = file
		changed = True
	End Method
	
	Method filecache_remove( filename:String, package:String )
Print( "## DATABASE / filecache_remove() is depreciated" )
DebugStop
		Local filecache:JSON = db.find( "filecache" )

		DebugStop
		Print "** filecache_remove is not implemented" 
	End Method
	
	Method filecache_get:TList( package:String )
Print( "## DATABASE / filecache_get() is depreciated" )
DebugStop
		Local filecache:JSON = db.find( "filecache" )
		
		' Loop through each cache entry
		'For Local name:String = EachIn JRepositories.keys()
		
		Local files:TList = New TList()
		For Local file:JSON = EachIn filecache.toArray()
			If package="" Or file["package"]=package; files.addlast( file )
		Next
		If files.isEmpty(); Return Null
		Return files
		
	End Method
EndRem
End Type
