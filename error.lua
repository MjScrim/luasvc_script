local Error = {}
Error.__index = Error

function Error:not_found(arc)
  error("Error! " .. arg .. " not found!")
end

function Error:not_content(path)
  error("Error! Content is null or incorret in " .. path .. " .")
end

function Error:exec_not_defined(exec, service)
  error("Error! Service not defined " .. exec .. " in serice: " .. service)
end

return setmetatable({}, {
  __index = function (_, key)
    return Error[key]
  end
})
