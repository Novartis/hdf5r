## in this file some very simple read/write tests will be stored in order
## to diagnose and improve performance of the package
## Possible issues revolve around the time it takes to create R6 objects, which
## are currently used in the read/write process

library(profvis)
library(hdf5r)

dim1 <- dim2 <- 10
num_slices <- 1000

## In this test, we create a file with dim1 x dim2 x num_slices array in which we write
## one slice (third dimension) row at a time the data out of another array
## and after, we read it back out one slice at a time and compare

file_h5_name <- tempfile(fileext=".h5")
file_h5 <- H5File$new(file_h5_name, mode="a")

test_array <- array(data=rnorm(dim1 * dim2 * num_slices), dim=c(dim1, dim2, num_slices))

test_array_h5 <- file_h5$create_dataset("test_array", dtype=h5types$H5T_NATIVE_DOUBLE, space=H5S$new(type="simple", dims=c(dim1, dim2, num_slices)))
                    
profvis_write <- profvis({
    for(i in seq_len(num_slices)) {
        test_array_h5[,,i] <- test_array[,,i]
    }
})

profvis_read <- profvis({
    for(i in seq_len(num_slices)) {
        res <- test_array_h5[,,i]
        if(any(test_array[,,i] != res)) {
            stop("Problem with the output at slice", i)
        }
    }
})


