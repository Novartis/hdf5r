
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










###################################################
## UI for operating on groups and files
###################################################

##' Get the names of the items in the group or at the \code{/} root of the file
##'
##' Works similar to the regular \code{names} function for a list. The names of the items of either a
##' \code{\link{H5File-class}} at the root or a \code{\link{H5Group-class}} are returned as a character vector.
##' The items are then accessed, again similar to a list, using \code{[[}.
##' @title Get the names of the items in the group or at the \code{/} root of the file
##' @param x An object of class \code{\link{H5File}} or \code{\link{H5Group}}
##' @return A character vector with the names of the items in the group/file. 
##' @author Holger Hoefling
##' @export
names.H5Group <- function(x) {
    link_access_pl <- h5const$H5P_DEFAULT
    ginfo <- x$group_info()
    nlinks <- ginfo$nlinks
    res <- character(nlinks)
    for(i in seq_len(nlinks)) {
        res[i] <- x$link_name_by_idx(i-1, ".", idx_type=h5const$H5_INDEX_NAME, order=h5const$H5_ITER_INC,
                                     link_access_pl=link_access_pl)
    }
    return(res)
}

##' @rdname names.H5Group
##' @export
names.H5File <- names.H5Group

##' Retrieve object from a group of file
##'
##' Works similar to retrieving objects in a list. \code{x[["my_name"]]} retrieves object \code{my_name} from the
##' HDF5-File or group \code{x}.
##'
##' One can also assign objects under a not yet existing name. For Either a  \code{\link{H5Group-class}} or \code{\link{H5D-class}},
##' a hard link is created. If it is a datatype, \code{\link{H5T-class}}, this is committed under the chosen name \code{name}. 
##' @title Retrieve object from a group of file
##' @param x An object of class \code{\link{H5File}} or \code{\link{H5Group}}
##' @param name Name of the object to retrieve. Has to be a character vector of length one. No integer values allowed/
##' @param ... Currently ignored
##' @param link_access_pl An object of class \code{\link{H5P_LINK_ACCESS-class}}. 
##' @param dataset_access_pl An object of class \code{\link{H5P_DATASET_ACCESS-class}}. 
##' @param type_access_pl Currently always \code{h5const$H5P_DEFAULT}
##' @param value What to assign. Has to be one of \code{\link{H5Group-class}},  \code{\link{H5D-class}} or  \code{\link{H5T-class}}
##' @return A \code{\link{H5Group-class}},  \code{\link{H5D-class}} or  \code{\link{H5T-class}}, depending on the object saved in the group under
##' the requested name.
##' @author Holger Hoefling
##' @rdname H5Group_access
##' @name H5Group_access
##' @export
'[[.H5Group' <- function(x, name, ..., link_access_pl=h5const$H5P_DEFAULT, dataset_access_pl=h5const$H5P_DEFAULT, type_access_pl=h5const$H5P_DEFAULT) {
    if(x$exists(name)) {
        return(x$open(name=name, link_access_pl=link_access_pl, dataset_access_pl=dataset_access_pl, type_access_pl=type_access_pl))
    }
    else {
        stop(paste("An object with name", name, "does not exist in this group"))
    }
}

##' @rdname H5Group_access
##' @export
'[[.H5File' <- get("[[.H5Group")


##' @rdname H5Group_access
##' @export
'[[<-.H5Group' <- function(x, name, ..., value) {
    ## if a group is given, make a link
    ## if a dataset is given, make a link
    ## if another r-obj is given, create a dataset for that object and write it
    ## if the object already exists, just fail
    if(x$exists(name)) {
        ## it is a peculiarity of the way R works that when assigning attributes,
        ## as it is done by value, the resulting object is written over itself (with the attribute attached)
        ## so here, we need to check if the object being assigned is itself
        if(inherits(value, "H5File") || inherits(value, "H5Group") || inherits(value, "H5D") || inherits(value, "H5T")) {
            value_oinfo <- value$obj_info()
            x_oinfo <- x[[name]]$obj_info()
            if(identical(value_oinfo, x_oinfo)) {
                return(invisible(x))
            }
        }
        
        stop("Cannot assign - already exists. Please use the 'link_delete' to delete the object before assigning a new one")
    }
    if(inherits(value, "H5Group")) {
        x$link_create_hard(value, ".", name)
    }
    else if(inherits(value, "H5D")) {
        x$link(value, name)
    }
    else if(inherits(value, "H5T")) {
        x$commit(name, value)
    }
    else {
        x$create_dataset(name, value)
    }
    return(invisible(x))
}

