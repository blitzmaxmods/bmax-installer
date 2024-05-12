' Repository and Repository Manager

' Repository Management functions:

'	Exists()		- Checks if a repository exists
'	ForKey()		- Gets a repository for a given key
'	Keys()			- Gets a list of keys (repository) in the database
'	Load()			- Loads the database
'	Save()			- Saves the database
'	Transpose()		- Transforms JSON to repository

' Modserver support methods

'	New()			- Creates a new modserver
'	expired()		- Checks if local modserver cache is valid
'	setcache()		- Sets the modserver cache path
'	update()		- Performs an update


Include "TRepositoryGitHub.bmx"

'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	A repository is a source of data located on a modserver.

Type TRepository

	Global list:TMap

	Field key:String			{noserialise}	' Database index
	Field platform:String = "undefined"
	'Field name:String
	'Field modserver:String		' The modserver we learned this repository

	'Field platform:TPlatform
	Field project:String		' This is the path inside the platform
	' This is from the defintion (if exists) and is only used
	' when creating a repo. 
	'Field folder:String

	'Function Exists:Int( repo_key:String )
	'	Return SYS.DB.repo_exists( repo_key )
	'End Function

	' Add new Repository
	Function Add:Int( repository:TRepository )
		If Not list; Load()
		' Check if repository exists
		If list.contains( repository.key ); Return False
		' Add to list
		list.insert( repository.key, repository )
		Return True		
	End Function

	' Create a repository
	Function Create:TRepository( key:String )
	
		Local data:String[] = key.split(":")
		If data.Length <> 2; die( "!! Invalid repository definition" )

		Local platform:String = data[0].tolower()
		Local repopath:String[] = Lower(data[1].Replace("\","/")).split("/")
		If repopath.Length <>2; die( "!! Invalid repository definition" )
		'If path.Length >2; folder = "/".join(path[2..])
		Local path:String = repopath[0]+"/"+repopath[1]
		
		Local repo_key:String = platform+":"+path
			
		Local repository:TRepository
		Select platform
		Case "git","github";		repository = New TRepositoryGithub( path ) ', modserver )
'		Case "sf","sourceforge";	repository = New TRepositorySourceForge( path )', modserver )
'		Case "webapi";				repository = New TRepositoryWebApi( path )', modserver )
		Default
			die( "Unsupported platform: "+platform )
		End Select
		
		repository.key = key
		Return repository
		
	End Function

	' Check if repository exists
	Function Exists:Int( key:String )
		If Not list; Load()
		Return list.contains( key )
	End Function

	' Get a repository
	Function ForKey:TRepository( key:String )
		If Not list; Load()
		Return TRepository( list.valueforkey( key ) )
Rem		' Get platform from key
		Local data:String[] = key.split(":")
		If data.Length <> 2; die( "!! Invalid repository definition" )
		Local platform:String = data[0].tolower()
			
		Local repository:TRepository
		Select platform
		Case "git","github";		Return TRepositoryGithub( list.valueforkey( key ) )
'		Case "sf","sourceforge";	Return TRepositorySourceForge( list.valueforkey( key ) )
'		Case "webapi";				Return TRepositoryWebApi( list.valueforkey( key ) )
		Default
			die( "Unsupported platform: "+platform )
		End Select
EndRem
	End Function

	' Get list of keys (repositories)
	Function Keys:TMapEnumerator()
		If Not list; Load()
		Return list.keys()
	End Function

	' Load database
	Function Load()
		list = New TMap()
'DebugStop
		Local repositories:JSON = SYS.DB.get( "repositories" )
		If Not repositories; Return
		
		Print( repositories.prettify() )
		'DebugStop
		For Local key:String = EachIn repositories.keys()
			'DebugStop
			Local J:JSON = repositories.search( key )
			If Not J Or J.isinvalid(); Continue
			Print( J.prettify() )
			Local repository:TRepository = TRepository.Transpose( J )
			repository.key = key
			list.insert( key, repository )
		Next
		'DebugStop
	End Function

	' Save database
	Function Save()
		'Print( "SAVING REPOSITORIES" )

		If Not list Or list.isempty(); Return
		Local J:JSON = New JSON()
		For Local key:String = EachIn list.keys()
			Local repository:TRepository = TRepository( list.valueforkey( key ) )
			J.set( key, repository.serialise() )
		Next
		SYS.DB.set( "repositories", J )
	End Function
	
	' Transform a JRepository to a repository
	Function Transpose:TRepository( J:JSON )
		Local platform:String = J.find( "platform" ).ToString()
		Local repository:TRepository
		'
		Select Lower(platform)
		Case "github"; repository = TRepositoryGithub.Transpose( J )
		End Select
		'
		If repository; repository.key = repository.platform + ":" + repository.project
		Return repository
	End Function
	
	' Finds an existing repository
	'Function find:TRepository( definition:String )
	'End Function

	'Method New()
	'	DebugStop
	'End Method
	
	' Returns a repostitory definition string
	' Please use key
