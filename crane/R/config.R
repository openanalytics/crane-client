
#' @name options
#' @section Options:
#' * `crane.config.file`: filepath to the config file for crane. See [default_config_file] for the default.
#' * `crane.config.autocreate`: automatically create the config file and its parent directories if it does not exist. 
{}

#' Default crane repository config file
#'
#' @description provides sensible default location
#' to store crane repository configuration.
#' 
#' @details The default is based on the XDG specification \url{https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html}. For more info, see \code{\link[tools]{R_user_dir}}
#' @export
default_config_file <- function() {
    file.path(
        tools::R_user_dir("crane", "config"), 
        "crane.json"
    )
}

#' Register settings for repository
#' 
#' @param repo repo url
#' @param client_id oauth2 client id
#' @param device_code_url endpoint to request the device code
#' @param token_url endpoint to request access tokens
#' @param config_file configuration file to store repository settings
#' @param autocreate_config_file create the configuration file and missing parent directories if it does not exist; `logical(1)`
#' @rdname register
#' 
#' @export 
register <- function(repo,
    client_id,
    device_code_url,
    token_url,
    config_file = get_crane_opt("config", "file",
      default = default_config_file()
    ),
    autocreate_config_file = get_crane_opt("config", "autocreate", default = TRUE)) {
  
  if (!is.character(client_id))
    errorf("`client_id` is not a character")
  if (!is.character(device_code_url))
    errorf("`device_code_url` is not a character")
  if (!is.character(token_url))
    errorf("`token_url` is not a character")
  
  if (!file_exists(config_file) && autocreate_config_file)
    create_empty_config(config_file)
  
  config <- read_config(config_file)
  
  config[[repo]] <- list(
      client_id = client_id,
      device_code_url = device_code_url,
      token_url = token_url
  )
  
  write_config(config, config_file)
  
  invisible()
  
}
#' @rdname register
#' @export
unregister <- function(
    repo,
    config_file = get_crane_opt("config", "file",
      default = default_config_file()
    )) {
  
  config <- read_config()
  config[[repo]] <- NULL
  write_config(config, config_file)
  
  invisible()
  
}

create_empty_config <- function(
    config_file = get_crane_opt("config", "file",
      default = default_config_file()
    )) {
    write_config(list(), config_file)
}

#' @importFrom jsonlite read_json
read_config <- function(
    config_file = get_crane_opt("config", "file",
      default = default_config_file()
    )) {
  
  if (!file_exists(config_file)) {
    list()
  } else {
    lst <- read_json(config_file, simplifyVector = TRUE)
    
    if (!is.null(lst)) lst else list()
  }
  
}

#' @importFrom jsonlite write_json
write_config <- function(lst, config_file) {
 
  if (!dir.exists(dirname(config_file))) {
    dir.create(dirname(config_file), recursive = TRUE)
  }

  write_json(lst, path = config_file, pretty = TRUE, auto_unbox = TRUE)
  
}

