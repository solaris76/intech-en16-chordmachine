CM={vel=100,h=0,n={60,64,67,71},e={1,1,1,1},s={0,0,0,0},r={}}
function CM.on(n)if n>127 then n=127 elseif n<0 then n=0 end local c=CM.r[n]or 0 if c==0 then midi_send(0,144,n,CM.vel)end CM.r[n]=c+1 end
function CM.off(n)local c=CM.r[n]or 0 if c<1 then return end c=c-1 if c<1 then midi_send(0,128,n,0)CM.r[n]=nil else CM.r[n]=c end end
function CM.rel()for i=1,4 do local n=CM.s[i]if n and n>0 then CM.off(n)CM.s[i]=0 end end end
function CM.trig()CM.rel()for i=1,4 do if CM.e[i]==1 then CM.on(CM.n[i])CM.s[i]=CM.n[i]end end end
function CM.paint()for i=0,3 do led_color(i,1,0,CM.e[i+1]*200,0)led_value(i,1,80)end end
function CM.enc(i,v)if i<4 then CM.n[i+1]=v if CM.h>0 then CM.trig()end end end
function CM.btn(i,v)if v==0 then return end if i<4 then CM.e[i+1]=1-CM.e[i+1]if CM.h>0 then CM.trig()end elseif i==13 then CM.h=1-CM.h if CM.h>0 then CM.trig()else CM.rel()end end CM.paint()end
CM.paint()
