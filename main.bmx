Rem 

PERSEPECTIVE DRAWING TOOL

DATE:  9/28/2016 12:52AM

AUTHOR: James Laderoute (JJL)

HISTORY:

001		09/28/16		JJL
		Initial Creation
		
002		10/02/16		JJL
		Gravity snap points added


TASKS:

o need to write the SHIFT snap to vanishing point code ( 10/01/2016 Done )
o vertical and horizontal mode ( 10/1/2016 Done )

o need to write SAVE code (you can use snipping tool for now) ( 10/01/2016 Started )
o need to create REDO code (low priority)
o need to add directions at the beginning

known bugs

o need to clear KEY entry cache when switching modes so we don't get funny/odd things happening


EndRem

Strict ' This prevents us from using mispelled variables by accident, very helpful

Include "geom.bmx"
Include "color.bmx"
Include "tlabel.bmx"
Include "tmenus.bmx"



'Const SCREEN_WIDTH = 1366,SCREEN_HEIGHT = 768, DEPTH = 32
Const SCREEN_WIDTH = 1200,SCREEN_HEIGHT = 800, DEPTH = 0
Const OBJECT_WIDTH=10, OBJECT_HEIGHT=10

Const K_SNAP=20

Const M_START_LINE=0, M_END_LINE=1, M_DELETE=2,  M_MENU_PICK=3
Const M_NO_SNAP=False, M_SNAP_GRID=True

Const K_CONSTRAINT_X=1, K_CONSTRAINT_Y=2, K_CONSTRAINT_XY=3
Const K_DIAGONALS=1, K_CONSTRAIN=2
Global mode:Int = M_START_LINE


Type coord
	Field x:Float
	Field y:Float
End Type

Global startPt:coord = New coord;
Global onlinePt:coord = New coord;
Global rawPt:coord = New coord;
Global gridPt:coord = New coord;
Global nearPt:coord = New coord
Global GmouseNearEndPoint = False
Global GonLinePoint = False


