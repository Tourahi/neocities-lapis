Url = require 'lua.resty.url'
LeRequest =  require "modules.leRequest"


class NeoCities

  -- @local
  GetApiKey = (acc) ->
    if acc.apiKey == nil then return acc.Get acc, 'key', {}, true

  -- @local
  ContainsKey = (tab, key) ->
    for k, _ in pairs tab
      if k == key then return true
    false

  urlAssemble: (needAuth, path) =>
    if needAuth then return @url.scheme .. @credentialStr .. @url.host .. path
    else return @url.scheme .. @url.host .. path

  Get: (method, params, needAuth) =>
    path = '/api/' .. method
    if @apiKey == nil
      Log.info "Using : username:password"
      return LeRequest\get @urlAssemble(needAuth, path), params: params
    else
      Log.info "Using : api key"
      return LeRequest\get @urlAssemble(false, path), headers: {['Authorization']: 'Bearer ' .. @apiKey}

  new: (user, password, opts) =>
    local url

    if opts and ContainsKey(opts,"url") then url = Url.parse opts.url
    else url = Url.parse 'https://neocities.org'

    @user     = user or url.user
    @password = password or url.password
    @credentialStr = LeRequest\CredentialStr @user, @password
    @opts     = opts or {}
    @url      = url
    @url.scheme = @url.scheme .. '://'

    if opts and ContainsKey(opts,"apiKey")
      @apiKey = GetApiKey(@).JSON!.api_key


  -- "https://neocities.org/api/info?sitename=sn"
  info: (siteName) =>
    if siteName then return @Get 'info', {sitename: siteName}, false
    else @Get 'info', {}, true

  getApiKey: =>
    if @apiKey then return @apiKey
    nil
