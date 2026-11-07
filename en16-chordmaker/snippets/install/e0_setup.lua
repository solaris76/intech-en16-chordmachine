function CM.on(n)n=CM.cl(n,0,127)local c=CM.refs[n]or 0 if c==0 then midi_send(CM.ch,144,n,CM.vel)end CM.refs[n]=c+1 end
function CM.off(n)local c=CM.refs[n]or 0 if c<1 then return end c=c-1 if c<1 then midi_send(CM.ch,128,n,0)CM.refs[n]=nil else CM.refs[n]=c end end
function CM.panic()for n in pairs(CM.refs)do midi_send(CM.ch,128,n,0)end CM.refs={}for i=1,8 do CM.snd[i]=0 end midi_send(CM.ch,176,123,0)end
function CM.rel()for i=1,8 do local n=CM.snd[i]if n>0 then CM.off(n)CM.snd[i]=0 end end end
self:encoder_mode(0)
self:encoder_min(0)
self:encoder_max(127)
self:button_mode(0)
local i=self:element_index()
if i<=7 then self:encoder_value(CM.n[i+1]) end
