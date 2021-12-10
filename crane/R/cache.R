
cache <- new.env(hash = TRUE)

cache_token <- function(repo, token) {

  cache[[repo]] <- token

}

cache_lookup_token <- function(repo) {

  cache[[repo]]

}
