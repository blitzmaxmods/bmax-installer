
'	Blitzmax Datetime functions
'	(c) Copyright Si Dunford [Scaremonger], Feb 2023, All rights reserved

'SuperStrict

Rem 
' DEPRECIATED 10 MAY 2024 - Please use TimestampNow()
Import Pub.StdC
Type DateTime

	' Return number of seconds since the epoch
	Function time:Int()
		Local time:Byte[256]
		Return time_( time )
	End Function
	
End Type
End Rem

'A Request has been added to include this in pub.stdc
'https://github.com/bmx-ng/pub.Mod/issues/70
'TODO: Replace with Blitzmax version (if included)
Function CurrentDateTime:SDateTime( utc:Int = True )
	Local dt:SDateTime
	CurrentDateTime( dt, utc )
	Return dt
End Function

Function TimestampNow:Long( utc:Int = True )
	Local dt:SDateTime
	CurrentDateTime( dt, utc )
	Return dt.ToEpochSecs()
End Function

