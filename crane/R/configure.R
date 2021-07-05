
#' Register client id for repository
#' @param repo repo
#' @param client_id oauth2 client id
#' @export 
register <- function(repo, client_id, device_code_url, token_url) {
  
  if (!is.character(client_id)) errorf("`client_id` is not a character")
  
  .globals[[repo]] <- list(
      client_id = client_id,
      device_code_url = device_code_url,
      token_url = token_url
  )
  
}

registered_repo <- function(repo) {
  if (repo %in% names(.globals)) {
    .globals[[repo]]
  } else {
    errorf("Repository not registered: %s", repo)
  }  
}

get_client_id <- function(repo) {
  registered_repo(repo)$client_id
}
