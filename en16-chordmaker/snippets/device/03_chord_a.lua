function CM.comp()local r={}for i=1,8 do r[i]=CM.n[i]end local o={}for i=1,8 do if CM.e[i]==1 then o[#o+1]=i end end
table.sort(o,function(a,b)return r[a]<r[b]end)local v=CM.cl(CM.inv,0,math.max(0,#o-1))for k=1,v do r[o[k]]=r[o[k]]+12 end
local t={}for i=1,8 do t[i]=CM.e[i]==1 and CM.cl(r[i]+CM.tr+CM.oct*12+CM.spr*(i-1),0,127)or nil end return t end
function CM.held()for i=1,8 do if CM.snd[i]>0 then return true end end return false end
