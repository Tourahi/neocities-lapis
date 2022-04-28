lapis = require "lapis"
NeoCities =  require "modules.neocitiesApi"
Secret = require "secret.secret"

-- Make sure the code_cache property is on in <config.moon>.
-- Why -- written in Chinese lang use google translate add-on.(Chrome-Chromium)
  --: https://blog.csdn.net/qinyushuang/article/details/44857995
account = NeoCities Secret.NEOCITIES_USER, Secret.NEOCITIES_PASS, { apiKey: true }

class extends lapis.Application
  "/info": =>
    res = account\info!

    json:
      message: {res.JSON!}


