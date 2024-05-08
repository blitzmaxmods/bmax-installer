
'	BlitzMax installer
'	(c) Copyright Si Dunford [Scaremonger], FEB 2023, All rights reserved

Rem	COMMAND LINE TESTING:

	bmax add modserver github:blitzmax-itspeedway-net/sandbox
	bmax add modserver github:blitzmaxmods/bmax-installer
	
	bmax show modservers
	
	bmax show repos
	bmax show repositories

	bmax show packages
	bmax show modules
	bmax show apps
	bmax show applications
	
done to here

	bmax update
	
	bmax install blitzmax
	bmax install blitzmax -latest
	bmax install blitzmax -named
	bmax install blitzmax -version xx

	bmax remove repository xx
	bmax remove modserver xx

	bmax purge

	bmax show revision blitzmax
	bmax show version blitzmax
	
	bmax show app xxx
	bmax show module xx
	bmax show repo xx
	bmax show modserver xx

EndRem

Rem ## PROGRAMMER NOTES

* A MODSERVER is just a file located in a repository (modserver.json)
* A REPOSITORY is a location where files are stored.
* An official package is one that is served by an offical repository
	For example: 
	
		"dot.example" is defined to be in repository github:fred/examples
		Repository github:fred/examples is defined in modserver located in
		github:mrhappy/modserver and also in github:fred/modserver
		
		By comparing the modserver repository against the package repository
		you can identify which is the offical repository.
		
		NOTE: This does not stop dot.example from being copied to 
		github:mrhappy/examples; you would then	have two modules with the 
		same name in different repositories that are both official. 
		This situation could also occur if there was a mirror of an offical.
		
		BMAX does not currently identify this problem!
		
EndRem

Rem ## KNOWN ISSUES

* There is no official support for BMAX and therefore blitzmax and most modules
  are flagged as unoffical. We hope in time that an offical modserver will be
  created by Brucey and others to support this utility.

* BMAX does not currently identify a potential problem if there are two modules
  with the same name, they are treated as one. See "Programmer notes" above for more 
  detail.

* Update does not:
	- Remove packages that are no longer referenced within the modserver

EndRem

Rem
blitzmaxng, Offical Blitzmax, https://github.com/bmx-ng

	bmx-ng						APP		Release
	maxide						APP		ZIP
	bcc							APP 	ZIP
	bmx							APP 	ZIP
	brl.Mod						Module	ZIP

maxmods, Bruceys Modules, https://github.com/maxmods

	bah.Mod						ZIP
		bah.volumes				Module	maxmods/bah.Mod/volumes.Mod
		etc...
	ifsogui.Mod					Module	ZIP
		ifsogui.Mod						maxmods/ifsogui.Mod
		
blitzmaxmods, Scaremongers Modules, https://github.com/blitzmaxmods

	timestamp.Mod				Module	ZIP
		bmx.timestamp
	modserver					MODSERVER	FILE
		packages.json

itspeedway, ITSpeedway modules, https://github.com/blitzmax-itspeedway-net

	Blitzmax-Language-Server	APP	ZIP
		bls
	json.Mod					ZIP
		bmx.json
	observer.Mod				ZIP
		bmx.observer
	behavior.Mod				ZIP
		bmx.behavior

End Rem

Rem ## ARGUMENTS

bmax <none>					WORKING	(Shows help)
bmax version				WORKING
bmax modserver ...
bmax repo ...

bmax add modserver ...
bmax add repo ...
bmax remove modserver ...
bmax remove repo ...

bmax list
bmax show ...
bmax debug

ARGUMENTS IN DETAIL

bmax modserver [show]
bmax modserver add type>:<path>
bmax modserver remove type>:<path>

	<type>	Currently only GITHUB is supported
	<path>	For GITHUB, the path consists of <username>[/<repository>]

			<username>		The User or Organisation where the repository is located
			<repository>	The repository that contains the modserver.json descriptor
							(This defaults to "modserver" if not specified)

bmax show modserver[s]
bmax show repo[s]


OLD BEYOND HERE


' MODSERVER SUPPORT

bmax modserver [show]
bmax modserver add type>:<path>
bmax modserver remove type>:<path>

	<type>	Currently only GITHUB is supported
	<path>	For GITHUB, the path consists of <username>[/<repository>]

			<username>		The User or Organisation where the repository is located
			<repository>	The repository that contains the modserver.json descriptor
							(This defaults to "modserver" if not specified)

' REPOSITORY SUPPORT

