
# Crane

Crane helps you install packages from CRAN-like private R repositories in a secure way.

Authentication is accomplished via the [Device Authorization Grant](https://oauth.net/2/device-flow/) in OAuth 2.0.

To keep dependencies minimal, the pacakge uses `curl` to make requests to the authorization service (instead of higher-level package like `httr` or `crul`).

## Install

From GitHub:
```
install.packages('remotes')
remotes::install_github("openanalytics/crane-client", subdir = "crane")
```

## Registering a repository

Before installing packages from a oauth2-protected private repository you need to tell `crane` about it.

Repository configuration is kept in a `crane.json` file.
The default location will be in your home directory, but you can change it by setting the R option `crane.repo.config` or the environment variable `CRANE_REPO_CONFIG`.

To register a repository, you need a *client id*, *device_code_url* and *token_url*. These should be supplied to you by your authorization service.

```R
crane::register(
    "https://my-repo-url",
    client_id = "R",
    device_code_url = "http://localhost:8080/auth/realms/master/protocol/openid-connect/auth/device",
    token_url = "http://localhost:8080/auth/realms/master/protocol/openid-connect/token",
)
```

You only need to register the repo once unless you remove the `crane.json` file.

## Authenticated Installs

Once registered, you can install packages from a private repository by using `crane::install()`:

```R
crane::install("foo", "https://my-repo-url")
```

## install.packages

Alternatively, you can enable integration with `utils::install.packages()` using `crane::enable_install_packages_hook()`. 

You can either run this in your R session before using `install.packages` or put it in your `.Rprofile` to always have it enabled.
To disable the integration, you can run `crane::disable_install_packages_hook()`.

The hook will only attach a token whenever `install.packages` sends a request to a matching registered private repository.
This means you can safely mix installs to private and public repositories:

```R
install.packages(c("privatePkg", "publicDependencyOfPrivatePkg"), repos = c("https://cloud.r-project.org", "https://my-repo-url"))
```

## roadmap

* CRAN release
* integration with [`pak`](https://github.com/r-lib/pak)

