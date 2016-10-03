Rem 
	menu system

	NOTE: Requires geom.bmx

	EXAMPLE:
	
	    Const GAME_WIDTH=640, GAME_HEIGHT=480
		menu:TMenuBar = TMenuBar.Create("MenuBar",0,0,GAME_WIDTH)
		menu.actionCallback = localCallback
		ml:TMenuList = menu.AddMenuList("File","File")
		mi:TMenuItem = ml.AddMenuItem("FileOpen", "Open...")
		mi:TMenuItem = ml.AddMenuItem("FileExit", "Exit")
		
		Function localCallback( mi:TMenuItem )
			Select mi.name$
				Case "FileExit"
					Exit
				Case "FileOpen"
					....
			End Select
		End Function

    MAINLOOP

	    If ( MouseHit(1) ) Then 
	        MENU.Pick(MouseX(), MouseY() ) ' see if user clicked on a menubar item or a menu item
	    EndIf 
	
	    MENU.Draw()
	
    END_MAIN_LOOP
		
End Rem
Const DEFAULT_HMARGIN=8
Const DEFAULT_VMARGIN=8


Type TMenuBar
	Field name$
	Field x#,y#
	Field r,g,b
	Field br, bg, bb
	Field lMenuLists:TList
	Field hmargin,vmargin
	Field w#,h#
	Field sw#,sh#  ' screen width and height
	Field actionCallback( button:TMenuItem )
	
	Function Create:TMenuBar(uname$="MenuBar",ux#=0,uy#=0,uw#=0,uh#=0,uhmargin=DEFAULT_HMARGIN,uvmargin=DEFAULT_VMARGIN)
		Local o:TMenuBar = New TMenuBar
		
		o.Init(uname$,ux#,uy#,uw#,uh#,uhmargin,uvmargin)
		
			
		Return o
		
	End Function
	
	Method Init(uname$="MenuBar",ux#=0,uy#=0,uw#=0,uh#=0,uhmargin=DEFAULT_HMARGIN,uvmargin=DEFAULT_VMARGIN)
		name$ = uname$
		lMenuLists = New TList
		x# = ux#
		y# = uy#
		br = 100
		bg = 100
		bb = 100
		r = 10
		g = 10
		b = 10
		h# = 0
		hmargin = uhmargin
		vmargin = uvmargin
		sw# = uw#
		sh# = TextHeight("TEXT")+vmargin*2
		actionCallback = tmenusActionCallback

	End Method
	
	
	Method AddMenuList:TMenuList(uname$,ulabel$,uhmargin=DEFAULT_HMARGIN,uvmargin=DEFAULT_VMARGIN)
		Local posx#,posy#,lastw#
		
		posx# = x#
		posy# = y#
		
		For Local ml:TMenuList = EachIn lMenuLists
			posx# = Max(posx#,ml.x#)
			lastw# = ml.sw#
		Next

		posx# :+ lastw#
		
		Local ml:TMenuList = TMenuList.Create(uname$,ulabel$,posx#,posy#,hmargin,vmargin)
		lMenuLists.AddLast( ml )
		ml.br = br
		ml.bg = bg
		ml.bb = bb

		h# = Max(h#,ml.h#)
		
		Return ml
		
	End Method
	
	Method GetHeight:Float()
		Return sh#
	End Method
	

	Method DrawBar()
		SetColor br,bg,bb
		DrawRect x#,y#,sw#,sh#
		
		'Print "drawbar sw="+sw#
	End Method
		
	Method Draw()
		Local mx#=MouseX()
		Local my#=MouseY()
		
		SetAlpha 1.0
		
		DrawBar()
		
		For Local ml:TMenuList = EachIn lMenuLists

			Local highlight = isPointInRect(mx#, my#, ml.x#, ml.y#, ml.sw#, ml.sh# )

			ml.Draw(highlight)

		Next
		
	End Method
	
	Method isAMenuActive:Int()
		Local isActive:Int = False
	
	    For Local ml:TMenuList = EachIn lMenuLists
	        If ml.visible Then isActive = True
		Next
		
		Return isActive
		
	End Method
	
	Method Pick:Int (mx#,my#)
	
		Local didpick:Int = 0
			
		For Local ml:TMenuList = EachIn lMenuLists
			
			'Print "menu "+ml.name$+" w is "+ml.sw#+" and x is "+ml.x#
			
			If isPointInRect(mx#, my#,  ml.x#, ml.y#, ml.sw#, ml.sh# ) Then
				If ml.visible Then
					ml.visible = False
				Else
					ml.visible = True
					
					didpick = True 
				
					' close all the other open menus
					
					For Local oml:TMenuList = EachIn lMenuLists
						If oml <> ml Then
							oml.visible = False
						EndIf
					Next
					
				EndIf
			Else
				' not clicked in a menubar menu text ( but maybe we clicked on a menulist item button)
				
				If ml.visible Then 
					For Local mi:TMenuItem = EachIn ml.lMenuItems
	
						If isPointInRect(mx#,my#,  mi.x#, mi.y#, mi.w#, mi.h# ) Then
							didpick = True
							actionCallback(mi)
						EndIf

						ml.visible = False ' close the menus

					Next
				EndIf
				
			EndIf

		Next

		Return (didpick)
		
	End Method
	
	
End Type

Type TMenuList
	Field name$
	Field label$
	Field lMenuItems:TList
	Field visible
	Field x#,y#
	Field w#,h#
	Field sw#,sh# ' height to be shown for the menu TEXT item label
	Field vmargin,hmargin
	Field br,bg,bb
	Field r,g,b ' text color
	Field drawMenuBorder
	
	Function Create:TMenuList(uname$,ulabel$,ux#,uy#,uhmargin=DEFAULT_HMARGIN,uvmargin=DEFAULT_VMARGIN)
		Local o:TMenuList = New TMenuList
		o.Init(uname$,ulabel$,ux#,uy#,uhmargin,uvmargin)
		Return o
	End Function
	
	Method Init(uname$,ulabel$,ux#,uy#,uhmargin=DEFAULT_HMARGIN,uvmargin=DEFAULT_VMARGIN)
		x# = ux#
		y# = uy#
		r = 10      ' text color (foreground)
		g = 10
		b = 10
		br = 100 ' background color
		bg = 100
		bb = 100
		w# = 0
		h# = 0
		vmargin = uvmargin
		hmargin = uhmargin
		drawMenuBorder = False

		sh# = TextHeight(ulabel$)+vmargin*2
		sw# = TextWidth(ulabel$)+hmargin*2
		w# = sw#
		
		visible = False
		
		name$ = uname$
		label$ = ulabel$
		lMenuItems = New TList 
	
	End Method
	
	
	Method addX(space#)
		
		x# :+ space#
		
		' adjust all the menu items's x location
		For Local mi:TMenuItem = EachIn lMenuItems
			mi.x# = x#
		Next
		
	End Method
	
	Method AddItem:TMenuItem(uname$,ulabel$)
		Local posx#,posy#

		posx# = x#
		posy# = y# + h#

		Local newItem:TMenuItem = TMenuItem.Create(uname$,ulabel$,posx#,posy#+sh#, hmargin, vmargin)
		
		lMenuItems.AddLast( newItem )
		
		h# = posy# + newItem.h#

		w# = Max(w#, newItem.w)
		
		For Local mi:TMenuItem = EachIn lMenuItems
			mi.w# = w#
		Next
		
		
	End Method
	
	Method DrawLabel(highlight)
		Local ox#=1
		Local oy#=1
		
		If ( drawMenuBorder ) Then 
			SetColor 255,255,255
			DrawRect x#,y#,sw#,sh#
		Else
			ox# = 0
			oy# = 0
		EndIf
		
		
		SetColor br,bg,bb
		DrawRect x#+ox#,y#+oy#,sw#-ox#*2,sh#-oy#*2
		
		SetColor r,g,b
		DrawText label$,x#+hmargin,y#+vmargin
		
		If ( highlight ) Then

			Local oldBlend = GetBlend() 		
			SetColor 0,100,200
		    SetBlend ALPHABLEND
			SetAlpha 0.6
			DrawRect x#,y#,sw#,sh#
			SetAlpha 1.0
			SetBlend oldBlend

		EndIf
		
		
	End Method
	
	
	Method DrawItems()
	
		If lMenuItems.Count() > 0 Then 
			If visible Then
			
				SetColor br,bg,bb
				DrawRect x#,y#+sh#,w#,h# ' draw menu rectangle that holds all items
				
				For Local mi:TMenuItem =EachIn lMenuItems
					mi.Draw()
				Next
			EndIf
		EndIf
		
	End Method

	Method Draw(highlight)
		DrawLabel(highlight)
		DrawItems()
	End Method	
	
End Type

Type TMenuItem
	Field name$
	Field visible
	Field x#,y# ' relative to it's parent
	Field w#,h#
	Field label$
	Field r,g,b ' text color
	Field br,bg,bb
	Field vmargin
	Field hmargin
		
	Function Create:TMenuItem(uname$,ulabel$,ux#,uy#,uhmargin,uvmargin)
		Local o:TMenuItem = New TMenuItem
		o.name$ = uname$
		o.label$ = ulabel$
		o.vmargin = uvmargin
		o.hmargin = uhmargin
		o.x# = ux#
		o.y# = uy#
		o.visible = True
		o.r = 20
		o.g = 20
		o.b = 20
		o.br = 150
		o.bg = 150
		o.bb = 150
		o.w# = TextWidth(ulabel$)+o.hmargin*2
		o.h# = TextHeight(ulabel$)+o.vmargin*2
		Return o
	End Function
	
	Method Draw()
		If visible Then

			SetColor 255,255,255
			DrawRect x#,y#,w#,h# ' draw outline
			
			SetColor br,bg,bb
			DrawRect x#+1,y#+1,w#-2,h#-2 ' draw background
			
			SetColor r,g,b
			DrawText label$,x#+hmargin,y#+vmargin
		EndIf
	End Method
	
End Type

Function tmenusActionCallback( mi:tMenuItem  )

	Print "PlaceHolder MenuItem actionCallback : " + mi.name$
	
End Function

