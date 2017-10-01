## intended method for H5D to reorder a dataset
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
}
