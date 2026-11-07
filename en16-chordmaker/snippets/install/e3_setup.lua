function CM.apply(s)if not s then return end local h=CM.held()
for i=1,8 do CM.n[i]=s.n[i]CM.e[i]=s.e[i]end
CM.tr=s.tr or 0 CM.oct=s.oct or 0 CM.inv=s.inv or 0 CM.spr=s.spr or 0
CM.sms=s.sms or 0 CM.strum=s.strum or 0 CM.gate=s.gate or 400 CM.hold=s.hold or 1 CM.vel=s.vel or CM.vel
if h or CM.hold==1 then CM.trig()end end
function CM.save(s)if s<1 or s>16 then return end CM.bank[s]=CM.snap()CM.load=s CM.dirty=0 end
function CM.recall(s)local b=CM.bank[s]if not b then return false end CM.apply(b)CM.load=s CM.slot=s CM.dirty=0 return true end
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(0)
local i=self:element_index()
if i<=7 then self:encoder_value(CM.n[i+1]) end
