function CM.col(i,r,g,b,v)local a=CM.led(i)led_color(a,1,r,g,b)led_value(a,1,v)end
function CM.paint()if CM.mode==1 then for i=0,15 do local s=i+1 local r,g,b,v=35,35,35,35
if CM.bank[s]then r,g,b,v=0,200,0,100 end if CM.load==s then r,g,b,v=0,80,255,127 end
if CM.arm==1 then r,g,b,v=255,160,0,110 end CM.col(i,r,g,b,v)end return end
for i=0,7 do if CM.mute==1 then CM.col(i,220,0,0,100)elseif CM.e[i+1]==1 and i==0 then CM.col(i,0,80,255,120)
elseif CM.e[i+1]==1 then CM.col(i,0,220,0,110)else CM.col(i,35,35,35,30)end end end