##' @rdname H5Group_access
##' @export
'[[<-.H5File' <- get("[[<-.H5Group")

###################################################
## UI for working with arguments
###################################################

##' Interface for HDF5 attributes
##'
##' Implements high-level functions that allows interactions with HDF5-attributes in a way very similar to regular R-object attributes
##' in R are handled. 
##' @title Interface for HDF5 attributes
##' @param x The object to which to attach the attribute to or retrieve it from. Can be one of \code{\link{H5Group-class}},  \code{\link{H5D-class}},
##' \code{\link{H5T-class}} or  \code{\link{H5File-class}} 
##' @param which The name of the attribute to assign it to
##' @param value The value to assign to the attribute.
##' @return For \code{h5attributes}, a named list with the content of the attributes read out. FOr \code{h5attr_names},
##' a vector of names of the attributes attached to the object \code{x}. For \code{h5attr}, the content of the attribute and
##' for \code{h5attr<-}, the assignment, the original object to which the attributes are attached (so that chaining is possible).
##' @author Holger Hoefling
##' @export
h5attributes <- function(x) {
    ## return a list with the names and content of all attributes
    obj_info <- x$obj_info()
    attr_data <- vector("list", length=obj_info$num_attrs)
    names(attr_data) <- h5attr_names(x)

    for(i in seq_along(attr_data)) {
        attr_obj <- x$attr_open_by_idx(i - 1, ".")
        attr_data[[i]] <- attr_obj$read()
    }
    return(attr_data)
}

##' @rdname h5attributes
##' @export
h5attr_names <- function(x) {
    ## get the number of attributes
    obj_info <- x$obj_info()
    attr_names <- character(obj_info$num_attrs);
    for(i in seq_along(attr_names)) {
        attr_names[i] <- x$attr_name_by_idx(i - 1, ".")
    }
    return(attr_names)
}

##' @rdname h5attributes
##' @export
h5attr <- function(x, which) {
    if(!x$attr_exists_by_name(which, ".")) {
        stop("Attribute does not exist")
    }
    attr_obj <- x$attr_open_by_name(which, ".")
    return(attr_obj$read())
}

##' @rdname h5attributes
##' @export
'h5attr<-' <- function(x, which, value) {
    if(x$attr_exists_by_name(which, ".")) {
        ## if it already exists, delete it first
        ## to make sure that unused object get closed
        gc()
        x$attr_delete_by_name(which, ".")
    }
    attr_obj <- x$create_attr(which, robj=value)
    return(invisible(x))
}


###################################################
## UI for working with datasets
###################################################

