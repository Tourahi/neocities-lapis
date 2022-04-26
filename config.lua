local config
config = require("lapis.config").config
return config({
  "development",
  "test"
}, function()
  port(9090)
  code_cache("off")
  daemon("off")
  notice_log("stderr")
  admin_email("tourahi.amine@gmail.com")
  measure_performance(true)
  app_name("neocities-lapis")
  host("localhost")
  resolver("8.8.8.8")
  num_workers(1)
  return logging({
    requests = true,
    queries = true,
    server = false
  })
end)
