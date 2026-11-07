CM={ch=0,vel=100,mode=0,arm=0,slot=1,load=0,dirty=0,mute=0,hold=0,strum=0,sms=0,gate=400,tr=0,oct=0,inv=0,spr=0,t=0}
CM.n={48,51,55,58,62,67,72,75}CM.e={1,1,1,1,0,0,0,0}CM.snd={0,0,0,0,0,0,0,0}CM.refs={}CM.bank={}CM.prev={}
for i=1,16 do CM.bank[i]=nil end
function CM.cl(n,a,b)if n<a then return a end if n>b then return b end return n end
function CM.led(i)local a=i if led_address_get then local x=led_address_get(i,0)if x~=nil then a=x end end return a end
CM.enc=function()end CM.btn=function()end CM.paint=function()end CM._ed=function()end CM._b2=function()end
print("CM")