##' Selecting and assigning subsets of HDF5-Spaces and HDF5-Datasets
##'
##' Used for subsetting HDF5-Datasets or HDF5-Spaces or for assigning data into HDF5-Datasets. Here are some differences to
##' consider with R itself. Most importantly HDF5-COMPOUND objects only have single dimension, but they correspond to R-data.frames,
##' which are 2 dimensional. For an HDF5 COMPOUND object, it is currently not possible to only subselect a specific columns.
##' All columns have to be extracted and can then be subset in R itself. The same is true for writing a COMPOUND object
##' (\code{\link{H5T_ARRAY-class}}). A complete data-frame
##' is needed, not just a subset of the columns. Another important differences is for datasets of HDF5-ARRAY type \code{\link{H5T_ARRAY-class}}
##' where the access to the object is only for the dimension of the object itself, not including the dimensions of the underlying array type.
##' @title Selecting and assigning subsets of HDF5-Spaces and HDF5-Datasets
##' @param x The  \code{\link{H5S-class}} or \code{\link{H5D-class}} to subset or assign values to
##' @param d1 First dimension of the object
##' @param ... Used for other dimension of the object
##' @param op Operation to perform on the \code{\link{H5S-class}}. Look into the HDF5 online help
##' \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SelectElements} and
##' \\url{https://www.hdfgroup.org/HDF5/doc/RM/RM_H5S.html#Dataspace-SelectHyperslab}
##' @param dataset_xfer_pl An object of class \code{\link{H5P_DATASET_XFER-class}}. 
##' @param flags Some flags governing edge cases of conversion from HDF5 to R. This is related to how integers are being treated and
##' the issue of R not being able to natively represent 64bit integers and not at all being able to represent unsigned 64bit integers
##' (even using add-on packages). The constants governing this are part of \code{\link{h5const}}. The relevant ones start with the term
##' \code{H5TOR} and are documented there. The default set here returns a regular 32bit integer if it doesn't lead to an overflow
##' and returns a 64bit integer from the \code{bit64} package otherwise. For 64bit unsigned int that are larger than 64bit signed int,
##' it return a \code{double}. This looses precision, however.
##' @param value The value to assign to the dataset
##' @param drop Logical. When reading data, should dimensions of size 1 be dropped.
##' @param envir The environment in which the dimension indices \code{d1, ...} are to be evaluated. Usually the environment from
##' where the function is called
##' @return For \code{x} being a \code{\link{H5S-class}}, the same object is returned, but with the selection set as requested. For
##' \code{\link{H5D-class}} it retrieves the subset of data requested or sets the subset of data assigned, as for any n-dimensional array
##' in R.
##' @author Holger Hoefling
##' @export
subset_h5.H5S <- function(x,d1,  ..., op=h5const$H5S_SELECT_SET, envir=parent.frame()) {
    args <- eval(substitute(alist(d1, ...)))

    if(!x$is_simple()) {
        stop("Dataspace has to be simple for a selection to occur")
    }
    simple_extent <- x$get_simple_extent_dims()    
    ## distinguish between scalar and non-scalar
    if(simple_extent$rank == 0 && x$get_select_npoint() == 1) {
        ## is a scalar
        if(are_args_scalar(args)) {
            return(invisible(x))
        }
        else {
            stop("Scalar dataspace; arguments have to be of length 1 and empty or equal to 1")
        }
    }
    else {
        ## is a simple dataspace; treat regularly
        args_eval <- evaluate_arguments(args, ds_dims=simple_extent$dims, ds_maxdims=simple_extent$maxdims, allow_expand=FALSE, envir=envir)
        file_mem_spaces <- space_selection(file_space=x, args_eval=args_eval, ds_dims=args_eval$ds_dims, op=op)
        ## if H5S_ALL is returned, this was not set on x itself; so set it
        if(file_mem_spaces$file_space$id == h5const$H5S_ALL$id) {
            x$select_all()
        }
        ## remember - on spaces everythign is done in as reference, so we can just return x
        return(invisible(x))
    }
}



##' @rdname subset_h5.H5S
##' @export
'[.H5S' <- subset_h5.H5S

