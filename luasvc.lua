#!/usr/bin/env lua

local svc = require("service")
local cr = require("core")

cr:init()

local cmd = arg[1]
local name = arg[2]

if cmd == "start" then
  svc:start(name)
elseif cmd == "stop" then
  svc:stop(name)
elseif cmd == "status" then
  svc:status_service(name)
elseif cmd == "list" then
  svc:list()
else
    print("Use: luasvc.lua [start|stop|status|list] <service>")
end

