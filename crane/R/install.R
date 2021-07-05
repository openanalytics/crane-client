
#' Install one or more packages from a Crane repository
#' @param pkgs packages to install
#' @param repo crane repo url
#' @export
install <- function(pkgs, repo, compatibility_patch = R.Version()$major < 4) {
  
  if (check_access(repo, token = NULL)) {
    messagef("Repo is public: %s", repo)
    install.packages(pkgs, repos = repo)
  } else {
    
    repo_config <- discover_repo(repo)
    
    if (compatibility_patch) {
      available.packages <- utils::available.packages
      body(available.packages)[[7]][[4]][[3]][[4]][[4]][[3]][[4]][[3]][[2]][[2]][[8]] <- quote(...)
      body(available.packages)[[7]][[4]][[3]][[4]][[4]][[3]][[7]][[3]][[6]][[3]][[2]][[2]][[8]] <- quote(...)
      unlockBinding("available.packages", getNamespace("utils"))
      assign("available.packages", available.packages, envir = getNamespace("utils"))
      lockBinding("available.packages", getNamespace("utils"))
    }
    
    device_code <- get_device_code(
        repo_config$device_code_url,
        repo_config$client_id)
    
    message(format_activation_instructions(device_code))
    
    token <- poll_access_token(
        repo_config$token_url,
        repo_config$client_id,
        device_code)
    
    check_access(repo, token)
    
    utils::install.packages(pkgs,
        repos = repo,
        headers = c("Authorization" = format_auth_header(token)))
    
  }
  
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
