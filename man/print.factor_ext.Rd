% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/factor_ext.R
\name{print.factor_ext}
\alias{print.factor_ext}
\title{Print an \code{factor_ext} object to the screen}
\usage{
\method{print}{factor_ext}(x, quote = FALSE, max.levels = NULL,
  width = getOption("width"), ...)
}
\arguments{
\item{x}{\code{factor_ext} object to print}

\item{quote}{Should they be quoted}

\item{max.levels}{Maximum number of levels to print}

\item{width}{Width of how much to print for the levels and values}

\item{...}{Currently ignored}
}
\value{
The object to print itsef, invisibly
}
\description{
Print an \code{factor_ext} object to the screen
}
\details{
Printing an \code{factor_ext} object. Adapted from \code{\link{print.factor}}.
}
\author{
Holger Hoefling
}
\seealso{
\code{\link{print.factor}}
}