bmax repo add type>:<path>				' bmax repo github:blitzmaxmods
bmax repo [list]
bmax repo show <path>
bmax repo remove type>:<path>

bmax install bmx.libcurl
- Lookup repo for "bmx.libcurl"
	Username:"maxmods", Repository:"bah.mod", Type:Github, path="libcurl.mod"
	If it does not exist, Repository should ask modserver to update
		Modserver downloads modserver.json and updates repository list
		repeats find and if fail then exits
- Ask repo for "libcurl.mod/installer.json"
DebugStop;- File not found

bmax install bmx.timestamp
- Lookup repo for "bmx.timestamp"
	Username:"blitzmaxmods", Repository:"bmx.timestamp", Type:Github, path=""
	If it does not exist, Repository should ask modserver to update
	
- archive exists in "installer" folder?
	YES:
	- Ask repo for "installer.json"
		File found:
		- Get sha version and compare against downloaded sha
		  MATCH: You already have the latest version
		  NO MATCH: Begin Download
		File not found:
		  Begin download
	NO:
	 Begin download
- Download
  - Are we downloading release or latest! (--latest)
DebugStop
		

DebugStop;bmax update
- 

A MODSERVER ONCE ADDED IS CHECKED FOR UPDATES AND THIS POPULATES
AND MAINTAINS THE LIST OF REPOSITORIES.

So if we add a github repository, that github modserver is responsible.
If it has a modserver configured, it will take prescedence
- This is where we ned to request the modserver.json file
If not, the user can manage it.

A repo can contain multiple modules or packages!
- We download them as a ZIP, the module/package is in a path within that ZIP

End Rem

SuperStrict

'Import bah.libcurl	' Obsolete, use net.libcurl
'Import net.libcurl
'Import bmx.json

'Import "bin/adler32.bmx"		' Also part of zlib but not exposed!
Import "bin/datetime.bmx"		'TODO: Move to Blitzmax own version
Import "bin/unzip.bmx"

Import "bin/system.bmx"			' System specific settings

'Include "bin/cmd_list.bmx"
Include "bin/cmd_modserver.bmx"
Include "bin/cmd_repository.bmx"
Include "bin/cmd_show.bmx"
Include "bin/cmd_update.bmx"

' INITIALISE DEFAULT DATA

Include "default-data.bmx"

' INITIALISE SYSTEM AND CONFIGURATION

SYS.initialise()

' LAUNCH APPLICATION

AppTitle = "bmax"
Local AppVersion:String = "0.0.0"

'	CONFIRM MODULE VERSIONS

If Not JSON.versioncheck( 3.2, 0 ) 
	Print( AppTitle + " has been compiled with incompatible 'bmx.json'." )
	Print( "Please update bmx.json and re-compile" )
	End
EndIf


Rem

Include "bin/config.bmx"
Include "bin/utils.bmx"

' Now that system paths and config are loaded
' We can update the system from configuration settings
SYS.Update()

' LAUNCH APPLICATION

AppTitle = "bmax"
Local AppVersion:String = "0.0.0"

Include "bin/TRepository.bmx"
Include "bin/TPackage.bmx"

Include "bin/TResponse.bmx"
Include "bin/TModserver.bmx"
Include "bin/TGitHub.bmx"

Include "bin/TRelease.bmx"

'	LOAD OR CREATE DATABASE

Include "default-data.bmx"
Include "bin/TDatabase.bmx"
Global DATABASE:TDatabase = New TDatabase()
'DATABASE.Update()
'DATABASE.save()

EndRem

Rem  VERY OLD



'Import "bin/TGitHub.bmx"





DebugStop;
'Import "bin/unzip.bmx"



'	ADD MODSERVERS TO LIST

'Local modservers:JSON = config.settings.find("modservers")
'Print modservers.prettify()
'debugStop

'For Local name:String = EachIn modservers.keys()
	'DebugStop
'	Local modserver:JSON = modservers.find(name)
	'Print modserver.prettify()
'	Select modserver.find("type").toInt()
'	Case MODSERVER_GITHUB
'		TModserver.register( name, New TGithub( modserver["repository"], modserver["desc"] ) )
'	EndSelect
'Next
EndRem

'	PARSE ARGUMENTS
'Global ModInfo:TMap = New TMap()

'Include "bin/adler32.bmx"
'Include "bin/TOptions.bmx"
'Include "bin/TScanner.bmx"

Print( "" )
Print( "  !! WARNING" )
Print( "  !! THIS IS A BETA RELEASE" )
Print( "  !! Some elements of this application may not be fully tested" )
Print( "" )

