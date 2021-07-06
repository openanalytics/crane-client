
#' Register settings for repository
#' @param repo repo
#' @param client_id oauth2 client id
#' @param device_code_url endpoint to request the device code
#' @param token_url endpoint to request access tokens
#' @export 
register <- function(repo,
    client_id,
    device_code_url,
    token_url,
    config_file = getOption("crane.repo.config", Sys.getenv("CRANE_REPO_CONFIG", "~/crane.json"))) {
  
  if (!is.character(client_id))
    errorf("`client_id` is not a character")
  if (!is.character(device_code_url))
    errorf("`device_code_url` is not a character")
  if (!is.character(token_url))
    errorf("`token_url` is not a character")
  
  config <- read_config(config_file)
  
  config[[repo]] <- list(
      client_id = client_id,
      device_code_url = device_code_url,
      token_url = token_url
  )
  
  write_config(config, config_file)
  
  invisible()
  
}

#' @importFrom jsonlite read_json
read_config <- function(config_file) {
  
  if (!file_exists(config_file)) list()
  else {
    lst <- read_json(config_file)
    
    if (!is.null(lst)) lst else list()
  }
  
}

#' @importFrom jsonlite write_json
write_config <- function(lst, config_file) {
  
  write_json(lst, path = config_file)
  
}