'	Method definition:String()
'Print( "Repository.defintion() is depreciated")
'		Return platform+":"+project	'+"/"+folder
'	End Method
	
	' Build a repository from database or create one
	Function get:TRepository( key:String )
		Local data:String[] = key.split(":")
		If data.Length <> 2; die( "!! Invalid repository definition" )

		Local platform:String = data[0].tolower()
		Local repopath:String[] = Lower(data[1].Replace("\","/")).split("/")
		If repopath.Length <>2; die( "!! Invalid repository definition" )
		'If path.Length >2; folder = "/".join(path[2..])
		Local path:String = repopath[0]+"/"+repopath[1]
		
		Local repo_key:String = platform+":"+path
		
		If Exists( repo_key )
			Return forKey( repo_key )
			Rem
		
			Local J:JSON = SYS.DB.get( "repositories|"+repo_key )
			If Not J Or J.isInvalid(); Return Null

			Select platform
			Case "git","github";		Return TRepositoryGithub.Transpose( J )
	'		Case "sf","sourceforge";	Return TRepositorySourceForge.Transpose( J )
	'		Case "webapi";				Return TRepositoryWebApi.Transpose( J )
			Default
				die( "Unsupported platform: "+platform )
			End Select
			EndRem
		Else
			Local repository:TRepository
			Select platform
			Case "git","github";		repository = New TRepositoryGithub( path ) ', modserver )
	'		Case "sf","sourceforge";	repository = New TRepositorySourceForge( path )', modserver )
	'		Case "webapi";				repository = New TRepositoryWebApi( path )', modserver )
			Default
				die( "Unsupported platform: "+platform )
			End Select
			'DebugStop
			repository.key = repo_key
			
			' Save new repository
			'SYS.DB.set( "repositories|"+repo_key, repository.serialise() )
			'Print( SYS.DB.get( "repositories|"+repo_key ).prettify() )
			'DebugStop
			Return repository
		End If
	
	End Function

	' Creates a repository from a definition
Rem DEPRECIATED, Please use get()
	Function fromDefinition:TRepository( definition:String, modserver:String="" )
		Local data:String[] = definition.split(":")
		If data.Length <> 2; die( "!! Invalid repository definition" )

		Local platform:String = data[0].tolower()
		Local path:String = data[1]

		Select platform
		Case "git","github";		Return New TRepositoryGithub( path, modserver )
'		Case "sf","sourceforge";	Return New TRepositorySourceForge( path, modserver )
'		Case "webapi";				Return New TRepositoryWebApi( path, modserver )
		Default
			die( "Unsupported platform: "+platform )
		End Select

	End Function
