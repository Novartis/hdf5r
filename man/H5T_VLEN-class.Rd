% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/R6Classes_H5T.R
\docType{class}
\name{H5T_VLEN-class}
\alias{H5T_VLEN}
\alias{H5T_VLEN-class}
\title{Class for HDF5 variable-length datatypes.}
\value{
Object of class \code{\link[=H5T_VLEN-class]{H5T_VLEN}}.
}
\description{
Inherits from class \code{\link[=H5T-class]{H5T}}.
}
\section{Methods}{

\describe{
\item{\code{new}}{

\strong{Usage:}
\preformatted{new(dtype_base, id = NULL)}
Create a variable length datatype

\strong{Parameters:}
\describe{
\item{dtype_base}{The basis-type of the variable length datatype}
\item{id}{Internal use only}
}}

\item{\code{get_super}}{

\strong{Usage:}
\preformatted{get_super()}
This function implements the HDF5-API function H5Tget_super.
Please see the documentation at \url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5T.html#Datatype-GetSuper} for details.}

\item{\code{describe}}{

\strong{Usage:}
\preformatted{describe()}
Print a detailed description of the datatype; this is experimental}
}}
\author{
Holger Hoefling
}
\seealso{
H5Class_overview, \code{\link[=H5T-class]{H5T}}
}

