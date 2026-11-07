function CM._ed(i,v)local d=CM.dlt(i,v)if d==0 and i~=14 then return end
if i==8 then CM.tr=CM.cl(CM.tr+d,-24,24)elseif i==9 then CM.oct=CM.cl(CM.oct+(d>0 and 1 or -1),-3,3)
elseif i==10 then CM.inv=CM.cl(CM.inv+(d>0 and 1 or -1),0,7)elseif i==11 then CM.spr=CM.cl(CM.spr+d,0,24)
elseif i==12 then CM.sms=CM.cl(CM.sms+d*5,0,250)elseif i==13 then CM.gate=CM.cl(CM.gate+d*20,20,2000)
elseif i==14 then CM.slot=CM.cl(math.floor(v/8)+1,1,16)else CM.vel=CM.cl(CM.vel+d,1,127)end
if i~=14 then if CM.held()and i>7 and i<12 then CM.trig()end CM.dirty=1 end CM.paint()end
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(0)
local i=self:element_index()
if i<=7 then self:encoder_value(CM.n[i+1]) end