##' @rdname subset_h5.H5S
##' @export
subset_h5.H5D <- function(x, d1, ..., dataset_xfer_pl=h5const$H5P_DEFAULT,
                          flags=getOption("hdf5r.h5tor_default"), drop=TRUE, envir=parent.frame()) {
    op <- h5const$H5S_SELECT_SET
    args <- eval(substitute(alist(d1, ...)))
    x_space <- x$get_space()
    if(!x_space$is_simple()) {
        stop("Dataspace has to be simple for a selection to occur")
    }
    simple_extent <- x_space$get_simple_extent_dims()    
    ## distinguish between scalar and non-scalar
    if(simple_extent$rank == 0 && x_space$get_select_npoint() == 1) {
        ## is a scalar
        if(are_args_scalar(args)) {
            res <- x$read(file_space=x_space, mem_space=x_space, dataset_xfer_pl=dataset_xfer_pl)
            return(res)
        }
        else {
            stop("Scalar dataspace; arguments have to be of length 1 and empty or equal to 1")
        }
    }
    else {
        ## is a simple dataspace; treat regularly
        args_eval <- evaluate_arguments(args, ds_dims=simple_extent$dims, ds_maxdims=simple_extent$maxdims, allow_expand=FALSE, envir=envir)
        file_mem_spaces <- space_selection(file_space=x_space, args_eval=args_eval, ds_dims=args_eval$ds_dims, op=op)
        robj_dim <- get_robj_dim(args_eval=args_eval, dtype=x$get_type(), simple_extent=simple_extent)

        ## check if we have a compound, where we don't have to set 
        if(!is.null(robj_dim)) {
            dim_to_set <- robj_dim
            set_dim <- TRUE
        }
        else {
            set_dim <- FALSE
            dim_to_set <- "auto"
        }
        res <- x$read(file_space=file_mem_spaces$file_space, mem_space=file_mem_spaces$mem_space,
                      dataset_xfer_pl=dataset_xfer_pl, set_dim=set_dim, dim_to_set=dim_to_set, drop=drop)
        return(res)
    }
}

##' @rdname subset_h5.H5S
##' @export
"[.H5D" <- subset_h5.H5D


##' @rdname subset_h5.H5S
##' @export
subset_assign_h5.H5D <- function(x, d1, ..., dataset_xfer_pl=h5const$H5P_DEFAULT, envir=parent.frame(), value) {


    op <- h5const$H5S_SELECT_SET
    args <- eval(substitute(alist(d1, ...)))

    x_space <- x$get_space()
    if(!x_space$is_simple()) {
        stop("Dataspace has to be simple for a selection to occur")
    }
    simple_extent <- x_space$get_simple_extent_dims()    
    ## distinguish between scalar and non-scalar
    if(simple_extent$rank == 0 && x_space$get_select_npoint() == 1) {
        ## is a scalar
        if(are_args_scalar(args)) {
            return(x$write(value, file_space=x_space, mem_space=x_space, dataset_xfer_pl=dataset_xfer_pl))
        }
        else {
            stop("Scalar dataspace; arguments have to be of length 1 and empty or equal to 1")
        }
    }
    else {
        ## is a simple dataspace; treat regularly
        args_eval <- evaluate_arguments(args, ds_dims=simple_extent$dims, ds_maxdims=simple_extent$maxdims, allow_expand=TRUE, envir=envir)
        ## need to check if we have to expand the dataset
        if(args_eval$ds_dims_updated) {
            ## need to set new dataset dimensions
            x$set_extent(args_eval$ds_dims)
            ## the dataset space has changed; need the new one
            x_space <- x$get_space()
        }
        file_mem_spaces <- space_selection(file_space=x_space, args_eval=args_eval, ds_dims=args_eval$ds_dims, op=op)
        return(x$write(value, file_space=file_mem_spaces$file_space, mem_space=file_mem_spaces$mem_space,
                       dataset_xfer_pl=dataset_xfer_pl))
    }
}

##' @rdname subset_h5.H5S
##' @export
"[<-.H5D" <- subset_assign_h5.H5D


###############################################################
# Helper functions for evaluating arguments
###############################################################

space_selection <- function(file_space, args_eval, ds_dims, op) {
    if(args_eval$all_null) {
        file_space <- h5const$H5S_ALL
        mem_space <- file_space
        return(list(file_space=file_space, mem_space=mem_space))
    }
    ## not all null; see if it is points or a hyperslab
    if(inherits(args_eval$args_eval, "hyperslab")) {
        do.call(file_space$select_hyperslab, c(as.list(args_eval$args_eval, list(op=op))))
    }
    else {
        point_mat <- expand_point_grid(args_eval$args_eval, ds_dims)
        file_space$select_elements(point_mat, op=op, byrow=TRUE)
    }
    ## create the mem_space according tho the dimensions of the arguments
    dim_args_eval <- get_dim_args_eval(args_eval=args_eval, ds_dims=ds_dims)
    mem_space <- H5S$new(type="simple", dims=dim_args_eval, maxdims=dim_args_eval)
    return(list(file_space=file_space, mem_space=mem_space))
}


