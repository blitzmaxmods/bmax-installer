'SuperStrict

'Import "utils.bmx"
'Import "TPlatform.bmx"
'Import "TPackage.bmx"
'Import "TRepository.bmx"
'Include "TModserver.bmx"
'Import "config.bmx"

'Import "TRelease.bmx"

Function cmd_modserver( action:String, args:String[] )
	'Print "MODSERVER SUPPORT"
	DebugStop
	Select action.toLower()
	Case "add"     ; cmd_modserver_add( args )
	Case "list"    ; cmd_modserver_list( args)
	Case "remove"  ; cmd_modserver_remove( args )
	Case "show"    ; cmd_modserver_show( args )
	Default        ; die( "Unexpected argument '"+action+"'" )
	End Select
End Function

' Add a modserver to local configuration
Function cmd_modserver_add( args:String[] )
	'DebugStop
	'Print "args.length="+args.Length
	If args.Length < 1 die( "No modserver specified" )
	If args.Length > 1 die( "Invalid argument" )
	'DebugStop
	
	Local key:String = args[0].Replace("\","/")
	If TModserver.exists( key ); die( key+" already exists!" )
	
'DebugStop
	Local modserver:TModserver = TModserver.Create( key )
	If Not modserver; Return
	
'DebugStop 

	' Validate modserver before adding
	'If Not modserver.fetch(); die( "Invalid modserver" )

'DebugStop
	' Update the newly added modserver
	TModserver.add( modserver )
	'modserver.Update()
'Print( "## cmd_modserver_add() needs to be tidied up!!!" )
		Print( "- New modserver added. Please run update to refresh packages." )
	Return
			


	' Support default modserver
	' This would be github specific, so not currently supported
	'If repo_key.split("/").Length = 1; repo_key :+ "/modserver"
	
	' Get repository
	' (This will be an unofficial repository because it is added from CLI)
'	Local repository:TRepository = TRepository.get( repo_key )
	'Local folder:String = repository.getFolder()
		
	'Local data:String[] = args[0].split(":")
	'If data.Length <> 2; die( "Invalid modserver definition" )
	'Local platformname:String = data[0].toUpper()
	'Local path:String = data[1]
	
	'DebugStop
	
	' Validate modserver by getting modserver.json

Rem
Q). Do we do a Local platform:TPlatform = TPlatform.get( platformname ) To get the github support
	Then Create a repository: platform.Create( data[1..])
	This would set up the platform, repo And modserver For us.
	We would Then only save:
		github: {
			blitzmaxmods : { modserver=blitzmax_installer}
			blitzmaxinstaller: { username:blitzmaxmods, repo:blitzmaxinstaller }
			timestamp.Mod, github
		}
End Rem

	' Get link to correct platform
	'Local platform:TPlatform = TPlatform.Find( platformname )
	'If Not platform; die( "Invalid platform: "+platformname )

	' Get a repo definition
	'DebugStop
	'Local argdata:SArgData = platform.splitRepoPath( path )
Rem	
	' Confirm if modserver already exists
	' NOTE THAT FOLDER IS USED IN MODSERVER DEFINTIONS
	Local modserver_repo_key:String = repository.definition()
	If SYS.DB.modserver_exists( modserver_repo_key ); die( "Modserver already exists" )

	' Create a modserver record
	Local modserver:TModserver = New TModserver( repository )

	' Download the modserver file	
	If Not modserver.fetch(); die( "Failed to download modserver" )

	' We have a valid modserver, save it
	'SYS.DB.add_modserver( modservername, modserver_repo_key )
	SYS.DB.add_modserver( modserver.name, modserver_repo_key )
	Print( "- Added modserver: "+ modserver.name )
	
	' Perform an update for this modserver
	modserver.Update()
	
EndRem
Rem	
	'	GET PACKAGES DEFINED IN MODSERVER
	Local packages:JSON = jmodserver.search("packages")
	If Not packages; die( "No packages defined by modserver" )

'	DebugStop
'DebugLog( "PACKAGES:~n"+packages.prettify() )
	'	ADD PACKAGES TO DATABASE

	For Local key:String = EachIn packages.keys()
		Local J:JSON = packages.find( key )
