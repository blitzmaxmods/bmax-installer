' Modserver and Modserver Manager

' Modserver Management functions:

'	Add()			- Add modserver after Validation
'	Exists()		- Checks If a modserver exists
'	ForKey()		- Gets a modserver for a given key
'	Keys()			- Gets a list of keys (modservers) in the database
'	Load()			- Loads the database
'	Save()			- Saves the database
'	Transpose()		- Transforms JSON to Modserver

' Modserver support methods

'	New()			- Creates a new modserver
'	expired()		- Checks if local modserver cache is valid
'	fetch()			- Downloads modserver.json (or fetches from cache)
'	setcache()		- Sets the modserver cache path
'	serialise()		- Convert Modserver into JSON
'	update()		- Performs an update

Type TModserver

	Global list:TMap

	Field key:String				{noserialise}	' Database index
	Field repo_key:String			{serializedname="repository"}
	Field repository:TRepository	{notranspose noserialise}
	Field name:String				' Name of this modserver
	Field cachefile:String			' File where cached "modserver.json" is saved
	'
	Field JModserver:JSON			{noserialise}	' Latest modserver definition

	' Add a modserver
	Function Add:Int( modserver:TModserver )
		If Not list; Load()
		' Check if modserver exists
		If list.contains( modserver.repo_key ); Return False
		' Add to database
		list.insert( modserver.repo_key, modserver )
		Return True
	End Function
	
Rem
	Function ZZZ_Validate:Int()
		' Attempt to download modserver.json to validate new modserver
		'Local modserver:TModserver = New TModserver( key )
		
		Local J:JSON = modserver.fetch()
		If J And J.isValid()
Print( "TODO: TModserver.add() should parse modserver.json directly." )
			' Add modserver.json definition into modserver
			modserver.JModserver = J
DebugStop
			TRepository.add( modserver.repository )
			list.insert( modserver.repo_key, modserver )
			Return True
		Else
			Print( "Bad or missing modserver.json in repository" )
			Return False
		End If

	End Function
End Rem
	
	' Create a modserver with a new or existing repository
	Function Create:TModserver( key:String )
		'Local repository:TRepository
		
		' Ensure there is a repository for this modserver
		'If Not TRepository.exists( key )
		'	repository = TRepository.Create( key )
		'Else
		'	repository = TRepository.get( key )
		'End If
		'DebugStop 
		
		Local modserver:TModserver = New TModserver( key )
		Return modserver
			
	End Function
	
	' Check if modserver exists
	Function Exists:Int( key:String )
		If Not list; Load()
		Return list.contains( key )
	End Function

	' Get a modserver
	Function ForKey:TModserver( key:String )
		If Not list; Load()
		Return TModserver( list.valueforkey( key ) )
	End Function

	' Get list of keys (modservers)
	Function Keys:TMapEnumerator()
		If Not list; Load()
		Return list.keys()
	End Function

	' Load database
	Function Load()
		Local modserver:TModserver
		
		DebugStop
		' Pre-load repositories because modservers reference them
'		TRepository.Load()
		
		' Load modservers from database
		If Not list; list = New TMap()
		Local modservers:JSON = SYS.DB.get( "modservers" )
		If modservers
			For Local key:String = EachIn modservers.keys()
				
				' Check that the repository for this modserver exists
