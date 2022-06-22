
#' Crane User Options
#'
#' @rdname options 
#' @description Consolidate and lookup user configuration,
#' which can be set both via environment variables and R 
#' options.
#' @param ... `character(1)` option key where each key level is given as a separate arg. The top-level \code{crane} is implied and does not need to be provided.
#' @param default default object to return if no value is set via an R base option or environment variable
#' 
#' @details the matching environment variable for an option can be found by dot separtors with underscores and uppercasing all letters. For example, the R option `crane.config.file` matches the environment variable `CRANE_REPO_CONFIG`.
#' If an option is set both via [base::options] and as an environment variable, the value set via an option will take precedence.
#'
#' @export
get_crane_opt <- function(..., default = NULL) {
    key <- c("crane", as.character(c(...)))

    base_opt <- getOption(paste(key, collapse = "."))
    if (!is.null(base_opt))
      return(base_opt)

    env_opt <- Sys.getenv(paste(base::toupper(key), collapse = "_"))
    if (env_opt != "")
      parse_env_opt(env_opt)
    else default
}

parse_env_opt <- function(env_opt) {
    from_json(env_opt)
}