Type vanishingPoint
	Global list:TList = New TList
	Field x:Float, y:Float
	Field selected:Int 
	
	Function Create:vanishingPoint( ux:Float , uy:Float )
		Local v:vanishingPoint = New vanishingPoint
		v.x = ux
		v.y = uy
		v.selected = True 
		list.AddLast(v)
		Return(v)
		
	End Function

	Function getSelected:vanishingPoint()
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			If ( o.selected ) Return o
		Next
		
		Return Null
				
	End Function	
	
	Function getSelectedX:Float()
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			If ( o.selected ) Return o.x
		Next
		
		Return SCREEN_WIDTH/2
		
	End Function

	Function getSelectedY:Float()
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			If ( o.selected ) Return o.y
		Next
		
		Return SCREEN_HEIGHT/2
		
	End Function
		
	Function drawAll()
	
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			o.draw()
		Next
	End Function
	
	Function drawAllTo( x:Float, y:Float )

		SetColor 50,50,50
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			o.drawTo(x,y)
		Next
		

	End Function
	
	Function nearest:vanishingPoint( ux:Float, uy:Float )
		Local nearestObj:vanishingPoint = Null
		Local nearestDist:Float = 1000000000
		
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			Local dx:Float = o.x - ux
			Local dy:Float = o.y - uy
			
			Local dist:Float = Sqr( dx^2 + dy^2 )
			If ( dist < nearestDist ) Then
				nearestDist = dist
				nearestObj = o
			EndIf
			
		Next
		
		Return nearestObj
		
	End Function
	
	Rem 
		nearestEdge ; this will take your mouse point ux,uy and 
		the starting click to determine the line-segment that 
		represents the line between the starting point and the
		vanishing point and then determines which of the many 
		vanishing points your mouse is closest too and returns
		that object.
		
	End Rem
	
	Function nearestEdge:vanishingPoint( ux:Float, uy:Float, sx:Float, sy:Float)

		Local smallest:Float = 100000000
		Local nearestObj:vanishingPoint = Null
		
		
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			Local dist:Float = getPerpDistance:Float ( ux, uy, sx, sy, o.x, o.y )
			If ( dist < smallest ) Then
				smallest = dist
				nearestObj = o
			EndIf
			
		Next
			
		Return nearestObj

	
	End Function
	
	
	
	Function Count:Int()
		Local counter:Int = 0
		
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			counter = counter + 1
		Next
		
		Return counter
	End Function
	
	Function removeAll()
		list.clear()
	End Function
	
	Function write( fid:TStream )
	
		For Local obj:vanishingPoint = EachIn list
			WriteLine fid,"V "+obj.x+" "+obj.y
		Next
		
	End Function
	
	
	Function remove(  obj:vanishingPoint )
		ListRemove( list, obj )
	End Function
	
		
	Function deselect()
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			o.selected = False
		Next
		
	End Function
	
	Function selectNext()
		Local grabNext = False
		Local haveSelect = False
		
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			If ( o.selected ) Then 
				grabNext=True
				o.selected = False
			ElseIf ( grabNext ) Then
				o.selected = True
				grabNext = False
				haveSelect = True
				Exit 
			EndIf
			
			
		Next
		
		If ( Not haveSelect ) Then
			Local o:vanishingPoint = vanishingPoint( vanishingPoint.list.First() )
			If ( o  ) Then o.selected = True
		EndIf
		
	End Function
	
	Function selectPrev()
		Local previous:vanishingPoint = Null
		
		For Local o:vanishingPoint = EachIn vanishingPoint.list
			If ( o.selected ) Then
				o.selected = False
				Exit 
			Else
				previous = o
			EndIf			
			
		Next
		
		If (  previous = Null  ) Then
			Local o:vanishingPoint = vanishingPoint( vanishingPoint.list.Last() )
			If ( o  ) Then o.selected = True
		Else
			previous.selected = True
		EndIf
		
	End Function
		
	Method draw()
		' draw anchor point of the vanishing point
	
		Local icon=1  ' 0=upside down V;  1= draw an X

		'SetColor 0,0,10
		'DrawLine( 0, y, SCREEN_WIDTH, y)
		
        ' draw vanishing point

		SetColor 0,0,255
		
		If ( selected ) SetColor 0,255,0
		
		Select icon
			Case 0
				DrawLine( x, y, x - 5, y + 5)
				DrawLine( x, y, x + 5, y + 5)
				
			Case 1
				DrawLine( x-5, y-5, x+5, y+5)
				DrawLine( x+5, y-5, x-5, y+5)
				
		End Select

		
		
	End Method

	Method drawTo( tx:Float, ty:Float )

		Local a:Float = ATan2( ty-y, x - tx )
		Local xx:Float, yy:Float
		Local radius:Float = 1000
		
		xx = x - Cos(a) * radius
		yy = y + Sin(a) * radius
		
		DrawLine( x, y, xx, yy )
		
		
		
	End Method
			
End Type


Type segmentObj
	Global list:TList = New TList
	Global lastNear:Float
	Field x0:Float, y0:Float
	Field x1:Float, y1:Float

	
	Function Create4:segmentObj( ux:Float , uy:Float , ex:Float, ey:Float)
		Local v:segmentObj= New segmentObj
		v.x0 = ux
		v.y0 = uy
		
		v.x1 = ex
		v.y1 = ey
		
		list.AddLast(v)
		Return(v)
		
	End Function
	
	Function write( fid:TStream )
	
		For Local obj:segmentObj = EachIn list
			WriteLine fid,"L "+obj.x0+" "+obj.y0+" "+obj.x1+" "+obj.y1
		Next
		
	End Function
	
	
	Function nearestLineSegment:segmentObj( ux:Float, uy:Float )
		
		Local near:Float = 10000000
		Local nearObj:segmentObj = Null
		
		
		For Local obj:segmentObj = EachIn segmentObj.list
		
			Local d:Float = getPerpDistance( ux, uy, obj.x0, obj.y0, obj.x1, obj.y1 )
			If ( Abs( d ) < Abs( near ) ) Then
				near = d
				nearObj = obj
			EndIf
		
		Next
		
		lastNear = near ' save this distance
		
		Return  nearObj
				
	End Function
	
	Function removeAll()
	
		list.Clear()
		
	End Function
	
	
	Function remove(  obj:segmentObj)
		ListRemove( list, obj )
	End Function
	
	Function drawAll()
	
		SetColor 0,255,0
		For Local o:segmentObj= EachIn segmentObj.list
			o.draw()
		Next
	End Function
	
	Function undo:coord()
	
		Local prev:coord = New coord
		Local last:segmentObj = New segmentObj
		
		If ( Not segmentObj.list.IsEmpty() ) Then
		
			last = segmentObj( segmentObj.list.Last() )
			
			If ( last  ) Then
			
				prev.x = last.x0
				prev.y = last.y0
				
				list.RemoveLast()
			
			EndIf 
			
		Else
			prev = Null
		EndIf
		
		
		
		Return( prev)
		
	End Function
	
	
	
	Method draw()
	
		DrawLine( x0, y0, x1, y1)
	
	End Method
		