'				If Not TRepository.exists( key )
'					Local repository:TRepository = TRepository.Create( key )
'					TRepository.add( repository )
'				End If
				
				'Local repository:TRepository.get( key )
				'TRepository.add()
				
				Local J:JSON = modservers.search( key )
				If Not J Or J.isInvalid(); Continue
				
				modserver = TModserver.Transpose( J )
				' At this point, you have a modserver, but if the 
				' repositories are not loaded they will be incomplete.
				list.insert( key, modserver )
				'DebugStop
			Next
		End If
		
		'	LOAD DEFAULT MODSERVERS
		
		Local J:JSON = JSON.parse( DEFAULT_MODSERVERS )
		If Not J; die( "Failed to parse DEFAULT MODSERVERS" )
		If J.isInValid(); die( "Failed to parse DEFAULT MODSERVERS", J.error() )

		' Loop through default modservers
		Local JModservers:JSON[] = J.toArray()
		For Local JModserver:JSON = EachIn JModservers
			
			' Confirm Repository exists
			'Print( Jmodserver.prettify() )
			
			modserver = TModserver.Transpose( JModserver )
			
			'DebugStop
			' Get details from package
			'Local repo_key:String  = JModserver.find("repository").ToString()
			
			' Add a repository if one does not already exist
			'If Not TRepository.exists( modserver.repo_key )
				'DebugStop
				'Local repository:TRepository = TRepository.get( repo_key )
			'	TRepository.add( modserver.repository )
			'End If

			' Confirm Modserver exists
			
			If Not TModserver.exists( modserver.repo_key )
				Print( "- Adding modserver: "+modserver.name )
				TModserver.add( modserver )
			End If
Rem
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
End Rem			
		Next
		
	End Function

	' Save database
	Function Save()
		If Not list Or list.isempty(); Return
		Local J:JSON = New JSON()
		For Local key:String = EachIn list.keys()
			Local modserver:TModserver = TModserver( list.valueforkey( key ) )
			J.set( key, modserver.serialise() )
		Next
		SYS.DB.set( "modservers", J )
	End Function
	
	' Transform a JModserver to a modserver
	Function Transpose:TModserver( J:JSON )
		Local modserver:TModserver = TModserver( J.Transpose( "TModserver" ) )
		' Get repository
		'DebugStop
		modserver.repository = TRepository.get( modserver.repo_key )
		modserver.setCache()
		Return modserver
	End Function
	
	' ############################################################

	' Create a modserver
	Method New( key:String )
'DebugStop
		Self.key        = key
		Self.repo_key   = key
		Self.repository = TRepository.get( key )
		setcache()
	End Method

	' Create a modserver
'	Method New( repo:TRepository )
'		repo_key    = repo.definition()
'		repository = repo
'		setcache()
'	End Method

	' Create a modserver using a JSON record from the database
'	Method New( J:JSON )
'		Local repo_key:String
'		name    = J.find( "name" ).ToString()
'		repo_key = J.find( "repository" ).ToString()
'		' Get repository
'		repository = TRepository.fromDefinition( repo_key )
'		cachefile = SYS.CACHEPATH+repository.cachefolder()+"modserver.json"
'	End Method
	
	' Validates the modserver cache and returns true if the cache is missing
	' or expired
	Method expired:Int()
		' Check cache for modserver
		Return Not validCache(cachefile, ONE_DAY)
	End Method

	' Retrieve the modserver.json file from remote repository
	Method fetch:Int()
		'DebugStop
		' Get modserver from the repository
		Print( "- Connecting to "+ repository.project )
		Local uri:String = repository.getModserverURL()
		Local def:String = repository.downloadString( uri, "modserver.json" )
		
		If def
			' Validate the JSON
			Local J:JSON = JSON.parse( def )
			If J And J.isValid()
				' Write the downloaded file to a cache
				SaveString( def, cachefile )
				' Save modserver definition into modserver
				JModserver = J
				' Extract modserver name from modserver definition
				name = Trim( jmodserver.find("name").ToString() )
				If name=""; name = repo_key
				Return True
			End If
		End If
		Return False
	End Method
		
	' Retrieve the modserver.json file from cache or remote repository
