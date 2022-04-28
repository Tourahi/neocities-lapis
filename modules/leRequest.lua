local httpSocket = assert(require('socket.http'))
local httpsSocket = assert(require('ssl.https'))
local urlParser = assert(require('socket.url'))
local ltn12 = assert(require('ltn12'))
local json = assert(require('cjson.safe'))
local xml = assert(require('xml'))
local mime = assert(require('mime'))
local md5Sum = assert(require('md5'))
local Singleton
do
  local _class_0
  local _base_0 = {
    __inherited = function(self, By)
      By.getInstance = function(...)
        do
          local I = By.Instance
          if I then
            return I
          end
        end
        do
          local I = By(...)
          By.Instance = I
          return I
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Singleton"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Singleton = _class_0
end
local Request
do
  local _class_0
  local makeRequest, itrUrlParams, formatParams, _formatParams, checkURL, checkDATA, basicAuthHeader, md5Hash, digestHashResponse, digestCreateHeaderString, digestAuthHeader, addAuthHeaders, createHeader, checkTIMEOUT, checkREDIRECT, parseArgs, parseDigestResponseHeader, useDigest
  local _parent_0 = Singleton
  local _base_0 = {
    request = function(self, method, url, args)
      local req = { }
      if type(url) == "table" then
        req = url
        if not req.url and req[1] then
          req.url = table.remove(req, 1)
        end
      else
        req = args or { }
        req.url = url
      end
      req.method = method
      parseArgs(req)
      if req.auth and req.auth._type == 'digest' then
        local res = makeRequest(req)
        return useDigest(res, req)
      else
        return makeRequest(req)
      end
    end,
    get = function(self, url, args)
      return self:request("GET", url, args)
    end,
    post = function(self, url, args)
      return self:request("POST", url, args)
    end,
    put = function(self, url, args)
      return self:request("PUT", url, args)
    end,
    delete = function(self, url, args)
      return self:request("DELETE", url, args)
    end,
    patch = function(self, url, args)
      return self:request("PATCH", url, args)
    end,
    options = function(self, url, args)
      return self:request("OPTIONS", url, args)
    end,
    head = function(self, url, args)
      return self:request("HEAD", url, args)
    end,
    trace = function(self, url, args)
      return self:request("TRACE", url, args)
    end,
    HTTPDigestAuth = function(self, user, password)
      return {
        _type = 'digest',
        user = user,
        password = password
      }
    end,
    HTTPBasicAuth = function(self, user, password)
      return {
        _type = 'basic',
        user = user,
        password = password
      }
    end,
    CredentialStr = function(self, user, password)
      return user .. ':' .. password .. '@'
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      self.httpSocket = httpSocket
      self.httpsSocket = httpsSocket
    end,
    __base = _base_0,
    __name = "Request",
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
  local self = _class_0
  makeRequest = function(req)
    local responseBody = { }
    local fullRequest = {
      method = req.method,
      url = req.url,
      headers = req.headers,
      sink = ltn12.sink.table(responseBody),
      redirect = req.allowRedirects,
      proxy = req.proxy
    }
    if req.data then
      fullRequest.source = ltn12.source.string(req.data)
    end
    local response = { }
    local ok
    local socket = string.find(fullRequest.url, '^https:') and not req.proxy and httpsSocket or httpSocket
    ok, response.STATUS_CODE, response.HEADERS, response.STATUS = socket.request(fullRequest)
    assert(ok, 'Error: whoops! -> ' .. req.method .. ' request: ' .. response.STATUS_CODE)
    response.TEXT = table.concat(responseBody)
    response.JSON = function()
      return json.decode(response.TEXT)
    end
    response.XML = function()
      return xml.load(response.TEXT)
    end
    return response
  end
  itrUrlParams = function(url, params)
    local tostring = tostring
    local next = next
    local type = type
    local n = #params
    url = url .. '?'
    local iter
    iter = function(t, i)
      local v
      while true do
        i, v = next(t, i)
        if (i == nil or type(i) ~= 'number' or i > n) then
          break
        end
      end
      url = url .. (tostring(i) .. '=')
      if i and v then
        if type(v) == "table" then
          local stringVal = ''
          for k = 1, #v do
            stringVal = stringVal .. (tostring(v[k]) .. ",")
          end
          url = url .. stringVal:sub(0, -2)
        else
          url = url .. tostring(v)
        end
        url = url .. '&'
        return i, v, url
      end
    end
    return iter, params, nil
  end
  formatParams = function(url, params)
    if not params or next(params) == nil then
      return url
    end
    url = url .. '?'
    for k, v in pairs(params) do
      if tostring(v) then
        url = url .. (tostring(k) .. '=')
        if type(v) == 'table' then
          local stringVal = ''
          for j = 1, #v do
            local val = v[j]
            stringVal = stringVal .. (tostring(val) .. ",")
          end
          url = url .. stringVal:sub(0, -2)
        else
          url = url .. tostring(v)
        end
        url = url .. '&'
      end
    end
    return url:sub(0, -2)
  end
  _formatParams = function(url, params)
    if not params then
      return url
    end
    local urlParam
    for _, _, URL in itrUrlParams(url, params) do
      urlParam = URL
    end
    return urlParam:sub(0, -2)
  end
  checkURL = function(request)
    assert(request.url, 'No url specified for request')
    request.url = formatParams(request.url, request.params)
  end
  checkDATA = function(request)
    if type(request.data) == "table" then
      request.data = json.encode(request.data)
    elseif request.data then
      request.data = tostring(request.data)
    end
  end
  basicAuthHeader = function(request)
    local enc = mime.b64(request.auth.user .. ':' .. request.auth.password)
    request.headers.Authorization = 'Basic ' .. enc
  end
  md5Hash = function(...)
    return md5Sum.sumhexa(table.concat({
      ...
    }, ":"))
  end
  digestHashResponse = function(authTab)
    return md5Hash(md5Hash(authTab.user, authTab.realm, authTab.password), authTab.nonce, authTab.nc, authTab.cnonce, authTab.qop, md5Hash(authTab.method, authTab.uri))
  end
  digestCreateHeaderString = function(auth)
    local authorization
    authorization = 'Digest username="' .. auth.user .. '", realm="' .. auth.realm .. '", nonce="' .. auth.nonce
    authorization = authorization .. '", uri="' .. auth.uri .. '", qop=' .. auth.qop .. ', nc=' .. auth.nc
    authorization = authorization .. ', cnonce="' .. auth.cnonce .. '", response="' .. auth.response .. '"'
    if auth.opaque then
      authorization = authorization .. ', opaque="' .. auth.opaque .. '"'
    end
    return authorization
  end
  digestAuthHeader = function(request)
    if not request.auth.nonce then
      return 
    end
    local url
    request.auth.cnonce = request.auth.cnonce or string.format("%08x", os.time())
    request.auth.nc_count = request.auth.nc_count or 0
    request.auth.nc_count = request.auth.nc_count + 1
    request.auth.nc = string.format("%08x", request.auth.nc_count)
    url = urlParser.parse(request.url)
    request.auth.uri = urlParser.build({
      path = url.path,
      query = url.query
    })
    request.auth.method = request.method
    request.auth.qop = 'auth'
    request.auth.response = digestHashResponse(request.auth)
    request.headers.Authorization = digestCreateHeaderString(request.auth)
  end
  addAuthHeaders = function(request)
    local addAuthCB = {
      basic = basicAuthHeader,
      digest = digestAuthHeader
    }
    return addAuthCB[request.auth._type](request)
  end
  createHeader = function(request)
    request.headers = request.headers or { }
    if request.data then
      request.headers['Content-Length'] = request.data:len()
    end
    if request.cookies then
      if request.headers.cookie then
        request.headers.cookie = request.headers.cookie .. ('; ' .. request.cookies)
      else
        request.headers.cookie = request.cookies
      end
    end
    if request.auth then
      return addAuthHeaders(request)
    end
  end
  checkTIMEOUT = function(timeout)
    httpSocket.TIMEOUT = timeout or 5
    httpsSocket.TIMEOUT = timeout or 5
  end
  checkREDIRECT = function(allowRedirects)
    if allowRedirects and type(allowRedirects) ~= "boolean" then
      return error("checkREDIRECT expects a boolean value. received type : " .. type(allowRedirects))
    end
  end
  parseArgs = function(request)
    checkURL(request)
    checkDATA(request)
    createHeader(request)
    checkTIMEOUT(request.timeout)
    return checkREDIRECT(request.allowRedirects)
  end
  parseDigestResponseHeader = function(res, req)
    for k, v in res.HEADERS['www-authenticate']:gmatch('(%w+)="(%S+)"') do
      req.auth[k] = v
    end
    if req.headers.cookie then
      req.headers.cookie = req.headers.cookie .. '; ' .. res.HEADERS['set-cookie']
    else
      req.headers.cookie = res.HEADERS['set-cookie']
    end
    req.auth.nc_count = 0
  end
  useDigest = function(res, req)
    if res.STATUS_CODE == 401 then
      parseDigestResponseHeader(res, req)
      createHeader(req)
      res = makeRequest(req)
      res.AUTH = req.auth
      res.COOKIES = req.headers.cookie
      return res
    else
      res.AUTH = req.auth
      res.COOKIES = req.headers.cookie
      return res
    end
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Request = _class_0
end
return Request.getInstance()
