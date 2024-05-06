

Type TModserver

	Field repository:TRepository
	Field name:String				' Name of this modserver
	Field cachefile:String			' File where cached "modserver.json" is saved
	Field Jmodserver:JSON			' Latest modserver definition
	
	' Create a modserver
	Method New( repo:TRepository )
		repository = repo
		cachefile = SYS.CACHEPATH+repository.cachefolder()+"modserver.json"
	End Method

	' Create a modserver using a JSON record from the database
	Method New( J:JSON )
		Local repodef:String
		name    = J.find( "name" ).ToString()
		repodef = J.find( "repository" ).ToString()
		' Get repository
		repository = TRepository.fromDefinition( repodef )
		cachefile = SYS.CACHEPATH+repository.cachefolder()+"modserver.json"
	End Method
	
	' Validates the modserver cache and returns true if the cache is missing
	' or expired
	Method expired:Int()
		' Check cache for modserver
		Return Not validCache(cachefile, ONE_DAY)
	End Method
	
	' Retrieve the modserver.json file from cache or remote repository
	Method get:Int()
	
		DebugStop
		Local modserver:String
		
		' Check cache for modserver
		Local repodef:String   = repository.definition()
		
		If validCache(cachefile, ONE_DAY)
			modserver = LoadString( cachefile )
		Else 
			' Get modserver from the repository
			DebugStop
			'Local modserver:String = platform.getModserver( argdata.project, argdata.folder )
			
			Print( "- Connecting to "+ repodef )
			Local folder:String    = repository.getFolder()
			Local uri:String       = repository.getModserverURL( folder )
			modserver = repository.downloadString( uri, "modserver.json" )
			' Write the downloaded file to a cache
			If modserver; SaveString( modserver, cachefile )
		End If
		
		If Not modserver; Return False
		
		'DebugStop
		'Print( "MODSERVER~n"+modserver )
		' Parse modserver.json
		Jmodserver  = JSON.parse( modserver )
		If Not Jmodserver Or Jmodserver.isinvalid()
			Local error:String = "~nFailed to pass JSON"
			If JModserver; error = "~n"+Jmodserver.getlasterror()
			Return fail( repodef + " does not contain a valid modserver.json"+error )
		End If
		' Extract modserver name from modserver definition
		name = Trim( jmodserver.find("name").ToString() )
		If name=""; name = repodef
		Return True
	End Method
	
	' Update attempts to download and update package information
	Method Update:Int()
		DebugStop
		
		' If we dont have a modserver definition, get one from the server
		If Not Jmodserver
			If Not get(); Return False	'fail( "Failed to connect to modserver "+name )
		End If
		
		'	GET PACKAGES DEFINED IN MODSERVER
		Local packages:JSON = jmodserver.search("packages")
		If Not packages; Return fail( "No packages defined by modserver" )

'	DebugStop
'DebugLog( "PACKAGES:~n"+packages.prettify() )
	'	ADD PACKAGES TO DATABASE

		' PARSE PACKAGES INTO DATABASE

		For Local key:String = EachIn packages.keys()
			Local J:JSON = packages.find( key )
'DebugLog( "PACKAGE:~n"+J.prettify() )
			'DebugStop
			Local package:TPackage = TPackage.Transpose( J )
			' Set the package source to the repository we retrieved it from
			package.modserver = repository.definition()
			If package
				package.name = key

				' Check if package is being provided by offical repository
				' We do this by asking the repository we downloaded from to
				' confirm the package repository is the same
				'DebugStop
				Local official:Int = repository.isofficial( package.repodef )
				'package.
				'If official
				'	Print( "- "+package.name+" (OFFICAL)" )
				'Else
				'	Print( "- "+package.name+" (Unoffical)" )
				'End If
				DebugStop
				' Get existing repository if it exists
				Local repo:TRepository
				Local JRepo:JSON = SYS.DB.get( "repositories", package.repodef )
				
				'If SYS.DB.repo_exists( package.repository )
				If JRepo And JRepo.isvalid()
					Print "- "+package.repodef+" exists"
					repo = TRepository.Transpose( JRepo )
					'
					' If saved repository is unoffical and modserver repository
					' is offical, we should upgrade the saved repository
					If official 'And repo.modserver <> package.modserver
						SYS.DB.set( "repositories|"+package.repodef+"|modserver", package.modserver )
					End If
				Else
					'Print "- Repo '"+package.repository+"' missing"
					' Package repository is not saved, so add it
					'DebugStop
					'Local repo:TRepository = TRepository.fromDefintion( package.repository )
					If SYS.DB.add_repository( package.repodef, "", repository.definition() )
						Print "- Added repository: "+ package.repodef
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
					If saved_package.repodef = package.repodef
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
						SYS.DB.set( dbpackage+"|repository", package.repodef )
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
			End If
			'DebugStop
		Next
	
	End Method
	
End Type