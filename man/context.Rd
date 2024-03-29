% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/context.R
\name{context}
\alias{context}
\alias{let}
\alias{run}
\title{Run an Action in an Ordered Context}
\usage{
let(`_data` = parent.frame(), ...)

run(`_data` = parent.frame(), `_expr`, ...)
}
\arguments{
\item{_data}{Context of named values, namely an environment, list or data
frame; if a list or data frame, it is interpreted as an environment (like
the \code{envir} argument of \code{\link[=eval]{eval()}}).}

\item{...}{Named expressions. An expression looks up values to the left of
it, and takes precedence over those in \code{`_data`}.
\link[rlang:topic-inject]{Quasiquotation} of names and expressions is
supported (see \sQuote{Examples}).}

\item{`_expr`}{Expression to evaluate (\dQuote{run}). Quasiquotation is
supported.}
}
\value{
\code{run()} returns the evaluation of \code{`_expr`} in the combined
environment of \code{`_data`} and \code{...}.

\code{let()} returns an environment where the bindings in \code{...} are in scope, as
\link[=delayedAssign]{promises}, as if they were assigned from left to right in
a child of the environment defined by \code{`_data`}.
}
\description{
Programming in R typically involves:
\enumerate{
\item Making a context: assigning values to names.
\item Performing an action: evaluating an expression relative to a context.
}

\code{let()} and \code{run()} enable you to treat these procedures as reusable,
\emph{composable} components.
\itemize{
\item \code{let()} makes a \strong{context}: it \emph{lazily} binds a sequence of ordered
named expressions to a child of a given environment (by default, the
current one).

For instance, in an environment \code{env} where \code{z} is in scope,

\if{html}{\out{<div class="sourceCode">}}\preformatted{  let(env, x = 1, y = x + 2, z = x * y * z)
}\if{html}{\out{</div>}}

is equivalent to calling

\if{html}{\out{<div class="sourceCode">}}\preformatted{  local(\{
    x <- 1
    y <- x + 2
    z <- x * y * z
    environment()
  \})
}\if{html}{\out{</div>}}

except \code{let()} binds the named expressions lazily (as
\link[=delayedAssign]{promises}) and comprehends tidyverse
\link[rlang:topic-inject]{quasiquotation}.
\item \code{run()} performs an \strong{action}: it evaluates an expression relative to an
environment (by default, the current one) and, optionally, a sequence of
\emph{lazily evaluated} ordered named expressions.

For instance, in an environment \code{env} where \code{x} is in scope,

\if{html}{\out{<div class="sourceCode">}}\preformatted{  run(env, x + y + z, y = x + 2, z = x * y * z)
}\if{html}{\out{</div>}}

is equivalent to calling

\if{html}{\out{<div class="sourceCode">}}\preformatted{  local(\{
    y <- x + 2
    z <- x * y * z
    x + y + z
  \})
}\if{html}{\out{</div>}}

except \code{run()}, like \code{let()}, binds \code{y} and \code{z} lazily and comprehends
quasiquotation.
}
}
\section{Composing Contexts}{

\strong{Contexts}, as made by \code{let()}, have an advantage over ordinary local
assignments because contexts are both lazy and composable. Like
assignments, the order of named expressions in a context is significant.

For example, you can string together contexts to make larger ones:

\if{html}{\out{<div class="sourceCode">}}\preformatted{  foo <-
    let(a = ., b = a + 2) \%>>>\%
    let(c = a + b) \%>>>\%
    run(a + b + c)

  foo(1)
  #> [1] 8
}\if{html}{\out{</div>}}

Earlier bindings can be overriden by later ones:

\if{html}{\out{<div class="sourceCode">}}\preformatted{  bar <-
    foo[1:2] \%>>>\%        # Collect the contexts of 'foo()'
    let(c = c - 1) \%>>>\%  # Override 'c'
    run(a + b + c)

  bar(1)
  #> [1] 7
}\if{html}{\out{</div>}}

Bindings are \link[=delayedAssign]{promises}; they are only evaluated on
demand:

\if{html}{\out{<div class="sourceCode">}}\preformatted{  run(let(x = a_big_expense(), y = "avoid a big expense"), y)
  #> [1] "avoid a big expense"
}\if{html}{\out{</div>}}
}

\section{Remark}{

\dQuote{Contexts} as described here should not be confused with
\dQuote{contexts} in
\href{https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Contexts}{R's internal mechanism}.
}

\examples{
# Miles-per-gallon of big cars
mtcars$mpg[mtcars$cyl == 8 & mtcars$disp > 350]
run(mtcars, mpg[cyl == 8 & disp > 350])
run(mtcars, mpg[big_cars], big_cars = cyl == 8 & disp > 350)

# 'let()' makes a reusable local context for big cars
cars <- let(mtcars, big = cyl == 8 & disp > 350)

eval(quote(mpg[big]), cars)  # Quoting restricts name lookup to 'cars'
run(cars, mpg[big])          # The same, but shorter and more transparent

run(cars, wt[big])
mtcars$wt[mtcars$cyl == 8 & mtcars$disp > 350]

# Precedence of names is from right to left ("bottom-up"):
a <- 1000
run(`_expr` = a + b, a = 1, b = a + 2)    # 4: all references are local
run(list(a = 1), a + b, b = a + 2)        # 4: 'b' references local 'a'
run(let(a = 1, b = a + 2), a + b)         # 4: 'b' references local 'a'
run(let(a = 1, b = a + 2), a + b, a = 0)  # 3: latter 'a' takes precedence
run(list(a = 1, b = a + 2), a + b)        # 1003: 'b' references global 'a'

# Bound expressions are lazily evaluated: no error unless 'x' is referenced
run(`_expr` = "S'all good, man.", x = stop("!"))
run(let(x = stop("!")), "S'all good, man.")
let(x = stop("!"))    # Environment binding 'x'
try(let(x = stop("!"))$x)  # Error: !

# Quasiquotation is supported
a <- 1
run(let(a = 2), a + !!a)               #> [1] 3
run(let(a = 1 + !!a, b = a), c(a, b))  #> [1] 2 2

}
\seealso{
\code{\link[=with]{with()}} is like \code{run()}, but more limited because it doesn't
support quasiquotation or provide a means to override local bindings.
}
