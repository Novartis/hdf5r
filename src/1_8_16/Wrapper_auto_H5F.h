#ifndef _WRAPPER_AUTO_H5F_H_
#define _WRAPPER_AUTO_H5F_H_
#include "global.h"
/* H5_DLL herr_t H5Fclear_elink_file_cache(hid_t file_id); */
SEXP R_H5Fclear_elink_file_cache(SEXP R_file_id);
/* H5_DLL herr_t H5Fclose(hid_t file_id); */
SEXP R_H5Fclose(SEXP R_file_id);
/* H5_DLL hid_t H5Fcreate(const char *filename, unsigned flags, hid_t create_plist, hid_t access_plist); */
SEXP R_H5Fcreate(SEXP R_filename, SEXP R_flags, SEXP R_create_plist, SEXP R_access_plist);
/* H5_DLL herr_t H5Fflush(hid_t object_id, H5F_scope_t scope); */
SEXP R_H5Fflush(SEXP R_object_id, SEXP R_scope);
/* H5_DLL hid_t H5Fget_access_plist(hid_t file_id); */
SEXP R_H5Fget_access_plist(SEXP R_file_id);
/* H5_DLL hid_t H5Fget_create_plist(hid_t file_id); */
SEXP R_H5Fget_create_plist(SEXP R_file_id);
/* H5_DLL ssize_t H5Fget_file_image(hid_t file_id, void * buf_ptr, size_t buf_len); */
SEXP R_H5Fget_file_image(SEXP R_file_id, SEXP R_buf_ptr, SEXP R_buf_len, SEXP _dupl_buf_ptr);
/* H5_DLL herr_t H5Fget_filesize(hid_t file_id, hsize_t *size); */
SEXP R_H5Fget_filesize(SEXP R_file_id, SEXP R_size);
/* H5_DLL hssize_t H5Fget_freespace(hid_t file_id); */
SEXP R_H5Fget_freespace(SEXP R_file_id);
/* H5_DLL herr_t H5Fget_info(hid_t obj_id, H5F_info_t *bh_info); */
SEXP R_H5Fget_info(SEXP R_obj_id, SEXP R_bh_info);
/* H5_DLL herr_t H5Fget_intent(hid_t file_id, unsigned * intent); */
SEXP R_H5Fget_intent(SEXP R_file_id, SEXP R_intent);
/* H5_DLL herr_t H5Fget_mdc_config(hid_t file_id, H5AC_cache_config_t * config_ptr); */
SEXP R_H5Fget_mdc_config(SEXP R_file_id, SEXP R_config_ptr);
/* H5_DLL herr_t H5Fget_mdc_hit_rate(hid_t file_id, double * hit_rate_ptr); */
SEXP R_H5Fget_mdc_hit_rate(SEXP R_file_id, SEXP R_hit_rate_ptr);
/* H5_DLL herr_t H5Fget_mdc_size(hid_t file_id, size_t * max_size_ptr, size_t * min_clean_size_ptr, size_t * cur_size_ptr, int * cur_num_entries_ptr); */
SEXP R_H5Fget_mdc_size(SEXP R_file_id, SEXP R_max_size_ptr, SEXP R_min_clean_size_ptr, SEXP R_cur_size_ptr, SEXP R_cur_num_entries_ptr);
/* H5_DLL ssize_t H5Fget_name(hid_t obj_id, char *name, size_t size); */
SEXP R_H5Fget_name(SEXP R_obj_id, SEXP R_name, SEXP R_size);
/* H5_DLL ssize_t H5Fget_obj_count(hid_t file_id, unsigned types); */
SEXP R_H5Fget_obj_count(SEXP R_file_id, SEXP R_types);
/* H5_DLL ssize_t H5Fget_obj_ids(hid_t file_id, unsigned types, size_t max_objs, hid_t *obj_id_list); */
SEXP R_H5Fget_obj_ids(SEXP R_file_id, SEXP R_types, SEXP R_max_objs, SEXP R_obj_id_list);
/* H5_DLL htri_t H5Fis_hdf5(const char *filename); */
SEXP R_H5Fis_hdf5(SEXP R_filename);
/* H5_DLL herr_t H5Fmount(hid_t loc, const char *name, hid_t child, hid_t plist); */
SEXP R_H5Fmount(SEXP R_loc, SEXP R_name, SEXP R_child, SEXP R_plist);
/* H5_DLL hid_t H5Fopen(const char *filename, unsigned flags, hid_t access_plist); */
SEXP R_H5Fopen(SEXP R_filename, SEXP R_flags, SEXP R_access_plist);
/* H5_DLL hid_t H5Freopen(hid_t file_id); */
SEXP R_H5Freopen(SEXP R_file_id);
/* H5_DLL herr_t H5Freset_mdc_hit_rate_stats(hid_t file_id); */
SEXP R_H5Freset_mdc_hit_rate_stats(SEXP R_file_id);
/* H5_DLL herr_t H5Fset_mdc_config(hid_t file_id, H5AC_cache_config_t * config_ptr); */
SEXP R_H5Fset_mdc_config(SEXP R_file_id, SEXP R_config_ptr);
/* H5_DLL herr_t H5Funmount(hid_t loc, const char *name); */
SEXP R_H5Funmount(SEXP R_loc, SEXP R_name);
#endif
