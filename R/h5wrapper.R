#' h5 wrapper functions
#' 
#' Wrapper functions to provide h5 compatible interface.
#' @param object H5RefClass; H5 Reference Class to be used
#' @param name character; Group/Filename to be created
#' @param path character; Path named to be used for iteration.
#' @param recursive logical; Specify if object should be traversed recursively.
#' @param ... Additional Parameters passed to \code{file$create_group}, \code{file$create_dataset}
#' 
#' @rdname h5-wrapper
#' @export
h5file <- H5File$new

#' @rdname h5-wrapper
#' @export
createGroup <- function(object, name, ...) {
  paths <- strsplit(name, "/")[[1]]
  paths <- paths[paths != ""]
  currentpath <- ""
  currentgroup <- NULL
  for(p in paths) {
    currentpath <- paste(currentpath, p, sep = "/")
    currentpath <- gsub("^\\/", "", currentpath)
    if (! object$exists(currentpath) ) {
      currentgroup <- object$create_group(currentpath, ...)
    }
  }
  currentgroup
}

#' @rdname h5-wrapper
#' @export
openLocation <- function(object, name) object$open(name=name)

#' @rdname h5-wrapper
#' @export
createDataSet <- function(object, name, ...) object$create_dataset(name, ...)

#' @rdname h5-wrapper
#' @export
readDataSet <- function(object) object$read()

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

#' @rdname h5-wrapper
#' @export
list.groups <- function(object, path = "/", recursive = TRUE, ...) {
  obj <- object
  if (path != "/") obj <- object[[path]]
  df <- obj$ls(... ,recursive = recursive)
  df[df$object.type == "H5O_TYPE_GROUP", 1]
}

#' @rdname h5-wrapper
#' @export
list.datasets <- function(object, path = "/", recursive = TRUE, ...) {
  obj <- object
  if (path != "/") obj <- object[[path]]
  df <- obj$ls(... ,recursive = recursive)
  df[df$object.type == "H5O_TYPE_DATASET", 1]
}

GetDimensions <- function(data) {
  datadim <- NULL
  if(is.vector(data)) {
    datadim <- length(data)
  } else if (is.matrix(data)) {
    datadim <- dim(data)
  } else if (is.array(data)) {
    datadim <- dim(data)
  } else {
    stop("Argument data must be of type vector, matrix or array.")
  }
  datadim
}

#' @rdname h5-wrapper
#' @export
extendDataSet <- function(dset, dims) {
  ddset <- dset$dims
  #dobj <- GetDimensions(object)
  if (length(dims) != length(ddset)) {
    stop("Number of extendible dimensions must agree with DataSet dimensions.")
  }
  if(!all(dims >= ddset)) {
    stop("Number of extendible dimensions must be greater or equal than DataSet dimensions.")
  }
  
  if(!all(dims <= dset$maxdims)) {
    stop("Number of extendible dimensions exceeds maximum dimensions of DataSet.")
  }
  
  dset$set_extent(dims = dims)
  invisible(dset)
}

#' @rdname h5-wrapper
#' @export
rbind.H5D <- function(x, mat) {
  startx <- x$dims[1] + 1
  endx <- x$dims[1] + nrow(mat)

  if(x$dims[2] != ncol(mat)) {
    stop(sprintf("Data to append does not match dataset dimensions (%d != %d).", 
                 x$dims[2], ncol(mat)))
  }
  
  x[startx:endx, 1:x$dims[2]] <- mat
  invisible(x)
}

#' @rdname h5-wrapper
#' @export
cbind.H5D <- function(x, mat) {
  starty <- x$dims[2] + 1
  endy <- x$dims[2] + ncol(mat)
  
  if(x$dims[1] != nrow(mat)) {
    stop(sprintf("Data to append does not match dataset dimensions (%d != %d).", 
                 x$dims[1], nrow(mat)))
  }
  
  x[1:x$dims[1], starty:endy] <- mat
  invisible(x)
}

#' @rdname h5-wrapper
#' @export
c.H5D <- function(x, ...) {
  vec <- do.call(c, list(...))
  start <- x$dims + 1
  end <- x$dims + length(vec)
  
  if(length(x$dims) != length(GetDimensions(vec))) {
    stop(sprintf("Data to append does not match dataset dimensions (%d != %d).", 
                 length(x$dims), length(GetDimensions(vec))))
  }
  x[start:end] <- vec
  invisible(x)
}

