AC_INIT([hdf5r], 0.1.0, [hoeflin@gmail.com])

dnl Grab that macro that checks for HDF5 availability
m4_include([inst/m4/ax_lib_hdf5.m4])
m4_include([inst/m4/ax_compare_version.m4])
m4_include([inst/m4/hh_hdf5rlib.m4])

AX_LIB_HDF5()

if test "$with_hdf5" = "yes"; then 
AX_COMPARE_VERSION([$HDF5_VERSION], [ge], [1.8.12], [hdf5_version_sufficient="yes"], [hdf5_version_sufficient="no"])
else 
hdf5_version_sufficient="no"
fi


if test "$hdf5_version_sufficient" = "yes"; then 

AX_COMPARE_VERSION(
	[$HDF5_VERSION], 
	[ge], 
	[1.8.12], 
	[HDF5_VERSION_USE="1_8_12"; DEFINE_H5FREE_MEMORY="1"])

dnl 1.8.13 uses the 1.8.12 code wrappers, but doesn't define the H5free_memory function as that was introducted in that version
AX_COMPARE_VERSION(
	[$HDF5_VERSION], 
	[ge], 
	[1.8.13], 
	[HDF5_VERSION_USE="1_8_14"; DEFINE_H5FREE_MEMORY="0"])

AX_COMPARE_VERSION(
	[$HDF5_VERSION], 
	[ge], 
	[1.8.14], 
	[HDF5_VERSION_USE="1_8_14"; DEFINE_H5FREE_MEMORY="0"])

AX_COMPARE_VERSION(
	[$HDF5_VERSION], 
	[ge], 
	[1.8.16], 
	[HDF5_VERSION_USE="1_8_16"; DEFINE_H5FREE_MEMORY="0"])

AX_COMPARE_VERSION(
	[$HDF5_VERSION], 
	[ge], 
	[1.10.0], 
	[HDF5_VERSION_USE="1_10_0"; DEFINE_H5FREE_MEMORY="0"])
fi

AC_SUBST(HDF5_VERSION_USE)

AC_MSG_RESULT([Using code intended for version: $HDF5_VERSION_USE])

AC_SUBST(DEFINE_H5FREE_MEMORY)
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT



