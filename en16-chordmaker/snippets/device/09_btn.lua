function CM.btn(i,v)if v==0 then return end
if CM.mode==1 then
if i==15 then if CM.arm==1 then CM.save(16)CM.arm=0 else CM.mode=0 CM.arm=0 end CM.paint()return end
if i==14 then CM.arm=1-CM.arm CM.paint()return end
local s=i+1 if CM.arm==1 then CM.save(s)CM.arm=0 else CM.recall(s)end CM.paint()return end
if i<8 then CM.e[i+1]=1-CM.e[i+1]CM.dirty=1
if CM.e[i+1]==0 then local n=CM.snd[i+1]if n>0 then CM.off(n)CM.snd[i+1]=0 end elseif CM.held()then CM.trig()end
CM.paint()return end
if i==8 then CM.tr=0 elseif i==9 then CM.oct=0 elseif i==10 then CM.inv=0 elseif i==11 then CM.spr=0
elseif i==12 then CM.strum=1-CM.strum elseif i==13 then CM.hold=1-CM.hold if CM.hold==1 then CM.trig()else CM.rel()end
elseif i==14 then CM.recall(CM.slot)else CM.mode=1 CM.arm=0 end
if i<14 then CM.dirty=1 end CM.paint()end
CM.paint()
