# hdf5r 1.0.1
- Updated package to work with version 1.10.2 and 1.10.3 of HDF5
- Fixed issue #84, adding full.names argument in h5-wrapper to list.groups; also added test
- Fixed issue #82, causing the "ls" method to hang for some large datasets; 
  this is caused by H5Oget_info being slow
  for such datasets; using the deprecated H5Aget_num_attrs instead where needed

# hdfr 1.0.0
- First release of the hdf5r package
