function CM.trig()if CM.mute==1 then return end local t=CM.comp()
for i=1,8 do local w,h=t[i],CM.snd[i]if h>0 and not w then CM.off(h)CM.snd[i]=0 elseif w then if h>0 and h~=w then CM.off(h)end if h~=w then CM.on(w)CM.snd[i]=w end end end end
function CM.snap()local s={n={},e={},tr=CM.tr,oct=CM.oct,inv=CM.inv,spr=CM.spr,sms=CM.sms,strum=CM.strum,gate=CM.gate,hold=CM.hold,vel=CM.vel}
for i=1,8 do s.n[i]=CM.n[i]s.e[i]=CM.e[i]end return s end
