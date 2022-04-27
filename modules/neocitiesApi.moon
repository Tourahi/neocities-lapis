Url = require 'lua.resty.url'
LeRequest =  require "modules.leRequest"

class NeoCities

  urlAssemble: (needAuth, path) =>
    if needAuth then return @url.scheme .. @credentialStr .. @url.host .. path
    else return @url.scheme .. @url.host .. path

  Get: (method, params, needAuth) =>
    path = '/api/' .. method
    return LeRequest\get @urlAssemble(needAuth, path), params: params

  new: (user, password, opts) =>
    local url
    if opts and opts.url then url = Url.parse opts.url
    else url = Url.parse 'https://neocities.org'

    @user     = user or url.user
    @password = password or url.password
    @credentialStr = LeRequest\CredentialStr @user, @password
    @opts     = opts or {}
    @url      = url
    @url.scheme = @url.scheme .. '://'


  -- "https://neocities.org/api/info?sitename=sn"
  info: (siteName) =>
    if siteName then return @Get 'info', {sitename: siteName}, false
    else @Get 'info', {}, true
