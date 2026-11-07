function CM.p(i,on)if on then CM.col(i,255,160,0,100)else CM.col(i,35,35,35,40)end end
local _p=CM.paint
function CM.paint()_p()if CM.mode==1 then return end
CM.p(8,CM.tr~=0)CM.p(9,CM.oct~=0)CM.p(10,CM.inv~=0)CM.p(11,CM.spr~=0)CM.p(12,CM.strum==1)CM.p(13,CM.hold==1)
if CM.bank[CM.slot]then local r,g,b=CM.sc(CM.slot)CM.col(14,r,g,b,CM.load==CM.slot and 127 or 95)else CM.col(14,35,35,35,40)end
if CM.dirty==1 then CM.col(15,180,0,220,110)else CM.col(15,255,160,0,80)end end
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(0)
local i=self:element_index()
if i<=7 then self:encoder_value(CM.n[i+1]) end
CM.paint()
