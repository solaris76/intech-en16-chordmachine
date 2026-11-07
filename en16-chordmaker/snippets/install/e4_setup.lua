function CM.sc(s)local x={255,0,0,0,255,255,255,220,0,0,60,255,255,0,180,0,255,0,255,100,0,160,0,255,255,255,255,0,200,100,255,40,100,180,255,0,0,180,255,255,160,0,200,0,60,100,255,200}local i=(s-1)*3 return x[i+1],x[i+2],x[i+3]end
function CM.col(i,r,g,b,v)local a=CM.led(i)led_color(a,1,r,g,b)led_value(a,1,v)end
function CM.paint()if CM.mode==1 then for i=0,15 do local s=i+1 local r,g,b,v=25,25,25,25
if CM.bank[s]then r,g,b=CM.sc(s)v=CM.load==s and 127 or 110 end
if CM.arm==1 then r,g,b,v=255,180,0,120 end CM.col(i,r,g,b,v)end return end
for i=0,7 do if CM.mute==1 then CM.col(i,220,0,0,100)elseif CM.e[i+1]==1 and i==0 then CM.col(i,0,80,255,120)
elseif CM.e[i+1]==1 then CM.col(i,0,220,0,110)else CM.col(i,35,35,35,30)end end end
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(0)
local i=self:element_index()
if i<=7 then self:encoder_value(CM.n[i+1]) end
