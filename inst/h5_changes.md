# Changes from h5 to hdf5r

- Change subset operator to [[
- Support on-the-fly group creation / Recursive group creation ? 
    e.g. file[["testgroup/testset"]] <- 1:10 without existing testgroup
- full.names in list.xxx does not return global path name

# Missing Features

- list.attributes (e.g. through H5Aiterate2)
- Adjust $print() for all HDF5 objects
- Create dataset without chunking?
- Get Chunk size from dataset
- Implement follow.link


# Issues
- H5S$new(maxdims = "test") should immediately throw error
- Check why H5T_STD_I64LE is not mapped to 64bit integer?
- Check why enum test case ist not working (test-zzz.enum.R)
- Does array retrieval work?