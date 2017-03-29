#' h5 wrapper functions
#' 
#' Wrapper functions to provide h5 compatible interface.
#' @param object H5RefClass; H5 Reference Class to be used
#' @param name character; Group/Filename to be created
#' @param ... Additional Parameters passed to \code{file$create_group}, \code{file$create_dataset}
#' @rdname h5-wrapper
#' @export
h5file <- H5File$new

#' @rdname h5-wrapper
#' @export
createGroup <- function(object, name, ...) object$create_group(name, ...)

#' @rdname h5-wrapper
#' @export
createDataSet <- function(object, name, ...) object$create_dataset(name, ...)

#' @rdname h5-wrapper
#' @export
h5close <- function(object) object$close()

#' @rdname h5-wrapper
#' @export
h5flush <- function(object) object$flush()

#' @rdname h5-wrapper
#' @export
existsGroup <- function(object, name) object$exists(name)

#' @rdname h5-wrapper
#' @export
is.h5file <-
function(name) {
  res <- FALSE
  if(file.exists(name)) {
    res <- as.logical(.Call('R_H5Fis_hdf5', PACKAGE = 'hdf5r', name))
  } else {
    warning("File does not exist.")
  }
  res
}