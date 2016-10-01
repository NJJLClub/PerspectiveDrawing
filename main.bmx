Rem 

PERSEPECTIVE DRAWING TOOL


DATE:  9/28/2016 12:52AM

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

Const M_START_LINE=0, M_TO_PREV_LINE=1, M_DELETE=2,  M_MENU_PICK=3
Const M_NO_SNAP=False, M_SNAP_GRID=True

Const K_CONSTRAINT_X=1, K_CONSTRAINT_Y=2, K_CONSTRAINT_XY=3



Global mode:Int = M_START_LINE


Type coord
	Field x:Float
	Field y:Float
End Type

Global startPt:coord = New coord;
Global rawPt:coord = New coord;
Global gridPt:coord = New coord;

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
		
		
		'SetLineWidth 1.0
		
		
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
	Global wiremode = K_CONSTRAINT_XY			' start off with freely drawing lines anywhere

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
		Local filename$ = "unnamed.txt"
		
		'' TBD
		
	End Function
	
		
		
	Function drawGrid()
	
		If ( snapgrid ) Then
			SetColor 30,30,30
		Else
			SetColor 0,0,30
		EndIf
		
		
	
		For Local i=0 To SCREEN_WIDTH Step K_SNAP
			DrawLine i,0,i,SCREEN_HEIGHT
		Next
		For Local i=0 To SCREEN_HEIGHT Step K_SNAP
			DrawLine 0,i,SCREEN_WIDTH,i
		Next
		
	
	
	End Function
	
	
	Function drawDirections()
	
		Local img1:TImage = LoadImage("directions.png")
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


AppTitle$ = "PERSPECTIVE DRAWING"
Graphics SCREEN_WIDTH,SCREEN_HEIGHT,DEPTH  ' this sets the size of the graphics window
HideMouse 
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
      mi:TMenuItem = ml.AddItem("FileSave", "Save...")
      mi:TMenuItem = ml.AddItem("FileExit", "Exit")

Function localCallback( mi:TMenuItem )
	Select mi.name$
		Case "FileExit"
			End
		Case "FileOpen"
			End
		Case "FileSave"
			gameObject.save()
			
	End Select
