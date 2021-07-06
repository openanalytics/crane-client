
#' Integration with install tooling in utils
#' @description insert a hook in \code{\link{install.packages}}
#' @name integration
#' @export
enable_install_packages_hook <- function() {
   expr <- quote(download.file <- crane::download_file_wrapper)
   trace(utils::install.packages, expr, print = FALSE)
   trace(utils::available.packages, expr, print = FALSE)
   trace(utils::download.packages, expr, print = FALSE)
   invisible()
}
#' @name integration
#' @export
disable_install_packages_hook <- function() {
  untrace(utils::install.packages)
  untrace(utils::available.packages)
  untrace(utils::download.packages)
  invisible()
}
#' @name integration
#' @export
download_file_wrapper <- function(url, ..., headers = NULL) {
  
  config <- read_config()
  repos <- match_repos(url, config)
  
  if (length(repos) > 0) {
    if (length(repos) > 1L) {
      warningf("More than one matching Crane repository found for url. Using the first match: %s", repos)
    }
    repo <- repos[1L]
    
    messagef("Authenticating request to Crane repository: %s", repo)
    
    repo_config <- discover_repo(repo, config)
    
    config_file <- getOption("crane.repo.config", Sys.getenv("CRANE_REPO_CONFIG", "~/crane.json"))
    
    token <- device_authorization_flow(repo_config)
    headers <- c(
        headers,
        "Authorization" = format_auth_header(token)
    )
  }
  
  utils::download.file(url = url, headers = headers, ...)
  
}