are_args_scalar <- function(args) {
    if(length(args) != 1) {
        return(FALSE)
    }
    if(args[[1]]==bquote(expr=) || args[[1]] == 1) {
        return(TRUE)
    }
    else {
        return(FALSE)
    }
}

evaluate_arguments <- function(args, ds_dims, ds_maxdims, allow_expand=FALSE, envir) {
    if(length(args) != length(ds_dims)) {
         stop(paste("The dataspace has rank", length(ds_dims), ". Given were", length(args), "dimensions"))
    }
    ## check which of the arguments are missing and if all are null
    all_null <- TRUE
    for(i in seq_along(args)) {
        if(class(args[[i]])=="name" && args[[i]]==bquote(expr=)) {
            args[i] <- list(NULL)
        }
        if(!is.null(args[[i]])) {
            all_null <- FALSE
        }
    }

    ## if all are null, return that; will later be used to set selection to "all" on the dataspace
    ## we do this as it is very general, easy, and also works for scalars
    if(all_null) {
        return(list(args_eval=NULL, ds_dims=ds_dims, ds_dims_updated=FALSE, all_null=TRUE))
    }

    ## not all null, so evaluate them separately
    args_eval <- do.call("rbind", lapply(args, dim_hyperslab, envir=envir))
    if(any(is.na(args_eval$start))) {
        args_eval <-  lapply(args, eval, envir=envir)
        ## check here if any of them is null; if yes, replace with the respective dimension
        for(i in seq_along(args_eval)) {
            if(is.null(args_eval[[i]])) {
                args_eval[[i]] <- seq_len(ds_dims[i])
            }
        }
    }

    ## now see what the maximum coordinate is
    max_coord <- get_maxcoord_args_eval(args_eval)
    violate_dims <- max_coord > ds_dims
    ds_dims_updated <- FALSE
    if(allow_expand) {
        ## check
        violate_maxdims <- max_coord > ds_maxdims
        if(any(violate_maxdims)) {
            stop(paste("The following coordinates are outside the maximum dataset dimensions:\n",
                       paste(paste0("Dim ", which(violate_maxdims), ": Dataset-max:", ds_dims[violate_maxdims], " Requested-max: ",
                                    max_coord[violate_maxdims])),
                       collapse="\n"))
        }
        ## get the dimension to which it will be expanded
        ds_dims <- pmax(ds_dims, max_coord)
        ds_dims_updated  <- TRUE
        args_eval <- set_maxcoord_args_eval(args_eval, ds_dims)
    }
    else {
        if(any(violate_dims)) {
            stop(paste("The following coordinates are outside the dataset dimensions:\n",
                       paste(paste0("Dim", which(violate_dims), ": Dataset", ds_dims[violate_dims], " Max-request ", max_coord[violate_dims])),
                       collapse="\n"))
        }
        args_eval <- set_maxcoord_args_eval(args_eval, ds_dims)
    }
    
    return(list(args_eval=args_eval, ds_dims=ds_dims, ds_dims_updated=ds_dims_updated, all_null=FALSE))    
}


get_maxcoord_args_eval <- function(x) {
    if(inherits(x, "hyperslab")) {
        res <- as.numeric(x$start + x$stride * (x$count - 1) + (x$block - 1))
        res[res==Inf] <- -1  # if it is inf, set it to -1 as it is arbitrary
    }
    else {
        res <- lapply(x, function(x) { if(is.null(x)) { return(-1) } else {return(max(x))}})
    }
    return(res)                                       
}

