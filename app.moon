lapis = require "lapis"
leRequest =  require "modules.leRequest.init"

class extends lapis.Application
  "/cat": =>
    res = leRequest\get 'https://catfact.ninja/fact'

    Log.info leRequest


    json:
      message: res.JSON!

