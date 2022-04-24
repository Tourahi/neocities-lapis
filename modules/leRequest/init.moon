
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
    socket = string.find(fullRequest.URL, '^https:') and not req.proxy and httpsSocket or httpSocket

    ok, response.STATUS_CODE, response.HEADERS, response.STATUS = socket.request fullRequest

    assert ok, 'Error: whoops! -> ' .. req.method .. ' request: ' .. response.STATUS_CODE
    response.TEXT = table.concat responseBody
    response.JSON = -> json.decode response.TEXT
    response.XML  = -> xml.load response.TEXT

    response

  new: =>
    @httpSocket = httpSocket
    @httpsSocket = httpsSocket

    Log.info "test"



