lapis = require "lapis"
requests = require 'requests'
m = require "moon"
Dump = m.p

class extends lapis.Application
  "/cat": =>
    res = requests.get 'https://catfact.ninja/fact'

    json:
      message: res.json!

