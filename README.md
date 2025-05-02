# lcutils Package

This package provides utilities for land cover/spatial data analysis.  

Install the package by using `devtools::install_github("max-merzdorf/lcutils")`

You can access example data via `system.file("extdata", "filename.end", package = lcutils)`

Please note that when loading the example lookup table with `read.csv()` you have to omit the first column. For more information see the github pages.

[Visit the github pages for a more detailed walkthrough of the function](https://max-merzdorf.github.io/lcutils/)


### WIP:
- extend `alluvial_pairs_diagram` / new function that plots multiple diagrams from left to right
- `squares_around_points` -> Create squares with a defined side-length n around a `sf` `POINT` or `MULTIPOINT` geometry.
