--- This module is lua-requests rewritten in ms to help me understand some concepts :).

httpSocket   = assert require 'socket.http'
httpsSocket  = assert require 'ssl.https'
urlParser    = assert require 'socket.url'
ltn12        = assert require 'ltn12'
json         = assert require 'cjson.safe'
xml          = assert require 'xml'
mime         = assert require 'mime'
md5Sum       = assert require 'md5'





-- @local
class Singleton
  --- Whenever a class inherits from Singleton, it sends a message to the Singleton class by calling this method.
  __inherited: (By) =>
    By.getInstance = (...) ->
      if I = By.Instance then return I
      with I = By ...
        By.Instance = I


class Request extends Singleton

  -- @local
  makeRequest = (req) ->
    responseBody = {}

    -- http.request{ -- https://tst2005.github.io/lua-socket/http.html
    --     url = string,
    --     [sink = LTN12 sink,]
    --     [method = string,]
    --     [headers = header-table,]
    --     [source = LTN12 source],
    --     [step = LTN12 pump step,]
    --     [proxy = string,]
    --     [redirect = boolean,]
    --     [create = function]
    -- }
    fullRequest =
      method: req.method
      url: req.url
      headers: req.headers
      sink: ltn12.sink.table responseBody
      redirect: req.allowRedirects
      proxy: req.proxy

    if req.data then fullRequest.source = ltn12.source.string req.data

    response = {}
    local ok
    socket = string.find(fullRequest.url, '^https:') and not req.proxy and httpsSocket or httpSocket

    ok, response.STATUS_CODE, response.HEADERS, response.STATUS = socket.request fullRequest

    assert ok, 'Error: whoops! -> ' .. req.method .. ' request: ' .. response.STATUS_CODE
    response.TEXT = table.concat responseBody
    response.JSON = -> json.decode response.TEXT
    response.XML  = -> xml.load response.TEXT

    response

  -- @local
  itrUrlParams = (url, params) ->
    n = 1
    for i, _ in ipairs(params) do n = i

    url ..= '?'

    local iter

    iter = (t, i) ->
      local v
      while true
        i, v = next(t, i)
        break if(i == nil or type(i) ~= 'number' or i > n)

      url ..= tostring(i)..'='

      if i and v
        if type(v) == "table"
          stringVal = ''
          for _, val in ipairs(v)
            stringVal ..= tostring(val) .. ","
          url ..= stringVal\sub 0, -2
        else
          url ..= tostring v

        l, f = next(t, i)
        if l ~= nil and f ~= nil then url ..= '&'

        return i, v, url

    return iter, params, nil


  -- @local
  -- Format the URL based on the parameters.
  -- If my solution is faster this will be removed.
  _formatParams = (url, params) ->
    if not params or next(params) == nil then return url

    url ..= '?'

    for k, v in pairs params
      if tostring v
        url ..= tostring(k)..'='

        if type(v) == 'table'
          stringVal = ''
          for _, val in ipairs(v)
            stringVal ..= tostring(val) .. ","

          url ..= stringVal\sub 0, -2
        else
          url ..= tostring v

        url ..= '&'

    url\sub 0, -2

  formatParams = (url, params) ->
    if not params then return url
    local urlParam

    for _, _, URL in itrUrlParams url, params
      urlParam = URL

    urlParam

  -- @local
  -- checks if a URL was given and appends params to it.
  checkURL = (request) ->
    assert request.url, 'No url specified for request'
    request.url = formatParams request.url, request.params

  -- @local
  checkDATA = (request) ->
    if type(request.data) == "table"
      request.data = json.encode request.data
    elseif request.data then request.data = tostring request.data

  -- @local
  -- adds basic authentication to the request header.
  basicAuthHeader = (request) ->
    enc = mime.b64 request.auth.user .. ':' .. request.auth.password
    request.headers.Authorization = 'Basic '.. enc

  -- @local
  md5Hash = (...) ->
    md5Sum.sumhexa table.concat({...}, ":")

  -- @local
  digestHashResponse = (authTab) ->
    md5Hash(
      md5Hash(authTab.user, authTab.realm, authTab.password),
      authTab.nonce,
      authTab.nc,
      authTab.cnonce,
      authTab.qop,
      md5Hash(authTab.method, authTab.uri)
    )

  -- @local
  digestCreateHeaderString = (auth) ->
    local authorization
    authorization = 'Digest username="'..auth.user..'", realm="'..auth.realm..'", nonce="'..auth.nonce
    authorization = authorization..'", uri="'..auth.uri..'", qop='..auth.qop..', nc='..auth.nc
    authorization = authorization..', cnonce="'..auth.cnonce..'", response="'..auth.response..'"'

    if auth.opaque then
      authorization = authorization..', opaque="'..auth.opaque..'"'

    authorization

  -- @local
  digestAuthHeader = (request) ->
    if not request.auth.nonce then return

    local url

    request.auth.cnonce = request.auth.cnonce or string.format("%08x", os.time())

    request.auth.nc_count = request.auth.nc_count or 0
    request.auth.nc_count = request.auth.nc_count + 1

    request.auth.nc = string.format("%08x", request.auth.nc_count)

    url = urlParser.parse(request.url)
    request.auth.uri = urlParser.build {path: url.path, query: url.query}
    request.auth.method = request.method
    request.auth.qop = 'auth'

    request.auth.response = digestHashResponse request.auth
    request.headers.Authorization = digestCreateHeaderString request.auth

  -- @local
  addAuthHeaders = (request) ->
    addAuthCB =
      basic: basicAuthHeader
      digest: digestAuthHeader

    addAuthCB[request.auth._type](request)

  -- @local
  createHeader = (request) ->
    request.headers = request.headers or {}
    if request.data then request.headers['Content-Length'] = request.data\len!

    if request.cookies
      if request.headers.cookie
        request.headers.cookie ..= '; '..request.cookies
      else
        request.headers.cookie = request.cookies

    if request.auth then addAuthHeaders request

  -- @local
  -- Set timeout
  checkTIMEOUT = (timeout) ->
    httpSocket.TIMEOUT = timeout or 5
    httpsSocket.TIMEOUT = timeout or 5

  -- @local
  checkREDIRECT = (allowRedirects) ->
    if allowRedirects and type(allowRedirects) != "boolean"
      error "checkREDIRECT expects a boolean value. received type : " .. type(allowRedirects)

  -- @local
  parseArgs = (request) ->
    checkURL request
    checkDATA request
    createHeader request
    checkTIMEOUT request.timeout
    checkREDIRECT request.allowRedirects

  parseDigestResponseHeader = (res, req) ->
    for k, v in res.HEADERS['www-authenticate']\gmatch('(%w+)="(%S+)"')
      req.auth[k] = v

    if req.headers.cookie
      req.headers.cookie = req.headers.cookie..'; ' .. res.HEADERS['set-cookie']
    else
      req.headers.cookie = res.HEADERS['set-cookie']

    req.auth.nc_count = 0


  useDigest = (res, req) ->
    if res.STATUS_CODE == 401
      parseDigestResponseHeader res, req
      createHeader req
      res = makeRequest req
      res.AUTH = req.auth
      res.COOKIES = req.headers.cookie
      return res
    else
      res.AUTH = req.auth
      res.COOKIES = req.headers.cookie
      return res


  new: =>
    @httpSocket = httpSocket
    @httpsSocket = httpsSocket

  request: (method, url, args) =>
    req = {}

    if type(url) == "table"
      req = url
      if not req.url and req[1]
        req.url = table.remove req, 1
    else
      req = args or {}
      req.url = url

    req.method = method
    parseArgs req

    if req.auth and req.auth._type == 'digest'
      res = makeRequest req
      return useDigest res, req
    else
      return makeRequest req


  get: (url, args) =>
    return @request "GET", url, args




Request.getInstance!
