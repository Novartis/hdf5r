


#############################################################################
##
## Copyright 2016 Novartis Institutes for BioMedical Research Inc.
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
#############################################################################








##' Class for representing HDF5 spaces
##' 
##' This class represents an HDF5 space-id. It inherits all functions of the
##' \code{\link{H5RefClass-class}}. 
##'
##' @docType class
##' @importFrom R6 R6Class
##' @return Object of class \code{\link{H5Group}}. 
##' @export
##' @author Holger Hoefling
##' @seealso H5Class_overview
H5S <- R6Class("H5S",
               inherit=H5RefClass,
               public=list(
                   initialize=function(type=c("simple", "scalar", "null"), dims=NULL, maxdims=dims, decode_buf=NULL, id=NULL) {
                       "Create a new HDF5-space. This can be done by either specifying a space with appropriate dimensions or by"
                       "decoding a character string that represents an encoded space"
                       "@param type Either a \\code{simple} space, for which \\code{dims} and \\code{maxdims} have to be given"
                       "or a \\code{scalar} or \\code{null} space. See the HDF5 user guide on spaces to explain the differences."
                       "@param dims The dimension of the space in case it is of type \\code{simple}"
                       "@param maxdims The maximal dimensions of the space"
                       "@param decode_buf The character string that holds the encoded representation of a space"
                       "@param id An existing HDF5 id; internal use only"
                       if(is.null(id)) {
                           if(!is.null(decode_buf)) {
                               id <- .Call("R_H5Sdecode", decode_buf, PACKAGE = "hdf5r")$return_val
                           }
                           else {
                               type <- match.arg(type)
                               type <- switch(type, scalar=h5const$H5S_SCALAR, simple=h5const$H5S_SIMPLE, null=h5const$H5S_NULL)
                               
                               if(type!=h5const$H5S_SIMPLE ||(type==h5const$H5S_SIMPLE && (is.null(dims) || is.null(maxdims)))) {
                                   id <- .Call("R_H5Screate", type, PACKAGE = "hdf5r")$return_val
                                   if(id < 0) {
                                       stop("Error creating dataspace")
                                   }
                               }
                               else {
                                   if(is.null(dims)) {
                                       stop("dims cannot be null")
                                   }
                                   rank <- length(dims)
                                   if(length(maxdims) > 0 && length(maxdims) != rank) {
                                       stop("maxdims, if it is not NULL, has to be of the same length as dims")
                                   }
                                   id <- .Call("R_H5Screate_simple", rank, rev(dims), rev(maxdims), PACKAGE="hdf5r")$return_val
                                   if(id < 0) {
                                       stop("Error creating simple dataspace")
                                   }
                               }
                           }
                       }
                       super$initialize(id)
                   },
                   copy=function() {
                       "This function implements the HDF5-API function H5Scopy. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-Copy} for details."

                       id <- .Call("R_H5Scopy", self$id, PACKAGE = "hdf5r")$return_val
                       return(H5S$new(id=id))
                   },
                   encode=function() {
                       "This function implements the HDF5-API function H5Sencode. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-Encode} for details."

                       ## first retrieve the size of the buffer necessary
                       nalloc <- .Call("R_H5Sencode", self$id, raw(0), numeric(1), FALSE, PACKAGE = "hdf5r")$nalloc
                       ## now get the actual buffer size
                       buf <- raw(nalloc)
                       res <- .Call("R_H5Sencode", self$id, buf, nalloc, FALSE, PACKAGE="hdf5r")
                       herr <- res$return_val
                       if(herr < 0) {
                           stop("Error when encoding the object")
                       }
                       return(res$buf)
                   },
                   is_simple=function() {
                       "This function implements the HDF5-API function H5Sis_simple. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-IsSimple} for details."

                       res <- .Call("R_H5Sis_simple", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error when trying to see if dataspace is simple")
                       }
                       return(as.logical(res))
                   },
                   get_simple_extent_ndims=function() {
                       "This function implements the HDF5-API function H5Sget_simple_extent_ndims. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSimpleExtentNdims} for details."

                       ndims <- .Call("R_H5Sget_simple_extent_ndims", self$id, PACKAGE = "hdf5r")$return_val
                       if(ndims < 0) {
                           stop("Error when retrieving rank of dataspace")
                       }
                       return(ndims)
                   },
                   offset_simple=function(offset) {
                       "This function implements the HDF5-API function H5Soffset_simple. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-OffsetSimple} for details."

                       rank <- self$get_simple_extent_ndims()
                       if(length(offset)==0) {
                           offset <- rep(0, rank)
                       }
                       if(length(offset) != rank) {
                           stop(paste("Offset has to be of rank", rank))
                       }
                       res <- .Call("R_H5Soffset_simple", self$id, rev(offset), PACKAGE = "hdf5r")
                       if(res$return_val < 0) {
                           stop("Error when setting offset")
                       }
                       return(invisible(self))
                   },
                   get_simple_extent_dims=function() {
                       "This function implements the HDF5-API function H5Sget_simple_extent_dims. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSimpleExtentDims} for details."

                       rank <- self$get_simple_extent_ndims()
                       res <- suppressWarnings(.Call("R_H5Sget_simple_extent_dims", self$id, request_empty(rank), request_empty(rank), PACKAGE = "hdf5r"))
                       if(res$return_val < 0) {
                           stop("Error when retrieving extent of simple dataspace")
                       }
                       names(res) <- c("rank", "dims", "maxdims")
                       res$dims <- rev(res$dims)
                       res$maxdims <- rev(res$maxdims)
                       return(res)                           
                   },
                   get_simple_extent_npoints=function() {
                       "This function implements the HDF5-API function H5Sget_simple_extent_npoints. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSimpleExtentNpoints} for details."

                       res <- .Call("R_H5Sget_simple_extent_npoints", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error trying to get number of points in dataspace")
                       }
                       return(res)
                   },
                   get_simple_extent_type=function() {
                       "This function implements the HDF5-API function H5Sget_simple_extent_type. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSimpleExtentType} for details."

                       return(.Call("R_H5Sget_simple_extent_type", self$id, PACKAGE = "hdf5r")$return_val)
                   },
                   extent_copy=function(h5s_source) {
                       "This function implements the HDF5-API function H5Sextent_copy. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-ExtentCopy} for details."

                       if(!inherits(h5s_source, "H5S")) {
                           stop("h5s_source has to be of class H5S")
                       }
                       res <- .Call("R_H5Sextent_copy", self$id, h5s_source$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error copying extent of dataspace")
                       }
                       return(invisible(self))
                   },
                   extent_equal=function(h5s_cmp) {
                       "This function implements the HDF5-API function H5Sextent_equal. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-ExtentEqual} for details."

                       if(!inherits(h5s_cmp, "H5S")) {
                           stop("h5s_source has to be of class H5S")
                       }
                       res <- .Call("R_H5Sextent_equal", self$id, h5s_cmp$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error copying extent of dataspace")
                       }
                       return(as.logical(res))
                   },
                   set_extent_simple=function(dims, maxdims) {
                       "This function implements the HDF5-API function H5Sset_extent_simple. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SetExtentSimple} for details."

                       rank <- length(dims)
                       if(rank ==0) {
                           stop("current_size has to be of length > 0")
                       }
                       if(length(maxdims) != rank) {
                           stop(paste("maximum_size has to be of same length as current_size, i.e. ", rank))
                       }
                       if(!all(maxdims >= dims)) {
                           stop("Maximum_size has to be greater or equal to current_size")
                       }
                       res <- .Call("R_H5Sset_extent_simple", self$id, rank, rev(dims), rev(maxdims), PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error setting simple extent")
                       }
                       return(invisible(self))
                   },
                   set_extent_none=function() {
                       "This function implements the HDF5-API function H5Sset_extent_none. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SetExtentNone} for details."

                       res <- .Call("R_H5Sset_extent_none", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error setting simple extent")
                       }
                       return(invisible(self))
                   },
                   get_select_type=function() {
                       "This function implements the HDF5-API function H5Sget_select_type. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSelectType} for details."

                       res <- .Call("R_H5Sget_select_type", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error getting selection type")
                       }
                       return(res)
                   },
                   get_select_npoints=function() {
                       "This function implements the HDF5-API function H5Sget_select_npoints. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSelectNpoints} for details."

                       res <- .Call("R_H5Sget_select_npoints", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error getting number of points in selection")
                       }
                       return(res)
                   },
                   get_select_hyper_nblocks=function() {
                       "This function implements the HDF5-API function H5Sget_select_hyper_nblocks. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSelectHyperNblocks} for details."

                       res <- .Call("R_H5Sget_select_hyper_nblocks", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error getting number of points in selection")
                       }
                       return(res)
                   },
                   get_select_hyper_blocklist=function(startblock=0, numblocks=(self$get_select_hyper_nblocks() - startblock)) {
                       "This function implements the HDF5-API function H5Sget_select_hyper_blocklist. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSelectHyperBlocklist} for details."

                       rank <- self$get_simple_extent_ndims()
                       ## create a buffer; a buffer of double values provides enough space; function will handle
                       ## appropriate conversion
                       res <- .Call("R_H5Sget_select_hyper_blocklist", self$id, startblock, numblocks, request_empty(rank * 2 * numblocks),
                                    PACKAGE = "hdf5r")
                       if(res$return_val < 0) {
                           stop("Error trying to retrieve blocklist")
                       }
                       ## get the buffer, format as array, reverse the dimensions and return
                       buffer <- res$buf
                       dim(buffer) <- c(rank, 2 * numblocks)
                       for(i in seq_len(ncol(buffer))) {
                           buffer[, i] <- rev(buffer[, i])
                       }
                       ## correct for first element 0
                       buffer <- t(buffer) + 1
                       return(buffer)
                   },
                   get_select_elem_npoints=function() {
                       "This function implements the HDF5-API function H5Sget_select_elem_npoints. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSelectElemNpoints} for details."

                       res <- .Call("R_H5Sget_select_elem_npoints", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error trying to get number of elements in current selection")
                       }
                       return(res)
                   },
                   get_select_elem_pointlist=function(startpoint=0, numpoints=(self$get_select_elem_npoints() - startpoint)) {
                       "This function implements the HDF5-API function H5Sget_select_elem_pointlist. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSelectElemPointlist} for details."

                       rank <- self$get_simple_extent_ndims()
                       ## create a buffer; a buffer of double values provides enough space; function will handle
                       ## appropriate conversion
                       res <- .Call("R_H5Sget_select_elem_pointlist", self$id, startpoint, numpoints, request_empty(rank * numpoints),
                                    PACKAGE = "hdf5r")
                       if(res$return_val < 0) {
                           stop("Error trying to retrieve blocklist")
                       }
                       ## get the buffer, format as array, reverse the dimensions and return
                       buffer <- res$buf
                       dim(buffer) <- c(rank, numpoints)
                       buffer_rev <- buffer
                       for(i in seq_len(rank)) {
                           buffer_rev[i,] <- buffer[rank + 1 - i,]
                       }
                       buffer <- buffer_rev

                       ## correct for first element 0
                       buffer <- t(buffer) + 1
                       return(buffer)
                   },
                   get_select_bounds=function() {
                       "This function implements the HDF5-API function H5Sget_select_bounds. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-GetSelectBounds} for details."

                       rank <- self$get_simple_extent_ndims()
                       start <- integer(rank)
                       end <- integer(rank)
                       res <- .Call("R_H5Sget_select_bounds", self$id, start, end, PACKAGE = "hdf5r")
                       if(res$return_val < 0) {
                           stop("Error trying to get bounding box of selection")
                       }
                       ## correct for first element 0
                       start <- rev(res$start) + 1
                       end <- rev(res$end) + 1
                       return(list(start=start, end=end))
                   },                   
                   select_all=function() {
                       "This function implements the HDF5-API function H5Sselect_all. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SelectAll} for details."

                       res <- .Call("R_H5Sselect_all", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error when selecting all points in dataspace")
                       }
                       return(invisible(self))
                   },
                   select_none=function() {
                       "This function implements the HDF5-API function H5Sselect_none. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SelectNone} for details."

                       res <- .Call("R_H5Sselect_none", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error when reseting selection region")
                       }
                       return(invisible(self))
                   },
                   select_valid=function() {
                       "This function implements the HDF5-API function H5Sselect_valid. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SelectValid} for details."

                       res <- .Call("R_H5Sselect_valid", self$id, PACKAGE = "hdf5r")$return_val
                       if(res < 0) {
                           stop("Error validating selection")
                       }
                       return(as.logical(res))
                   },
                   select_elements=function(coord, op=h5const$H5S_SELECT_SET, byrow=TRUE) {
                       "This function implements the HDF5-API function H5Sselect_elements. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SelectElements} for details."

                       rank <- self$get_simple_extent_ndims()
                       
                       ## check that coord is an array; is rank=1, also allowed to be a vector
                       if(rank==0) {
                           stop("Dataspace has no extent; rank 0")
                       }
                       if(rank==1) {
                           num_elem <- length(coord)
                       }
                       else if(rank==length(coord)) {
                           coord <- matrix(coord, ncol=1)
                           num_elem <- 1
                       }
                       else {
                           if(byrow) {
                               if(!is.matrix(coord)) {
                                   stop("coord has to be a matrix")
                               }
                               if(ncol(coord) != rank) {
                                   stop(paste("Number of columns of coord has to be equal to rank (for byrow=TRUE)", rank))
                               }
                               num_elem <- nrow(coord)
                               coord <- t(coord)
                           }
                           else {
                               if(!is.matrix(coord)) {
                                   stop("coord has to be a matrix")
                               }
                               if(nrow(coord) != rank) {
                                   stop(paste("Number of rows of coord has to be equal to rank (for byrow=FALSE)", rank))
                               }
                               num_elem <- nrow(coord)
                           }
                       }
                       ## correct for first element 0
                       coord <- coord - 1
                       ## reverse all the coordinates
                       coord_rev <- coord
                       for(i in seq_len(rank)) {
                           coord_rev[i,] <- coord[rank + 1 - i,]
                       }
                       coord <- coord_rev
                       herr <- .Call("R_H5Sselect_elements", self$id, op, num_elem, coord, PACKAGE = "hdf5r")
                       if(herr < 0) {
                           stop("Error when selecting elements")
                       }
                       return(invisible(self))
                   },
                   select_hyperslab=function(start, count, stride=NULL, block=NULL, op=h5const$H5S_SELECT_SET) {
                       "This function implements the HDF5-API function H5Sselect_hyperslab. Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SelectHyperslab} for details."

                       rank <- self$get_simple_extent_ndims()
                       if(is.null(stride)) {
                           stride <- rep(1, rank)
                       }
                       if(is.null(block)) {
                           block <- rep(1, rank)
                       }
                       if(length(start) != rank) {
                           stop(paste("start has to be of the same length as the rank of the dataspace,", rank))
                       }
                       if(length(stride) != rank) {
                           stop(paste("stride has to be of the same length as the rank of the dataspace,", rank))
                       }
                       if(length(count) != rank) {
                           stop(paste("count has to be of the same length as the rank of the dataspace,", rank))
                       }
                       if(length(block) != rank) {
                           stop(paste("block has to be of the same length as the rank of the dataspace,", rank))
                       }
                       ## correct for first element 0
                       start <- start - 1
                       herr <- .Call("R_H5Sselect_hyperslab", self$id, op, rev(start), rev(stride), rev(count), rev(block),
                                     PACKAGE = "hdf5r")$return_val
                       if(herr < 0) {
                           stop("Error when selecting hyperslab")
                       }
                       return(invisible(self))
                   }                       
                   ),
               active=list(
                   dims=function() {
                       "Get the dimensions of the space. Return NULL if the space is not simple (i.e. NULL-space) or a length-0 integer if it is a scalar"
                       if(!self$is_simple()) {
                           return(NULL)
                       }
                       return(self$get_simple_extent_dims()$dims)
                   },
                   maxdims=function() {
                       "Get the maximal dimensions of the space.Return NULL if the space is not simple (i.e. NULL-space) or a length-0 integer if it is a scalar"
                       if(!self$is_simple()) {
                           return(NULL)
                       }
                       return(self$get_simple_extent_dims()$maxdims)
                   }
                   ),
               private=list(
                   closeFun=function(id) if(!is.na(id) && is.loaded("R_H5Sclose", PACKAGE="hdf5r")) {
                          invisible(.Call("R_H5Sclose", id, PACKAGE = "hdf5r"))}
                   ),
               cloneable = FALSE
               )

## make 'rank' a copy of get_simple_extent_ndims
H5S$set("active", "rank", H5S$public_methods$get_simple_extent_ndims, overwrite=TRUE)



#' Class for HDF5 default space
#'
#' It inherits all functions of the \code{\link{H5S-class}}. As this is implemented, this is likely not the best choice as almost
#' all functions that work for H5S-class objects will fail. It is likely better to implement this as a separate default class,
#' avoid the id-tracking associated with it (which doesn't make sense anyway). Should find a better way to handle this.
#' @docType class
#' @importFrom R6 R6Class
#' @return Object of class \code{\link[=H5S_DEFAULT-class]{H5S_DEFAULT}}. 
#' @author Holger Hoefling
#' @export
#' @seealso H5Class_overview, \code{\link[=H5S-class]{H5S}}
H5S_DEFAULT <- R6Class("H5S_DEFAULT",
                       inherit=H5S,
                       public=list(
                           initialize=function(id) {
                               private$pid <- new_id_obj(id)
                               return(self)
                           }
                           ),
                       private=list(
                           closeFun=identity
                           ),
                       cloneable=FALSE
                       )
