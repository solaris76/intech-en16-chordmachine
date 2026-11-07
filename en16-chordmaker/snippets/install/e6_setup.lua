function CM.dlt(i,v)local p=CM.prev[i]CM.prev[i]=v if not p then return 0 end local d=v-p if d>64 then d=d-128 elseif d<-64 then d=d+128 end return d end
function CM.enc(i,v)if not CM.go then return end
if CM.mode==1 then if i==15 then CM.mode=0 CM.arm=0 CM.paint()return elseif i==14 then CM.slot=CM.cl(math.floor(v/8)+1,1,16)CM.paint()end return end
if i<8 then CM.n[i+1]=CM.cl(v,0,127)CM.dirty=1 if CM.held()then CM.trig()end CM.paint()return end
CM._ed(i,v)end
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(0)
local i=self:element_index()
if i<=7 then self:encoder_value(CM.n[i+1]) end
