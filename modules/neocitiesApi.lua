local Url = require('lua.resty.url')
local LeRequest = require("modules.leRequest")
local NeoCities
do
  local _class_0
  local GetApiKey, ContainsKey
  local _base_0 = {
    urlAssemble = function(self, needAuth, path)
      if needAuth then
        return self.url.scheme .. self.credentialStr .. self.url.host .. path
      else
        return self.url.scheme .. self.url.host .. path
      end
    end,
    Get = function(self, method, params, needAuth)
      local path = '/api/' .. method
      if self.apiKey == nil then
        Log.info("Using : username:password")
        return LeRequest:get(self:urlAssemble(needAuth, path), {
          params = params
        })
      else
        Log.info("Using : api key")
        return LeRequest:get(self:urlAssemble(false, path), {
          headers = {
            ['Authorization'] = 'Bearer ' .. self.apiKey
          }
        })
      end
    end,
    info = function(self, siteName)
      if siteName then
        return self:Get('info', {
          sitename = siteName
        }, false)
      else
        return self:Get('info', { }, true)
      end
    end,
    getApiKey = function(self)
      if self.apiKey then
        return self.apiKey
      end
      return nil
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, user, password, opts)
      local url
      if opts and ContainsKey(opts, "url") then
        url = Url.parse(opts.url)
      else
        url = Url.parse('https://neocities.org')
      end
      self.user = user or url.user
      self.password = password or url.password
      self.credentialStr = LeRequest:CredentialStr(self.user, self.password)
      self.opts = opts or { }
      self.url = url
      self.url.scheme = self.url.scheme .. '://'
      if opts and ContainsKey(opts, "apiKey") then
        self.apiKey = GetApiKey(self).JSON().api_key
      end
    end,
    __base = _base_0,
    __name = "NeoCities"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  GetApiKey = function(acc)
    if acc.apiKey == nil then
      return acc.Get(acc, 'key', { }, true)
    end
  end
  ContainsKey = function(tab, key)
    for k, _ in pairs(tab) do
      if k == key then
        return true
      end
    end
    return false
  end
  NeoCities = _class_0
  return _class_0
end
