
test_config <- tempfile(fileext = ".json")
options(crane.repo.config = test_config)
crane::register(
    "http://localhost:7070/repo/test",
    client_id = "R",
    device_code_url = "http://localhost:8080/auth/realms/master/protocol/openid-connect/auth/device",
    token_url = "http://localhost:8080/auth/realms/master/protocol/openid-connect/token",
    config_file = test_config)

crane::install("foo", "http://localhost:7070/repo/test",
    compatibility_patch = TRUE)

crane::enable_install_packages_hook()
install.packages("foo", repos = "http://localhost:7070/repo/test")
crane::disable_install_packages_hook()

