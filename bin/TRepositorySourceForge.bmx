

' API DOCUMENTATION
' https://anypoint.mulesoft.com/apiplatform/sourceforge/#/portals/organizations/98f11a03-7ec0-4a34-b001-c1ca0e0c45b1/apis/32951/versions/34322

' API: https://sourceforge.net/rest/p/{PROJECT}/{REPO}

Type TRepositorySourceForge Extends TRepository

	Const API:String = "https://sourceforge.net/rest/p/"
	
	Method New()
		name = "sourceforge"
	End Method

	' Get URL to modserver.json
	Method getModserverPath:String( project:String, folder:String="" )
		If folder And Not folder.endswith( "/" ); folder :+ "/"
		Return API + project+"/"+folder+"modserver.json"
	End Method
	
End Type