Rem
	Method getX:Int()
	
		' Obtain Raw Text Modserver from Cache or from the repository
		DebugStop
		Local modserverdef:String
		
		' Check cache for modserver
		'Local repo_key:String   = repository.definition()
		
		If validCache( cachefile, ONE_DAY )
			modserverdef = LoadString( cachefile )
		Else 
			' Get modserver from the repository
			DebugStop
			'Local modserver:String = platform.getModserver( argdata.project, argdata.folder )
			
			Print( "- Connecting to "+ repository.project )
			'Local folder:String    = repository.getFolder()
			Local uri:String = repository.getModserverURL()
			modserverdef = repository.downloadString( uri, "modserver.json" )
			' Write the downloaded file to a cache
			If modserverdef; SaveString( modserverdef, cachefile )
		End If
		
		If Not modserverdef; Return False
		
		' Convert Raw-text modserver into JSON
		
		'DebugStop
		'Print( "MODSERVER~n"+modserver )
		' Parse modserver.json
		Jmodserver = JSON.parse( modserverdef )
		If Not Jmodserver Or Jmodserver.isinvalid()
			Local error:String = "~nFailed to pass JSON"
			If JModserver; error = "~n"+Jmodserver.getlasterror()
			Return fail( repo_key + " does not contain a valid modserver.json"+error )
		End If
		
		' Extract modserver name from modserver definition
		name = Trim( jmodserver.find("name").ToString() )
		If name=""; name = repo_key
		Return True
	End Method
EndRem
	' Convert modserver to JSON
	Method serialise:JSON()

	'DebugStop
		Return JSON.serialise( Self )
	End Method

	' Set the location of the cache file
	Method setcache()
		cachefile = SYS.CACHEPATH+repository.cachefolder()+"modserver.json"
	End Method

	' Update attempts to download and update package information
	Method Update:Int()
		DebugStop
		
		' If we dont have a modserver definition, get one from the server or fail!
		If Not Jmodserver And Not fetch(); Return False

		' If we still don;t have one, then update failed
		'If Not JModserver; Return False	'fail( "Failed to connect to modserver "+name )
		
		'	GET PACKAGES DEFINED IN JMODSERVER
		Local packages:JSON = jmodserver.search("packages")
		If Not packages; Return fail( "No packages defined by modserver" )

'TODO: Remove deleted packages
'* Loop through packages in database
'* Identify packages in this modserver
'* Check package defined in JSON : packages.search( package.key )
'* If not, then remove package: package.delete()

		' PARSE PACKAGES INTO DATABASE

		For Local key:String = EachIn packages.keys()
			Local JPackage:JSON = packages.find( key )

			' Create a TPackage from JPackage
			Local package:TPackage = TPackage.Transpose( JPackage )
			If Not package
				Print( "- Modserver contains invalid package: "+key )
				Continue
			EndIf
			' Set the package source to the repository we retrieved it from		
			package.key = key
			package.modserver_key = repository.key
			If Trim(package.name)=""; package.name = key
			
			' Check if package already exists and update or add
			If TPackage.exists( package.key )
				Local dbpackage:TPackage = TPackage.forKey( package.key )
				'
				If dbpackage.name <> package.name; dbpackage.name = package.name
				If dbpackage.author <> package.author; dbpackage.author = package.author
				If dbpackage.description <> package.description; dbpackage.description = package.description
				If dbpackage.class <> package.class; dbpackage.class = package.class
				If dbpackage.folder <> package.folder; dbpackage.folder = package.folder
				If dbpackage.target <> package.target; dbpackage.target = package.target
				If dbpackage.JDependencies <> package.JDependencies; dbpackage.JDependencies = package.JDependencies
				If dbpackage.JInstall <> package.JInstall; dbpackage.JInstall = package.JInstall
				If dbpackage.name <> package.name; dbpackage.name = package.name
				' When modserver or repo change, we need to do some checks
				Local investigate:Int = False
				If dbpackage.repo_key <> package.repo_key
					Print( "WARNING: Repository has changed. This could indicate an malicious package." )
					investigate = True
					dbpackage.repo_key = package.repo_key
				End If
				If dbpackage.modserver_key <> package.modserver_key
					Print( "WARNING: modserver has changed. This could indicate an malicious package." )
					investigate = True
					dbpackage.modserver_key = package.modserver_key
				End If
				'
				If investigate
					' A potentially malicious package has been detected.
				End If
	
			Else
				TPackage.add( package )
			End If
			
			' Check if package's repository exists
			Local repository:TRepository = TRepository.Create( package.repo_key )
			If Not TRepository.exists( package.repo_key ); TRepository.Add( repository )
			
			DebugStop
			' A Package is official if it's repository is the same organisation
			' as the modserver that provided it.
			package.official = repository.isofficial( Self.repo_key )
			
