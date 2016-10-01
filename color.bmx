Rem 
	color manager
	
End Rem


Type RGB
    Field name$
	Field r,g,b
End Type

Type tColorManager
	Field lcolors:TList
	
	Function Create:tColorManager()
		Local o:tColorManager = New tColorManager
		o.lcolors = New TList
		
		o.add("RED", 255,0,0)
		o.add("DARKRED", 100,0,0)
		
		o.add("GREEN", 0, 255, 0 )
		o.add("DARKGREEN", 0, 100, 0 )
		
		o.add("BLUE", 0, 0, 255)
		o.add("DARKBLUE", 0, 0, 100)
		
		o.add("SIENNA", 160, 82, 45 )
		o.add("DARKKHAKI",189,183,107)
		o.add("OLIVEDRAB", 107,142,35)		
		Return o
	End Function
	
	Method set( name$ )
		Local c:RGB = Self.find( name$)
		If c <> Null Then
			CSetColor( c )
		EndIf
		
	End Method
	
	
	Method add( name$, r, g, b )

		Local found:RGB = Self.find( name$) 	

		If found <> Null Then
			found.r = r
			found.g = g
			found.b = b
		Else
		
			Local c:RGB = New RGB
			c.name$ = Upper$(name$)
			c.r = r
			c.g = g
			c.b = b
			
			lcolors.addlast( c )
			
		EndIf
		
	End Method
	
	Method find:RGB( name$ )
		For Local c:RGB = EachIn lcolors
			If c.name$ = Upper$(name$) Then
				Return c
			EndIf
		Next
		
		Return Null
		
	End Method
	
End Type
	
Function CSetColor( c:RGB )
	SetColor c.r,c.g,c.b
End Function


