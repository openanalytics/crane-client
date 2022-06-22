
#' Install one or more packages from a Crane repository
#' @param pkgs packages to install
#' @param compatibility_patch patch older versions of available.packages to accept a dots argument
#' @inheritParams login
#' @export
install <- function(
    pkgs,
    repo,
    compatibility_patch = R.Version()$major < 4) {
  
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
   
    token <- login(repo)
    
    check_access(repo, token, force = TRUE)
    
    utils::install.packages(pkgs,
        repos = repo,
        headers = c("Authorization" = format_auth_header(token)))
    
  }
  
}

