[![Build Status](https://travis-ci.org/zappingseb/rayshaderanimate.svg?branch=master)](https://travis-ci.org/zappingseb/rayshaderanimate)

# rayshaderanimate

A package to animate a GPX path on a 3d landscape - with [rayshader](http://rayshader.com)

## Purpose

This package shall be used to create a 3d flyover video of a GPX path. You can imagine
a cycling trip or a hike. You did it with a GPX tracker. This data shall now be plotted
onto a 3d landscape. This is what this package will do for you.

As an example the package contains one of [my](https://github.com/zappingseb) cycling
trips at the 21 hard serpentines of Alpe d'Huez. You can go through the vignette
of this package which explains [How to create the video?](https://zappingseb.github.io/rayshaderanimate/articles/create_video.html).

**Final video**

*as a gif*

![](inst/video.gif)


*as a mp4*

[![](inst/youtube.png)](https://www.youtube.com/watch?v=NNb50ccJ6jI)



## Functionality

Getting started:

```
devtools::install_github("zappingseb/rayshaderanimation")
```

### How to create a video?

Please go step by step through the vignette: [How to create the video?](https://zappingseb.github.io/rayshaderanimate/articles/create_video.html).

## API

### GPX read functions

Read in a gpx file to a table

```r
get_table_from_gpx()
```

Enrich the table and convert it to a boundary box

```r
get_enriched_gpx_table()

get_bbox_from_gpx_table()
```

### Elevation data functions

Elevation data can be downloaded from [SRTM](http://srtm.csi.cgiar.org/srtmdata/).

```r
get_elevdata_from_bbox()
get_elevdata_long()
```

### Output plot functions

Two functions are provided for 2D outputs within this package:

```r
# Animate GPX line on 2d plot
plot_2d_animation()

# Plot a 2D raster of the bbox
plot_2d_elevdata()

```

### Creating a video

To create a video there is just the function [`video_animation()`](https://zappingseb.github.io/rayshaderanimate/reference/video_animation.html) which will do 
the most important job of this package. Rendering the video.