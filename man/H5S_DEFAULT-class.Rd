% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/R6Classes_H5S.R
\docType{class}
\name{H5S_DEFAULT-class}
\alias{H5S_DEFAULT}
\alias{H5S_DEFAULT-class}
\title{Class for HDF5 default space}
\value{
Object of class \code{\link[=H5S_DEFAULT-class]{H5S_DEFAULT}}.
}
\description{
It inherits all functions of the \code{\link{H5S-class}}. As this is implemented, this is likely not the best choice as almost
all functions that work for H5S-class objects will fail. It is likely better to implement this as a separate default class,
avoid the id-tracking associated with it (which doesn't make sense anyway). Should find a better way to handle this.
}
\section{Methods}{

\describe{
\item{\code{new}}{

\strong{Usage:}
\preformatted{new(id)}
NO DOCUMENTATION AVAILABLE}
}}
\author{
Holger Hoefling
}
\seealso{
H5Class_overview, \code{\link[=H5S-class]{H5S}}
}