Rem

			' Check if package is being provided by offical repository
			' We do this by asking the repository we downloaded from to
			' confirm the package repository is the same
			'DebugStop
			
			'package.
			'If official
			'	Print( "- "+package.name+" (OFFICAL)" )
			'Else
			'	Print( "- "+package.name+" (Unoffical)" )
			'End If
			DebugStop
			' Get or create a repository
			Local repo:TRepository = TRepository.get( package.repo_key )
			'Local JRepo:JSON = SYS.DB.get( "repositories", package.repo_key )
			TRepository.add( repo )
			
			'If SYS.DB.repo_exists( package.repository )
			If JRepo And JRepo.isvalid()
				Print "- "+package.repo_key+" exists"
				repo = TRepository.Transpose( JRepo )
				'
				' If saved repository is unoffical and modserver repository
				' is offical, we should upgrade the saved repository
				If official 'And repo.modserver <> package.modserver
					SYS.DB.set( "repositories|"+package.repo_key+"|modserver", package.modserver )
				End If
			Else
				'Print "- Repo '"+package.repository+"' missing"
				' Package repository is not saved, so add it
				'DebugStop
				'Local repo:TRepository = TRepository.fromDefintion( package.repository )
				If SYS.DB.add_repository( package.repo_key, "", repository.definition() )
					Print "- Added repository: "+ package.repo_key
				End If
			End If
			
			'DebugStop
			
			' Check if package already exists
			If SYS.DB.package_exists( package.name )
				' Package already exists, so upgrade it from modserver

				'Print( "# Package "+package.name+" already exists" )
				'Print( "# IMPLEMENTATION INCOMPLETE" )
				
				' Get saved package
				Local dbpackage:String = "packages|"+package.name
				Local JSaved_package:JSON = SYS.DB.get( dbpackage )
				Local saved_package:TPackage = TPackage.Transpose( JSaved_package )
				
				' Check if repository has changed
				If saved_package.repo_key = package.repo_key
					' Repository the same, so update details
					SYS.DB.set( dbpackage+"|author", package.author )
					SYS.DB.set( dbpackage+"|description", package.description )
					SYS.DB.set( dbpackage+"|revision", package.revision )
					'
					If package.revision > saved_package.revision
						Print( "- Revision "+package.revision+" available" )
					Else
						Print( "- Package already exists" )
					End If
				ElseIf official
					' An offical repository will always override an unoffical one
					SYS.DB.set( dbpackage+"|author", package.author )
					SYS.DB.set( dbpackage+"|description", package.description )
					SYS.DB.set( dbpackage+"|revision", package.revision )
					'
					SYS.DB.set( dbpackage+"|modserver", repository.definition() )
					SYS.DB.set( dbpackage+"|repository", package.repo_key )
					'
					Print( "- Package upgraded to OFFICIAL" )
					If package.revision > saved_package.revision
						Print( "- Revision "+package.revision+" available" )
					End If
				Else
					' Repository has changed!
					' Inform user so they can work it out.
					Fail( "- Changed repository detected; please contact author" )
				End If
			Else
				SYS.DB.add_package( package )
				Local state:String = ["Unofficial","Offical"][official]
				'If official
				Print( "- Added "+package.name+" ("+state+"), Revision "+package.revision+", "+package.description )
				'Else
				'	Print( "- Found "+package.name+" (Unoffical), "+package.description )
				'End If
			EndIf 
			package.save()
EndRem
		Next	
	End Method
	
End Type