#############################################################################
##
## Copyright [2016] Novartis Institutes for BioMedical Research Inc.
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

library(bit64)
library(R6)
library(plyr)
library(brew)
library(knitr)


extract_dotcall <- function(expr, c_func_pattern) {
    if(length(expr) > 1) {
        if(is.call(expr)) {
            if(expr[[1]]==".Call") {
                if(is.character(expr[[2]])) {
                    last <- length(expr)
                    expr_names <- names(expr)
                    if(length(expr_names) > 0 && expr_names[last] == "PACKAGE" && is.character(expr[[last]])) {
                        if(c_func_pattern=="" || grepl(c_func_pattern, expr[[2]])) {
                            return(data.frame(c_function=expr[[2]], package=expr[[last]], stringsAsFactors=FALSE))
                        }
                        else {
                            return(NULL)
                        }
                    }
                    else {
                        return(data.frame(c_function=expr[[2]], package=NA, stringsAsFactors=FALSE))
                    }
                }
                else {
                    return(NULL)
                }
            }
            else {
                res <- ldply(as.list(expr), extract_dotcall, c_func_pattern=c_func_pattern)
                if(nrow(res)==0) {
                    return(NULL)
                }
                else {
                    return(res)
                }
            }
        }
        else {
            return(NULL)
        }
    }
    else {
        if(is.function(expr)) {
            return(extract_dotcall(body(expr), c_func_pattern=c_func_pattern))
        }
        else {
            return(NULL)
        }
    }
}


summarize_list <- function(x, c_func_pattern) {
    obj_names <- names(x)

    obj_info <- vector("list", length(obj_names))

    for(i in seq_along(obj_names)) {
        obj <- .subset2(x, obj_names[i])
        if(is.function(obj)) {
            obj_info[i] <- list(extract_dotcall(obj, c_func_pattern=c_func_pattern))
            if(is.null(obj_info[[i]])) {
                obj_info[[i]] <- data.frame(c_function=NA, package=NA, stringsAsFactors = FALSE)

            }
            deparse_func <- as.character(deparse(args(obj)))
            ## drop the NULL at the end
            if(deparse_func[length(deparse_func)] == "NULL") {
                deparse_func <- deparse_func[-length(deparse_func)]
            }
            deparse_func <- gsub("^\\s*", "", deparse_func)
            obj_info[[i]]$args <- paste(deparse_func, collapse = "")
            obj_info[[i]]$name <- obj_names[i]
        } else {
            obj_info[i] <- list(NULL)
        }
    }
    return(ldply(obj_info))
}


summarize_r6classgenerator <- function(r6class_gen, c_func_pattern) {
    if(!inherits(r6class_gen, "R6CalssGenerator")) {
        classname <- r6class_gen$classname
        if(!is.null(r6class_gen$inherit)) {
            cls_inherits <- as.character(r6class_gen$inherit)
        }
        else {
            cls_inherits <- NA
        }
    }
    public_methods <- summarize_list(r6class_gen$public_methods, c_func_pattern=c_func_pattern)
    active_methods <- summarize_list(r6class_gen$active, c_func_pattern=c_func_pattern)

    if(nrow(active_methods) > 0) {
        active_methods$active <- TRUE
    }
    if(nrow(public_methods) > 0) {
        public_methods$active <- FALSE
    }
    all_methods <- rbind(active_methods, public_methods)
    all_methods$class <- classname
    all_methods$inherits <- cls_inherits
    all_methods$h5_link <- create_h5_html_ref(all_methods$c_function)
    all_methods$rd_link <- create_h5_html_ref(all_methods$c_function, in_Rd=TRUE)

    return(all_methods[, c("class", "inherits", "name", "active", "c_function", "package", "h5_link", "rd_link", "args")])
}




