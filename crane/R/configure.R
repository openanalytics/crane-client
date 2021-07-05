
#' Register client id for repository
#' @param repo repo
#' @param client_id oauth2 client id
#' @export 
register <- function(repo, client_id) {
  
  if (!is.character(client_id)) errorf("`client_id` is not a character")
  
  .globals[[repo]] <- client_id
  
}

get_client_id <- function(repo) {
  if (repo %in% names(.globals)) {
    .globals[[repo]]
  } else {
    errorf("Repository not registered: %s", repo)
  }  
}
