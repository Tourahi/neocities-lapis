
httpSocket   = assert require 'socket.http'
httpsSocket  = assert require 'ssl.http'
urlParser    = assert require 'ssl.url'
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

-- @local
makeRequest = (req) ->
  responseBody = {}
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


class Request extends Singleton
  new: =>
    @httpSocket = httpSocket
    @httpsSocket = httpsSocket