set_maxcoord_args_eval <- function(x, ds_dims) {
    if(inherits(x, "hyperslab")) {
        x$block <- pmin(x$block, ds_dims)
    }
    else {
        for(i in seq_along(x)) {
            if(is.null(x)) {
                x <- seq_len(ds_dims[i])
            }
        }
    }
    return(x)
}

get_dim_args_eval <- function(args_eval, ds_dims) {
    if(args_eval$all_null) {
        return(ds_dims)
    }
    if(inherits(args_eval$args_eval, "hyperslab")) {
        ## it is a hyperslab
        ## there is by contruction one row per dimension in the correct order
        args_eval_dim <- args_eval$args_eval$count * args_eval$args_eval$block
    }
    else {
        ## not a hyperslab; get the size of each selected dimension
        args_eval_dim <- unlist(lapply(args_eval$args_eval, length))
    }
    return(args_eval_dim)
}

get_robj_dim <- function(args_eval, dtype, simple_extent) {
    ## need to see if we have to add array dimensions
    add_array_dims <- NULL
    if(dtype$get_class() == h5const$H5T_ARRAY) {
        add_array_dims <- dtype$get_array_dims()
    }

    if(dtype$get_class() == h5const$H5T_COMPOUND) {
        return(NULL)
    }
    if(args_eval$all_null) {
        if(simple_extent$rank == 1 && is.null(add_array_dims)) {
            return(NULL)
        }
        else {
            return(c(simple_extent$dims, add_array_dims))
        }
    }
    if(inherits(args_eval$args_eval, "hyperslab")) {
        ## it is a hyperslab
        ## there is by contruction one row per dimension in the correct order
        args_eval_dim <- args_eval$args_eval$count * args_eval$args_eval$block
    }
    else {
        ## not a hyperslab; get the size of each selected dimension
        args_eval_dim <- unlist(lapply(args_eval$args_eval, length))
    }
    if(length(args_eval_dim) == 1 && is.null(add_array_dims)) {
        return(NULL)
    }
    else {
        return(c(args_eval_dim, add_array_dims))
    }
}

expand_point_grid <- function(point_list, ds_dims) {
    point_list_size <- unlist(lapply(point_list, length))
    cum_prod_std <- c(1, cumprod(point_list_size))
    cum_prod_rev <- rev(c(1, cumprod(rev(point_list_size))))
    num_points <- prod(point_list_size)
    point_mat <- matrix(numeric(num_points * length(point_list)), nrow=num_points)
    for(i in seq_along(point_list)) {
        point_mat[, i] <- rep(point_list[[i]], each=cum_prod_std[i], times=cum_prod_rev[i+1])
    }
    return(point_mat)
}

##' Create a hyperslab object for simpler internal processing
##'
##' Simple wrapper around a data.frame with a specific pattern.
##' @title Create a hyperslab object for simpler internal processing
##' @param start The start value for an HDF5 hyperslab
##' @param count The count value for an HDF5 hyperslab
##' @param stride The stride value for an HDF5 hyperslab
##' @param block The block value for an HDF5 hyperslab
##' @return A structure of class \code{hyperslab} that wraps a data.frame with columns  \code{start}, \code{count},
##' \code{stride} and \code{block}. 
##' @author Holger Hoefling
##' @keywords internal
hyperslab <- function(start, count, stride, block) {
    return(structure(data.frame(start=start, count=count, stride=stride, block=block), class=c("hyperslab", "data.frame")))
}

