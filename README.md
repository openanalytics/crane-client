
# crane 

`crane` helps you install packages from CRAN-like private R repositories in a secure way.

Authentication is accomplished via the [Device Authorization Grant](https://oauth.net/2/device-flow/) in OAuth 2.0.
Crane has been designed to work well with the [crane repository server](https://github.com/openanalytics/crane) and [RDepot](https://rdepot.io)
but should work with any repository server acting as an OAuth2 resource server and OAuth2 authorization server that supports OIDC and the device authorization grant. 

## Install

From GitHub:

```R
install.packages('remotes')
remotes::install_github("openanalytics/crane-client", subdir = "crane")
```

## Registering a repository

Before installing packages from a oauth2-protected private repository you need to tell `crane` about it.

Repository configuration is kept in a configuration file.
The default location for this file is based on the XDG specification (see `?default_config_file`). You can change this by setting the R option `crane.repo.config` or the environment variable `CRANE_REPO_CONFIG`.

To register a repository, you need a *client id*, *device_code_url* and *token_url*.
These should be supplied to you by your authorization service.

```R
crane::register(
    "https://my-repo-url",
    client_id = "R",
    device_code_url = "https://my-auth-server/protocol/openid-connect/auth/device",
    token_url = "http://my-auth-server/protocol/openid-connect/token",
)
```

You only need to register the repo once unless you remove the `crane.json` file.

## Authenticated Installs

Once registered, you can install packages from a private repository by using `crane::install()`:

```R
crane::install("foo", "https://my-repo-url")
```

## install.packages

Alternatively, you can enable integration with `utils::install.packages()`:

```R
`crane::enable_install_packages_hook()` 
```

You can either run this in your R session before using `install.packages` or put it in your `.Rprofile` to always have it enabled.
Run `crane::disable_install_packages_hook()` to disable the integration again.

The hook will only attach a token whenever `install.packages` sends a request to a matching registered private repository.
This means you can safely mix installs to private and public repositories:

```R
install.packages(c("privatePkg", "publicDependencyOfPrivatePkg"), repos = c("https://cloud.r-project.org", "https://my-repo-url"))
```

## User Options

You can configure a variety of settings through R options and environment variables. See `?crane::options` for an overview of availble options and more info.

Learn more at https://crane.rdepot.io

**(c) Copyright Open Analytics NV, 2021-2022 - Apache License 2.0**

