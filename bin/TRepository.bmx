
'Import "TPackage.bmx"


Include "TRepositoryGitHub.bmx"

'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

'	A repository is a source of data located on a modserver.

Type TRepository

	Field platform:String = "undefined"
	Field name:String
	Field modserver:String		' The modserver we learned this repository

	'Field platform:TPlatform
	Field project:String		' This is the path inside the platform
	' This is from the defintion (if exists) and is only used
	' when creating a repo. 
	Field folder:String

	Function Transpose:TRepository( J:JSON )
		Return TRepository( J.Transpose( "TRepository" ) )
	End Function
	
	' Finds an existing repository
	Function find:TRepository( definition:String )
	End Function

	'Method New()
	'	DebugStop
	'End Method
	
	' Returns a repostitory definition string
	Method definition:String()
		Return platform+":"+project	'+"/"+folder
	End Method
	
	' Build a repository from database
	Function get:TRepository( definition:String )
		Local data:String[] = definition.split(":")
		If data.Length <> 2; die( "!! Invalid repository definition" )

		Local platform:String = data[0].tolower()
		'Local path:String     = data[1]
		
		Local J:JSON = SYS.DB.get( "repositories|"+definition )
		If Not J Or J.isInvalid(); Return Null

		Select platform
		Case "git","github";		Return TRepositoryGithub.Transpose( J )
'		Case "sf","sourceforge";	Return TRepositorySourceForge.Transpose( J )
'		Case "webapi";				Return TRepositoryWebApi.Transpose( J )
		Default
			die( "Unsupported platform: "+platform )
		End Select
	
	End Function
	
	' Creates a repository from a definition
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

	' Identify if this is an official repository
	Method isOfficial:Int()
		Return isOfficial( modserver )
	End Method

	' Identify if this is an official repository
	' (May be platform specific)
	Method isOfficial:Int( other:String )
		Local data:String[] = Lower(other.Replace("\","/")).split(":")
		If data.Length <> 2 Or data[0] <> platform Or data[1] <> project; Return False
		Return True
	End Method
	
	Public
	
	' Returns the folder from a repository definition
	Method getFolder:String()
		Return folder
	End Method
	
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
		Local path:String = platform+"/"+project+"/"
		If folder; path :+ folder+"/"
		Return path
	End Method

	' Download a string from the repository (Platform Specific)
	Method downloadString:String( uri:String, description:String="File" ) Abstract

	' Get details regarding the last commit on this repository
	Method getLastCommit:String( filepath:String ) Abstract
	
	' Retrieves the URL for a modserver (Platform specific)
	Method getModserverURL:String( folder:String="" ) Abstract

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


