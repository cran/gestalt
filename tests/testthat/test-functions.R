test_that("can make unary functions without default values", {
  expect_equal(fn(x ~ x + 1), function(x) x + 1)
  expect_equal(fn_(x ~ x + 1), function(x) x + 1)
})

test_that("can make unary functions with default values", {
  expect_equal(fn(x = 1 ~ x + 1), function(x = 1) x + 1)
  expect_equal(fn_(x = 1 ~ x + 1), function(x = 1) x + 1)
})

test_that("can make variadic functions", {
  expect_equal(fn(... ~ list(...)), function(...) list(...))
  expect_equal(fn_(... ~ list(...)), function(...) list(...))
})

test_that("can make multi-argument functions without default values", {
  expect_equal(fn(x, y ~ x + y), function(x, y) x + y)
  expect_equal(fn_(x, y ~ x + y), function(x, y) x + y)
})

test_that("can make multi-argument functions with default values", {
  expect_equal(fn(x, y = 0 ~ x + y), function(x, y = 0) x + y)
  expect_equal(fn(x, y = x ~ x + y), function(x, y = x) x + y)
  expect_equal(fn(x = 0, y ~ x + y), function(x = 0, y) x + y)
  expect_equal(fn(x = y, y ~ x + y), function(x = y, y) x + y)
  expect_equal(fn(x = 0, y = 1 ~ x + y), function(x = 0, y = 1) x + y)
  expect_equal(fn_(x, y = 0 ~ x + y), function(x, y = 0) x + y)
  expect_equal(fn_(x, y = x ~ x + y), function(x, y = x) x + y)
  expect_equal(fn_(x = 0, y ~ x + y), function(x = 0, y) x + y)
  expect_equal(fn_(x = y, y ~ x + y), function(x = y, y) x + y)
  expect_equal(fn_(x = 0, y = 1 ~ x + y), function(x = 0, y = 1) x + y)
})

test_that("can make multi-argument, variadic functions", {
  expect_equal(fn(x, y, ... ~ x + y), function(x, y, ...) x + y)
  expect_equal(fn(x, ... = , y ~ x + y), function(x, ..., y) x + y)
  expect_equal(fn(x, y = 1, ... ~ x + y), function(x, y = 1, ...) x + y)
  expect_equal(fn(x, ... = , y = 1 ~ x + y), function(x, ..., y = 1) x + y)
  expect_equal(fn_(x, y, ... ~ x + y), function(x, y, ...) x + y)
  expect_equal(fn_(x, ... = , y ~ x + y), function(x, ..., y) x + y)
  expect_equal(fn_(x, y = 1, ... ~ x + y), function(x, y = 1, ...) x + y)
  expect_equal(fn_(x, ... = , y = 1 ~ x + y), function(x, ..., y = 1) x + y)
})

test_that("can get a function with empty signature, when LHS is empty", {
  expect_equal(fn(~NULL), function() NULL)
  expect_equal(fn_(~NULL), function() NULL)
})

test_that("can accept a separating comma, between the arguments and body", {
  expect_equal(fn(x, ~ NULL), function(x) NULL)
  expect_equal(fn(... = , ~ NULL), function(...) NULL)
  expect_equal(fn(x = 1, ~ NULL), function(x = 1) NULL)
  expect_equal(fn_(x, ~ NULL), function(x) NULL)
  expect_equal(fn_(... = , ~ NULL), function(...) NULL)
  expect_equal(fn_(x = 1, ~ NULL), function(x = 1) NULL)
})

test_that("body can be a closure", {
  foo  <- function(x) function(y) x + y
  expect_equal(foo, fn(x ~ function(y) x + y))
  expect_equal(foo, fn(x ~ !!function(y) x + y))
  expect_equal(foo, fn(x ~ !!fn(y ~ x + y)))
  expect_equal(foo, fn(x ~ !!fn_(y ~ x + y)))
  expect_equal(foo, fn_(x ~ function(y) x + y))
})
