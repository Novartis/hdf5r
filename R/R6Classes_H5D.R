

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





##' Class for representing HDF5 datasets
##'
##' This class represents an HDF5 group-id. It inherits all functions of the
##' \code{\link{H5RefClass-class}}.
##'
##' @docType class
##' @importFrom R6 R6Class
##' @return Object of class \code{\link{H5D}}.
##' @export
##' @author Holger Hoefling
##' @seealso H5Class_overview
H5D <- R6Class("H5D",
               inherit=H5RefClass,
               public=list(
                   initialize=function(id=NULL) {
                       "Intializes a new dataset-object. Only for internal use. Use the \\code{create_dataset} function for \\code{\\link{H5Group}}"
                       "and \\code{\\link{H5File}} objects"
                       "@param id For internal use only"
                       if(is.null(id)) {
                           stop("An id has to be provided for a dataset of class H5D. For creating a dataset, use 'create_dataset' for an H5File or H5Group")
                       }
                       super$initialize(id=id)
                   },
                   get_space=function() {
                       "This function implements the HDF5-API function H5Dget_space."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-GetSpace} for details."

                       id <- .Call("R_H5Dget_space", self$id, PACKAGE="hdf5r")$return_val
                       if(id < 0) {
                           stop("Error retrieving dataspace")
                       }
                       return(H5S$new(id=id))
                   },
                   get_space_status=function() {
                       "This function implements the HDF5-API function H5Dget_space_status."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-GetSpaceStatus} for details."

                       res <- .Call("R_H5Dget_space_status", self$id, request_empty(1), PACKAGE="hdf5r")
                       if(res$return_val < 0) {
                           stop("Error retrieving space status")
                       }
                       return(res$allocation)
                   },
                   get_type=function(native=TRUE) {
                       "This function implements the HDF5-API function H5Dget_type."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-GetType} for details."

                       id <- .Call("R_H5Dget_type", self$id, PACKAGE="hdf5r")$return_val
                       if(id < 0) {
                           stop("Error retrieving datatype of dataset")
                       }
                       if(native) {
                           ## return the native type
                           id_native <- .Call("R_H5Tget_native_type", id, h5const$H5T_DIR_ASCEND, PACKAGE="hdf5r")$return_val
                           ## have the new id, can close the old one
                           .Call("R_H5Tclose", id, PACKAGE="hdf5r")
                           if(id_native < 0) {
                               stop("Error retrieving native-c-type")
                           }
                           return(H5T_factory(id_native))
                       }
                       else {
                           return(H5T_factory(id))
                       }
                   },
                   get_create_plist=function() {
                       "This function implements the HDF5-API function H5Dget_create_plist."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-GetCreatePlist} for details."

                       id <- .Call("R_H5Dget_create_plist", self$id, PACKAGE="hdf5r")$return_val
                       if(id < 0) {
                           stop("Error retrieving dataset creation property list")
                       }
                       return(H5P_DATASET_CREATE$new(id=id))
                   },
                   get_access_plist=function() {
                       "This function implements the HDF5-API function H5Dget_access_plist."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-GetAccessPlist} for details."

                       id <- .Call("R_H5Dget_access_plist", self$id, PACKAGE="hdf5r")$return_val
                       if(id < 0) {
                           stop("Error retrieving dataset access property list")
                       }
                       return(H5P_DATASET_ACCESS$new(id=id))
                   },
                   get_offset=function() {
                       "This function implements the HDF5-API function H5Dget_offset."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-GetOffset} for details."

                       haddr <- .Call("R_H5Dget_offset", self$id, PACKAGE="hdf5r")$return_val
                       if(haddr < 0) {
                           stop("Error retrieving address; is undefined")
                       }
                       return(haddr)
                   },
                   get_storage_size=function() {
                       "This function implements the HDF5-API function H5Dget_storage_size."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-GetStorageSize} for details."

                       size <- .Call("R_H5Dget_storage_size", self$id, PACKAGE="hdf5r")$return_val
                       return(size)
                   },
                   vlen_get_buf_size=function(type, space) {
                       "This function implements the HDF5-API function H5Dvlen_get_buf_size."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-VlenGetBufSize} for details."

                       check_class(type, "H5T")
                       check_class(space, "H5S")

                       res <- .Call("R_H5Dvlen_get_buf_size", self$id, type$id, space$id, request_empty(1), PACKAGE="hdf5r")
                       if(res$return_val < 0) {
                           stop("Error trying to calculate vlen buffer size")
                       }
                       return(res$size)
                   },
                   vlen_reclaim=function(buffer, type, space, dataset_xfer_pl=h5const$H5P_DEFAULT) {
                       "This function implements the HDF5-API function H5Dvlen_reclaim."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-VlenReclaim} for details."

                       check_class(type, "H5T")
                       check_class(space, "H5S")

                       check_pl(dataset_xfer_pl, "H5P_DATASET_XFER")
                       herr <- .Call("R_H5Dvlen_reclaim", type$id, space$id, dataset_xfer_pl$id, buffer, FALSE, PACKAGE="hdf5r")$return_val
                       if(herr < 0 ) {
                           stop("Error trying to reclaim buffer vlen data")
                       }
                       return(invisible(self))
                   },
                   read_low_level=function(file_space=h5const$H5S_ALL, mem_space=NULL, mem_type=NULL,
                       dataset_xfer_pl=h5const$H5P_DEFAULT, flags=getOption("hdf5r.h5tor_default"), set_dim=TRUE, dim_to_set="auto", drop=TRUE) {
                       "This function is for advanced users. It is recommended to use \\code{read} instead or the \\code{[} interface."
                       "This function implements the HDF5-API function H5Dread, with minor changes to the API to accomodate R."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-Read} for details."
                       "It reads the data in the dataset as specified by \\code{mem_space} and return it as an R-obj"
                       "@param file_space An HDF5-space, represented as class \\code{\\link{H5S-class}} that determines which part"
                       "of the dataset is being read."
                       "@param mem_space The space as it is represented in memory; advanced feature; may be removed in the future"
                       "@param mem_type Memory type; extracted from the dataset if null (can be passed in for efficiency reasons"
                       "@param dataset_xfer_pl Dataset transfer property list. See \\code{\\link{H5P_DATASET_XFER-class}}"
                       "@param flags Conversion rules for integer values. See also \\code{\\link{h5const}}"
                       "@param set_dim If \\code{TRUE}, the dimension attribute is set in the return value. How it is set "
                       "is determined by \\code{dim_to_set}."
                       "@param dim_to_set The dimension to set; if \\code{auto}, it is determined automatically using the internal"
                       "datatypes; otherwise, the object passed is used as the dimension attribute"
                       "@param drop Logical. Should dimensions of length 1 be dropped (R-default for arrays)"
                       if(is.null(mem_type)) {
                           mem_type <- self$get_type()
                       }

                       check_class(mem_type, "H5T")
                       if(!is.null(mem_space)) {
                           check_class(mem_space, "H5S")
                       }
                       check_class(file_space, "H5S")
                       check_pl(dataset_xfer_pl, "H5P_DATASET_XFER")

                       if(file_space$id==h5const$H5S_ALL$id) {
                           ## get the actual file-space and ascertain its size
                           file_space_ds <- self$get_space()
                           file_space_ds$select_all()
                           file_space_type <- as.character(file_space_ds$get_simple_extent_type())
                           nelem <- file_space_ds$get_select_npoints()
                           ## in this case, we ignore what mem_space is set to
                           mem_space <- h5const$H5S_ALL
                       }
                       else {
                            ## else, just get a linear space
                           file_space_ds <- file_space
                           nelem <- file_space$get_select_npoints()
                           if(is.null(mem_space)) {
                               ## use this simple space; this may come with some speed penalties
                               mem_space <- H5S$new(type="simple", dims=nelem, maxdims=nelem)
                           }
                           ## if a mem_space is passed in, we assume it is set to the correct value
                       }
                       ## need to create the buffer to write this into
                       buffer <- H5ToR_Pre(mem_type, nelem)
                       res <- .Call("R_H5Dread", self$id, mem_type$id, mem_space$id, file_space$id, dataset_xfer_pl$id,
                                    buffer, FALSE, PACKAGE="hdf5r")
                       if(res$return_val < 0) {
                           stop("Error reading dataset")
                       }
                       buffer_post <- H5ToR_Post(res$buf, mem_type, nelem, flags, self$id)
                       if(set_dim) {
                           if(is.character(dim_to_set) && dim_to_set=="auto") {
                               dim_to_set <- extract_dim(space=file_space_ds, dtype=mem_type)
                           }
                           if(drop) {
                               dim_to_set <- dim_to_set[dim_to_set != 1]
                           }
                           
                           if(length(dim_to_set) > 1) {
                               .Call("set_dim_attribute", buffer_post, as.numeric(dim_to_set), PACKAGE = "hdf5r")
                           }
                       }
                       ## reclaim vlen data if the mem_type is vlen
                       if(mem_type$is_vlen()) {
                           mem_space_explicit <- H5S$new(type="simple", dims=nelem, maxdims=nelem)
                           self$vlen_reclaim(buffer=res$buf, type=mem_type, space=mem_space_explicit, dataset_xfer_pl=dataset_xfer_pl)
                       }

                       return(buffer_post)
                   },
                   read=function(args, dataset_xfer_pl=h5const$H5P_DEFAULT, flags=getOption("hdf5r.h5tor_default"), drop=TRUE, envir=parent.frame()) {
                       "Main interface for reading data from the dataset. It is the function that is used by \\code{[}, where"
                       "all indices are being passed in the parameter \\code{args}."
                       "@param args The indices for each dimension to subset given as a list. This makes this easier to use as a programmatic API."
                       "For interactive use we recomment the use of the \\code{[} operator."

                       "@param op The operator to use. Same as for the other HDF5 space selection functions. One of the elements shown in"
                       "\\code{h5const$H5S_seloper_t}"
                       "@param envir The environment in which to evaluate \\code{args}"
                       "@param dataset_xfer_pl An object of class \\code{\\link{H5P_DATASET_XFER-class}}." 
                       "@param flags Some flags governing edge cases of conversion from HDF5 to R. This is related to how integers are being treated and"
                       "the issue of R not being able to natively represent 64bit integers and not at all being able to represent unsigned 64bit integers"
                       "(even using add-on packages). The constants governing this are part of \\code{\\link{h5const}}. The relevant ones start with the term"
                       "\\code{H5TOR} and are documented there. The default set here returns a regular 32bit integer if it doesn't lead to an overflow"
                       "and returns a 64bit integer from the \\code{bit64} package otherwise. For 64bit unsigned int that are larger than 64bit signed int,"
                       "it return a \\code{double}. This looses precision, however."
                       "@param drop Logical. When reading data, should dimensions of size 1 be dropped."
                       "@param envir The environment in which the dimension indices \\code{d1, ...} are to be evaluated. Usually the environment from"
                       "where the function is called."
                       "@return The data that was read as an R object"

                       op <- h5const$H5S_SELECT_SET
                       self_space <- self$get_space()
                       
                       if(!self_space$is_simple()) {
                           stop("Dataspace has to be simple for a selection to occur")
                       }
                       simple_extent <- self_space$get_simple_extent_dims()    
                       ## distinguish between scalar and non-scalar
                       if(simple_extent$rank == 0 && self_space$get_select_npoint() == 1) {
                           ## is a scalar
                           if(are_args_scalar(args)) {
                               res <- self$read_low_level(file_space=self_space, mem_space=self_space, dataset_xfer_pl=dataset_xfer_pl)
                           }
                           else {
                               stop("Scalar dataspace; arguments have to be of length 1 and empty or equal to 1")
                           }
                       }
                       else {
                           reg_eval_res <- args_regularity_evaluation(args=args, ds_dims=simple_extent$dims, envir=envir)
                           ## need to check if maximum dimension in indices are larger than dataset dimensions
                           ## if yes need to throw an error
                           if(any(reg_eval_res$max_dims > simple_extent$dims)) {
                               stop("The following coordinates are outside the dataset dimensions: ",
                                    paste(which(reg_eval_res$max_dims > simple_extent$dims), sep=", "))
                           }
                           robj_dim <- get_robj_dim(reg_eval_res, self$get_type()) 
                           selection <- regularity_eval_to_selection(reg_eval_res=reg_eval_res) 
                           apply_selection(space_id=self_space$id, selection=selection) 
                           
                           mem_space_dims <- robj_dim$robj_dim_pre_shuffle
                           mem_space <- H5S$new(type="simple", dims=mem_space_dims, maxdims=mem_space_dims)
                           
                           ## check if we have a compound, where we don't have to set 
                           dim_to_set <- robj_dim$robj_dim_pre_shuffle
                           
                           res <- self$read_low_level(file_space=self_space, mem_space=mem_space,
                                         dataset_xfer_pl=dataset_xfer_pl, set_dim=TRUE, dim_to_set=dim_to_set, drop=drop)
                           
                           if(any(reg_eval_res$needs_reshuffle)) {
                               res <- do_reshuffle(res, reg_eval_res)
                           }
                       }
                       return(res)
                   },
                   write_low_level=function(robj, file_space=h5const$H5S_ALL, mem_space=NULL, mem_type=NULL, dataset_xfer_pl=h5const$H5P_DEFAULT,
                       flush=getOption("hdf5r.flush_on_write")) {
                       "This function is for advanced users. It is recommended to use \\code{read} instead or the \\code{[<-} interface"
                       "as used for arrays."
                       "This function implements the HDF5-API function H5Dwrite, with some changes to accomodate R."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-Write} for details."
                       "It writes that data from the \\code{robj} into the dataset."
                       "@param robj The object to write into the dataset"
                       "@param mem_space The space as it is represented in memory; advanced feature; may be removed in the future"
                       "@param mem_type Memory type; extracted from the dataset if null (can be passed in for efficiency reasons"
                       "@param file_space An HDF5-space, represented as class \\code{\\link{H5S-class}} that determines which part"
                       "of the dataset is being written."
                       "@param dataset_xfer_pl Dataset transfer property list. See \\code{\\link{H5P_DATASET_XFER-class}}"
                       "@param flush Should a flush be done after the write"

                       if(is.null(mem_type)) {
                           mem_type <- self$get_type()
                       }

                       check_class(mem_type, "H5T")
                       if(!is.null(mem_space)) {
                           check_class(mem_space, "H5S")
                       }
                       check_class(file_space, "H5S")
                       check_pl(dataset_xfer_pl, "H5P_DATASET_XFER")

                       ## compare if the number of elements matches
                       if(file_space$id==h5const$H5S_ALL$id) {
                           ## get the actual file-space and ascertain its size
                           file_space_ds <- self$get_space()
                           file_space_type <- as.character(file_space_ds$get_simple_extent_type())

                           nelem_file <- file_space_ds$get_select_npoints()
                           mem_space <- file_space
                       }
                       else {
                           nelem_file <- file_space$get_select_npoints()
                           if(is.null(mem_space)) {
                               mem_space <- H5S$new(type="simple", dims=nelem_file, maxdims=nelem_file)
                           }
                       }

                       nelem_robj <- guess_nelem(robj, mem_type)

                       if(nelem_robj != nelem_file && (nelem_file %% nelem_robj != 0 || nelem_file < nelem_robj)) {
                           stop("Number of objects in robj is not the same and not a multiple of number of elements selected in file")
                       }
                       buffer <- RToH5(robj, mem_type, nelem_robj)
                       if(nelem_robj != nelem_file) {
                           ## need to multiply input buffer
                           buffer <- rep(buffer, times=nelem_file / nelem_robj)
                       }
                       
                       res <- .Call("R_H5Dwrite", self$id, mem_type$id, mem_space$id, file_space$id, dataset_xfer_pl$id,
                                    buffer, PACKAGE="hdf5r")
                       if(res$return_val < 0) {
                           stop("Error writing dataset")
                       }
                       if(flush) {
                           self$flush
                       }
                       return(invisible(self))
                   },
                   write=function(args, value, dataset_xfer_pl=h5const$H5P_DEFAULT, envir=parent.frame()) {
                       
                       op <- h5const$H5S_SELECT_SET
                       self_space <- self$get_space()
                       
                       if(!self_space$is_simple()) {
                           stop("Dataspace has to be simple for a selection to occur")
                       }
                       simple_extent <- self_space$get_simple_extent_dims()    
                       ## distinguish between scalar and non-scalar
                       if(simple_extent$rank == 0 && self_space$get_select_npoint() == 1) {
                           ## is a scalar
                           if(are_args_scalar(args)) {
                               return(self$write(value, file_space=self_space, mem_space=self_space, dataset_xfer_pl=dataset_xfer_pl))
                           }
                           else {
                               stop("Scalar dataspace; arguments have to be of length 1 and empty or equal to 1")
                           }
                       }
                       else {
                           reg_eval_res <- args_regularity_evaluation(args=args, ds_dims=simple_extent$dims, envir=envir, post_read=FALSE)
                           ## need to check if maximum dimension in indices are larger than dataset dimensions
                           ## if yes need to throw an error
                           if(any(reg_eval_res$max_dims > simple_extent$dims)) {
                               ## need to reset the extent of the arguments
                               if(any(reg_eval_res$max_dims > simple_extent$maxdims)) {
                                   stop("The following coordinates are larger than the largest possible dataset dimensions (maxdims): ",
                                        paste(which(reg_eval_res$max_dims > simple_extent$maxdims), sep=", "))
                               }
                               self$set_extent(pmax(reg_eval_res$max_dims, simple_extent$dims))
                               self_space <- self$get_space()
                           }
                           robj_dim <- get_robj_dim(reg_eval_res, self$get_type()) 
                           selection <- regularity_eval_to_selection(reg_eval_res=reg_eval_res) 
                           apply_selection(space_id=self_space$id, selection=selection) 
                           
                           mem_space_dims <- robj_dim$robj_dim_post_shuffle
                           mem_space <- H5S$new(type="simple", dims=mem_space_dims, maxdims=mem_space_dims)
                           
                           if(any(reg_eval_res$needs_reshuffle)) {
                               ## need to ensure that the input has the right dimensions attached in case it is just a vector)
                               dim(value) <- reg_eval_res$result_dims_pre_shuffle
                               value <- do_reshuffle(value, reg_eval_res)
                           }
                           return(self$write_low_level(value, file_space=self_space, mem_space=mem_space, dataset_xfer_pl=dataset_xfer_pl))
                       }
                   },
                   set_extent=function(dims) {
                       "This function implements the HDF5-API function H5Dset_extent."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5D.html#Dataset-SetExtent} for details."

                       rank <- self$get_space()$get_simple_extent_ndims()
                       if(length(dims) != rank) {
                           stop(paste("Length of dims is", length(dims), "but has to be equal to the rank of the dataspace:", rank))
                       }
                       res <- .Call("R_H5Dset_extent", self$id, rev(dims), PACKAGE="hdf5r")$return_val
                       if(res < 0) {
                           stop("Error setting new extent")
                       }
                       return(invisible(self))
                   },
                   get_fill_value=function() {
                       "This function implements the HDF5-API function H5Pget_fill_value, automatically"
                       "supplying the datatype of the dataset for convenience."
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5P.html#Property-GetFillValue} for details."

                       dtype <- self$get_type()
                       create_plist <- self$get_create_plist()
                       value_h5 <- H5ToR_Pre(dtype, 1)
                       res <- .Call("R_H5Pget_fill_value", create_plist$id, dtype$id, value_h5, FALSE, PACKAGE="hdf5r")
                       if(res$return_val < 0) {
                           stop("Error retrieving fill value")
                       }
                       return(H5ToR_Post(value_h5, dtype, 1, -1))
                   },
                   reorder=function(reorder_dim, start, end, new_order, max_mem, dataset_xfer_pl=h5const$H5P_DEFAULT, key_info=NULL) {
                       "Reorder a subset of an HDF5 dataset along a specific dimension. It is mostly intended as a function to be"
                       "used by a sorting algorithm and is not checked for correct inputs. Incorrect use can corrupt a dataset"
                       "@param reorder_dim The number of the dimension along which the reordering should occur."
                       "@param start,end The start and end index where the reordering should occur (can be vectors of equal length)"
                       "@param new_order The new ordering of the items to re-order. The ith item gives the index in the source for the i-th item in"
                       "the destination (for the \\code{reorder_dim})"
                       "@param max_mem Memory usage of the function in bytes (a rough guide, can be somewhat exceeded)"
                       "@param dataset_xfer_pl The dataset transfer propery list"
                       "@param key_info The key_info returned by the \\code{key_info} method of the dataset"
                       
                       check_pl(dataset_xfer_pl, "H5P_DATASET_XFER")

                       if(is.null(key_info)) {
                           key_info <- self$key_info
                       }
                       ## divide memory by two as at least 2 buffers will be needed
                       max_mem <- max_mem / 2

                       ds_dims <- key_info$dims
                       chunk_dims <- key_info$chunk_dims
                       if(any(is.na(chunk_dims))) {
                           ## not chunked, every element separate
                           chunk_dims <- rep(1, length(ds_dims))
                       }
                       chunk_dims[reorder_dim] <- sum(end - start + 1)

                       ## calculate number of chunks that can be fitted into
                       ## memory size
                       ds_type_size <- key_info$type_size_raw
                       chunk_size <- ds_type_size * prod(chunk_dims)

                       ## check if we can then read in even one datapoint
                       if(chunk_size > max_mem) {
                           chunk_dims <- rep(1, length(ds_dims))
                           chunk_dims[reorder_dim] <- sum(end - start + 1)
                           chunk_size <- ds_type_size * prod(chunk_dims)
                           if(chunk_size > max_mem) {
                               stop("max_mem too small to read in necessary data for reordering")
                           }
                           else {
                               warning("Cannot process data along chunk lines, reverting to smaller sizes")
                           }
                       }

                       ## calculate the number of chunks per dimension we can read in at the same time
                       num_chunks <- ceiling(ds_dims / chunk_dims)
                       num_chunks[reorder_dim] <- 1
                       ## repurposing the function that calculates the number of elements in a chunk
                       ## to calculate the number of chunks in a hyperslab
                       ## for s
                       chunk_mult <- guess_chunks(space_maxdims=num_chunks, dtype_size=chunk_size, chunk_size=max_mem)
                       metachunk_dims <- chunk_dims * chunk_mult
                       metachunk_dims[reorder_dim] <- sum(end - start + 1)
                       num_metachunks <- ceiling(ds_dims / metachunk_dims)
                       num_metachunks[reorder_dim] <- 1

                       ## now we have defined the optimal chunk size; now need to read it in, reorder it
                       ## and write it back out one item at a time
                       ## will use the lowest level read function to get optimal speed
                       total_chunks <- prod(num_metachunks)
                       ## need to get a buffer of sufficient size
                       buffer_size <- ds_type_size * prod(metachunk_dims)
                       buffer <- raw(buffer_size)

                       ds_file_space <- key_info$space
                       ds_mem_space <- H5S$new(type="simple", dims=metachunk_dims, maxdims=metachunk_dims)
                       ds_mem_space_start <- rep(1, length(ds_dims))
                       ds_mem_space_count <- rep(1, length(ds_dims))
                       ds_mem_space_stride <- rep(1, length(ds_dims))
                       # print(metachunk_dims)
                       is_vlen_type <- key_info$type$is_vlen()
                       for(i in seq_len(prod(num_metachunks))) {
                           ds_file_space$select_none()
                           ds_mem_space$select_none()
                           chunk_indices <- array_counter(count=i-1, dims=num_metachunks)
                           # print(chunk_indices)

                           ## create a return similar to that of the evaluate_arugments function so that we can re-use the
                           ## space_selection function
                           slab_start <- chunk_indices * metachunk_dims + 1
                           slab_count <-  rep(1, length(ds_dims))
                           slab_stride <- rep(1, length(ds_dims))
                           slab_block <- pmin(metachunk_dims, ds_dims - slab_start + 1)

                           ## the memory block is simply one contiguous set
                           ds_mem_space_block <- slab_block
                           ds_mem_space_block[reorder_dim] <- metachunk_dims[reorder_dim] # this one is always maximal
                           ds_mem_space$select_hyperslab(start=ds_mem_space_start, count=ds_mem_space_count, stride=ds_mem_space_stride,
                                                         block=ds_mem_space_block, op=h5const$H5S_SELECT_SET)
                           ## need to build a complex selection here for the file space
                           for(i in seq_along(start)) {
                               slab_start[reorder_dim] <- start[i]
                               slab_block[reorder_dim] <- end[i] - start[i] + 1
                               ds_file_space$select_hyperslab(start=slab_start, count=slab_count, stride=slab_stride, block=slab_block,
                                                              op=h5const$H5S_SELECT_OR)                               
                           }
                           # print(ds_file_space$get_select_hyper_blocklist())
                           ## now read the data into the buffer; the buffer may be larger than the data
                           res_read <- .Call("R_H5Dread", self$id, key_info$type$id, ds_mem_space$id, ds_file_space$id, dataset_xfer_pl$id,
                                        buffer, FALSE, PACKAGE="hdf5r")
                           if(res_read$return_val < 0) {
                               stop("Error reading dataset")
                           }

                           ## reorder the columns; here we set the dimensions of the dataset to the metachunk dimensions
                           ## on the re-ordering dimension, this is exact, but it may be larger on the others.
                           ## in this case, we may be re-ordering a part of the larger array, that contains data that is not part
                           ## of the current selection; this is fine, as we ignore this part again later when writing the data back out
                           buffer_reordered <- array_reorder(res_read$buf, dims=metachunk_dims, reorder_dim=reorder_dim, new_order=new_order,
                                                             item_size = ds_type_size)

                           ## write the buffer back out
                           res_write <- .Call("R_H5Dwrite", self$id, key_info$type$id, ds_mem_space$id, ds_file_space$id, dataset_xfer_pl$id,
                                        buffer_reordered, PACKAGE="hdf5r")
                           
                           ## reclaim vlen data if the mem_type is vlen
                           if(is_vlen_type) {
                               self$vlen_reclaim(buffer=res_read$buf, type=key_info$type, space=ds_mem_space, dataset_xfer_pl=dataset_xfer_pl)
                           }                          
                           
                       }                     
                       ## only close the memory space we created here
                       ds_mem_space$close()
                       
                       return(self)
                   },
                   create_reference=function(...) {
                       "This function implements the HDF5-API function H5Rcreate. The parameters are interpreted as in '['."
                       "The function always create \\code{H5R_DATASET_REGION} references"
                       "Please see the documentation at \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5R.html#Reference-Create} for details."

                       space <- self$get_space()
                       do.call("[", c(list(space), list(...)))
                       
                       ref_type <- h5const$H5R_DATASET_REGION
                       ref_obj <- H5R_DATASET_REGION$new(1, self)
                       
                       res <- .Call("R_H5Rcreate", ref_obj$ref, self$id, ".", h5const$H5R_DATASET_REGION, space$id, FALSE, PACKAGE="hdf5r")
                       if(res$return_val < 0) {
                           stop("Error creating object reference")
                       }
                       ref_obj$ref <- res$ref
                       return(ref_obj)
                   }

                   ),
               active=list(
                   dims=function() {
                       "Get the dimension of the dataset"
                       ds_space <- self$get_space()
                       res <- ds_space$dims
                       ds_space$close()
                       return(res)
                   },
                   maxdims=function() {
                       "Get the maximal dimension of the dataset"
                       ds_space <- self$get_space()
                       res <- ds_space$maxdims
                       ds_space$close()
                       return(res)
                   },
                   chunk_dims=function() {
                       "Return the dimension of the chunks. NA if the dataset is not chunked"
                       dataset_create_pl <- self$get_create_plist()
                       ds_space <- self$get_space()
                       ndims <- ds_space$get_simple_extent_ndims()
                       ds_space$close()
                       res <- dataset_create_pl$get_chunk(ndims)
                       dataset_create_pl$close()
                       return(res)
                   },
                   key_info=function() {
                       "Returns the key types as a list, consisting of type, space, dataset_create_pl,"
                       "type_size_raw, type_size_variable, dims and chunk_dims."
                       "type_size_raw versus variable differs for variable length types, which return \\code{Inf}"
                       "for type_size_variable and the underlying size for type_size_raw"
                       ds_space <- self$get_space()
                       ds_type <- self$get_type(native=TRUE)
                       ds_create_pl <- self$get_create_plist()
                       ds_dims <- ds_space$dims
                       return(list(space=ds_space, type=ds_type, create_pl=ds_create_pl,
                                   type_size_raw=ds_type$get_size(variable_as_inf=FALSE), type_size_variable=ds_type$get_size(variable_as_inf=TRUE),
                                   dims=ds_dims, chunk_dims=ds_create_pl$get_chunk(length(ds_dims))))
                   }
                   ),
               private=list(
                   closeFun=function(id) {
                       nrt <- NA
                       if(!is.na(id) && is.loaded("R_H5Dclose", PACKAGE="hdf5r")) {
                           invisible(.Call("R_H5Dclose", id, PACKAGE = "hdf5r"))
                       }
                   }
                   ),
               cloneable=FALSE
               )

R6_set_list_of_items(H5D, "public", commonFGDT, overwrite=TRUE)
R6_set_list_of_items(H5D, "public", commonFGDTA, overwrite=TRUE)
