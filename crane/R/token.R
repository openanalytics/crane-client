
get_device_code <- function(repo, client_id) {
  
  request <- device_code_request(repo, client_id)
  
  response <- perform(request)
  
  if (response$status_code != 200L)
    errorf("Could not obtain device code. Server responded with:\n%s",
        format_error_response(response))
  
  from_json(rawToChar(response$content))
  
}

poll_access_token <- function(repo, device_code, interval, expires_in) {
  
  for (i in seq_len(floor(expires_in / interval))) {
    
    tryCatch({
          
          return(get_access_token())
          
        }, error = function(e) {
          
          messagef("polling for access token: %s", e$message)
          
        })
    
    message("retrying in [%s]", interval)
    sleep(interval)
    
  }
  
  errorf("Polling for access token failed: code expired.")
  
}

get_access_token <- function(repo, device_code) {
  
  request <- access_token_request(repo, device_code)
  
  response <- perform(request)
  
  if (response$status_code != 200L)
    errorf("Could not obtain access token. Server responded with:\n%s",
        format_error_response(response))
  
  rawToChar(response$content)
  
}

device_code_request <- function(repo, client_id) {
  
  post_form_request(
      url = sprintf("%s/oauth2/device_code", repo),
      data = c(
          client_id = client_id,
          scope = "message.read openid"
      )
  )
  
}

access_token_request <- function(repo, client_id, device_code) {
  
  post_form_request(
      url = sprintf("%s/oauth2/token", repo),
      data = c(
          client_id = client_id,
          device_code = device_code,
          grant_type = "urn:ietf:params:oauth:grant-type:device_code"
      )
  )
  
}