EndRem



	' Identify if this is an official repository
	'Method isOfficial:Int()
	'	Return isOfficial( modserver )
	'End Method

	' Identify if this is an official repository
	' (May be platform specific)
	Method isOfficial:Int( other:String )
		Local data:String[] = Lower(other.Replace("\","/")).split(":")
		If data.Length <> 2 Or data[0] <> platform Or data[1] <> project; Return False
		Return True
	End Method
	
	Public
	
	' Returns the folder from a repository definition
	'Method getFolder:String()
	'	Return folder
	'End Method
	
	' Download a file as a string
	Method API_download_String:TResponse( url:String, headers:String[] = [], verbose:Int=0 )
		Local curl:TCurlEasy = TCurlEasy.Create()
		If curl<>Null
			curl.setWriteString()
			curl.setOptInt( CURLOPT_VERBOSE, verbose )
			curl.setOptInt( CURLOPT_FOLLOWLOCATION, 1)
			curl.setOptString( CURLOPT_CAINFO, SYS.CERTFILE )
			curl.setOptString( CURLOPT_URL, url )
			'curl.setProgressCallback( progressCallback )
			headers :+ ["User-Agent: "+SYS.USERAGENT, "Referer:"]
			curl.httpHeader( headers )
		EndIf
		Local error:Int = curl.perform()
		If error; Throw CurlError( error )
		'DebugStop
		'Local results:TCurlInfo = curl.getInfo()
		Local response:TResponse = New TResponse( curl.getInfo() )
		response.Text = curl.ToString()
		curl.cleanup()
		Return response
	End Method

	' Get the relative cache file path for this repository
	Method cachefolder:String()
		Return platform+"/"+project+"/"
	End Method

	' Return the key for this repository
	'Method key:String()
	'	Return platform+":"+project
	'End Method

	' Serialise self into JSON
	Method serialise:JSON()
		Return JSON.serialise( Self )
	End Method

	' Download a string from the repository (Platform Specific)
	Method downloadString:String( uri:String, description:String="File" ) Abstract

	' Get details regarding the last commit on this repository
	Method getLastCommit:SDateTime( filepath:String ) Abstract
	
	' Retrieves the URL for a modserver (Platform specific)
	Method getModserverURL:String() Abstract

	' Get API headers (Platform specific)
	Method getHeaders:String[]() Abstract

End Type

'Type TRepository_OLD

	'Global initialised:Int
	'Global repositories:TMap = New TMap()
	'Field JRepository:JSON

	'Field name:String

	                           ' GITHUB               WEBAPI  SOURCEFORGE
'	Field repo:String          ' {REPO}
	'Field path:String          ' {USERNAME}/{REPO}  n/a     n/a
	'Field revision:int
'	Field platform:String    ' GITHUB/WEBAPI/SOURCEFORGE etc

'	Field modserver:TModserver
'	
	'Function Initialise()
'DebugStop

	'	Local name:String, repo:String
	'	RestoreData repositories
	'	ReadData( name )
	'	ReadData( repo )
		
	'	While Name
	'		New TRepository( name, repo )
	'		ReadData( name )
	'		If name
	'			ReadData( repo )
	'		End If
	'	Wend

	'End Function

Rem
	' Retrieve a Repository
	Function get:TRepository( name:String )		
		' Get repository from database
		'DebugStop
		Local JRepository:JSON = DATABASE.get( "repositories", name )
		If Not JRepository; Return Null
		
		' Create repository object
		'Local repository:TRepository = New TRepository( JRepository )
		

		'TRepository( repositories.valueForKey( name.toLower() ) )
		'If repository; Return repository
		'repository = New TRepository()
		'repository.name = name
		'repository.path = path
		'repositories.insert( name.toLower(), repository )
		Local repository:TRepository = TRepository( JRepository.Transpose( "TRepository" ) )
		If repository; repository.initialise()
		Return repository
	End Function
End Rem

'	Method New( modserver:TModserver, repo:String )
'		Self.modserver = modserver
'		Self.repo = repo
'	End Method

	'Method New( JRepository:JSON )
	'	Self.JRepository = JRepository
	'End Method

	'Method find:TRepository( name:String )
	'	Return TRepository( repositories.valueForKey( name.toLower() ) )
	'End Method
	
	'Method workspace:String()
	'	Return username + "/" + repo
	'End Method
	
	' Format a temporary cache filename for this repository
'	Method filename:String()
'		Return Self.modserver.username+"_"+Self.repo+"_releases.cache"
'	End Method

	' Initialise the modserver for this repository
	'Method initialise()
	'	Select platform
	'	Case "GITHUB"
	'		modserver = New TGithub( repopath )
	'	Default
	'		Die( "Unknown modserver '"+platform+"' defined for repository "+name )
	'	End Select
	''End Method
	
	' Get releases for a package
'	Method getReleases:TList( filter:String = "" )
'		Return modserver.getReleases( Self, filter )
'	End Method

	' Download a binary from the repository
'	Method downloadBinary:Int( url:String, destination:String="" )
'		Return modserver.downloadBinary( url, destination )
'	End Method
	
	' Download a string from a file in the repository
'	Method downloadString:TResponse( filepath:String, headers:String[] = [] )
'		Return modserver.downloadString( repo + "/" + filepath , headers )
'	End Method
	

	
'End Type
'TRepository.initialise()

'#repositories
'DefData "BlitzMax", "bmx-ng/bmx-ng"	'	,TRepository.GITHUB
'DefData ""


