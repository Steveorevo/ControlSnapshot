#tag Class
Protected Class App
Inherits Application
	#tag Method, Flags = &h0
		Function ControlSnapshot(theControl as RectControl) As Picture
		  // Locate the parent window
		  Dim winParent As Window
		  winParent = theControl.Window
		  Dim thePicture As new Picture(theControl.Width, theControl.Height, 32)
		  
		  
		  #If TargetWin32 Then
		    
		    // OS level declares
		    Declare Function GetDC Lib "User32" (hWnd As Integer) As Integer
		    Declare Function BitBlt Lib "GDI32" (DCdest As Integer, xDest As Integer, yDest As Integer, nWidth As Integer, nHeight As Integer, _
		    DCdource As Integer, xSource As Integer, ySource As Integer, rasterOp As Integer) As Boolean
		    Declare Function ReleaseDC Lib "User32" (HWND As Integer, DC As Integer) As Integer
		    Const CAPTUREBLT = &h40000000
		    Const SRCCOPY = &HCC0020
		    
		    // OS BitBlt
		    Dim picDC as Integer = GetDC(winParent.Handle)
		    Call BitBlt(thePicture.Graphics.Handle(1), 0, 0, theControl.Width , theControl.Height , picDC,_
		    theControl.Left, theControl.Top, SRCCOPY or CAPTUREBLT)
		    Call ReleaseDC(TheControl.Handle, picDC)
		    
		  #Else
		    
		    // Create temp file
		    Dim myRandom As New Random
		    Dim fiSnapshot as FolderItem
		    Dim myShell as New Shell
		    fiSnapshot =  SpecialFolder.Temporary.Child(App.ExecutableFile.Name + "-" + CStr(myRandom.InRange(0, 99999)) + ".png")
		    
		    // Calculate absolute control position
		    Dim left As String = CStr(winParent.Left + theControl.Left)
		    Dim top As String = CStr(winParent.Top + theControl.Top)
		    Dim height As String  = CStr(theControl.Height)
		    Dim width As String = CStr(theControl.Width)
		    
		    // Use OS' native capture
		    Dim cmd As String
		    #if TargetMacOS then
		      cmd = "screencapture -x -R " + left + "," + top + "," + width + "," + height + " " + fiSnapshot.ShellPath
		    #elseif TargetLinux then
		      cmd = "import -window root -crop " + width + "x" + height + "+" + left + "+" + top + " " + fiSnapshot.ShellPath
		    #endif
		    myShell.Execute cmd
		    
		    // Return the snapshot
		    If fiSnapshot.Exists then
		      thePicture = Picture.Open(fiSnapshot)
		      fiSnapshot.Delete
		    end if
		  #endif
		  Return thePicture
		End Function
	#tag EndMethod


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
