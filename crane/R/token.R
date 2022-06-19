
#' @name options
#' @section Options:
#' * `crane.poll.verbose`: poll verbosely for access token
#' * `crane.device.offline`: request an offline refresh token. If enabled, this
#'   adds the `offline_access` OIDC scope.
#' * `crane.device.scope`: extra scopes to add to the device authorization code
#'   request
{}

get_device_code <- function(url, client_id) {
  
  request <- device_code_request(url, client_id)
  
  response <- perform(request)
  
  if (response$status_code != 200L)
    errorf("Could not obtain device code. Server responded with:\n%s",
        format_error_response(response))
  
  from_json(rawToChar(response$content))
  
}

poll_access_token <- function(
    url,
    client_id,
    device_code,
    interval = device_code$interval,
    expires_in = device_code$expires_in,
    verbose = get_crane_opt("poll", "verbose", default = FALSE)) {
  
  last_response <- "(no response)"
  
  for (i in seq_len(floor(expires_in / interval))) {
    
    tryCatch({
          
          return(get_access_token(url, client_id, device_code))
          
        }, error = function(e) {
          
          last_response <- e$message
          
          if (verbose) messagef("polling for access token: %s", e$message)
          
          #FIXME grepping the error message is not ideal
          # error handling should be revised
          if (!grepl("authorization_pending", e$message)) {
            errorf("Polling for access token failed: Unexpected response.\n\t%s", e$message)
          }
          
        })
    
    if (verbose) messagef("retrying in [%s]", interval)
    sleep(interval)
    
  }
  
  errorf("Polling for access token failed: code expired. Last response: %s",
      last_response)
  
}

get_access_token <- function(
    url,
    client_id,
    device_code) {
  
  request <- access_token_request(url, client_id, device_code)
  
  response <- perform(request)
  
  if (response$status_code != 200L)
    errorf("Could not obtain access token. Server responded with:\n%s",
        format_error_response(response))
  
  token <- from_json(rawToChar(response$content))
  
  token$obtained <- unix_time_now()
  token$refresh_obtained <- unix_time_now()
  
  token
  
}

refresh_access_token <- function(
  url,
  client_id = client_id,
  refresh_token,
  scope = character()) {

  request <- refresh_access_token_request(
    url,
    client_id = client_id,
    refresh_token,
    scope)

  response <- perform(request)

  if (response$status_code != 200L)
    errorf("Could not refresh access token. Server responded with: \n%s", format_error_response(response))

  token <- from_json(rawToChar(response$content))

  token$obtained <- unix_time_now()

  token

}

merge_token <- function(old_token, new_token) {

  for (name in names(new_token)) {
    old_token[[name]] <- new_token[[name]]
  }

  old_token

}

is_expired <- function(
    token,
    tol = floor(token$expires_in / 10)) {
  
  (unix_time_now() - token$obtained) > (token$expires_in - tol)
  
}

is_refresh_expired <- function(
  token,
  tol = floor(token$refresh_expires_in / 10)) {

  if (token$refresh_expires_in == 0L) FALSE
  else {
    (unix_time_now() - token$refresh_obtained) > (token$refresh_expires_in - tol)
  }
}

device_code_request <- function(
    url,
    client_id,
    offline_access = get_crane_opt("device", "offline", default = FALSE),
    scope = get_crane_opt("device", "scope", default = character())) {

  post_form_request(
      url = url,
      data = c(
          client_id = client_id,
          scope = format_scope(c(
              "message.read",
              "openid",
              if (offline_access) "offline_access",
              scope
          ))
      )
  )
  
}

access_token_request <- function(
    url,
    client_id,
    device_code) {
  
  post_form_request(
      url = url,
      data = c(
          client_id = client_id,
          device_code = device_code$device_code,
          grant_type = "urn:ietf:params:oauth:grant-type:device_code"
      )
  )
  
}

refresh_access_token_request <- function(
    url,
    client_id,
    refresh_token,
    scope = character()) {

  post_form_request(
    url = url,
    data = c(
      grant_type = "refresh_token",
      client_id = client_id,
      refresh_token = refresh_token,
      scope = format_scope(scope)
    )
  )
}

format_scope <- function(scope) {
  if (!is.character(scope)) errorf("`scope` must be character()")
  paste(scope, collapse = " ")
}