End Type

Type gameObject
	Global showDirections = True 				' flag to show directions on screen		
	Global snapgrid = M_NO_SNAP					' snap to grid or not (boolean)
	Global constraint = K_CONSTRAINT_XY			' start off with freely drawing lines anywhere
	Global linemode = K_DIAGONALS				' or K_CONSTRAIN
	Global filename$ = "unnamed.vpd"

	Function drawBigCross( x:Float, y:Float)
		Local size:Int = 2000
		SetColor 100,100,0
		DrawLine x,y-size,x,y+size
		DrawLine x-size,y,x+size,y
	End Function
	
	Function drawX( x:Float, y:Float )
	
		SetColor 0,200,0
		DrawLine x-10,y-10,x+10,y+10
		DrawLine x+10,y-10,x-10,y+10
		
	End Function
	
	Function drawDeleteCursor( x:Float, y:Float )
	
		SetColor 255,0,0
		Local size:Int = 8
		DrawLine x-size, y-size, x+size, y+size
		DrawLine x+size, y-size, x-size, y+size
	
	End Function
		
	Function drawXcursor( x:Float, y:Float)
		SetColor 0,255,0
		Local size:Int = 8
		DrawLine x, y-size, x, y+size
		DrawLine x+size, y, x-size, y
	End Function
		
	'+
	'   Save the drawing to a file
	'-
	Function save()
		If ( filename$ = "" ) Then Return
		
		Local fid:TStream = WriteFile( filename$  )
		If Not fid RuntimeError "could not create file "+filename$

        SetWindowTitle( filename$ )
		
		WriteLine fid, "# Perspective Drawing File"
		WriteLine fid, "#"
		
		segmentObj.write( fid )
		vanishingPoint.write( fid )
		
				
		If ( fid ) Then CloseStream( fid )

	End Function
	
	Function read()
		If ( filename$ = "" ) Then Return
        SetWindowTitle( filename$ )
		
		Local line:String
		Local x0#, y0#, x1#, y1#
		Local fid:TStream = ReadFile( filename$ )
		Local first:vanishingPoint = Null 
		
		
		If ( fid ) Then
			segmentObj.removeAll()
			vanishingPoint.removeAll()
		EndIf
		
		While Not Eof(fid)
			Local line$ = ReadLine(fid)
			'L x0 y0 x1 y1
			 Local parts$[] = line.split(" ")
			Select parts$[0]
				Case "L"
					x0# = Float(parts$[1])
					y0# = Float(parts$[2])
					x1# = Float(parts$[3])
					y1# = Float(parts$[4])
					
					Local s:segmentObj = segmentObj.Create4( x0#, y0#, x1#, y1#)
					
				Case "V"
					x0# = Float(parts$[1])
					y0# = Float(parts$[2])
					Local v:vanishingPoint = vanishingPoint.Create( x0#, y0# )
					v.selected = False
					If ( first = Null ) Then first = v
					
					
			End Select
			
			
		Wend
		
		If ( first ) Then first.selected = True
		
		
		
	End Function
	
		
		
	Function drawGrid()
	
		SetColor 30,30,30
	
		For Local i=0 To SCREEN_WIDTH Step K_SNAP
			DrawLine i,0,i,SCREEN_HEIGHT
		Next
		For Local i=0 To SCREEN_HEIGHT Step K_SNAP
			DrawLine 0,i,SCREEN_WIDTH,i
		Next
		
	End Function
	
	
	Function drawDirections()
	
		Local img1:TImage = LoadImage("media/directions.jpg")
		If ( img1 ) Then
			DrawImage( img1, 0, 0 )
		Else
			SetColor 255,255,255
			Local note$ = "Unable to find directions.png file - please fix - press SPACE to continue"
			DrawText note$, SCREEN_WIDTH/2 - TextWidth(note$)/2, SCREEN_HEIGHT/2
		EndIf
		
	End Function
	
	
	Function smartDeleteSegment( x:Float, y:Float)
	
		
		Local isegment:segmentObj = segmentObj.nearestLineSegment( x, y)
		Local ipoint:vanishingPoint = vanishingPoint.nearest(x , y)
		
		If ( ipoint And isegment) Then
			Local dx:Float = ipoint.x - x
			Local dy:Float = ipoint.y - y
			Local d:Float = Sqr( dx^2 + dy^2 )
			If ( segmentObj.lastNear < d ) Then
				ipoint = Null 
			Else
				isegment = Null
			EndIf
			
			
		EndIf
		
		
		If ( isegment ) Then segmentObj.remove( isegment )
		If ( ipoint ) Then vanishingPoint.remove( ipoint )
		
		
		
	End Function


End Type

Rem
	SETUP GRAPHICS
	This section of the code sets up the graphics system.
	=============================================================================
EndRem


AppTitle$ = "PERSPECTIVE DRAWING: unnamed.vpd"
Graphics SCREEN_WIDTH,SCREEN_HEIGHT,DEPTH  ' this sets the size of the graphics window
 
SetMaskColor 0,0,0	' which color we will use for our mask layer (transparent layer)
SeedRnd MilliSecs()
SetBlend MASKBLEND

Rem
	Create the Menu Bar and Menu Buttons
	=============================================================================
End Rem


Local menu:TMenuBar = TMenuBar.Create("MenuBar",0,0,SCREEN_WIDTH)
menu.actionCallback = localCallback
Local ml:TMenuList = menu.AddMenuList("File","File")
Local mi:TMenuItem = ml.AddItem("FileOpen", "Open...")
      mi:TMenuItem = ml.AddItem("FileSave", "Save")
      mi:TMenuItem = ml.AddItem("FileSaveAs", "Save As...")
      mi:TMenuItem = ml.AddItem("FileExit", "Exit")

Function localCallback( mi:TMenuItem )
	Select mi.name$
		Case "FileExit"
			gameObject.save()
			End
			
		Case "FileOpen"
			Local filter$ = "Vansishing Point Files:vpd,txt"
			gameObject.filename$ = RequestFile( "Select vpd file to open", filter$ )		
			gameObject.read()
			
		Case "FileSave"
			If ( gameObject.filename$ = "" ) Then
				Local filter$ = "Vansishing Point Files:vpd,txt"
			    gameObject.filename$ = RequestFile( "Select vpd file to save", filter$, True )			
			EndIf
			
			gameObject.save()
			
		Case "FileSaveAs"

			Local filter$ = "Vansishing Point Files:vpd,txt"
			gameObject.filename$ = RequestFile( "Select vpd file to save", filter$, True )					
			gameObject.save()
	End Select
	
End Function
		
Type mainFlow Extends tFlow
	Method Activate( label$, udata$)
		Select label$
			Case "Start"
				gameObject.showDirections = False
				HideMouse
		End Select
	End Method
End Type

		
' Create a START button to begin the application
Global startBtn:tButton = tButton.Create( "Start", "Start", SCREEN_WIDTH/2, SCREEN_HEIGHT - 50)

startBtn.flow = New mainFlow



Rem
	This is the main loop that does all the work and interactions with the user.
	===============================================================================
EndRem


#MAIN_LOOP
While Not (  AppTerminate() )

	Cls

	' When starting, we show the directions to the user before
	' starting. This shows the keybindings that can be used and
	' how the mouse clicks are used.
	'
	If gameObject.showDirections Then
	
		SetColor 255,255,255
		
		If ( MouseHit(1) ) Then startBtn.Update(1)
	
		gameObject.drawDirections()
		
		startBtn.Draw()  ' we have to draw the button last or else the directions screen would cover this button
			
		Flip
		
	
		If KeyHit(KEY_SPACE) Then
			gameObject.showDirections = False
			HideMouse
		EndIf
		
		Continue
	EndIf

	gameObject.drawGrid()	  ' We draw the grid first so it does not cover any other graphical elements		
	
	Rem
		Now get the current coordinate of the user's mouse
		
		And setup rawPt , gridPt and nearPt
		
	EndRem
	
	Local mouse_x = MouseX()  ' Determine where the user's mouse is on the screen
	Local mouse_y = MouseY()
	
	rawPt.x = mouse_x			' rawPt is the actual mouse location
	rawPt.y = mouse_y
	
	gridPt.x = snapX( rawPt.x  )		' gridPt is the raw point snapped to our grid system
	gridPt.y = snapY( rawPt.y )
			

	Local s1:segmentObj = segmentObj.nearestLineSegment( mouse_x, mouse_y )
	GmouseNearEndPoint = False
	
	If ( s1 ) Then
		If ( isNear( rawPt.x, rawPt.y, s1.x0#, s1.y0# , 5.0 ) ) Then
			nearPt.x = s1.x0#
			nearPt.y = s1.y0#
			GmouseNearEndPoint = True
			
		ElseIf isNear( rawPt.x, rawPt.y, s1.x1#, s1.y1#, 5.0)
			nearPt.x = s1.x1#
			nearPt.y = s1.y1#
			GmouseNearEndPoint = True
		EndIf
		
	EndIf
	
	If ( GmouseNearEndPoint And KeyDown( KEY_Z) ) Then 
		GmouseNearEndPoint = False
	EndIf
	
	
		
	If ( KeyHit( KEY_G ) ) Then
		gameObject.snapgrid = Not gameObject.snapgrid ' toggle grid mode
	EndIf

	GonLinePoint = False

	'+
	'  We allow the user to draw directly along the line from his
	'  first click point to the selected vanishing point. The user
	'  can change the selected vanishing point with keybindings as
	'  described in the help section.
	'-
	
	If ( mode=M_END_LINE And  KeyDown(KEY_LSHIFT) And vanishingPoint.Count()>0) Then
		
		gameObject.drawX( rawPt.x, rawPt.y ) ' draw an X where the current mouse is positioned - it's helpful feedback to the user
		
		' set mouse_x,y at intercept point between user mouse and nearest vanishing point
		
		Local vpoint:vanishingPoint = vanishingPoint.getSelected() ' make sure a selected vanishing point exists first
		If ( vpoint ) Then
			Local dx:Float = startPt.x - vpoint.x
			Local dy:Float = startPt.y - vpoint.y
			Local a:Float = ATan2( dy, dx )
			Local xx0:Float, yy0:Float
			Local xx1:Float, yy1:Float
			Local radius:Float = 2000     ' large number to extend the vanishing line off the screen
			Local x:Float = startPt.x
			Local y:Float = startPt.y
		
			' This code creates the extended line segment coordinates
			
			xx0 = x + Cos(a) * radius
			yy0 = y + Sin(a) * radius
			xx1 = x + Cos(a) * radius * -1
			yy1 = y + Sin(a) * radius * -1
			
			' Now we get the perpendicular intersection point of the vanishing line and use that
			
			Local location:GeomPoint =  getPerpPoint( mouse_x, mouse_y, xx0, yy0, xx1, yy1 )

			onlinePt.x = location.x
			onlinePt.y = location.y
			
			'mouse_x = location.x
			'mouse_y = location.y
			
			GonLinePoint = True
			GmouseNearEndPoint = False ' online over-rules nearest endpoint

			gameObject.drawBigCross( onlinePt.x, onlinePt.y )
			
			gameObject.snapgrid = M_NO_SNAP	' turn off grid snapping when in this mode
			gameObject.constraint = K_CONSTRAINT_XY
	
		EndIf
		
	Else
	
		

	EndIf

	'+
	'   Toggle various wire modes
	'-
		
	If KeyHit(KEY_S) Then
	
		If ( mode = M_END_LINE ) Then 
		
			Select gameObject.linemode
				Case K_CONSTRAIN
					gameObject.linemode =  K_DIAGONALS
				Case K_DIAGONALS
					gameObject.linemode = K_CONSTRAIN
			End Select
		
		EndIf
		
	EndIf


	 
	'+
	'  Allow the user to traverse thru all the vanishing points for choosing the selection
	'-
	If KeyHit(KEY_SPACE) Or KeyHit(KEY_RIGHT) Then
		vanishingPoint.selectNext()
	ElseIf KeyHit(KEY_LEFT) Then
		vanishingPoint.selectPrev()
	EndIf

	
	If KeyHit(KEY_D) Then
		mode = M_DELETE
	EndIf
	

	'+
	'  Perform the Undo Action
	'-

	If KeyHit(KEY_Z) And ( KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL))  Then
		' undo
		Local prevPt:coord = New coord
		
		prevPt = segmentObj.undo()
		If ( prevPt ) Then
			startPt.x = prevPt.x
			startPt.y = prevPt.y
		Else			
			mode = M_START_LINE  ' when there are no more previous segments, then go back into START LINE mode
		EndIf
		
		
	EndIf

	'+
	'  You can only drop down a vanishing point marker while in the START LINE mode
	'-
	If  mode=M_START_LINE And KeyHit(KEY_V) Then
		vanishingPoint.deselect()  ' de-select the currently selected point
		Local usePt:coord = New coord
		

		usePt.x = rawPt.x
		usePt.y = rawPt.y

		If ( gameObject.snapgrid = M_SNAP_GRID ) 
			usePt.x = gridPt.x
			usePt.y = gridPt.y
		EndIf	
				 
		Local vp:vanishingPoint = vanishingPoint.Create( usePt.x, usePt.y ) ' creating a new point also selects it
	EndIf

	'+
	'  did the user CLICK his MB1 mouse button? If so then do some action based on
	'  which command the user is in.
	'-
	
	If MouseHit( 1) Then

		Local oldmode = mode

	    Local didpick = MENU.Pick( rawPt.x, rawPt.y )  ' see if the user has clicked in the MENU BAR area or on any drop-down menus from the menu bar
	
	
		' since we have a menubar present ; we need to change mode to menu pick if the mouseY < menubar height
		If ( ( rawPt.y < MENU.getHeight() ) Or didpick Or MENU.isAMenuActive()  ) Then 
			'+
			'  by switching to some unhandled mode (ie. M_MENU_PICK) we can bypass any action
			'  that would normally take place due to a mouse click operation
			'-
			mode = M_MENU_PICK
		EndIf
	
		Select mode
			Case M_START_LINE
			
				startPt.x = rawPt.x
				startPt.y = rawPt.y
				
				If ( gameObject.snapgrid = M_SNAP_GRID ) Then
					startPt.x = gridPt.x
					startPt.y = gridPt.y
				EndIf
			
				If ( GmouseNearEndPoint ) Then
					startPt.x = nearPt.x
					startPt.y = nearPt.y
				EndIf
									
				mode = M_END_LINE
				
			Case M_END_LINE

				Local endPt:coord = New coord

				If ( gameObject.snapgrid = M_SNAP_GRID ) 
					endPt.x = gridPt.x
					endPt.y = gridPt.y
				Else
					endPt.x = rawPt.x
					endPt.y = rawPt.y
				EndIf

				If ( GmouseNearEndPoint   )
					endPt.x = nearPt.x
					endPt.y = nearPt.y
				ElseIf ( gameObject.linemode = K_CONSTRAIN )
					If Abs( endPt.x - startPt.x ) > Abs( endPt.y - startPt.y) Then
						gameObject.constraint = K_CONSTRAINT_X
						endPt.y = startPt.y
					Else
						gameObject.constraint = K_CONSTRAINT_Y
						endPt.x = startPt.x
					EndIf
					
				EndIf				
		
				If ( GonLinePoint ) Then
					endPt.x = onlinePt.x
					endPt.y = onlinePt.y
				EndIf								
	
				segmentObj.Create4(  startPt.x , startPt.y, endPt.x , endPt.y  )

				startPt.x = endPt.x
				startPt.y = endPt.y
	
			
			Case M_DELETE
				gameObject.smartDeleteSegment(  rawPt.x, rawPt.y )		
				
			Case M_MENU_PICK 
				mode = oldmode  ' restore command mode to what it was before MENU took it over
				
			 
		End Select

		
		
	EndIf
	
	'+
	'   Now we are in a mode where the user has already placed down his first
	'	coordinate of a line segment and possibly others. We want to draw the
	'   dynamic line from the startPt coordinate to the current modified coordinate.
	'   Modified based on gridSnap mode, or nearest point or constraint mode
	'-
	
	
	If ( mode = M_END_LINE And ( rawPt.y > MENU.getHeight()  ) And ( Not MENU.isAMenuActive() )   ) Then

		Local endPt:coord = New coord
		
		If ( gameObject.snapgrid = M_SNAP_GRID ) 
			endPt.x = gridPt.x
			endPt.y = gridPt.y
		Else
			endPt.x = rawPt.x
			endPt.y = rawPt.y
		EndIf
		
		If ( GmouseNearEndPoint   )
			endPt.x = nearPt.x
			endPt.y = nearPt.y
		ElseIf ( gameObject.linemode = K_CONSTRAIN )
			If Abs( endPt.x - startPt.x ) > Abs( endPt.y - startPt.y) Then
				gameObject.constraint = K_CONSTRAINT_X
				endPt.y = startPt.y
			Else
				gameObject.constraint = K_CONSTRAINT_Y
				endPt.x = startPt.x
			EndIf
			
		EndIf	

		If ( GonLinePoint ) Then
			endPt.x = onlinePt.x
			endPt.y = onlinePt.y
		EndIf
				
		gameObject.drawBigCross( endPt.x, endPt.y )
		gameObject.drawX( rawPt.x, rawPt.y )

		vanishingPoint.drawAllTo( startPt.x, startPt.y ) ' show all the vanishing lines available
	
		SetColor 255,255,255		

		DrawLine startPt.x, startPt.y, endPt.x, endPt.y

	EndIf

	
	
	If MouseHit(2) Or KeyHit(KEY_ESCAPE) Then
		mode = M_START_LINE
		gameObject.constraint = K_CONSTRAINT_XY
		gameObject.linemode = K_DIAGONALS
	EndIf
	
		
	vanishingPoint.drawAll()
	segmentObj.drawAll()
	MENU.Draw()
	
	
	' draw mouse cursor to indicate mode of operation

	If ( mode = M_DELETE ) Then
		gameObject.drawDeleteCursor( rawPt.x, rawPt.y)
	ElseIf ( mode = M_START_LINE )
	
		Local endPt:coord = New coord
		
		If ( gameObject.snapgrid = M_SNAP_GRID ) 
			endPt.x = gridPt.x
			endPt.y = gridPt.y
		Else
			endPt.x = rawPt.x
			endPt.y = rawPt.y
		EndIf
		
		If ( GmouseNearEndPoint   )
			endPt.x = nearPt.x
			endPt.y = nearPt.y
		EndIf
		
		
		gameObject.drawXcursor( endPt.x, endPt.y )
		
	ElseIf ( mode = M_END_LINE )
		' draw no cursor
	EndIf
	
	If (  rawPt.y <= MENU.getHeight() Or MENU.isAMenuActive() )
		ShowMouse
	Else
		HideMouse
	EndIf
	
	
	
	Flip 

Wend

End

Function snapX:Float( x:Float )
	Local n:Int  
	
	
	If ( x < 0 ) Then
		n = x - K_SNAP/2
		
	Else
		n = x + K_SNAP/2
	EndIf


	'Print "snapX: " + x + " n is " + n
		
	Return ( Int(n / K_SNAP) * K_SNAP )
	
End Function

Function snapY:Float( y:Float )
	Local n:Int  
	
	If ( y < 0 ) Then
		n = y - K_SNAP/2
	Else
		
		n = y + K_SNAP/2
	EndIf
		
	Return ( Int(n / K_SNAP) * K_SNAP )

End Function


Function SetWindowTitle( title:String)
	Extern "Win32"
		Function SetWindowTextW:Int( handle:Int, text$w)
	EndExtern
	Local hwnd:Int = GetBlitzmaxWindow()
	If hwnd Then
		AppTitle = title
		SetWindowTextW( hwnd, title)	
	EndIf
EndFunction

Function GetBlitzmaxWindow:Int()
?Win32
	Extern "Win32"
		Function FindWindowW:Int( classname$w, windowtitle$w)	
	EndExtern
	Local handle:Int
	handle = FindWindowW( "BBDX9Device Window Class", AppTitle)			' D3D9Max2D
	If Not handle Then handle = FindWindowW( "BlitzMax GLGraphics", AppTitle)	' GLMax2D
	If Not handle Then handle = FindWindowW( "BBDX7Device Window Class", AppTitle)	' D3D7Max2D
	If Not handle Then handle  = FindWindowW( "BLITZMAX_WINDOW_CLASS", AppTitle)	' MaxGUI
	Return handle
?
EndFunction


