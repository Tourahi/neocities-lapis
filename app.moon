lapis = require "lapis"
NeoCities =  require "modules.neocitiesApi"
Secret = require "secret.secret"

account = NeoCities Secret.NEOCITIES_USER, Secret.NEOCITIES_PASS, { apiKey: true }

class extends lapis.Application
  -- @before_filter =>
  --   after_dispatch ->
  --     Log.info ngx.ctx.performance

  "/info": =>
    res = account\info!

    json:
      message: {res.JSON!}

  "/infoLol": =>
    res = account\info!

    json:
      message: {res.JSON!}


