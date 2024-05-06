# BlitzMax Installer

*EXPERIMENTAL*

CURRENT STATE:  BROKEN
	' A PACKAGE IS IN A REPO
	' modserver.json is a file in a REPO and is therefore similar to a package!
	' A MODSERVER is a repo containing a modserver.json
	' So you must add the repo before adding the modserver

	' THESE TWO DO NOT DO ANYTHING - REDUNDANT
	' add repository blitzmaxmods github:blitzmaxmods/bmx.mod
	' add repository blitzmaxmods.modserver github:blitzmaxmods/modserver

	' add package bmax github:blitzmaxmods/bmax-installer
	'	-> Adds a package to your definition
	'	-> The repository blitzmaxmods/bmax-installer will be added as a source
	
	' add module bmx.mod github:blitzmaxmods/bmx.mod
	'	-> Adds a module to your definition
	'	-> The repository blitzmaxmods/bmx.mod will be added as a source
	
	' add modserver blitzmaxmods github:blitzmaxmods/modserver
	'	-> This downloads a list of packages and modules in modserver.json
	'	-> The repository blitzmaxmods/modserver will be added as a source

	' add module database.mod github:bruceysmodules/bah.mod/database.mod
	'	-> Adds a module to your definition from a folder inside a repository
	'	-> The repository bruceysmodules/bah.mod will be added as a source


Will download latest official release but does not unzip it etc (yet)
Only supports modservers from github at present. Will be extended if required.

DEV NOTE:
* Modserver is the platform (Github/Sourceforge etc) tied to a username/organisation
* A Modserver must be able to provide a list of mods/packages etc.
    - For github, this means a defined repository containing modserver.json
* A modserver default repo is called modserver, but can be changed.
* Github Modservers are named USERNAME
* Github Repositories are named USERNAME:REPOSITORY


# Command Line

NOTE: This should be based on something like "apt"

```
    bmax version                        IMPLEMENTED     Application version
    bmax install <package> [options]    IMPLEMENTED     Installs Blitzmax, a package or module

        Package:
            blitzmax                    IMPLEMENTED     Install the current official BlitzMax release 
            <module>                    EXPERIMENTAL    Install specified module (See list)
        Options:
            -latest                     TBC             Install blitzmax release plus latest modules
            -in                         TBC             Override default installation directory

    bmax purge                          TBC             Clean up install directory

    NOT IMPLEMENTED
    bmax list <options>                 TBC             List modules and/ packages

        Options:
            -installed | -i             TBC             Lists modules installed
            -available | -a             TBC             Lists modules available for install
            -modules   | -m
            -packages  | -p

    bmax show <package>                 TBC             Show details of a package

        Package:
            blitzmax                    TBC             Show details of package Blitzmax 
            <module>                    TBC             Show details of a module

    bmax --debug        Produce a CSV containing all module data

    bmax upgrade <options>

    bmax update <package|module> <options>

    bmax uninstall <package|module> <options>
    bmax remove <package|module> <options>

```

#Installation

*To compile the installer, you will need the following third party components:

    https://github.com/blitzmax-itspeedway-net/json.mod
    https://github.com/blitzmaxmods/timestamp.mod

ON LINUX:
* You also need libidn
	sudo apt-get install libidn11-dev	

* Copy certificate:
	FROM: mods/bah.mod/libcurl.mod/certificates/cacert.pem
	TO: ~/BlitzMax/cfg/

ADD MODSERVER SUPPORT TO YOUR MODULES

1. On Github; identify the username or origanisation you will use as your modserver.

	For example, "https://github.com/blitzmaxmods" would be "blitzmaxmods"
    	
2. Identify the modserver repository

	You can either use an existing repository or create one called "modserver"

    To use the default modserver repository for an author use:

        bmax add modserver blitzmaxmods github:blitzmaxmods

    NOTE: The above will add a repository called blitzmaxmods:modserver to your config

    To use a specific repository specify the name of the repository:

        bmax add modserver github:blitzmaxmods:example.mod

    NOTE: The above will add a repository called blitzmaxmods:example.mod to your config


3. Add a file called "modserver.json" to your modserver root.

    See below for details regarding this file

4. Add your modserver to the installer

	a: Request via discord or make a pull request to add your modserver to the installer

	** 19 MAR 2023 - not documented at the moment
	
	b: Ask users to add your modserver from the command line:
	
		If you are using the repository 'modserver' you do not need to include it:

		bmax --add GITHUB:username[/repository]
		
		For example:
		bmax --add GITHUB:blitzmax-itspeedway-net
		bmax --add GITHUB:myBlitzMaxMods/mbm.master

5. Add an installer.json file to your module root to help with version control and dependencies.

NEED COMMUNITY INPUT BUT THIS MIGHT CHANGE

* Instructions to install should be:

    Create folder in home directory called BlitzMax
    Copy the downloaded file to that folder
    Unzip it.
    Run the executeable for your platform

* This applicaton MUST install into the current folder
    so the use of -in and -default are not available
   THE CHOICE OF FOLDER IS MADE BY THE CREATION OF FOLDER
   NT BY --default or --in xxx

* Community input into this change is necessary 

# Configuration
An optional local configuration file can be used to override some default settings

The location of the config file depends on your system:

| Linux | /home/<username>/.blitzmax/config/bmax.cfg |
| MacOS | /Users/username/Library/Application Support/.blitzmax/config/bmax.cfg |
| Windows | C:\Documents and Settings\username\Application Data\.blitzmax\config\bmax.cfg |




