Rem

geom.bmx

End Rem

' x0,y0 = point in space
' x1,y1;x2,y2 = line segment in space
'

Type GeomPoint
	Field x:Float
	Field y:Float
End Type

Function  getPerpDistance:Float ( x:Float, y:Float,  x1:Float, y1:Float, x2:Float, y2:Float )

  Local A:Float = x - x1
  Local B:Float = y - y1
  Local C:Float = x2 - x1
  Local D:Float = y2 - y1

  Local dot:Float = A * C + B * D
  Local len_sq:Float = C * C + D * D
  Local param:Float = -1
  If (len_sq <> 0) Then   param = dot / len_sq

'   'in Case of 0 length line
      

  Local xx:Float, yy:Float

  If (param < 0) Then
    xx = x1
    yy = y1
  
  Else If (param > 1) Then
    xx = x2
    yy = y2
  Else 
    xx = x1 + param * C
    yy = y1 + param * D
  EndIf


  Local dx:Float = x - xx
  Local dy:Float = y - yy
  Return Sqr(dx * dx + dy * dy)

	
End Function


Function  getPerpPoint:GeomPoint ( x:Float, y:Float,  x1:Float, y1:Float, x2:Float, y2:Float )

  Local A:Float = x - x1
  Local B:Float = y - y1
  Local C:Float = x2 - x1
  Local D:Float = y2 - y1

  Local dot:Float = A * C + B * D
  Local len_sq:Float = C * C + D * D
  Local param:Float = -1
  If (len_sq <> 0) Then   param = dot / len_sq

'   'in Case of 0 length line
      

  Local xx:Float, yy:Float

  If (param < 0) Then
    xx = x1
    yy = y1
  
  Else If (param > 1) Then
    xx = x2
    yy = y2
  Else 
    xx = x1 + param * C
    yy = y1 + param * D
  EndIf

	Local coord:GeomPoint = New GeomPoint
	coord.x = xx
	coord.y = yy
	
	Return(coord)

'  Local dx:Float = x - xx
'  Local dy:Float = y - yy
'  Return Sqr(dx * dx + dy * dy)

	
End Function


Function isNear( x0#,y0#, x1#, y1#, nearDist# )
	Local dx# = x1#  - x0#
	Local dy# = y1# - y0#
	Local dist# = Sqr( dx#^2 + dy#^2 )
	
	If ( dist# <= nearDist# ) Then Return True
	
	Return False
		
End Function


Function isRectTouching(x#,y#, w#, h#, ox#,oy#,ow#,oh# )

	If ( x#+w# < ox# ) Then Return False
	If ( x# > ox#+ow#) Then Return False
	If ( y#+h# < oy# )  Then Return False
	If ( y# > oy#+oh#) Then Return False
	
	
	Return True
	
End Function

Function isPointInRect(mx#, my#,  rx#,ry#,rw#,rh#)
	
	If ( mx# < rx#) Then Return False
	If ( mx# > (rx#+rw#)) Then Return False
	If ( my# > (ry#+rh#) ) Then Return False
	If ( my# < ry# ) Then Return False
	
	
	Return True
	
	
End Function

Function isPointInCircle(x#,y#,  cx#,cy#,cr#  )
	Local dx#,dy#,d#

	dx# = cx# - x#
	dy# = cy# - y#
	d# = Sqr( dx#^2 + dy#^2 )
	
	If ( d# <= cr# ) Then Return True
	
	Return False
	
End Function


Function isCircleTouching(x1#,y1#, rad1#,  x2#,y2#,rad2# )

	Local d# = Sqr( (x2#-x1#)^2 + (y2#-y1#)^2 )
	
	If ( d# < (rad1# + rad2#) ) Then Return True
	
	
	Return False
	
End Function