create_h5_html_ref <- function(c_function, in_Rd=FALSE) {
    ## first check if it is an h5 name
    res <- data.frame(c_function=c_function)
    res$is_h5 <- grepl("R_H5", c_function)
    res$group <- NA
    res$group[res$is_h5] <- gsub("^R_(H5[A-Z]*)[a-z].*$", "\\1", res$c_function[res$is_h5], perl=TRUE)
    res$h5_name_in_group <- NA
    res$h5_name_in_group[res$is_h5] <- gsub("^R_(H5[A-Z]+)([a-z].*)$", "\\2", res$c_function[res$is_h5], perl=TRUE)

    res$h5_name_in_group_camel <- NA
    res$h5_name_in_group_camel[res$is_h5] <- gsub("^([a-z])", "\\U\\1\\E", res$h5_name_in_group[res$is_h5], perl=TRUE)
    res$h5_name_in_group_camel[res$is_h5] <- gsub("_([a-z])", "\\U\\1\\E", res$h5_name_in_group_camel[res$is_h5], perl=TRUE)
    
    group_names_base <- c(H5="Library", H5A="Annot", H5D="Dataset", H5E="Error", H5F="File", H5G="Group",
                          H5I="Identify", H5L="Link", H5O="Object", H5P="Property", H5R="Reference", H5S="Dataspace",
                          H5T="Datatype", H5Z="Compression")

    res$name_on_page <- NA
    res$doc_dir <- NA
    res <- within(res, {
        is_base_group <- group %in% names(group_names_base);
        name_on_page[is_base_group] <- paste0(group_names_base[group[is_base_group]], "-", h5_name_in_group_camel[is_base_group]);
        name_on_page[!is_base_group] <- gsub("^_", "", c_function[!is_base_group], perl=TRUE);
        doc_dir[is_base_group] <- "RM";
        doc_dir[!is_base_group] <- "HL"
    })

    if(!in_Rd) {
        res$h5_manual_link <- NA
        res$h5_manual_link[res$is_h5] <- with(subset(res, is_h5), paste0("https://www.hdfgroup.org/HDF5/doc/", doc_dir, "/RM_", group,
                                                                         ".html#", name_on_page))
        res$h5_manual_link[res$is_h5] <- with(subset(res, is_h5), make_HTML_link(h5_manual_link, name_on_page))
        return(res$h5_manual_link)
    }
    else {
        res$h5_rd_link <- NA
        res$h5_rd_link[res$is_h5] <- with(subset(res, is_h5), paste0("\\\\url{https://www.hdfgroup.org/HDF5/doc/", doc_dir, "/RM_", group,
                                                                     ".html#", name_on_page, "}"))

        return(res$h5_rd_link)
    }
                                          
}


create_HTML_table <- function(data_frame, table_name) {
    output.html <- kable(data_frame, "html", table.attr= paste("id=\"", table_name, "\"", sep=""), escape=FALSE)    
    javascript <- c("<script type=\"text/javascript\">", "$(document).ready(function() {", paste("$('#", table_name, "').DataTable();", sep=""),
                    "} );", "</script>")
    output.html <- c(output.html, javascript)
    return(output.html)
}

make_HTML_link <- function(url, text=url) {
    return(paste("<a href=\"", url, "\">", text, "</a>\n", sep=""))
}


brew_overview <- function(tbl_with_inheritance, tbl_no_inheritance, brew_file="function_overview.brew") {
    env <- new.env()
    env$table_no_inheritance.html <- create_HTML_table(replace_NA_with_empty(tbl_no_inheritance), "tbl_no_inheritance")
    env$table_with_inheritance.html <-     create_HTML_table(replace_NA_with_empty(tbl_with_inheritance), "tbl_with_inheritance")

    brew(brew_file, output=gsub("brew$", "html", brew_file), envir=env)
}

replace_NA_with_empty <- function(df) {
    for(i in seq_along(df)) {
        col <- df[[i]]
        col[is.na(col)] <- ""
        df[[i]] <- col
    }
    return(df)
}

add_inherited_functions <- function(df) {

    ## split the rest into the parts that inherits from a base class and that doesn't
    ## inherit from a base class
    base_class_funcs <- df[is.na(df$inherits),]
    base_classes <- unique(base_class_funcs$class)
    inherits_from_base_class <- df[!is.na(df$inherits) & df$inherits %in% base_classes,]
    inherits_from_other_class <- df[!is.na(df$inherits) & !(df$inherits %in% base_classes),]

    ## for the classes that inherit from the base classes, add the function of said class
    class_inherits_from_base <- unique(inherits_from_base_class$class)
    func_expanded <- NULL
    for(cls in class_inherits_from_base) {
        base_class <- unique( subset(inherits_from_base_class, class==cls)$inherits)
        funcs_inherited <- subset(base_class_funcs, class==base_class)
        funcs_inherited$class <- cls
        func_expanded <- rbind(func_expanded, subset(inherits_from_base_class, class==cls),
                               funcs_inherited)
    }
    if(!is.null(func_expanded) && nrow(func_expanded) > 0) {
        func_expanded$inherits <- NA
    }

    ## now check if there are any other classes left
    if(nrow(inherits_from_other_class) > 0) {
        res <- add_inherited_functions(rbind(base_class_funcs, func_expanded, inherits_from_other_class))
    }
    else {
        res <- rbind(base_class_funcs, func_expanded)
    }
    return(res)
}

