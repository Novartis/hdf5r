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


#ifndef _H5LS_H
#define _H5LS_H


#include "global.h"

herr_t H5Dget_info(hid_t d_id, H5D_info_t * dataset_info);

herr_t H5Dget_info_by_name(hid_t g_id, const char* name, H5D_info_t * dataset_info, hid_t lapl_id);

herr_t gather_data_from_link(hid_t g_id, const char *name, const H5L_info_t *info, void *op_data);

SEXP R_H5ls(SEXP _g_id, SEXP _recursive, SEXP _index_type, SEXP _order, SEXP _lapl_id, SEXP _dapl_id, SEXP _tapl_id);

#endif
