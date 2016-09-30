

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






## implements a data type in R that stores (and manipulates) a raw HDF5 compound datatype
## this can be practical for the direct manipulation of tables
## as well as for creating the structs in c code (that we need as input for the API interface functions)

## for now we implement this as a simple S3 class that can then be passed into an out of the RToH5 and H5ToR
create_RCOMPOUND <- function(dtype, len) {
    if(!inherits(dtype, "H5T_COMPOUND")) {
        stop("The dtype has to be of class H5T_COMPOUND")
    }
    cpd_size <- dtype$get_size()
    x <- raw(cpd_size * len)
    class(x) <- "RCOMPOUND"
    attr(x, "dtype") <- dtype
}


## a function that converts a data frame to an RCOMPOUND
dataframe_to_RCOMPOUND <- function(dF, dtype) {
    if(!inherits(dtype, "H5T_COMPOUND")) {
        stop("The dtype has to be of class H5T_COMPOUND")
    }
    x <- RToH5(dF, dtype=dtype)
    class(x) <- "RCOMPOUND"
    attr(x, "dtype") <- dtype
}

## and from an RCOMPOUND back to R
RCOMPOUND_to_dataframe <- function(x) {
    if(!inherits(x, "RCOMPOUND")) {
        stop("x needs to be an RCOMPOUND object")
    }
    dtype <- attr(x, "dtype")
    retRobj <- H5ToR_Pre(dtype, nelem)
    dtype_size <- dtype$get_size()
    ## need to guess the number of elements -> length of the x vector / size of the compound
    nelem <- length(x) / dtype_size
    retRobj <- copyRVec(retRobj, x, nelem * dtype_size);
    retRobj <- H5ToR_Post(retRobj, dtype, nelem)
    return(retRobj)
}


