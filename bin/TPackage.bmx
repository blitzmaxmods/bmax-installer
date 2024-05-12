'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

' Package and Package Manager

' Package Management functions:

'	Exists()		- Checks if a package exists
'	ForKey()		- Gets a package for a given key
'	Keys()			- Gets a list of keys (package) in the database
'	Load()			- Loads the database
'	Save()			- Saves the database
'	Transpose()		- Transforms JSON to package

' Modserver support methods


Const PACKAGE_NONE:Int = 0
Const PACKAGE_CURRENT:Int = 1
Const PACKAGE_OFFICIAL:Int = 2
Const PACKAGE_LATEST:Int = 3

Const PACKAGE_MODULE:Int = 0
Const PACKAGE_PROGRAM:Int = 1	' BCC, BMK, MAXIDE, BLS, BMAX, etc.
Const PACKAGE_SOURCE:Int = 2	

Type TPackage
	
	Global list:TMap

	Field name:String
	Field key:String			{noserialise}	' Index in database
	Field author:String
	Field description:String
	Field revision:Int = 0
	Field official:Int = False

	Field class:String			{serializedname="type"}			'module or application
	Field repo_key:String		{serializedname="repository"}
	Field modserver_key:String	{serializedname="modserver"} 	' The modserver we learnt this from
	'Field commitfile:String 	{serializedname="commit"}
	Field branch:String = "master"

	' Fields used to access data inside an archive file
	Field folder:String			' Folder inside archive
	Field target:String			' Target folder (Relative to BMX_ROOT)
	Field JDependencies:JSON	{serializedname="dependencies"}
	Field JInstall:JSON			{serializedname="install"}
	
	Field lastCommit:Long		' Last commit date
	
	Function Add:Int( package:TPackage )
		If Not list; Load()
		' Check if package exists
		If list.contains( package.name ); Return False
		' Add to database
		list.insert( package.name, package )
		Return True
	End Function

	' Remove all packages associated with a modserver
	Function RemoveModserver:Int( modserver_key:String )
		If Not list; Load()
		For Local package:TPackage = EachIn list
			If package.modserver_key = modserver_key
				Print( "- Package "+package.name+ " removed" )
				list.remove( package.key )
			End If
		Next
	End Function
	
	' Check if package exists
	Function Exists:Int( key:String )
		If Not list; Load()
		Return list.contains( key )
	End Function

	' Get a package
	Function ForKey:TPackage( key:String )
		If Not list; Load()
		Return TPackage( list.valueforkey( key ) )
	End Function

	' Get list of keys (packages)
	Function Keys:TMapEnumerator()
		If Not list; Load()
		Return list.keys()
	End Function

	' Load database
	Function Load()
		list = New TMap()
		Local packages:JSON = SYS.DB.get( "packages" )
		If Not packages; Return
		'
		For Local key:String = EachIn packages.keys()
			Local J:JSON = packages.find( key )
			Local package:TPackage = TPackage.Transpose( J )
			list.insert( key, package )
		Next
	End Function

	' Save database
	Function Save()
		'Print( "SAVING PACKAGES" )

		If Not list Or list.isempty(); Return
		Local J:JSON = New JSON()
		For Local key:String = EachIn list.keys()
			Local package:TPackage = TPackage( list.valueforkey( key ) )
			J.set( key, package.serialise() )
		Next
		SYS.DB.set( "packages", J )
	End Function

	' Transform a JPackage to a package
	Function Transpose:TPackage( J:JSON )
		Return TPackage( J.Transpose( "TPackage" ) )
	End Function
	
	' Save package to the database
