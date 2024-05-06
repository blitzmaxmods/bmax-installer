
Import net.libcurl

' Response object

Type TResponse

	Field code:Int
	'Field httpConnectCode:Int
	'Field FileTime:Long
	'Field totalTime:Double
	'Field namelookupTime:Double
	'Field connectTime:Double
	'Field preTransferTime:Double
	'Field startTransferTime:Double
	'Field redirectTime:Double
	'Field redirectCount:Int
	'Field sizeUpload:Double
	'Field sizeDownload:Double
	'Field speedDownload:Double
	'Field speedUpload:Double
	'Field headerSize:Int
	'Field requestSize:Int
	'Field sslVerifyResult:Int
	'Field contentLengthDownload:Double
	'Field contentLengthUpload:Double
	Field contentType:String
	'Field httpAuthAvail:Int
	'Field proxyAuthAvail:Int
	'Field osErrno:Int
	'Field numConnects:Int
	Field errorCode:Int
	
	Field Text:String
	Field binary:String

	Method New( info:TCurlInfo )
'DebugStop
		code = info.responseCode()
		'httpConnectCode = info.httpConnectCode()
		'FileTime = info.FileTime()
		'totalTime = info.totalTime()
		'namelookupTime = ifno.namelookupTime()
		'connectTime = info.connectTime()
		'preTransferTime = info.preTransferTime()
		'startTransferTime = info.startTransferTime()
		'redirectTime = info.redirectTime()
		'redirectCount = info.redirectCount()
		'sizeUpload = info.sizeUpload()
		'sizeDownload = info.sizeDownload()
		'speedDownload = info.speedDownload()
		'speedUpload = info.speedUpload()
		'headerSize = info.headerSize()
		'requestSize = info.requestSize()
		'sslVerifyResult = info.sslVerifyResult()
		'contentLengthDownload = info.contentLengthDownload()
		'contentLengthUpload = info.contentLengthUpload()
		contentType = info.contentType()
		'httpAuthAvail = info.httpAuthAvail()
		'proxyAuthAvail = info.proxyAuthAvail()
		'osErrno = info.osErrno()
		'numConnects = info.numConnects()
		errorCode = info.errorCode()
	End Method
	
	Method reveal:String()
		Local result:String
		result  = "code:        "+code+"~n"
		result :+ "contentType: "+contentType+"~n"
		result :+ "errorCode:   "+errorCode			'+"~n"	
		Return result
	End Method
End Type