DebugLog( "## ARGUMENTS:   "+AppArgs.Length )
Local args:String[] = AppArgs[1..]
DebugLog( "## ARGS LENGTH: "+args.Length )
For Local n:Int = 0 Until args.Length
	DebugLog n+") "+args[n]
Next

' Display Help Information
If AppArgs.Length < 2
	RestoreData help_syntax
	showdata()
EndIf

DebugStop
'	PARSE ARGUMENTS
Select AppArgs[1].tolower()
Case "add"
	Select AppArgs[2].tolower()
	Case "modserver" ; cmd_modserver( "add", AppArgs[3..] )
	Case "repo","repository" ; cmd_repository( "add", AppArgs[3..] )
	'Case "module"; cmd_module( "add", AppArgs[2..] )
	'Case "package"; cmd_package( "add", AppArgs[2..] )
	Default          ; die( "Unknown command: add " +AppArgs[2] )
	End Select	
Case "modserver"
	Select AppArgs[2].tolower()
	Case "add","remove" ; cmd_modserver( AppArgs[2].tolower(), AppArgs[3..] )
	Default             ; die( "Unknown command: modserver " +AppArgs[2] )
	End Select	
'Case "module"
'	Select AppArgs[2].tolower()
'	Case "add","remove" ; cmd_module( AppArgs[2].tolower(), AppArgs[3..] )
'	Default             ; die( "Unknown command: module " +AppArgs[2] )
'	End Select	
'Case "package"
'	Select AppArgs[2].tolower()
'	Case "add","remove" ; cmd_package( AppArgs[2].tolower(), AppArgs[3..] )
'	Default             ; die( "Unknown command: package " +AppArgs[2] )
'	End Select	
Case "repo","repository"
	Select AppArgs[2].tolower()
	Case "add","remove" ; cmd_repository( AppArgs[2].tolower(), AppArgs[3..] )
	Default             ; die( "Unknown command: "+ AppArgs[1]+" "+AppArgs[2] )
	End Select	
Case "help"
	If AppArgs.Length < 2
		RestoreData help_syntax
		showdata()
	End If
	
	Select AppArgs[2].toLower()
	Case "UNTESTED"
	Default
		die( "Sorry, help is not available for "+AppArgs[2] )
	End Select
	
'Case "list"		' Show installed packages
'	cmd_list()
Case "show"
	If args.Length<>2; die( "Invalid command" )
	Select AppArgs[2].tolower()
	Case "apps", "applications" ; cmd_show( AppArgs[2].tolower(), AppArgs[2] )
	Case "modservers"           ; cmd_show( AppArgs[2].tolower(), AppArgs[2] )
	Case "modules"              ; cmd_show( AppArgs[2].tolower(), AppArgs[2] )
	Case "packages"             ; cmd_show( AppArgs[2].tolower(), AppArgs[2] )
	Case "repos","repositories" ; cmd_show( AppArgs[2].tolower(), AppArgs[2] )
	Default                     ; die( "Unknown command: show " +AppArgs[2] )
	End Select	
'Case "debug"
'	DebugStop
'	cmd_debug( "all-modules.csv" )
Case "install"
	DebugStop
	If AppArgs.Length < 3; Die( "No package specified" )
	Select True
	' No arguments is install blitzmax
	Case AppArgs[2].toLower() = "blitzmax"
		DebugStop ' DISABLED DURING DEBUGGING
'		cmd_install_blitzmax( getOptions( AppArgs[3..] ) )
	Case Instr( AppArgs[2], "." ) > 0
		DebugStop ' DISABLED DURING DEBUGGING
'		cmd_install_module( AppArgs[2], getOptions( AppArgs[3..] ) )
	Case AppArgs[2].startswith("-")
		Die( "No package specified" )
	Default
		DebugStop ' DISABLED DURING DEBUGGING
'		cmd_install_package( AppArgs[2], getOptions( AppArgs[3..] ) )
	EndSelect
'Case "search"
'Case "download"		
'Case "remove", "uninstall"
Case "update"
	Print AppArgs.Length
	' Update packages from online repositories
	DebugStop
	cmd_update() 
Case "upgrade"
	Print "## UPGRADE IS NOT IMPLEMENTED"
	' With no arguments we upgrade to the latest offical release
Case "version", "--version"
	Print AppTitle+" "+AppVersion+" ("+AppDir+")"
Default
	die( "Unknown command: " +AppArgs[1] )
End Select