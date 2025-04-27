#' Rename a shapefile and it's associated files
#'
#' This function renames all parts of a shapefile (e.g., .shp, .shx, .dbf, etc.) to a new base name.
#' Optionally, it can delete the original files after renaming.
#'
#' @param path Character. Path (without the .shp extension) to the shapefile to be renamed.
#' @param newname Character. New base name for the shapefile (without extension).
#' @param delete Logical. If \code{TRUE}, the original files will be deleted after renaming. Defaults to \code{FALSE}.
#'
#' @return Invisibly returns a character vector with the new file names.
#'
#' @examples
#' \dontrun{
#' rename_shapefile("data/old_shapefile", "new_shapefile")
#' rename_shapefile("data/old_shapefile", "new_shapefile", delete = TRUE)
#' }
#' @export
rename_shapefile <- function(path, newname, delete = FALSE) {
  # Check arguments
  if (!is.character(path) || length(path) != 1) stop("path must be a single character string.")
  if (!is.character(newname) || length(newname) != 1) stop("newname must be a single character string.")
  if (!is.logical(delete) || length(delete) != 1) stop("delete must be a single logical value.")

  # Extract directory and base name
  dir_path <- dirname(path)
  old_basename <- basename(path)

  # List all matching files
  files <- list.files(path = dir_path, pattern = paste0("^", old_basename, "\\."), full.names = TRUE)

  if (length(files) == 0) {
    stop("No shapefile components found for the given path.")
  }

  # Rename files
  new_files <- character(length(files))
  for (i in seq_along(files)) {
    file_ext <- tools::file_ext(files[i])
    new_file <- file.path(dir_path, paste0(newname, ".", file_ext))
    file.copy(files[i], new_file, overwrite = TRUE)
    new_files[i] <- new_file
  }

  # Optionally delete old files
  if (delete) {
    file.remove(files)
  }

  invisible(new_files)
}
