
#' Install one or more packages from a Crane repository
#' @param pkgs packages to install
#' @param repo crane repo url
#' @param compatibility_patch patch older versions of available.packages to accept a dots argument
#' @inheritParams login
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
    
    if (compatibility_patch) {
      available.packages <- utils::available.packages
      if (length(body(available.packages)) != 12L) {
        errorf("utils::available.packages has been altered. Please disable any hooks or tracing.")
      }
      body(available.packages)[[7]][[4]][[3]][[4]][[4]][[3]][[4]][[3]][[2]][[2]][[8]] <- quote(...)
      body(available.packages)[[7]][[4]][[3]][[4]][[4]][[3]][[7]][[3]][[6]][[3]][[2]][[2]][[8]] <- quote(...)
      unlockBinding("available.packages", getNamespace("utils"))
      assign("available.packages", available.packages, envir = getNamespace("utils"))
      lockBinding("available.packages", getNamespace("utils"))
    }
   
    token <- login(repo,config_file = config_file)
    
    check_access(repo, token, force = TRUE)
    
    utils::install.packages(pkgs,
        repos = repo,
        headers = c("Authorization" = format_auth_header(token)))
    
  }
  
}

#' Login to a Crane repository
#' @param repo crane repo url
#' @param config_file file containing repository configuration
#' @return access token
#' @export
login <- function(
    repo,
    config_file = getOption("crane.repo.config", Sys.getenv("CRANE_REPO_CONFIG", "~/crane.json"))) {
    
    repo_config <- discover_repo(repo, read_config(config_file))
    
    
    token <- cache_lookup_token(repo)
    if (is.null(token) || is_expired(token)) {
      token <- device_authorization_flow(repo_config)
      cache_token(repo, token)
    }
    token
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
