
' API DOCUMENTATION
' 
' GITHUB:
' MODSERVER:	http://api.github.com/repos/{USERNAME}
' REPOSITORY:	http://api.github.com/repos/{USERNAME}/{REPO}

'Global API:String = "http://api.github.com/repos/{USERNAME}/{REPO}/contents/{FILEPATH}"

'	GITHUB API:
'	https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28

' GITHUB:
' MODSERVER:	http://api.github.com/repos/{USERNAME}
' REPOSITORY:	http://api.github.com/repos/{USERNAME}/{REPO}

Type TRepositoryGitHub Extends TRepository

	Const GITHUB_API:String = "http://api.github.com/repos/"

	Function Transpose:TRepositoryGitHub( J:JSON )
		Return TRepositoryGitHub( J.Transpose( "TRepositoryGitHub" ) )
	End Function
		
	Method New()
'		DebugStop
	End Method

	Method New( path:String )	', modserver:String )
		Self.platform = "github"
		'Self.modserver = modserver
		'DebugStop
		'Local this:TRepositoryGitHub = Self
		Local data:String[] = (path.Replace("\","/")).split("/")
		If data.Length < 2; die( "Invalid repository" )
		project = "/".join( data[..2] )
		'name = project	' Use project as a name by default
		'Local folder:String = ""
		'If data.Length > 2; folder = "/"+ ( "/".join( data[2..] ) )
	End Method

	' Download a TResponse from a repository
	Method download:TResponse( uri:String )				
		Local headers:String[] = getheaders()
		Return API_download_String( uri, headers )		
	End Method	

	' Download a string from a repository
	Method downloadString:String( uri:String, description:String="File" )

		' Download file
		Local response:TResponse = download( uri )	
		If response; Print( response.reveal() )
		
		'DebugStop
		Select response.code
		Case 200
			Print( "-> downloaded "+uri )
			Return decode_file( response )
		Case 404 ' Not Found
			Fail( description+" not found in repository" )	
			Return ""
		Default
			Fail( "Unexpected error "+response.code+" retrieving "+description )
			Return ""
		End Select
	End Method	

	' Get details regarding the last commit on this repository
	' http://api.github.com/repos/{USERNAME}/{REPO}/commits?path={FILEPATH}&page=1&per_page=1
	Method getLastCommit:SDateTime( branch:String = "master" )
'		DebugStop
'"https://api.github.com/repos/{owner}/{repository_name}/commits/{branch_name}"
		Local curl:TCurlEasy = New TCurlEasy.Create()
		'Local encoded:String = curl.escape( filepath )
		'Local url:String     = GITHUB_API + project +"/commits?path="+encoded+"&page=1&per_page=1"
		Local url:String     = GITHUB_API + project +"/commits/"+branch
		
		' Retrieve a response from the server
		Local response:TResponse = download( url )
		If response; Print( response.reveal() )
	
		' Extract the response text
		Local J:JSON = JSON.parse( response.Text )
		If Not J Or J.isInvalid(); Return Null
		'Print( J.prettify() )
		DebugStop
		
		Local CommitString:String = J.search( "commit|author|date" ).ToString()

		'Print( "COMMIT DATE: "+CommitString )
		' Use CTime to convert datestring into SDateTime
		Local tm:CTime = New CTime( CommitString, "%Y-%m-%dT%H:%M:%S%z" )
		Local dt:SDateTime = tm.convert()
		'Print( "TIMESTAMP:   "+tm.timestamp() )
		'Print( "DATE:        "+tm.format() )

		'Local now:CTime = New CTime()
		'Print( "NOW:         "+now.format() )
		
		'DebugStop
		'Return tm.timestamp()
		Return dt
	End Method
	
	' Get URL to modserver.json
	Method getModserverURL:String()
		Return GITHUB_API + project+"/contents/modserver.json"
	End Method

	' Get API headers
	Method getHeaders:String[]()
		
		Local githubEnvironment:String = SYS.CONFIG["github|environment"]
		Local token:String
		Local env:String[]
		
		'DebugStop
		If githubEnvironment; env = [ getenv_( githubEnvironment ) ]
		env :+ [ "GITHUB_TOKEN", "GITHUBTOKEN", "GITTOKEN" ] 
				
		For Local environment:String = EachIn env
			githubEnvironment = environment
			token = getenv_( environment )
			If token <> ""; Exit
		Next

		If token = ""
			Print "## WARNING: GITHUB token not found in '"+githubEnvironment+"'"
			Return []
		Else
			Print "- Using GITHUB token in environment variable '"+githubEnvironment+"'"
			Return [ "Authorisation: "+token ]
		End If
		
	End Method

	' Identify if this is an official repository
	' In Github the USERNAME part of the project should match
	' for it to be considered an official repository
	Method isOfficial:Int( other:String )
		' Match platform
		other = Lower( other.Replace("\","/") )
		Local path:String[] = other.split(":")
		If path.Length <> 2 Or path[0] <> platform; Return False
		' Extract username/repository from other
		path = path[1].split("/")
		' Extract username/repositry from self
		Local me:String[] = (project.Replace("\","/")).split("/")
		' Compare username
		If me[0] <> path[0]; Return False
		Return True
	End Method


	' Split a passed argument containing project and optional folder name
	' Github path contains {USERNAME}/{REPOSITORY} and optional {FOLDER}
Rem Performed by new()
	Method splitRepoPath:SArgData( path:String )
		'DebugStop
		Local data:String[] = (path.Replace("\","/")).split("/")
		If data.Length < 2 Or data.Length > 3 ; die( "!! Invalid repository" )
		Local project:String = "/".join( data[..2] )
		Local folder:String = ""
		If data.Length > 2; folder = "/".join( data[2..] )
		'DebugStop
		'Local result:SArgData
		'result.platformname = name
		'result.project = project
		'result.folder = folder
		'Return result
		Return New SArgData( name, project, folder )
	End Method
End Rem

	' Github file responses are encoded
	Method decode_file:String( response:TResponse )
		Try
			Local jtext:JSON = JSON.parse( response.Text )
			If Not jtext Or jtext.isInvalid(); Return ""
			'
			'Print( jtext.prettify() )
			'DebugStop
			'Local sha:String = jtext.find["sha"]
			Local encoded:String = jtext.find("content").ToString()
			Local encoding:String = jtext.find("encoding").ToString()
			Select Lower(encoding)
			Case "base64"
				Local data:Byte[] = TBase64.Decode(encoded)
				'content = String.FromUTF8String(data)
				Return String.FromUTF8String(data)
			Default
				die( encoding+ " encoding is not supported" )
			EndSelect

			'Print( "CONTENT:~n"+content )
			'DebugStop
			
			
			'Local J:JSON = JSON.parse( content )
			'If J And J.isValid()
			'	Print J.prettify()
			'End If
			'Return content
			
		Catch e:String
			Print( "ERROR: "+e )
		EndTry
	End Method
	
End Type

