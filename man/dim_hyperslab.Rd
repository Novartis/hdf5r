% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/high_level_UI.R
\name{dim_hyperslab}
\alias{dim_hyperslab}
\title{Analyze arguments passed to '[' function for hyperslab}
\usage{
dim_hyperslab(x, envir)
}
\arguments{
\item{x}{The dimension arguments (as passed to a '[' function)}

\item{envir}{The environment in which the arguments are to be evaluated}
}
\value{
return an object of class \code{hyperslab} by function \link{hyperslab} that overloads a dataframe and
describes one dimension of a hyperslab
}
\description{
Analyze arguments passed to '[' function for hyperslab
}
\details{
It takes as argument \code{x} an index as is usually pased for a dimension to '['. Instead of just calculating
the index values itself, non-standard evaluation is used to capture the functions \code{:}, \code{seq} and \code{seq_len}
and convert these into the appropriate values as needed by HDF5 to describe a hyperslab, i.e. \code{start}, \code{count},
\code{stride} and \code{block}.

If none of these functions are present, the index vector is checked if it has constant differences between consecutive
values - then this will also be converted to a hyperslab. Otherwise, a hyperslab object \code{\link{hyperslab}} will be returned
with all values set to NA.
}
\author{
Holger Hoeflng
}
\keyword{internal}

