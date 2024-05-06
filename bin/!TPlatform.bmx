'   NAME
'   (c) Copyright Si Dunford, MMM 2022, All Rights Reserved. 
'   VERSION: 1.0

'   CHANGES:
'   DD MMM YYYY  Initial Creation
'
SuperStrict

Import net.libcurl

Import "system.bmx"
Import "utils.bmx"

Include "TRepository.bmx"
Include "TResponse.bmx"

Include "TPlatformGitHub.bmx"
Include "TPlatformSourceForge.bmx"
'Include "TPlatformWebApi.bmx"

Type TPlatform

	Field name:String = "UNDEFINED"		' Name of the platform

	' Get a platform controller by name
	Function Find:TPlatform( name:String )
		Select Upper( name )
		Case "GIT","GITHUB";		Return New TPlatformGithub()
'		Case "SF","SOURCEFORGE";	Return New TPlatformSourceForge()
'		Case "WEBAPI";				Return New TPlatformWebApi()
		Default
			die( "Unsupported platform: "+name )
		End Select
	End Function

	' Confirm if a modserver exists
	Method isModserver:Int( project:String )
		Return SYS.DB.modserver_exists( name, project )
	End Method
	
	' Get a repository for given project
	Method getRepository:TRepository( project:String, folder:String, usenull:Int=False )
		If usenull And Not SYS.DB.modserver_exists( name, project ); Return Null
		Return New TRepository( Self, project, folder )		
	End Method
	

	
	' Get URL to modserver.json
	Method getModserverPath:String( project:String, folder:String="" ) Abstract

	' The modserver response is encoded
	Method decode_modserver:String( response:TResponse ) Abstract

	
	' Split a passed argument containing project and optional folder name
	Method splitRepoPath:SArgData( path:String ) Abstract
	
End Type