End Function
		

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
	
		gameObject.drawDirections()
		Flip
		
	
		If KeyHit(KEY_SPACE) Then
			gameObject.showDirections = False
		EndIf
		
		Continue
	EndIf

	gameObject.drawGrid()	  ' We draw the grid first so it does not cover any other graphical elements		
	
	Local mouse_x = MouseX()  ' Determine where the user's mouse is on the screen
	Local mouse_y = MouseY()
	
	If ( KeyHit( KEY_G ) ) Then
		gameObject.snapgrid = Not gameObject.snapgrid ' toggle grid mode
	EndIf
	
	'+
	'  We allow the user to draw directly along the line from his
	'  first click point to the selected vanishing point. The user
	'  can change the selected vanishing point with keybindings as
	'  described in the help section.
	'-
	If ( KeyDown(KEY_LSHIFT) And vanishingPoint.Count()>0) Then
		
		gameObject.drawx( mouse_x, mouse_y ) ' draw an X where the current mouse is positioned - it's helpful feedback to the user
		
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
			mouse_x = location.x
			mouse_y = location.y

			gameObject.drawBigCross( mouse_x, mouse_y )
			
			gameObject.snapgrid = M_NO_SNAP	' turn off grid snapping when in this mode
			gameObject.wiremode = K_CONSTRAINT_XY
	
		EndIf
		
	Else
	
		If ( gameObject.snapgrid = M_SNAP_GRID ) Then
			mouse_x = snapX( mouse_x )
			mouse_y = snapY( mouse_y )
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
	

	'+
	'  Perform the Undo Action
	'-

	If KeyHit(KEY_Z) And ( KeyDown(KEY_LCONTROL) Or KeyDown(KEY_RCONTROL))  Then
		' undo
		Local prevPt:coord = New coord
		
		prevPt = segmentObj.undo()
		If ( prevPt ) Then
			startPt = prevPt
		Else			
			mode = M_START_LINE  ' when there are no more previous segments, then go back into START LINE mode
		EndIf
		
		
	EndIf

	
	If ( mode = M_START_LINE ) Then

		'+
		'  You can only drop down a vanishing point marker while in the START LINE mode
		'-
		If KeyHit(KEY_V) Then
			vanishingPoint.deselect()  ' de-select the currently selected point 
			Local vp:vanishingPoint = vanishingPoint.Create( mouse_x, mouse_y ) ' creating a new point also selects it
		EndIf

	EndIf
	
	'+
	'  did the user CLICK his MB1 mouse button? If so then do some action based on
	'  which command the user is in.
	'-
	
	If MouseHit( 1) Then

		Local oldmode = mode

	    MENU.Pick(MouseX(), MouseY() )  ' see if the user has clicked in the MENU BAR area or on any drop-down menus from the menu bar
	
		' since we have a menubar present ; we need to change mode to menu pick if the mouseY < menubar height
		If ( MouseY() < MENU.getHeight() ) Then 
			'+
			'  by switching to some unhandled mode (ie. M_MENU_PICK) we can bypass any action
			'  that would normally take place due to a mouse click operation
			'-
			mode = M_MENU_PICK
		EndIf
	
		Select mode
			Case M_START_LINE
				rawPt.x = MouseX()
				rawPt.y = MouseY()
				gridPt.x =snapX( rawPt.x )
				gridPt.y = snapY( rawPt.y )
				startPt = rawPt
				
				If ( gameObject.snapgrid = M_SNAP_GRID ) Then
					startPt = gridPt
				EndIf
								
				mode = M_TO_PREV_LINE
				
			Case M_TO_PREV_LINE

				If ( gameObject.wiremode = K_CONSTRAINT_X ) Then
					mouse_y = startPt.y
				ElseIf ( gameObject.wiremode = K_CONSTRAINT_Y ) Then
					mouse_x = startPt.x
				EndIf


				If ( gameObject.snapgrid = M_SNAP_GRID ) Then
					segmentObj.Create4(  startPt.x , startPt.y, snapX(mouse_x), snapY( mouse_y) )
				Else
					segmentObj.Create4(  startPt.x , startPt.y, mouse_x, mouse_y )
				EndIf

				
	
				rawPt.x = mouse_x
				rawPt.y = mouse_y
				gridPt.x =snapX( rawPt.x )
				gridPt.y = snapY( rawPt.y )
				startPt = rawPt
				If ( gameObject.snapgrid = M_SNAP_GRID ) Then
					startPt = gridPt
				EndIf
			
			Case M_DELETE
				gameObject.smartDeleteSegment( mouse_x, mouse_y)		
				
			Case M_MENU_PICK 
				mode = oldmode  ' restore command mode to what it was before MENU took it over
				
			 
		End Select

		
		
	EndIf
	
	If ( mode = M_TO_PREV_LINE ) Then
	
		SetLineWidth 1.0
		
		If ( gameObject.wiremode = K_CONSTRAINT_X ) Then
			mouse_y = startPt.y
		ElseIf ( gameObject.wiremode = K_CONSTRAINT_Y ) Then
			mouse_x = startPt.x
		EndIf
		
		gameObject.drawBigCross( mouse_x, mouse_y)

		vanishingPoint.drawAllTo( startPt.x, startPt.y )
	
		SetColor 255,255,255
		
		If ( gameObject.snapgrid = M_SNAP_GRID ) Then
			DrawLine startPt.x, startPt.y, snapX( mouse_x),  snapY( mouse_y)
		Else
			DrawLine startPt.x, startPt.y, mouse_x, mouse_y
		EndIf
		

	EndIf

	'+
	'   Toggle various wire modes
	'-
		
	If KeyHit(KEY_W) Then
	
		Select gameObject.wiremode
			Case K_CONSTRAINT_X
				gameObject.wiremode =  K_CONSTRAINT_Y
			Case K_CONSTRAINT_Y
				gameObject.wiremode = K_CONSTRAINT_XY
			Case K_CONSTRAINT_XY
				gameObject.wiremode = K_CONSTRAINT_X
		End Select
		
	EndIf
	
	
	If KeyHit(KEY_DELETE) Then
		mode = M_DELETE
	EndIf
	
	
	If MouseHit(2) Then
		mode = M_START_LINE
		gameObject.wiremode = K_CONSTRAINT_XY
	ElseIf KeyHit(KEY_ESCAPE)
		mode = M_START_LINE
	EndIf
	
		
	vanishingPoint.drawAll()
	segmentObj.drawAll()
	MENU.Draw()
	
	
	' draw mouse cursor to indicate mode of operation
		
	SetLineWidth 4.0
	If ( mode = M_DELETE ) Then
		gameObject.drawDeleteCursor( mouse_x, mouse_y)

	ElseIf ( mode = M_START_LINE )
		gameObject.drawXcursor( mouse_x, mouse_y)
	ElseIf ( mode = M_TO_PREV_LINE )

	EndIf
	
	SetLineWidth 1.0
	
	
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





