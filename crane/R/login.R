#' Login to a Crane repository
#'
#' @param repo crane repo url
#' @param verbose print info during the login process
#'
#' @return access token
#'
#' @details Find or negiotate an access token. In order of preference:
#'
#' 1. load a valid access token from cache
#' 2. refreshing a cached access token
#' 3. negotiate a new access token using the device authorization flow
#' 
#' @export
login <- function(
    repo,
    verbose = FALSE) {

    config <- read_config()

    repo_config <- discover_repo(repo, config)
    
    token <- cache_lookup_token(repo)
    if (is.null(token) || is_refresh_expired(token)) {
      token <- device_authorization_flow(repo_config)
    }
    if (is_expired(token) || 
      get_crane_opt("debug", "alwaysrefresh", default = FALSE)) {

      if (verbose) messagef("Refreshing access token for Crane repository: %s", repo)

      token <- tryCatch({
        refresh_token_flow(repo_config, token)
      }, error = function(e) {
        if (verbose) messagef("Re-initiating device code flow. Reason: %s", e$message)
        device_authorization_flow(repo_config)
      })
    }
    cache_token(repo, token)

    token
}

refresh_token_flow <- function(
  repo_config,
  token) {

  merge_token(token, refresh_access_token(
    repo_config$token_url,
    repo_config$client_id,
    token$refresh_token
  ))

}

#' @name options
#' @section Options:
#' * `crane.interactive`: open the verification url in the browser of the user automatically using [utils::browseURL] during the device authorization flow. By default this will only happen if running in interactive mode ([base::interactive()])
{}

device_authorization_flow <- function(
  repo_config,
  interactive = get_crane_opt("interactive", default = base::interactive())
  ) {

  device_code <- get_device_code(
      repo_config$device_code_url,
      repo_config$client_id)
 
  message(format_activation_instructions(device_code))
  if (interactive) {
    readline(prompt="Press [Enter] to open the verification URL in your browser.")
    browse_url(device_code$verification_uri_complete)
  }
  
  poll_access_token(
      repo_config$token_url,
      repo_config$client_id,
      device_code
  )
} 

format_activation_instructions <- function(device_code) {
  
  sprintf(
      nd(
        "--------------------------------------------------",
        "Please activate your R session:",
        "\tpoint your browser to %s",
        "\tuser code: %s",
        "--------------------------------------------------"),
      device_code$verification_uri_complete,
      device_code$user_code)
  
}

