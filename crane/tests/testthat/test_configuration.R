
test_that("register", {
      
      tmp_file = tempfile(fileext = ".json")
      on.exit(unlink(tmp_file))

      expect_false(file_exists(tmp_file))
      
      register("http://testrepo",
          client_id = "testclient",
          token_url = "http://testurl/oauth/token",
          device_code_url = "http://testurl/oauth/device/code",
          config_file = tmp_file)
      
      config <- read_json(tmp_file)
      expect_length(config, 1)
      
      register("http://testrepo",
          client_id = "testclient",
          token_url = "http://testurl/oauth/token",
          device_code_url = "http://testurl/oauth/device/code",
          config_file = tmp_file)
      
      config <- read_json(tmp_file)
      expect_length(config, 1L)
      
      register("http://testrepo2",
          client_id = "testclient",
          token_url = "http://testurl/oauth/token",
          device_code_url = "http://testurl/oauth/device/code",
          config_file = tmp_file)
      
      config <- read_json(tmp_file)
      expect_length(config, 2L)
      
    })
