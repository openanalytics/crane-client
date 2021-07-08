
discover_repo <- function(repo, config) {
  list(
      repo = repo,
      device_code_url = config[[repo]]$device_code_url,
      token_url = config[[repo]]$token_url,
      client_id = config[[repo]]$client_id
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
  
  e <- tryCatch({
        index <- rawToChar(response$content)
        tmpIndexFile <- tempfile()
        writeLines(index, tmpIndexFile)
        read.dcf(tmpIndexFile)
        NULL
      }, error = identity)
  if (force && !is.null(e)) errorf("Cannot parse packages index: %s", e$message)
  
  response$status_code == 200L && is.null(e)
  
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

match_repos <- function(url, config) {
  
  if (length(url) != 1L) stop("expected length 1 `url`")
  
  names(config)[startsWith(url, names(config))]
  
}