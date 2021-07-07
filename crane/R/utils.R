
with_default <- function(x, default) if (is.null(x)) default else x

`%?%` <- with_default

errorf <- function(fmt, ...) stop(sprintf(fmt, ...), call. = FALSE)

warningf <- function(fmt, ...) warning(sprintf(fmt, ...), call. = FALSE)

messagef <- function(fmt, ...) message(sprintf(fmt, ...))

sleep <- function(seconds) Sys.sleep(time = seconds)

from_json <- function(txt) jsonlite::fromJSON(txt)

nd <- function(...) paste(c(...), collapse = "\n")

file_exists <- file.exists

unix_time_now <- function() as.integer(strftime(Sys.time(), format = "%s"))
