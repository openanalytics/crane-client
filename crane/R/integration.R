
#' @name options
#' @section Options:
#' * `crane.shim.verbose`: be verbose about extra actions in the [utils::download.file] shim (that is activated with [enable_install_packages_hook])
#' * `crane.debug.alwaysrefresh`: always refresh cached tokens even if they are not expired.
{}

#' Integration with install tooling in utils
#' @description insert a hook in \code{\link{install.packages}}
#' @name integration
#' @export
enable_install_packages_hook <- function() {
  tracingState(TRUE)  # to make sure trace has an effect
  expr <- quote(download.file <- crane::download_file_shim)
  trace(utils::install.packages, expr, print = FALSE)
  trace(utils::available.packages, expr, print = FALSE)
  trace(utils::download.packages, expr, print = FALSE)
  trace(utils::update.packages, expr, print = FALSE)
  invisible()
}
#' @name integration
#' @export
disable_install_packages_hook <- function() {
  untrace(utils::install.packages)
  untrace(utils::available.packages)
  untrace(utils::download.packages)
  untrace(utils::update.packages)
  invisible()
}
#' @name integration
#' @param url `url` argument to [utils::download.file]
#' @param ... further arguments to [utils::download.file]
#' @param headers `headers` argument to [utils::download.file]. The negotiated token will be added as a bearer token in an `Authorzation` header. If an `Authoryzation` header is already present, it will be replaced.
#' @export
download_file_shim <- function(url, ..., headers = NULL) {
  
  config <- read_config()
  repos <- match_repos(url, config)
  verbose <- get_crane_opt("shim", "verbose", default = TRUE)

  if (length(repos) > 0) {
    if (length(repos) > 1L) {
      warningf("More than one matching Crane repository found for url. Using the first match: %s", repos)
    }
    repo <- repos[1L]
    
    messagef("Authenticating request to Crane repository: %s", repo)
    
    token <- login(repo, verbose = verbose)
    
    headers <- c(
        headers[names(headers) != "Authorization"],
        "Authorization" = format_auth_header(token)
    )
  }
  
  utils::download.file(url = url, headers = headers, ...)
  
}

