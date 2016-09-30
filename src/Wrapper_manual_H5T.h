
/**************************************************************************
 * 
 * Copyright 2016 Novartis Institutes for BioMedical Research Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 *************************************************************************/


#ifndef _WRAPPER_MANUAL_H5T_H_
#define _WRAPPER_MANUAL_H5T_H_

#include "global.h"

SEXP h5create_compound_type(SEXP names, SEXP _dtype_ids, SEXP _size, SEXP _offset);
SEXP h5create_enum_type(SEXP _labels, SEXP _values, SEXP _dtype_id);
SEXP h5get_enum_labels(SEXP _dtype_id);
SEXP h5get_enum_values(SEXP _dtype_id);
SEXP h5get_compound_types(SEXP _dtype_id);
SEXP h5get_compound_names(SEXP _dtype_id);
SEXP h5get_compound_classes(SEXP _dtype_id);
SEXP h5get_compound_offsets(SEXP _dtype_id);

// uses a private function to detect if a datatype has a variable length component
// the internal function of H5T_detect_class already has this ability, but it is
// hidden from users in the API in order to return H5T_STRING, even for variable length
// strings; internally, a variable length string is counted as variable length
SEXP R_H5Tdetect_vlen(SEXP _dtype_id);

#endif
