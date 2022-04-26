local lapis = require("lapis")
local leRequest = require("modules.leRequest.init")
local to_json
to_json = require("lapis.util").to_json
local after_dispatch
after_dispatch = require("lapis.nginx.context").after_dispatch
do
  local _class_0
  local _parent_0 = lapis.Application
  local _base_0 = {
    ["/cat"] = function(self)
      local queryparameters = {
        max_length = 100
      }
      local res = leRequest:get('https://catfact.ninja/fact', {
        params = queryparameters
      })
      return {
        json = {
          message = {
            res.JSON()
          }
        }
      }
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = nil,
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  return _class_0
end
