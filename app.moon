lapis = require "lapis"
requests = require 'requests'
leRequest =  require "modules.leRequest.init"

class extends lapis.Application
  "/cat": =>
    res = requests.get 'https://catfact.ninja/fact'

    reqs = leRequest.getInstance!



    json:
      message: res.json!

