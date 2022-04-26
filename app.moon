lapis = require "lapis"
leRequest =  require "modules.leRequest.init"
import to_json from require "lapis.util"
import after_dispatch from require "lapis.nginx.context"


class extends lapis.Application
  -- @before_filter =>
  --   after_dispatch ->
  --     Log.info ngx.ctx.performance

  "/cat": =>
    queryparameters = { max_length: 100}
    res = leRequest\get 'https://catfact.ninja/fact'


    json:
      message: {res.JSON!}

