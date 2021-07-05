
#' Install one or more packages from a Crane repository
#' @param pkgs packages to install
#' @param repo crane repo url
#' @export
install <- function(pkgs, repo) {
  
  client_id <- get_client_id(repo)
  
  device_code <- get_device_code(repo, client_id)
  
  message(format_activation_instructions(device_code))
  
  token <- poll_access_token(
      repo,
      device_code$device_code,
      device_code$interval)

  utils::install.packages(pkgs,
      repos = repo,
      headers = c("Authorization" = sprintf("Bearer %s", token)))
  
}

format_activation_instructions <- function(device_code) {
  
  sprintf("Please activate your R session:\n*navigate to %s\n* and enter your user code: %s",
      device_code$verification_url,
      device_code$user_code)
  
}
