
discover_repo <- function(repo) {
  
  list(
      repo = repo,
      device_code_url = registered_repo(repo)$device_code_url,
      token_url = registered_repo(repo)$token_url,
      client_id = registered_repo(repo)$client_id
  )
}

check_access <- function(repo, token = NULL, force = FALSE) {
  
  request <- packagelist_request(repo, token)
  
  if (!is.null(token)) 
    request <- authenticate(request, token)
  
  response <- perform(request)
  
  if (force && response$status_code != 200L)
    errorf("Cannot access repository. Server responded with:\n%s",
        format_error_response(response))
  
  response$status_code == 200L
  
}

packagelist_request <- function(url, token = NULL) {
  h <- new_handle()
  
  h <- handle_setopt(h,
      url = sprintf("%s/src/contrib/PACKAGES", url)
  )
  
  h
}

authenticate <- function(request, token) {
  request <- handle_setheaders(request,
      "Authorization" = format_auth_header(token)
  )
  request
}

format_auth_header <- function(token) {
  sprintf("Bearer %s", token$access_token)
}
