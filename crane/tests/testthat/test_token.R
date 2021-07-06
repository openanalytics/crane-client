
test_that("device_code_request", {
      
      expect_silent(
          request <- device_code_request("https://testrepo",
              "testclient")
      )
      
    })

test_that("access_token_request", {
      
      expect_silent(
          request <- access_token_request("https://testrepo",
              "testclient",
              list(device_code = "testcode"))
      )
      
    })