##' Analyze arguments passed to '[' function for hyperslab
##'
##' It takes as argument \code{x} an index as is usually pased for a dimension to '['. Instead of just calculating
##' the index values itself, non-standard evaluation is used to capture the functions \code{:}, \code{seq} and \code{seq_len}
##' and convert these into the appropriate values as needed by HDF5 to describe a hyperslab, i.e. \code{start}, \code{count},
##' \code{stride} and \code{block}.
##'
##' If none of these functions are present, the index vector is checked if it has constant differences between consecutive
##' values - then this will also be converted to a hyperslab. Otherwise, a hyperslab object \code{\link{hyperslab}} will be returned
##' with all values set to NA. 
##' @title Analyze arguments passed to '[' function for hyperslab
##' @param x The dimension arguments (as passed to a '[' function)
##' @param envir The environment in which the arguments are to be evaluated
##' @return return an object of class \code{hyperslab} by function \link{hyperslab} that overloads a dataframe and
##' describes one dimension of a hyperslab
##' @author Holger Hoeflng
##' @importFrom bit64 is.integer64
##' @keywords internal
dim_hyperslab <- function(x, envir) {
    if(is.null(x)) {
        return(structure(data.frame(start=1, count=1, stride=1, block=Inf), class=c("hyperslab", "data.frame")))
    }
    if(is.call(x)) {
        if(length(x) > 1) {
            for(i in 2:length(x)) {
                x[[i]] <- eval(x[[i]], envir=envir)
            }
        }
        if(x[[1]] == ":") {
            if(length(x) == 3) {
                if(x[[3]] < x[[2]]) {
                    stop("Retrieving hyperslabs in reverse order not supported")
                }
                start <- x[[2]]
                block <- x[[3]] - start + 1
                return(structure(data.frame(start=start, count=1, stride=1, block=block), class=c("hyperslab", "data.frame")))
            }
        }
        else if(x[[1]] == "seq_len") {
                return(structure(data.frame(start=1, count=1, stride=1, block=x[[2]]), class=c("hyperslab", "data.frame")))
        }
        else if(x[[1]] == "seq") {
            if(length(x) >= 2 && (is.integer(x[[2]]) || is.numeric(x[[2]]))) {
                ## in both cases use a matching to seq.default, as the signatures are the same
                matched_call <- match.call.withDef(seq.default, x)
                if(is.null(matched_call$length.out)) {
                    length.out <- floor(((matched_call$to - matched_call$from) / matched_call$by) + 1)
                }
                else {
                    length.out <- matched_call$length.out
                }
                stride <- matched_call$by
                start <- matched_call$from
                if(stride==1) {
                    return(structure(data.frame(start=start, count=1, stride=1, block=length.out), class=c("hyperslab", "data.frame")))
                }
                else {
                    return(structure(data.frame(start=start, count=length.out, stride=stride, block=1), class=c("hyperslab", "data.frame")))
                }
            }
        }
    }   
    else {
        x <- eval(x, envir=envir)
    }
    if(is.numeric(x) || is.integer(x) || is.integer64(x)) {
        x <- as.numeric(x)
        x_diff <- diff(x)
        if(length(x_diff) == 0) {
            return(structure(data.frame(start=x, count=1, stride=1, block=1), class=c("hyperslab", "data.frame")))
        }
        x_diff_unique <- unique(x_diff)
        if(length(x_diff_unique) == 1) {
            if(x_diff_unique == 1) {
                return(structure(data.frame(start=min(x), count=1, stride=1, block=length(x)), class=c("hyperslab", "data.frame")))
            }
            else {
                return(structure(data.frame(start=min(x), count=length(x), stride=x_diff_unique, block=1), class=c("hyperslab", "data.frame")))
            }
        }
    }
    return(structure(data.frame(start=NA, count=NA, stride=NA, block=NA), class=c("hyperslab", "data.frame")))
}



##' Match arguments in a call to function and add default values
##'
##' Given the definition of a function and a call, it matches the arguments
##' so that they are named and inserts any default argument values where
##' those are missing
##' @title Match arguments in a call to function and add default values
##' @param definition Definition of the function to match against
##' @param call The call that should be matched
##' @return A call with named arguments and default values
##' @author Holger Hoefling
##' @keywords internal
match.call.withDef <- function(definition, call) {
    def.formals <- formals(definition)
    foo <- try(as.list(match.call(definition = definition, call=call)), silent=TRUE)

    if(inherits(foo, "try-error")) {
        return(foo)
    }
    ## add the default arguments if they are missing
    for(v in names(def.formals)) {
        if(!(v %in% names(foo))) {
            foo <- c(foo, def.formals[v])
        }
    }
    return(foo)
}


