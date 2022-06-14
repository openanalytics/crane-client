
with_default <- function(x, default) if (is.null(x)) default else x

`%?%` <- with_default

errorf <- function(fmt, ...) stop(sprintf(fmt, ...), call. = FALSE)

warningf <- function(fmt, ...) warning(sprintf(fmt, ...), call. = FALSE)

messagef <- function(fmt, ...) message(sprintf(fmt, ...))

sleep <- function(seconds) Sys.sleep(time = seconds)

from_json <- function(txt) jsonlite::fromJSON(txt)

read_json <- function(path, ...) jsonlite::read_json(path, ...)

write_json <- function(x, path, ...) jsonlite::write_json(x, path, ...)

nd <- function(...) paste(c(...), collapse = "\n")

file_exists <- function(...) file.exists(...)

unix_time_now <- function() as.integer(strftime(Sys.time(), format = "%s"))

browse_url <- function(url, ...) utils::browseURL(url, ...) 

file_path <- function(...) file.path(...)
