local leRequest = require('modules.leRequest.init')

describe("Get request test ::", function()
  describe("GET request with no parameters", function()

    local url = 'http://localhost:9090/cat';

    local res = leRequest:get(url);
    local _, err = res.JSON();

    it("Status code should 200.", function()
      assert.truthy(200 == res.STATUS_CODE)
    end);

    assert.falsy(err);

  end)
end)