# modserver.json

** This design has not been completed **

```{
"name": "My Mod server",
"packages": {
	"example.amazingframework":{
        "author":"John Doe [johndoe]"
        "description":"Amazing Framework for BlitzMax",
        "repository":"github:example/amazingframework",
        "target":"${BLITZMAX}/mod/amazing.mod/framework.mod/",
        "type":"module"
         },
	"example.amazingapp":{
        "author":"John Doe [johndoe]"
        "dependencies":{
		    "bcc":{"version":"", "date":"2023-03-11" },
		    "bmx.json":{"version":"3.2", "date":"2024-04-10" }
	    },
        "description":"Amazing Application",
        "repository":"github:example/amazingapp",
        "target":"${BLITZMAX}/mod/amazing.mod/framework.mod/",
        "type":"application",
        "install.win32":[],
        "install.linux":[]
        }
	}
}```

Within an application package, you can provide install scripts; however
these are over-ridden if the application provides an installer.json in it's
downloaded package.
This feature was added to bmax before support for the installer is generally implemented and may be revoked at a later date.

# installer.json

** This design has not been completed **

```{
	"modname": "mms.amazingfeatures",
	"author": "Jack Frost",
	"date": "2023-03-18 08:43:00",
	"checksum": "38759287B9",
	"version": 1.6,
	"dependencies": [
		{ "module": "bcc", "version": "", "date": "2023-03-11" },
	]
}```

# NOTES

The application currently collects info from ModuleInfo statements in modules and follows include and import statements for dependencies

Before INSTALL/UNINSTALL is possible, we need a way to identify some additonal data:

    One or more "modserver" definitions where module details can be downloaded
    modserver definitions should contain module version numbers that can be used to
        identify modules that need to be updated
    the definitions also need to provide dependency information and this is the tricky bit
        How to document the module versions that everything works with.

    The module version number and details really needs to be in an external file. Parsing the modules to get
    this information is not the correct way to do it, but for now thats all that can be done

    Maybe Brucey will see this and add some type of dependency system in the modules.

    @bmk version - (see some of my other modules) can write version details to a file
        Basically it should write to some type of JSON file.

	Need a way to flag depreciated modules to the user
	
UPDATE FROM GITHUB
https://api.github.com/
https://www.advancedinstaller.com/github-integration-for-updater.html
https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28

This uses the "Release" API

To get a list of releases; you call this:
https://api.github.com/repos/<username>/<repository_name>/releases

INSTALLER LOGIC

	Some modules have Blitzmax dependencies
	Some modules have operating system dependencies
		For example, libcurl needs libidn11-dev
	Find list of documented libraries for "sudo apt-get install"

MODSERVER INFORMATION

PACKAGE			REPO					MODSERVER		INSTALL
BlitzMaxNG		bmx-ng					bmx-ng					
BlitzMax		bmx-ng					bmx-ng

bcc				bmx-bg					bcc				. to ${BLITZMAX}/src/bcc
		After compile: the exe needs copying to ${BLITZMAX}/bin/
bmk				bmx-bg					bmk				. to ${BLITZMAX}/src/bmk
		After compile: the exe needs copying to ${BLITZMAX}/bin/
maxide			bmx-bg					maxide			. to ${BLITZMAX}/src/maxide
		After compile: the exe needs copying to ${BLITZMAX}/
bmax			blitzmax-itspeedway-net	bmax			. to ${BLITZMAX}/src/bmax
		After compile:
			the exe needs copying to ${BLITZMAX}/
			Copy package database into ${BLITZMAX}/cfg/
bls				blitzmax-itspeedway-net	bls				tbc

audio.*			bmx-bg
brl.*			bmx-bg
crypto.mod		bmx-bg
maxgui.mod		bmx-bg
mky.mod			bmx-bg
pub.mod			bmx-bg
random.mod		bmx-bg
sdl.mod			bmx-bg
steam.mod		bmx-bg
text.mod		bmx-bg

bah.libcurl		maxmods 				bah.mod			Modules inside parent zip
bah.mbedtls		maxmods 				bah.mod			Modules inside parent zip
bah.libssh2		maxmods 				bah.mod			Modules inside parent zip

bmx.observer	blitzmax-itspeedway-net	observer.mod	. to /mod/bmx/observer.mod
bmx.json		blitzmax-itspeedway-net	json.mod		. to /mod/bmx/json.mod

Need to document other users modules; i'm sure there are a lot of them

THINGS TO DO
* Downloaded files need to go in an installer or setup folder (not in downloads)
* Document how to re-generate the certificate (Before it expires)
* Do we need setProgressCallback() in TModserver.downloadString()?
* setProgressCallback() needs to be in MB instead of bytes... and only show increases.
* Improve TModserver.sanitise()
* We dont need to download releases EVERY time. Once per day is enough.
* Move from my ADLER32 to the one in ZLib; it is so much faster!
* Repo default modserver should be modserver, but if it doesn't exist we
	must add them manually into the repo until owner supports the installer!
* When downloading the "modserver.json" file, we must extract the SHA and save
	it into the	setup folder. This should be used to see if file has changed.
	We should be able to do the same for version files related to modules.
	In that case we need a installer.json file in module repository.
	- This also needs bmk and bmx code to update the file during build so
	   developers can easily add installer support.
	- version insformation without a version file should be dealt with inside
	   installer but requires download and checksum creation.
* Document layout of modserver.json and installer.json files
