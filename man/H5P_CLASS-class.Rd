% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/R6Classes_H5P.R
\docType{class}
\name{H5P_CLASS-class}
\alias{H5P_CLASS}
\alias{H5P_CLASS-class}
\title{Class for HDF5 property list classes (not HDF5 property lists)}
\value{
Object of class \code{\link[=H5P_CLASS-class]{H5P_CLASS}}.
}
\description{
It inherits all functions of the \code{\link{H5RefClass-class}}. The intent of this class is to
provide a mechanism to compare the class of HDf5 property classes. This is mainly intended for internal use
to get the class type of an HDF5 identifier that is known to be a property list, but not of which type.
}
\section{Methods}{

\describe{
\item{\code{equal}}{

\strong{Usage:}
\preformatted{equal(cmp)}
This function implements the HDF5-API function H5Pequal.
Please see the documentation at \url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5P.html#Property-Equal} for details.}
}}
\author{
Holger Hoefling
}
\seealso{
H5Class_overview, \code{\link[=H5P-class]{H5P}}
}

