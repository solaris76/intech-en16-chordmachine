function CM.btn(i,v)if v==0 or not CM.go then return end
if CM.mode==1 then
if i==15 then if CM.arm==1 then CM.save(16)CM.arm=0 else CM.mode=0 CM.arm=0 end CM.paint()return end
if i==14 then CM.arm=1-CM.arm CM.paint()return end
local s=i+1 if CM.arm==1 then CM.save(s)CM.arm=0 else CM.recall(s)end CM.paint()return end
CM._b2(i)end
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(0)
local i=self:element_index()
if i<=7 then self:encoder_value(CM.n[i+1]) end