Rem
	Method save()
		Local resource:String = "packages|"+name+"|"
		SYS.DB.set( resource + "author",      author )
		SYS.DB.set( resource + "description", description )
		SYS.DB.set( resource + "modserver",   modserver_key )
		SYS.DB.set( resource + "name",        name )
		SYS.DB.set( resource + "repository",  repo_key )
		SYS.DB.set( resource + "folder",      folder )
		SYS.DB.set( resource + "revision",    revision )
		SYS.DB.set( resource + "target",      revision )
		SYS.DB.set( resource + "type",        class )

		Local J:JSON = New JSON.serialise( Self )
		SYS.DB.set( "packages2|"+name, J )
		
	End Method
End Rem	

	' Convert package to JSON
	Method serialise:JSON()
		Return JSON.serialise( Self )
	End Method
	
	' Update this package
	Method Update:Int()
		DebugStop
'THIS IS RETURNING A TREPOSITORY INSTEAD OF A GITHUB REPOSITORY
'IT IS Not AN ISSUE IN FORKEY
'THE ISSUE SEEMS To BE THAT THE LIST CONTAINS INCORRECT TYPES WHEN LOADED
		Local repository:TRepository = TRepository.get( repo_key )
		If Not repository Return Fail( "Failed to get repository" )
		
		DebugStop
		'Local commit:String = commitfile
		'If commit = ""; commit = "package.json"
		'If branch = ""; branch = "master"
		
		Local lastcommit:SDateTime = repository.getLastCommit( branch )

		Print( "-Last commit: "+lastCommit )
		
		DebugStop

		If lastcommit.ToEpochSecs() > Self.lastcommit
			Print( "* Found version dated "+lastcommit.ToString() )
			Self.lastcommit = lastcommit
		End If
		
		
Rem		

