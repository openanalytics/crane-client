
context("bearer token")

test_that("getBearerToken", {
      
      mockr::with_mock(
          POST = function(url, ...) {
            structure(
                list(
                    url = url,
                    headers = list("Content-Type" = "application/json"),
                    status_code = 200,
                    content = charToRaw(
                        jsonlite::toJSON(auto_unbox = TRUE,
                            list(token_type = "Bearer", access_token = "x")))
                ),
                class = "response")
          },
          expect_equal(
              getBearerToken(
                  url = "https://websso.openanalytics.eu",
                  username = "my-user",
                  password = "my-pass",
                  clientId = "my-client-id",
                  clientSecret = "my-client-secret",
                  realm = "my-realm"),
              "Bearer x")
      )
      
    })
