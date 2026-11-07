-- Non-blocking event scheduler (host clock or Grid timer bridge).

local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Scheduler)
  self.now_ms = opts.now_ms or function() return 0 end
  self.jobs = {} -- {t=, fn=, id=}
  self.next_id = 1
  self.on_arm_timer = opts.on_arm_timer -- function(delay_ms) for Grid
  return self
end

function Scheduler:set_now(fn)
  self.now_ms = fn
end

function Scheduler:after(delay_ms, fn)
  local id = self.next_id
  self.next_id = id + 1
  local t = self.now_ms() + math.max(0, delay_ms)
  self.jobs[#self.jobs + 1] = { id = id, t = t, fn = fn }
  table.sort(self.jobs, function(a, b) return a.t < b.t end)
  if self.on_arm_timer then
    local soon = self.jobs[1]
    if soon then
      local d = soon.t - self.now_ms()
      if d < 0 then d = 0 end
      self.on_arm_timer(d)
    end
  end
  return id
end

function Scheduler:cancel(id)
  for i = #self.jobs, 1, -1 do
    if self.jobs[i].id == id then
      table.remove(self.jobs, i)
    end
  end
end

function Scheduler:cancel_all()
  self.jobs = {}
end

function Scheduler:tick(now)
  now = now or self.now_ms()
  while #self.jobs > 0 and self.jobs[1].t <= now do
    local job = table.remove(self.jobs, 1)
    job.fn()
  end
  if self.on_arm_timer and #self.jobs > 0 then
    local d = self.jobs[1].t - now
    if d < 0 then d = 0 end
    self.on_arm_timer(d)
  end
end

return Scheduler
