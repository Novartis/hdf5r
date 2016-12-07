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

context("High-level-UI")

test_that("Names and [[", {
    test_file <- tempfile(fileext=".h5")
    ## open a new one, truncate if it exists
    file.h5 <- H5File$new(test_file, mode="w")
    test1 <- file.h5$create_group("test1")
    test2 <- test1$create_group("test2")
    test3 <- file.h5$create_group("test3")

    expect_equal(names(file.h5), c("test1", "test3"))
    expect_equal(file.h5$names, c("test1", "test3"))
    expect_equal(names(test1), "test2")
    expect_equal(names(test2), character(0))

    test4 <- file.h5[["test1", dataset_access_pl=h5const$H5P_DEFAULT]]
    expect_equal(test1$get_obj_name(), test4$get_obj_name())
    test.error <- try(file.h5[["asdf"]], silent=TRUE)
    expect_true(inherits(test.error, "try-error"))


    ## now test various assignments
    ## first the group
    ## here we have to try test2; test1 in fact does not raise an error, as an hdf5 object can be assigned onto itself
    expect_true(inherits(try(file.h5[["test1"]] <- test2, silent=TRUE), "try-error"))
    file.h5[["test_hard_link"]] <- test1
    test_hard_link <- file.h5[["test_hard_link"]]
    ## should contain the same 
    expect_equal(test_hard_link$obj_info(), test1$obj_info())

    ## now a dataset
    robj <- matrix(as.integer(1:20), ncol=4)
    test_dataset <- test1$create_dataset("test_dataset", robj)
    file.h5[["dataset_hard_link"]] <- test_dataset
    test_dataset_hl <- file.h5[["dataset_hard_link"]]
    expect_equal(test_dataset_hl$obj_info(), test_dataset$obj_info())

    ## and a type
    file.h5[["test_type"]] <- h5types$H5T_NATIVE_INT64
    expect_true(h5types$H5T_NATIVE_INT64$equal(file.h5[["test_type"]]))

    ## and a dataset
    file.h5[["test_dataset2"]] <- robj
    expect_equal(file.h5[["test_dataset2"]]$read(), robj)
    
    file.h5$close_all()
    file.remove(test_file)
})


test_that("dim_hyperslab", {
    dim_hyperslab_wrapper <- function(x, envir=parent.frame()) {
        return(dim_hyperslab(substitute(x), envir=envir))
    }  

    expect_equal(dim_hyperslab_wrapper(1:4), hyperslab(1, 1, 1, 4))
    expect_equal(dim_hyperslab_wrapper(seq(to=4, from=1, by=2)), hyperslab(1, 2, 2, 1))
    expect_equal(dim_hyperslab_wrapper(seq_len(5)), hyperslab(1, 1, 1, 5))
})



test_that("subset_h5.H5S", {
    ## create a dataspace
    h5s_obj <- H5S$new(type="simple", dims=c(10,20,30), maxdims=c(10,20,30))
    subset_h5.H5S(h5s_obj, seq_len(3), seq(2,4,by=3), 5:9)
    expect_equal(h5s_obj$get_select_type(), h5const$H5S_SEL_HYPERSLABS)
    expect_equal(h5s_obj$get_select_hyper_blocklist(), matrix(c(1,3,2,2,5,9), nrow=2))

    subset_h5.H5S(h5s_obj, seq_len(3), seq(2,4,by=3), c(1,2,4))
    expect_equal(h5s_obj$get_select_type(), h5const$H5S_SEL_POINTS)
    
})

test_that("subset_h5.H5D", {
    ## create a file with a dataset in it
    ## fill it with simple numbers and read it back
    test_file <- tempfile(fileext=".h5")
    ## open a new one, truncate if it exists
    file.h5 <- H5File$new(test_file, mode="w")

    robj <- matrix(as.integer(1:40), ncol=4)
    file.h5[["test"]] <- robj
    test <- file.h5[["test"]]
    
    expect_equal(test[1:3, 2:4], robj[1:3, 2:4])

    expect_equal(test[c(1,3,4),], robj[c(1,3,4),])

    test[1:3, 2:4] <- 1:9
    expect_equal(test[1:3, 2:4], matrix(1:9, ncol=3))

    ## write outside of the current set
    ## will trigger an automatic expansion of the current set if possible
    test[11:15, ] <- 1:20
    expect_equal(as.vector(test[11:15,]), 1:20)

    ## also test an indirect subsetting
    get_1 <- function(i, ds) {
        return(ds[i,])
    }
    expect_equal(get_1(11, test), c(1, 6, 11, 16))


    ## need to recreate an error where writing into an array failed when there was a missing dimension
    ## and the other given dimension was a call
    test2 <- file.h5$create_dataset("test_array", dtype=h5types$H5T_NATIVE_INT, space=H5S$new("simple", dims=c(10,10,100)),
                           chunk_dims=c(10,10,1))
    pos_list <- list(1)
    test2[,,pos_list[[1]]] <- 1:100
    expect_equal(test2[,,1], matrix(1:100, ncol=10))
    
    file.h5$close_all()
    file.remove(test_file)
})


test_that("attributes", {
    ## open a file, set 2 attributes, read out their names
    ## read them both, read them separately

    test_file <- tempfile(fileext=".h5")
    ## open a new one, truncate if it exists
    file.h5 <- H5File$new(test_file, mode="w")

    robj1 <- matrix(as.integer(1:10), ncol=2)
    robj2 <- paste("Test", 1:10)

    h5attr(file.h5, "integer") <- robj1
    h5attr(file.h5, "character") <- robj2

    expect_equal(sort(h5attr_names(file.h5)), sort(c("integer", "character")))
    all_attr <- h5attributes(file.h5)
    expect_equal(all_attr$integer, robj1)
    expect_equal(all_attr$character, robj2)

    expect_equal(h5attr(file.h5, "integer"), robj1)
    expect_equal(h5attr(file.h5, "character"), robj2)

    h5attr(file.h5, "integer") <- robj2
    expect_equal(h5attr(file.h5, "integer"), robj2)


    
    file.h5$close_all()
    file.remove(test_file)
})


test_that("Subsetting dimensions, drop and repeated write", {
    test_file <- tempfile(fileext=".h5")
    file.h5 <- H5File$new(test_file, mode="w")

    ex_array <- array(1:60, dim=c(3,4,5))
    file.h5[["ex_array"]] <- ex_array
    ex_arr_ds <- file.h5[["ex_array"]]

    expect_equal(ex_arr_ds[2,,],  ex_array[2,,])
    expect_equal(ex_arr_ds[,2,],  ex_array[,2,])
    expect_equal(ex_arr_ds[,,2],  ex_array[,,2])

    expect_equal(ex_arr_ds[2,,, drop=FALSE],  ex_array[2,,, drop=FALSE])
    expect_equal(ex_arr_ds[,2,, drop=FALSE],  ex_array[,2,, drop=FALSE])
    expect_equal(ex_arr_ds[,,2, drop=FALSE],  ex_array[,,2, drop=FALSE])

    ## now test the repeated write
    ex_arr_ds[,,] <- 1
    ex_array[,,] <- 1
    expect_equal(ex_array[,,], ex_arr_ds[,,])
    ex_arr_ds[,,] <- c(1,2,3)
    ex_array[,,] <- c(1,2,3)
    expect_equal(ex_array[,,], ex_arr_ds[,,])
    

    file.h5$close_all()
    file.remove(test_file)
    
})

