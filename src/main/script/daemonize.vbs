

if WScript.Arguments.Count>0 Then
	AllArguments=""
	For Each Arg in WScript.Arguments
		AllArguments = AllArguments & """" & Arg & """ "
	next

	rem run process in background
	Dim WinScriptHost
	Set WinScriptHost = CreateObject("WScript.Shell")
	WinScriptHost.Run AllArguments, 0
	Set WinScriptHost = Nothing

	WScript.Echo "daemonize.vbs: executed command: " & AllArguments
else
	WScript.Echo "daemonize.vbs: not enough arguments"
end if
