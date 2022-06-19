
test_that("cache roundtrip", {
  cache_token("foorepo", "bartoken", persistent = FALSE)
  expect_equal(
    cache_lookup_token("foorepo", persistent = FALSE),
    "bartoken"
  )
})

test_that("cache persistent roundtrip", {
  cache_dir <- file_path(tempdir(), "cache")
  cache_token("foorepo", "bartoken", persistent = TRUE, cache_dir = cache_dir)
  cache_token("foorepo", "biztoken", persistent = FALSE)
  expect_equal(
    cache_lookup_token("foorepo", persistent = TRUE, cache_dir = cache_dir),
    "bartoken"
  )
  cache_clear(persistent = FALSE)
  expect_equal(
    cache_lookup_token("foorepo", persistent = TRUE, cache_dir = cache_dir),
    "bartoken"
  )
})

test_that("missing cache file", {
  expect_silent(
    restore_cache(file_path(tempdir(), "non/existent/dir"))
  )
})

