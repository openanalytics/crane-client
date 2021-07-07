
#' Install one or more packages from a Crane repository
#' @param pkgs packages to install
#' @param repo crane repo url
#' @export
install <- function(
    pkgs,
    repo,
    compatibility_patch = R.Version()$major < 4,
    config_file = getOption("crane.repo.config", Sys.getenv("CRANE_REPO_CONFIG", "~/crane.json"))) {
  
  if (check_access(repo, token = NULL)) {
    messagef("Repo is public: %s", repo)
    utils::install.packages(pkgs, repos = repo)
  } else {
    
    repo_config <- discover_repo(repo, read_config(config_file))
    
    if (compatibility_patch) {
      available.packages <- utils::available.packages
      body(available.packages)[[7]][[4]][[3]][[4]][[4]][[3]][[4]][[3]][[2]][[2]][[8]] <- quote(...)
      body(available.packages)[[7]][[4]][[3]][[4]][[4]][[3]][[7]][[3]][[6]][[3]][[2]][[2]][[8]] <- quote(...)
      unlockBinding("available.packages", getNamespace("utils"))
      assign("available.packages", available.packages, envir = getNamespace("utils"))
      lockBinding("available.packages", getNamespace("utils"))
    }
    
    token <- cache_lookup_token(repo)
    if (is.null(token) || is_expired(token)) {
      token <- device_authorization_flow(repo_config)
      cache_token(repo, token)
    }
    
    check_access(repo, token, force = TRUE)
    
    utils::install.packages(pkgs,
        repos = repo,
        headers = c("Authorization" = format_auth_header(token)))
    
  }
  
}

device_authorization_flow <- function(repo_config) {
  device_code <- get_device_code(
      repo_config$device_code_url,
      repo_config$client_id)
  
  message(format_activation_instructions(device_code))
  
  poll_access_token(
      repo_config$token_url,
      repo_config$client_id,
      device_code
  )
} 

format_activation_instructions <- function(device_code) {
  
  sprintf(
      nd(
        "------------------------------",
        "Please activate your R session:",
        "\tpoint your browser to %s",
        "\tand enter your user code: %s",
        "------------------------------"),
      device_code$verification_uri,
      device_code$user_code)
  
}
