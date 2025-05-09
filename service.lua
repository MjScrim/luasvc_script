local lfs = require("lfs")
local er = require("error")
local cr = require("core")

local Service = {}
Service.__index = Service
Service.SERVICE_DIR = "./services"

function Service:new()
  return setmetatable({}, self)
end

function Service:start(name, started)
  started = started or {}

  if started[name] then return end

  started[name] = true

  local path = Service:get_service_path(name)
  local service = cr:parse_service_file(path)

  if not service then return er:not_found(service) end

  if service["Requires"] then
    for dep in service["Requires"]:gmatch("[^, ]+") do
      Service:start(dep, started)
    end
  end

  local pid_path = cr:get_pid_path(name)

  if cr:read_file(pid_path) then
    print("Service '" .. name .. "' already running.")
    return
  end

  local exec = service["Exec"]

  if not exec then return er:service_not_defined(exec, service) end

  local log = service["Log"]
  local cmd

  if log then
    cmd = string.format("(%s) >> %s 2>&1 & echo $!", exec, log)
  else
    cmd = string.format("(%s) & echo $!", exec)
  end

  local handle = io.popen(cmd)

  if not handle then return er:not_found(cmd) end

  local pid = handle:read("*a"):match("%d+")

  handle:close()

  if pid then
    local pid_file = io.open(pid_path, "w")

    if not pid_file then return er:not_found(pid_file) end

    pid_file:write(pid)
    pid_file:close()

    print("Started service '" .. name .. "' with PID " .. pid)
  else
    print("Failed to start service: " .. name)
  end
end

function Service:get_service_path(path)
  path = path or nil

  if not path then return er:not_found(path) end

  return self.SERVICE_DIR .. "/" .. path .. ".service"
end

function Service:stop(name)
  name = name or nil

  if not name then return nil end

  local pid = cr:read_file(cr:get_pid_path(name))

  local remove = cr:get_pid_path(name)

  if not remove then return nil end

  os.execute("kill" .. pid)
  os.remove(remove)

  print("Stopped service '" .. name .. "' (PID " .. pid .. ")")
end

function Service:status_service(name)
  name = name or nil

  if not name then return er:not_found(name) end

  local pid = cr:read_file(cr:get_pid_path(name))

  if pid then
    local exists = os.execute("kill -0" .. pid .. "2>/dev/null")

    if exists == true or exists == 0 then
      print("Service " .. name .. " is running (PID " .. pid .. ")")
    else
      print("Service " .. name .. " is not running, but PID file exists.")
    end
  else
    print("Service " .. name .. " is not running")
  end
end

function Service:test_status_service(name)
  name = name or nil

  if not name then return er:not_found(name) end

  local pid = cr:read_file(cr:get_pid_path(name))

  if pid then
    local exists = os.execute("kill -0" .. pid .. "2>/dev/null")

    if exists == true or exists == 0 then
      print("Service " .. name .. " is running (PID " .. pid .. ")")
    else
      print("Service " .. name .. " is not running, but PID file exists.")
    end
  else
    print("Service " .. name .. " is not running")
  end
end

function Service:list()
  print("Available services")

  for file in lfs.dir(self.SERVICE_DIR) do
    if file:match("%.service$") then
      print(" - " .. file:gsub("%.service$", ""))
    end
  end
end

return setmetatable({}, {
  __index = function(_, key)
    return Service[key]
  end
})
