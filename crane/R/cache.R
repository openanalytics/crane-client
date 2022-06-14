
#' @name options
#' @section Options:
#' * `crane.cache.persistent`: store cache in the filesystem.
#' * `crane.cache.dir`: directory to use to store cache. See [default_cache_dir] for the default.
{}

utils::globalVariables("cache")

cache <- new.env(hash = TRUE)

#' Default crane cache directory
#' 
#' @description provides a sensible default directory to
#' store crane cache.
#' 
#' @details The default is based on the XDG specification \url{https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html}. For more info, see \code{\link[tools]{R_user_dir}}
#'
#' @export
default_cache_dir <- function() {
    tools::R_user_dir("crane", "cache") 
}

cache_token <- function(
    repo,
    token,
    persistent = get_crane_opt("cache", "persistent", default = FALSE)
    ) {

  assign(repo, token, envir = cache)
  if (persistent) persist_cache()

}

cache_lookup_token <- function(
    repo,
    persistent = get_crane_opt("cache", "persistent", default = FALSE)
    ) {

  if (persistent) restore_cache()
  if (exists(repo, envir = cache))
    get(repo, envir = cache)
  else NULL

}

persist_cache <- function(
  cache_dir = get_crane_opt("cache", "dir", default = default_cache_dir())
  ) {

  if (!dir.exists(cache_dir))
    dir.create(cache_dir, recursive = TRUE)
  write_json(
    as.list(cache),
    file_path(cache_dir, "cache.json"))
}

restore_cache  <- function(
  cache_dir = get_crane_opt("cache", "dir", default = default_cache_dir())
  ) {

  tokens <- read_json(file_path(cache_dir, "cache.json"), simplifyVector = TRUE)
  for (repo in names(tokens)) {
    if (!exists(repo, envir = cache))
      assign(repo, tokens[[repo]], envir = cache)
  }
}

