
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


#ifndef _EXPORT_MANUAL_H_
#define _EXPORT_MANUAL_H_

R_CallMethodDef library_WRAPPER_MANUAL_H5T[] = {
  {"h5create_compound_type", (DL_FUNC) &h5create_compound_type, 4},
  {"h5create_enum_type", (DL_FUNC) &h5create_enum_type, 3},
  {"h5get_enum_labels", (DL_FUNC) &h5get_enum_labels, 1},
  {"h5get_enum_values", (DL_FUNC) &h5get_enum_values, 1},
  {"h5get_compound_types", (DL_FUNC) &h5get_compound_types, 1},
  {"h5get_compound_names", (DL_FUNC) &h5get_compound_names, 1},
  {"h5get_compound_classes", (DL_FUNC) &h5get_compound_classes, 1},
  {"h5get_compound_offsets", (DL_FUNC) &h5get_compound_offsets, 1},
  {"R_H5Tdetect_vlen", (DL_FUNC) &R_H5Tdetect_vlen, 1},
  {NULL, NULL, 0}
};
#endif