{
  "author": {
    "avatar_url": "https://avatars.githubusercontent.com/u/95883?v=4",
    "events_url": "https://api.github.com/users/woollybah/events{
      /privacy
    }",
    "followers_url": "https://api.github.com/users/woollybah/followers",
    "following_url": "https://api.github.com/users/woollybah/following{
      /other_user
    }",
    "gists_url": "https://api.github.com/users/woollybah/gists{
      /gist_id
    }",
    "gravatar_id": "",
    "html_url": "https://github.com/woollybah",
    "id": 95883,
    "login": "woollybah",
    "node_id": "MDQ6VXNlcjk1ODgz",
    "organizations_url": "https://api.github.com/users/woollybah/orgs",
    "received_events_url": "https://api.github.com/users/woollybah/received_events",
    "repos_url": "https://api.github.com/users/woollybah/repos",
    "site_admin": False,
    "starred_url": "https://api.github.com/users/woollybah/starred{
      /owner
    }{
      /repo
    }",
    "subscriptions_url": "https://api.github.com/users/woollybah/subscriptions",
    "type": "User",
    "url": "https://api.github.com/users/woollybah"
  },
  "comments_url": "https://api.github.com/repos/bmx-ng/maxide/commits/306fde2021198fa5cc7509d5a9872613f2789d0b/comments",
  "commit": {
    "author": {
      "date": "2023-04-17T11:48:16Z",
      "email": "woollybah@gmail.com",
      "name": "Brucey"
    },
    "comment_count": 0,
    "committer": {
      "date": "2023-04-17T11:48:16Z",
      "email": "noreply@github.com",
      "name": "GitHub"
    },
    "message": "Merge pull request #81 from thareh/master\n\nFixed UTF8 characters in output panel",
    "tree": {
      "sha": "2f678b69988444c8ba2840dc71f05934b7ad8188",
      "url": "https://api.github.com/repos/bmx-ng/maxide/git/trees/2f678b69988444c8ba2840dc71f05934b7ad8188"
    },
    "url": "https://api.github.com/repos/bmx-ng/maxide/git/commits/306fde2021198fa5cc7509d5a9872613f2789d0b",
    "verification": {
      "payload": "tree 2f678b69988444c8ba2840dc71f05934b7ad8188\nparent 0d0193cb06bfcac9288a4c78e0d6e36659518e38\nparent a8d8ceb751d6103baad4d462a024b0e8389ed892\nauthor Brucey <woollybah@gmail.com> 1681732096 +0100\ncommitter GitHub <noreply@github.com> 1681732096 +0100\n\nMerge pull request #81 from thareh/master\n\nFixed UTF8 characters in output panel",
      "reason": "valid",
      "signature": "-----BEGIN PGP SIGNATURE-----\n\nwsBcBAABCAAQBQJkPTIACRBK7hj4Ov3rIwAA9dYIAIm9k6nb4c4m2ixjz3ZFAofx\nS2FvUiJ7SGEKt+ZH6CrIH0EMe1AlgVCj9OZx3byVxCxP6ns2O7+dKyM9Puh/yNYs\nyJdAbcbkc+JE4DaWcUL2aVojkUqoZc+GrxkKcjVxUcRvMIAfWmv/PYOStNf3fVEI\n7hM5goTLDlPYorB26fDTDRmwYSH8ap1VMDUevvQS8MQ6QbDcPPx6tNCTqRY/Nl2D\nT2ak4DvNuBUi3hxhCs4IpFMlnqST8Ezt8Dyxnpl0fUCeiypCf8kS8CRCLbmeUZQ7\nuJeJXR+Z933yDR0A1/1wrpu7M7JgwALmZ9w5NlafmoC4qNhjt23qF6gznie7rqw=\n=3q5Y\n-----END PGP SIGNATURE-----\n",
      "verified": True
    }
  },
  "committer": {
    "avatar_url": "https://avatars.githubusercontent.com/u/19864447?v=4",
    "events_url": "https://api.github.com/users/web-flow/events{
      /privacy
    }",
    "followers_url": "https://api.github.com/users/web-flow/followers",
    "following_url": "https://api.github.com/users/web-flow/following{
      /other_user
    }",
    "gists_url": "https://api.github.com/users/web-flow/gists{
      /gist_id
    }",
    "gravatar_id": "",
    "html_url": "https://github.com/web-flow",
    "id": 19864447,
    "login": "web-flow",
    "node_id": "MDQ6VXNlcjE5ODY0NDQ3",
    "organizations_url": "https://api.github.com/users/web-flow/orgs",
    "received_events_url": "https://api.github.com/users/web-flow/received_events",
    "repos_url": "https://api.github.com/users/web-flow/repos",
    "site_admin": False,
    "starred_url": "https://api.github.com/users/web-flow/starred{
      /owner
    }{
      /repo
    }",
    "subscriptions_url": "https://api.github.com/users/web-flow/subscriptions",
    "type": "User",
    "url": "https://api.github.com/users/web-flow"
  },
  "files": [
    {
      "additions": 1,
      "blob_url": "https://github.com/bmx-ng/maxide/blob/306fde2021198fa5cc7509d5a9872613f2789d0b/maxide.bmx",
      "changes": 2,
      "contents_url": "https://api.github.com/repos/bmx-ng/maxide/contents/maxide.bmx?ref=306fde2021198fa5cc7509d5a9872613f2789d0b",
      "deletions": 1,
      "filename": "maxide.bmx",
      "patch": "@@ -4074,
      7 +4074,
      7 @@ Type TOutputPanel Extends TToolPanel\t'used build and run\n \r\n \t\tbytes=pipe.ReadPipe()\r\n \t\tIf bytes\r\n-\t\t\tline$=String.FromBytes(bytes,
      Len bytes)\r\n+\t\t\tline$=String.FromUTF8Bytes(bytes,
      Len bytes)\r\n \t\t\tline=line.Replace(Chr(13),
      \"\")\r\n \t\t\tWrite line\r\n \t\tEndIf\r",
      "raw_url": "https://github.com/bmx-ng/maxide/raw/306fde2021198fa5cc7509d5a9872613f2789d0b/maxide.bmx",
      "sha": "309ecf103b1423a2801d46ce359df5217dcd064a",
      "status": "modified"
    }
  ],
  "html_url": "https://github.com/bmx-ng/maxide/commit/306fde2021198fa5cc7509d5a9872613f2789d0b",
  "node_id": "C_kwDOAY7CAdoAKDMwNmZkZTIwMjExOThmYTVjYzc1MDlkNWE5ODcyNjEzZjI3ODlkMGI",
  "parents": [
    {
      "html_url": "https://github.com/bmx-ng/maxide/commit/0d0193cb06bfcac9288a4c78e0d6e36659518e38",
      "sha": "0d0193cb06bfcac9288a4c78e0d6e36659518e38",
      "url": "https://api.github.com/repos/bmx-ng/maxide/commits/0d0193cb06bfcac9288a4c78e0d6e36659518e38"
    },
    {
      "html_url": "https://github.com/bmx-ng/maxide/commit/a8d8ceb751d6103baad4d462a024b0e8389ed892",
      "sha": "a8d8ceb751d6103baad4d462a024b0e8389ed892",
      "url": "https://api.github.com/repos/bmx-ng/maxide/commits/a8d8ceb751d6103baad4d462a024b0e8389ed892"
    }
  ],
  "sha": "306fde2021198fa5cc7509d5a9872613f2789d0b",
  "stats": {
    "additions": 1,
    "deletions": 1,
    "total": 2
  },
  "url": "https://api.github.com/repos/bmx-ng/maxide/commits/306fde2021198fa5cc7509d5a9872613f2789d0b"
}		
EndRem
	
		DebugStop
		
	End Method
	