'DebugLog( "PACKAGE:~n"+J.prettify() )
		'DebugStop
		Local package:TPackage = TPackage.Transpose( J )
		' Set the package source to the repository we retrieved it
		package.modserver = modserver_repo_key
		If package
			package.name = key

			' Check if package is being provided by offical repository
			' We do this by asking the repository we downloaded from to
			' confirm the package repository is the same
			'DebugStop
			Local official:Int = repository.isofficial( package.repository )
			'If official
			'	Print( "- "+package.name+" (OFFICAL)" )
			'Else
			'	Print( "- "+package.name+" (Unoffical)" )
			'End If
			' Get existing repository if it exists
			Local repo:TRepository
			Local JRepo:JSON = SYS.DB.get( "repositores", package.repository )
			'If SYS.DB.repo_exists( package.repository )
			If JRepo And JRepo.isvalid()
				Print "- Repo '"+package.repository+"' exists"
				repo = TRepository.Transpose( JRepo )
				'
				' If saved repository is unoffical and modserver repository
				' is offical, we should upgrade the saved repository
				If official And repo.modserver <> package.modserver
					SYS.DB.set( "respositories|"+key+"|modserver", package.modserver )
				End If
			Else
				'Print "- Repo '"+package.repository+"' missing"
				' Package repository is not saved, so add it
				'DebugStop
				'Local repo:TRepository = TRepository.fromDefintion( package.repository )
				If SYS.DB.add_repository( package.repository, "", repo_key )
					Print "- Added repository: "+ package.repository
				End If
			End If
			
			'DebugStop
			
			' Check if package already exists
			If SYS.DB.package_exists( package.name )
				' Package already exists, so upgrade it from modserver
				' NOT IMPLEMENTED YET
				Print( "# Package "+package.name+" already exists" )
				Print( "# IMPLEMENTATION INCOMPLETE" )
				' We need to check if saved package points to an unoffical
				' repo and upgrade it if the new modserver is official
			Else
				SYS.DB.add_package( package )
				If official
					Print( "- Found "+package.name+" (OFFICAL), "+package.description )
				Else
					Print( "- Found "+package.name+" (Unoffical), "+package.description )
				End If
			EndIf 
		End If
		'DebugStop
	Next
End Rem

Rem


	Select platformname
	Case "GITHUB"
		DebugStop
		modserver = New TGithub( username, modserverrepo )
		Local repository:TRepository = New TRepository( modserver, modserverrepo )
		'modserver = TModserver.find( "GITHUB" )
		'Local repository:TRepository = modserver.get
		'Local repository:TRepository = New TRepository( modserver, modserverrepo )
		'TRepository.get( modsv, path )
		Local Jmodserver:JSON = modserver.getRemoteConfig()
		DebugStop
		
		If jmodserver.isinvalid()
			die( "Invalid modserver.json in repository" )
		End If
		'TODO:
		' Get the modserver default repository and download available packages		
		'Local repository:TRepository = modserver.repository()
		
		' Get the packages.json file from the repository
		'Local packages:String = repository.getfile( "packages.json" )
		
		' Parse the packages into the database
		'TModserver.register( name, modserver )
		database.add_modserver( modservername, platform, username, modserverrepo )
		DebugStop
	Default
		Throw( "Invalid modserver platform '"+platform+"'" )
	End Select
EndRem
	'
	'Local key:String = "modservers|"+modsv
	'config[ key+"|platform" ] = platform
	''config[ key+"|username" ] = username
	'config[ key+"|repository" ] = path
	'config.save()
End Function

' List all configured modservers
Function cmd_modserver_list( args:String[] )
End Function

' Remove a modserver from local configuration
Function cmd_modserver_remove( args:String[] )
	DebugStop
	Print "args.length="+args.Length
	If args.Length < 1 die( "No modserver specified" )
	If args.Length > 1 die( "Invalid argument" )
	DebugStop
	
	Local key:String = args[0].Replace("\","/")
	If Not TModserver.exists( key ); die( "Modserver doesn't exist" )
	
DebugStop
	TModserver.remove( key )
	Print( "- Modserver removed." )
	TPackage.removeModserver( key )

End Function

' Show a modserver
Function cmd_modserver_show( args:String[] )

'	Must show if offical or not
'	See repo.isOffical()

End Function

