Rem

	Label object - draws text within a rect area
	Button object - draws a label and adds an activate button
	
End Rem


Type tLabel
	Field name$
	Field x,y
	Field label$
	Field w,h
	Field margin
	Field outline ' thickness of outline
	Field fg:RGB
	Field bg:RGB
	Field ol:RGB  ' outline color
	
	Function Create:tLabel(uname$="",ulabel$="", ux=0, uy=0)
		Local o:tLabel = New tLabel
		o.Init( uname$, ulabel$, ux, uy )
		Return o
	End Function
	
	
	Method Init( uname$, ulabel$, ux, uy)
		
		x = ux
		y = uy
				
		name$ = uname$
		label$ = ulabel$
		margin = 2
		outline = 2
		
		fg = New RGB
		bg = New RGB
		ol = New RGB
		
		ol.r = 0
		ol.g = 0
		ol.b = 0
		
		fg.r = 0
		fg.g = 0
		fg.b = 0
		
		bg.r = 200
		bg.g = 200
		bg.b = 200
		
		Self.SetLabel( ulabel$ )
		
	End Method
	
	Method SetLabel( ulabel$ )
		
		label$ = ulabel$
		w = TextWidth(label$)
		h = TextHeight(label$)
		
		
	End Method
	
	
	Method Draw()
	
		If outline > 0 Then 
			CSetColor ol
			DrawRect x - outline - margin, y - outline - margin,w + outline*2 + margin*2,h + outline*2 + margin*2
		EndIf

		' draw background + margin
		CSetColor bg
		DrawRect x - margin,y-margin,w+margin*2,h+margin*2
		
		' draw text
		CSetColor fg
		DrawText label$,x,y
		
	End Method
	
End Type


Type tFlow
	Method Activate( label$, udata$)		
	End Method
End Type


Type tButton Extends tLabel
	Field flow:tFlow
	Field userdata$

	Function Create:tButton(uname$="",ulabel$="", ux=0, uy=0)
		Local o:tButton = New tButton
		o.Init( uname$, ulabel$, ux, uy )
		Return o
	End Function
	
	Method SetLabel(ulabel$)
		
		Super.SetLabel(ulabel$)
	End Method
	
	Method Init(uname$,ulabel$,ux,uy)
		
		Super.Init(uname$,ulabel$,ux,uy)
		flow = Null
		userdata$ = ""
	End Method

	Method Activate()
		If flow<>Null Then
			flow.Activate(name$,userdata$)
		Else
		    Print "You Activated "+label$+" button!"
		EndIf
	End Method
	
	Method Update(buttonHit)
		If buttonHit And isPointInRect( MouseX(),MouseY(), x,y,w,h ) Then
			Activate()
		EndIf
	End Method
	
	Method Draw()
		Super.Draw()
		' if mouse x,y is inside button then highlight button
		If isPointInRect( MouseX(),MouseY(), x,y,w,h ) Then
			Local oldBlend = GetBlend()
			SetColor 0,200,200
			SetAlpha 0.6
			SetBlend ALPHABLEND
			DrawRect x,y,w,h
			SetAlpha 1.0
			SetBlend oldBlend
			SetColor 255,255,255
		EndIf
		
	End Method
	
End Type
