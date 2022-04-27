lapis = require "lapis"
NeoCities =  require "modules.neocitiesApi"
Secret = require "secret.secret"


class extends lapis.Application
  -- @before_filter =>
  --   after_dispatch ->
  --     Log.info ngx.ctx.performance

  "/test": =>
    account = NeoCities Secret.NEOCITIES_USER, Secret.NEOCITIES_PASS

    res = account\info!


    json:
      message: {res.JSON!}

