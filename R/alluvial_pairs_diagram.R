#' Create alluvial diagrams for a classified raster with 2 or more layers.
#'
#' This function analyzes land cover change between the categorized layers of a SpatRaster
#' object using `terra`and visualizes from-to relations using `ggalluvial` diagrams.
#'
#' The function is intended for visualizing land cover change analysis.
#' For better readability the layers should have timestamps, these can be set
#' with terra::time().
#'
#' @param raster A `SpatRaster` object containing multiple raster layers. The function
#'               will compare transitions between consecutive layers.
#' @param lookup A data frame or list with at least three columns:
#'               - The first column: Class names (factor levels),
#'               - The second column: Class identifiers (factors),
#'               - The third column: Color mapping for each class.
#' @param naValue A value to replace any `NA` or `NaN` values in the raster layers
#'                (default is `NA`).
#' @param a_unit A string indicating the units for the area label (default is "px").
#'
#' @return A list of ggplot objects, each representing an alluvial diagram for the
#'         transition between two consecutive raster layers.
#'
#' @details
#' This sets arbitrary timestamps if they are not present. It also ensures that the raster layers
#' are categorized using the provided lookup table, which assigns class names, identifiers,
#' and colors to each raster class.
#'
#' The function works by iterating through consecutive raster layers, computing
#' a crosstabulation of the class transitions between layers, and then plotting
#' the resulting transitions using the `ggalluvial` package. The resulting plots
#' are returned as a list of `ggplot` objects.
#'
#' @importFrom ggplot2 ggplot aes geom_label ggtitle labs theme_minimal scale_fill_manual after_stat
#' @importFrom ggalluvial geom_alluvium geom_stratum
#' @importFrom terra timeInfo time nlyr levels values rast crosstab sapp
#' @importFrom viridis viridis
#'
#' @export
alluvial_pairs_diagram <- function(raster, lookup, naValue = NA, a_unit = "px"){

  # check & set times
  if (terra::timeInfo(raster)$time == FALSE) {
    terra::time(raster) <- seq(nlyr(rstack))
    warning("At least one layer has no set time. Times set as layer number")
  }

  # Convert NA
  set_NA <- function(rst) {
    rst[is.na(rst)] <- naValue
    rst[is.nan(rst)] <- naValue
    return(rst)
  }

  if (!is.null(naValue)) {
    raster <- terra::sapp(raster, set_NA)
  }

  # Get number of layers
  n_layers <- terra::nlyr(raster)

  if (n_layers < 2) stop("Need at least two layers to compare transitions.")

  plots <- list()

  has_categories <- function(x){
    if (is.null(ncol(terra::levels(x)[[1]]))){
      return(FALSE)
    } else {
      return(TRUE)
    }
  }

  # Loop through layer pairs
  for (i in 1:(n_layers-1)) {

    r1 <- raster[[i]]
    r2 <- raster[[i+1]]

    # check & set levels
    if (has_categories(r1) == FALSE){
      writeLines("Raster levels set using LUT.")
    }

    levels(r1) <- lookup
    levels(r2) <- lookup

    # Crosstab for this pair
    xtab <- terra::crosstab(c(r1, r2), long = TRUE)
    names(xtab)[1:2] <- c("from", "to")

    # Force factor levels
    xtab$from <- factor(xtab$from, levels = lookup[[2]])
    xtab$to   <- factor(xtab$to,   levels = lookup[[2]])

    # Color mapping
    color_mapping <- setNames(lookup[[3]], lookup[[2]])

    # Plot for this pair
    p <- ggplot2::ggplot(xtab, aes(y = n, axis1 = from, axis2 = to,
                                   fill = after_stat(stratum), discern = NULL)) +
      ggalluvial::geom_alluvium(width = 1/5, alpha = 0.3, discern=FALSE) +
      ggalluvial::geom_stratum(width = 1/5, color = "black", discern=FALSE) +
      ggplot2::scale_fill_manual(values = color_mapping, name = "Class") +
      ggplot2::ggtitle(paste0(time(raster[[i]]), " -> ", time(raster[[i+1]]))) +
      ggplot2::labs(y = paste0("Area in ", a_unit)) +
      ggplot2::theme_minimal()
    plots[[i]] <- p
  }

  return(plots)
}
