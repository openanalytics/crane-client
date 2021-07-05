
#' @importFrom xml2 read_xml xml_text
format_error_response <- function(response) {
  
  if (response$status_code < 400) stop("Not an error response.")
  if (response$type != "text/html")
    errorf("Cannot format error response; unrecognized content type: %s",
        response$type)
  
  xml_text(read_xml(rawToChar(response$content), as_html = TRUE))
  
}

#' @importFrom curl handle_data curl_fetch_memory
perform <- function(request) {
  curl_fetch_memory(handle_data(request)$url, request)
}

#' Build a POST request
#' @description build a POST request with data encoded in
#' @param url request url
#' @param data named character of request data
#' \code{appplication/x-www-form-urlencoded}
#' @importFrom curl new_handle curl handle_setheaders handle_setopt curl_escape
post_form_request <- function(url, data) {
  
  h <- new_handle()
  
  h <- handle_setheaders(h,
      "Content-Type" = "application/x-www-form-urlencoded"
  )
  
  h <- handle_setopt(h,
      url = url,
      post = 1L,
      copypostfields = paste(collapse = "&",
          sprintf("%s=%s", curl_escape(names(data)), curl_escape(data))
      )
  )
  
  h
  
}