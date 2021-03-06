% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/polySolve.r
\name{polySolve}
\alias{polySolve}
\title{Solve a System of Polynomial Equations}
\usage{
polySolve(lhs, rhs, varOrder, ...)
}
\arguments{
\item{lhs}{a mpolyList or character vector of left hand sides}

\item{rhs}{a mpolyList or character vector of right hand sides}

\item{varOrder}{variable order (see examples)}

\item{...}{stuff to pass to bertini}
}
\value{
an object of class bertini
}
\description{
\code{polySolve} solves a system of polynomial equations, specifiable in any
of several ways.
}
\examples{
\dontrun{

# it can solve linear systems 
# (here where the line y = x intersects y = 2 - x)
polySolve(c("y", "y"), c("x", "2 - x"), c("x", "y"))

# or nonlinear systems
polySolve(c("y", "y"), c("x^2", "2 - x^2"), c("x", "y"))

# perhaps an easier specification is equations themselves
# with either the " = " or " == " specifications
# varOrder is used to order the solutions returned
polySolve(c("y = x^2", "y = 2 - x^2"), varOrder = c("x", "y"))
polySolve(c("y == x^2", "y == 2 - x^2"), varOrder = c("x", "y"))


# mpoly objects can be given instead of character strings
lhs <- mp(c("y - (2 - x)", "x y"))
rhs <- mp(c("0","0"))
polySolve(lhs, rhs, varOrder = c("x", "y"))

# if no default right hand side is given, and no "=" or "==" is found,
# rhs is taken to be 0's.
# below is where the lines y = x and y = -x intersect the unit circle
polySolve(c("(y - x) (y + x)", "x^2 + y^2 - 1"))

# the output object is a bertini object
out <- polySolve(c("(y - x) (y + x)", "x^2 + y^2 - 1"))
str(out,1)

# here is the code that was run :
cat(out$bertiniCode)

# the finite and real solutions:
out$finite_solutions
out$real_finite_solutions




# example from Riccomagno (2008), p. 399
polySolve(c(
  "x (x - 2) (x - 4) (x - 3)",
  "(y - 4) (y - 2) y",
  "(y - 2) (x + y - 4)",
  "(x - 3) (x + y - 4)"
))

}

}
\seealso{
\code{\link{variety}}, \code{\link{bertini}}
}
