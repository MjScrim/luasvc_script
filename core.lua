local er = require("error")

local Core = {}
Core.__index = Core
Core.PID_DIR = "/tmp/luasvc_pids"

function Core:new()
  return setmetatable({}, self)
end

function Core:init()
  os.execute("mkdir -p \"" .. self.PID_DIR .. "\"")
end

function Core:get_pid(name)
  name = name or nil

  if not name then return nil end

  local pid_path = Core:get_pid_path(name)

  if not pid_path then return er:not_found(pid_path) end

  local file = io.open(pid_path, "r")

  if not file then return er:not_found(file) end

  local pid = file:read("*l")

  file:close()

  return pid
end

function Core:is_running(pid)
  pid = pid or nil

  if not pid then return er:not_found(pid) end

  local file = io.popen("ps -p " .. pid .. " -o pid=")

  if not file then return er:not_found(file) end

  local result = file:read("*l")

  file:close()

  return result ~= nil
end

function Core:get_pid_path(name)
  name = name or nil

  if not name then return er:not_found(name) end

  return self.PID_DIR .. "/" .. name .. ".pid"
end

function Core:read_file(path)
  path = path or nil

  if not path then return er:not_found(path) end

  local file = io.open(path, "r")

  if not file then return er:not_found(file) end

  local content = file:read("*a")

  file:close()

  return content
end

function Core:parse_service_file(path)
  path = path or nil

  if not path then return er:not_found(path) end

  local content = Core:read_file(path)

  if not content then return er:not_content(path) end

  local config = {}

  for line in content:gmatch("[^\r\n]+") do
    local key, val = line:match("^(%w+)%s*=%s*(.+)$")

    if key and val then
      config[key] = val
    end
  end

  return config
end

return setmetatable({}, {
  __index = function(_, key)
    return Core[key]
  end
})