Rem
	'Field modserver:TModserver
	'Field username:String
	'Field repository:String
	'Field zippath:String
	'Field ismodule:Int = False

	'Field installed:Int = PACKAGE_NONE

	'Field versions:TPackageDetail[3]
	
	'Field current:TPackageDetail		' The installed version
	'Field official:TPackageDetail		' The offical version
	'Field latest:TPackageDetail			' The latest version

	'Function find:TPackage( name:String )
	'	Return TPackage( list.valueforkey( name ) )
	'End Function
	

	

	
	'Function add( package:TPackage )
	'	If package And package.name; list.insert( package.name, package )
	'End Function

	'Method New( name:String )
	'	Self.name = name
	'End Method
	
	'Method New( name:String, class:Int, modserver:TModserver, username:String, reponame:String, zippath:String )
	'	Self.name = name
	'	Self.class = class
	'	Self.modserver = modserver
	'	Self.username = username
	'	Self.reponame = reponame
	'	Self.zippath = zippath
	'End Method
	
	'Method install:Int( revision:Int )
		' Update the official/latest package details
	'	If revision = PACKAGE_NONE; Return uninstall()
		
		' Get installer.json from modserver
		'modserver.getfile( "installer.json", username, reponame, zippath, revision )
	'End Method
	
	'Method uninstall:Int()
		' Uninstall is simply the removal of the module / package...
		' ha ha... not actually that simple...
	'End Method

	' Retrieve a Repository for a package
	Function get:TPackage( name:String )		
		' Get package from database
		Local JPackage:JSON = DATABASE.get( "packages", name )
		If Not JPackage; Return Null
		' Create package object
		'Local package:TPackage = New TPackage( JPackage )
		'Return package
		Return TPackage( JPackage.Transpose( "TPackage" ) )
	End Function
	
	'Method New( JPackage:JSON )
	'	name       = JPackage.find( "name" ).toString()
	'	repository = JPackage.find( "repository" ).toString()
	'End Method

	Method getLastCommit:String()
		Local repo:TRepository '= New TRepository().get( repository )
		If Not repo Return ""
		
		DebugStop
		Local commit:String = commitfile
		If commit = ""; commit = "package.json"
		
		Local lastcommit:String = repo.getLastCommit( commit )
	End Method

EndRem

End Type

'Type TPackageDetail
'	Field checksum:Long
'	Field version:String
'	Field filedate:Long	'TIMESTAMP
'End Type

