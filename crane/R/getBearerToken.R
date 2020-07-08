
#' Retrieve Bearer Token
#' @param url url
#' @param username username
#' @param password password
#' @param clientId client id
#' @param clientSecret client secret
#' @param realm realm
#' @param ... further arguments to \code{\link{POST}}
#' @importFrom httr modify_url POST stop_for_status content
#' @export
getBearerToken <- function(
    url,
    username,
    password,
    clientId,
    clientSecret,
    realm,
    ...) {
  
  url <- httr::modify_url(url,
      path = c("auth", "realms", realm, "protocol", "openid-connect", "token"))
  
  formBody <- list(
      "username" = username,
      "password" = password,
      "client_id" = clientId,
      "client_secret" = clientSecret,
      "audience" = clientId,
      "scope" = "openid",
      "grant_type" = "password")
  
  tokenRequestResponse <- POST(url, encode = "form", body = formBody, ...)
  
  httr::stop_for_status(tokenRequestResponse)
  
  paste(
      httr::content(tokenRequestResponse)$token_type,
      httr::content(tokenRequestResponse)$access_token)
  
}
