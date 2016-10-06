[![Build Status](https://travis-ci.org/mannau/hdf5r.svg?branch=master)](https://travis-ci.org/mannau/hdf5r) 
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/mannau/hdf5r?branch=master&svg=true)](https://ci.appveyor.com/project/mannau/hdf5r)
[![codecov.io](http://codecov.io/github/mannau/hdf5r/coverage.svg?branch=master)](http://codecov.io/github/mannau/hdf5r?branch=master)

hdf5r is an R interface to the HDF5 library. It is implemented using R6 classes based on the HDF5-C-API, 
supports all data-types supported by HDF5 (including references),
is (almost) feature complete, provides many convenience functions yet also an extensive selection of the native HDF5-C-API functions. It is also 
tested using several hundred assertions.

Currently, OS X, Linux and Windows (soon to come) are supported.

# Install

As hdf5r is currently not yet released on CRAN, it has to be installed from Github. 

```r
library(devtools)
install_github("Novartis/hdf5r")
```

The package is compatible with HDf5 version 1.8.12 or higher (also Version 1.10.0). 

## Requirements

### Windows

Binary can be downloaded from CRAN. (not yet published on CRAN).

### OS X

On OS X you can install HDF5 with the necessary header files using [Homebrew](http://brew.sh). The command for the installation is

```
brew install homebrew/science/hdf5
```


### Linux

On Linux, HDF5 can be installed on Debian-based systems (including Ubuntu) with 
```
sudo apt-get install libhdf5-dev
```

On systems supporting yum and RPMs, the command is

```
sudo yum install hdf5-devel
```

# Getting started

## How to get help

The package provides most of the regular HDF5-API in addition to a number of convenience functions. As such, the number of available methods is 
quite large. As the package uses R6 classes, all applicable methods for a class are contained in that class. The easiest way to get an 
overview of the available methods is to call the *methods* method. 

```r
native_int_type <- h5types$H5T_NATIVE_INT
native_int_type$methods()
```

Additionally, there is an web-browser-based searchable tables for all classes and methods of the package. There are two tables, one
that only shows methods for class that are directly implemented in that class and one that also shows all inherited methods). If your setup supports a 
browser, you can call it up with 

```r
H5Class_overview()
```

Of course, there is also the regular R help that you can call for each class. These help pages tend to be long, as they also document all
methods of that class.

```r
help("H5T-class")
```

Last, I very much recomment reading the included vignette. You can view all vignettes included in the pacakge with

```r
vignette(package="hdf5r")
```

and call up the introduction vignette with

```r
vignette("hdf5r", package="hdf5r")
```


## Simple code example

If you don't have time to read the vignette, which contains more code example, here is a very brief code example to 
create a file, write some data and read it back again.

```r
test_file <- tempfile(fileext=".h5")
file.h5 <- H5File$new(test_file, mode="w")

data(cars)
file.h5$create_group("test")
file.h5[["test/cars"]] <- cars
cars_ds <- file.h5[["test/cars"]]
h5attr(cars_ds, "rownames") <- rownames(cars)

## Close the file at the end
## the 'close' method closes only the file-id, but leaves object inside the file open
## This may prevent re-opening of the file. 'close_all' closes the file and all objects in it
file.h5$close_all()
```


```r
## now re-open it 
file.h5 <- H5File$new(test_file, mode="r+")

## lets look at the content
file.h5$ls(recursive=TRUE)

cars_ds <- file.h5[["test/cars"]]
## note that for now tables in HDF5 are 1-dimensional, not 2-dimensional
mycars <- cars_ds[]
h5attr_names(cars_ds)
h5attr(cars_ds, "rownames")

file.h5$close_all()
```

# License

The hdf5r package is licensend under Apache License Version 2.0. HDF5 itself doesn't ship with the hdf5r package on Linux or Mac, but on windows the downloadable binary compiled on CRAN has the HDF5 binary included. The HDF5 Copyright notice can be found below.

## hdf5r package

Copyright 2016 Novartis Institutes for BioMedical Research Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


## HDF5

The licensing terms of HDF5 can as of this writing be found in the inst/HDF5_COPYRIGHTS file or online at

https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.0/src/unpacked/COPYING