## get all the functions that are in the classes

## first source all the R-scripts into an environment
r_files <- list.files("../../R", pattern=glob2rx("*.R"), full.names=TRUE)
source_env <- new.env()
for(r_file in r_files) {
    source(r_file, local=source_env)
}
## remove the Chunk_sort_tracker
rm(list="Chunk_sort_tracker", envir=source_env)

## first, get all R6ClassGenerators
obj_names <- ls(envir=source_env)
r6classes <- NULL
for(obj_name in obj_names) {
    obj <- get(obj_name, envir=source_env)
    if(inherits(obj, "R6ClassGenerator")) {
        r6classes <- c(r6classes, list(obj))
    }
}
all_classes_summary <- ldply(r6classes, summarize_r6classgenerator, c_func_pattern="")
all_classes_h5only_summary <- ldply(r6classes, summarize_r6classgenerator, c_func_pattern="_H5")


no_package <- subset(all_classes_summary, !is.na(c_function) & (is.na(package) | package!="hdf5r"))
if(nrow(no_package) > 0) {
    stop("There are functions with a .Call that don't point to this package")
}

## for the tables, we don't need "active" or "package"
all_classes_h5only_summary_pretty <- all_classes_h5only_summary[, c("class", "inherits", "name", "c_function", "h5_link")]
all_classes_inherited <- add_inherited_functions(all_classes_h5only_summary_pretty)
all_classes_inherited$inherits <- NULL


tbl_inherited_for_brew <- all_classes_inherited
tbl_inherited_for_brew$c_function <- gsub("^_", "", tbl_inherited_for_brew$c_function)
tbl_no_inheritance_for_brew <- all_classes_h5only_summary_pretty
tbl_no_inheritance_for_brew$c_function <- gsub("^_", "", tbl_no_inheritance_for_brew$c_function)

rownames(tbl_inherited_for_brew) <- NULL
rownames(tbl_no_inheritance_for_brew) <- NULL
brew_overview(tbl_inherited_for_brew, tbl_no_inheritance_for_brew, brew_file="function_overview.brew")


###########################################################
## Now will create the field and methods section for the
## documentation of R6 classes
###########################################################


## this function is currently unused 
extract_comment <- function(func) {
    ## first need to get the deparse function
    func_deparsed <- deparse(func, control="useSource")

    ## now delete the top of the function (up to and including the first {
    all_curly <- grep(pattern="\\{", func_deparsed)
    if(length(all_curly) == 0) {
        return(character(0))
    }

    first_curly <- min(all_curly)
    func_deparsed <- func_deparsed[- seq_len(first_curly)]
    
    ## now check if there is a comment at the beginning; it has to start with ##
    ## grab all the comments
    ## remove the ## and return the rest
    has_comment <- grepl("\\s*#'", func_deparsed)
    if(!all(has_comment)) {
        ## use only the beginning
        first_not_comment <- which(!has_comment)[1]
        comment_section <- func_deparsed[seq_len(first_not_comment - 1)]
    }
    else {
        comment_section <- func_deparsed
    }
    
    ## remove the spaces and ##
    comment_section <- gsub("\\s*#'\\s*", "", comment_section)
    ## check that it contains the document keyword
    return(comment_section)
}


## Now will also write out a file that contains a default docstring for all
## functions that contain a call to an HDF5 file
## this is to make the task of writing docstrings for these functions easier.
## we will just have to copy/paste

template_docstring <- with(subset(all_classes_h5only_summary, !is.na(rd_link)), {
    template_docstring <- paste0(class, "-", name, "\n\"This function implements the HDF5-API function ", substr(c_function, 3, nchar(c_function)),".\"\n\"Please see the documentation at ", rd_link, " for details.\"\n")
})

cat(template_docstring, file="docstring_templates.txt", sep="\n")
                           
