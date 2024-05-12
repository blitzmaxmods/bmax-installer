
'	Test the CTime structure

SuperStrict

Import "ctime.bmx"
'Import bmx.timestamp

Print "~nSDateTime Test:"

' Convert CTime to SDateTime
Local timedate:String = "2023-04-17T12:48:16Z"
Local timestamp:Long =	1681732096	' 2023-04-17 12:48:16

Local ct:CTime = New Ctime( timedate, DT_GITHUB )
Local dt:SDateTime = ct.convert()

Print "~nTIMESTAMP:"
Print "BEFORE:   "+timestamp
Print "AFTER:    "+dt.ToEpochSecs()

Print "~nDATESTRING:"
Print "BEFORE:   "+timedate
Print "AFTER:    "+dt.ToString()


