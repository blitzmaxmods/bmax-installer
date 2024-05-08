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
	Field commitfile:String 	{serializedname="commit"}

	' Fields used to access data inside an archive file
	Field folder:String			' Folder inside archive
	Field target:String			' Target folder (Relative to BMX_ROOT)
	Field JDependencies:JSON	{serializedname="dependencies"}
	Field JInstall:JSON			{serializedname="install"}
	
	Function Add:Int( package:TPackage )
		If Not list; Load()
		' Check if package exists
		If list.contains( package.name ); Return False
		' Add to database
		list.insert( package.name, package )
		Return True
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
		Local repository:TRepository = TRepository.get( repo_key )
		If Not repository Return Fail( "Failed to get repository" )
		
		DebugStop
		Local commit:String = commitfile
		If commit = ""; commit = "package.json"
		
		Local lastcommit:String = repository.getLastCommit( commit )
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

