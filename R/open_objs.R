

#############################################################################
##
## Copyright 2016 Novartis Institutes for BioMedical Research Inc.
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
#############################################################################






## count how many references are open in R to an object
obj_tracker <- new.env()


make_id_char <- function(id) {
    if(is.na(id)) {
        return(NA)
    }
    else {
        id_char <- format(as.integer64(id), width=25, scientific = FALSE)
        return(id_char)
    }
}

new_id_obj <- function(id) {
    return(environment())
}

is_open <- function(id) {
    id_char <- make_id_char(id)
    return(exists(id_char, envir=obj_tracker))
}

get_obj <- function(id) {
    id_char <- make_id_char(id)
    if(exists(id_char, envir=obj_tracker)) {
        return(get(id_char, envir=obj_tracker)$obj)
    }
    else {
        return(NULL)
    }

}

incr_count <- function(id) {
    id_char <- make_id_char(id)
    if(exists(id_char, envir=obj_tracker)) {
        item <- get(id_char, envir=obj_tracker)
        item$count <- item$count + 1
        assign(x=id_char, value=item, envir=obj_tracker)
        return(item)
    }
    else {
        item <- list(count=1, obj=new_id_obj(id))
        assign(x=id_char, value=item, envir=obj_tracker)
        return(item)
    }
}

rm_obj <- function(id) {
    id_char <- make_id_char(id)
    item <- try(get(id_char, envir=obj_tracker), silent=TRUE)
    if(!inherits(item, "try-error")) {
#        H5_close_any(item$obj$id)
        item$obj$id <- NA
        rm(list=id_char, envir=obj_tracker)
    }
    else {
        print(paste("Couldn't delete", id_char))
    }
    return(invisible(NULL))
}

decr_count <- function(id) {
    id_char <- make_id_char(id)
    if(exists(id_char, envir=obj_tracker)) {
        item <- get(id_char, envir=obj_tracker)
        if(item$count == 1) {
            rm_obj(id)
            return(invisible(NULL))
        }
        else {
            item$count <- item$count - 1
            assign(x=id_char, value=item, envir=obj_tracker)
            return(item)
        }
    }
    else {
        stop(paste("Can't decrease count of obj", id_char," - already 0"))
    }

}

obj_info <- function(id) {
    if(!is.character(id)) {
        id_char <- make_id_char(id)
    }
    else {
        id_char <- id
    }
    item <- get(id_char, envir=obj_tracker)
    id_internal <- item$obj$id
    return(data.frame(id=id, count=item$count, id_internal=id_internal))
}

list_tracked_obj <- function() {
    ## first trigger garbage collection; otherwise might happen that an object
    ## is deleted between listing it and trying to access it
    gc()
    all_obj <- as.list(ls(envir=obj_tracker))
    res <- do.call("rbind", lapply(all_obj, obj_info))
    rownames(res) <- NULL
    return(res)
}
