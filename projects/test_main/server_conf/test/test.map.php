MAP
  NAME "Testing"
  EXTENT -3 48 3 54
  IMAGETYPE png
  IMAGECOLOR 255 255 255
  STATUS ON
  SIZE 200 200
  FONTSET "fonts.txt"
  SYMBOLSET "symbols.txt"

  SHAPEPATH "shapes"

  REFERENCE
    IMAGE images/keymap.png
    EXTENT -0.5 50.977222 0.5 51.977222
    STATUS ON
    COLOR -1 -1 -1
    OUTLINECOLOR 255 0 0
    SIZE 100 100
  END

  SCALEBAR
    STATUS OFF
    POSTLABELCACHE TRUE
    STYLE 0
    UNITS METERS
    SIZE 150 3
    POSITION LR
    TRANSPARENT TRUE
    COLOR 0 0 0
    IMAGECOLOR 242 255 195
    BACKGROUNDCOLOR 255 255 255
    LABEL
      TYPE BITMAP
      SIZE TINY
      COLOR 0 0 0
      POSITION UR
      BUFFER 10
    END
  END

  WEB
    METADATA
      "key1" "value1"
      "key2" "value2"
      "key3" "value3"
      "key4" "value4"
    END
    
    #IMAGEPATH "/var/www/cartoserver/www-data/images/" 
    #IMAGEURL "/cartogfx/"

  END

  PROJECTION
    "init=epsg:4326"
  END
  
  QUERYMAP
    COLOR 0 0 0
    STATUS ON
    STYLE Hilite
  END
  
<?php

printLayer('POLYGON', 
<<<AUTOLAYER

  LAYER
    NAME <?php printName(); ?>
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    DATA "polygon"
    METADATA
      "key1" "value1"
      "key2" "value2"
      "key3" "value3"
      "key4" "value4"
      "id_attribute_string" "FID|string"
      "query_returned_attributes" "FID FNAME"
    END
    CLASSITEM "FNAME"
    
    # for queries
    TEMPLATE "ttt"
    
    CLASS
      NAME "Polygon class 1"
      METADATA
        "key1" "value1"
        "key2" "value2"
        "key3" "value3"
        "key4" "value4"
      END
      STYLE
        COLOR <?php if(getIndex() == 2) print "200 200 255";
                                   else print "255 153 102"; ?>
        OUTLINECOLOR 0 0 204
        SYMBOL 1
        SIZE 2
      END
    END
    CLASS
      #NAME "1"
      EXPRESSION "foo"
      STYLE
        COLOR 255 153 102
        OUTLINECOLOR 0 0 204
        SYMBOL 1
        SIZE 2
      END
    END
  END
AUTOLAYER
);

?>

  LAYER
    NAME "some_rectangles"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    METADATA
      "id_attribute_string" "A_NAME|string"
      "force_imagetype" "jpeg"
    END
    DATA "some_rectangles"
    CLASSITEM "A_NAME"
    
    # for queries
    TEMPLATE "ttt"
    
    CLASS
      NAME "0"
      STYLE
        COLOR 50 50 100
      END
    END
  END

  LAYER
    NAME "LINE"
    TYPE LINE
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    DATA "line"
    METADATA
      "id_attribute_string" "FID|string"
    END
    CLASSITEM "FNAME"

    # for queries
    TEMPLATE "ttt"

    CLASS
      NAME "Line class 1"
      STYLE
        COLOR 153 153 0
        SYMBOL 1
        SIZE 2
      END
      MAXSCALE 7
    END
    CLASS
      NAME "Line class 2"
      EXPRESSION "foo"
      STYLE
        COLOR 0 153 0
        SYMBOL 1
        SIZE 4
      END
      MAXSCALE 12
    END
  END

  LAYER
    NAME "POINT"
    #EXTENT -0.5 51.0 0.5 52.0
    TYPE POINT
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    METADATA
      "id_attribute_string" "FID|string"
    END
    DATA "point"
    CLASSITEM "FNAME"
    LABELITEM "FNAME"
    TEMPLATE "ttt"
    CLASS
      NAME "Point class 1"
      STYLE
        COLOR 0 0 0
        SYMBOL 1
        SIZE 13
      END
      STYLE
        COLOR 204 204 204
        SYMBOL 1
        SIZE 7
      END
      LABEL
        TYPE TRUETYPE
        FONT "Vera"
        SIZE 10
        COLOR 0 0 0
      END
    END
    CLASS
      #NAME "1"
      EXPRESSION "foo"
      STYLE
        COLOR 0 0 0
        SYMBOL 1
        SIZE 13
      END
    END
    MINSCALE 7
    MAXSCALE 11
  END
 
  LAYER
    NAME "more_points"
    TYPE POINT
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    DATA "more_points"
    #CLASSITEM "FID"
    TEMPLATE "ttt"
    CLASS
      NAME "Point class 2"
      STYLE
        COLOR 0 0 255
        SYMBOL 1
        SIZE 5
      END
    END
    MINSCALE 1
    MAXSCALE 20
    TOLERANCE 5
    TOLERANCEUNITS pixels
  END

  LAYER
    NAME "INLINE"
    TYPE POINT
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    FEATURE
      POINTS -0.2 51.5 END
    END
    CLASS
      NAME "0"
      STYLE
        COLOR 0 0 0
        SYMBOL 1
        SIZE 3
      END
    END
  END

  LAYER
    NAME "cartoweb_point_outline"

    TYPE POINT
    PROJECTION
      "init=epsg:4326"
    END

    TRANSPARENCY 50
    CLASS
      STYLE
        OUTLINECOLOR 0 0 204
        SYMBOL 1
        SIZE 15
      END
      LABEL
        ANTIALIAS true
        FONT Vera
        TYPE truetype
        COLOR 51 51 51
        SIZE 10
        POSITION ur
      END
    END
  END

  LAYER
    NAME "cartoweb_line_outline"

    TYPE LINE
    PROJECTION
      "init=epsg:4326"
    END

    TRANSPARENCY 50
    CLASS
      STYLE
        OUTLINECOLOR 0 0 204
        SYMBOL 1
        SIZE 1
      END
      LABEL
        ANGLE auto
        ANTIALIAS true
        FONT Vera
        TYPE truetype
        COLOR 255 51 51
        SIZE 10
      END
    END
  END

  LAYER
    NAME "cartoweb_polygon_outline"

    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END

    TRANSPARENCY 50
    CLASS
      STYLE
        COLOR 155 153 102
        OUTLINECOLOR 0 0 204
        SYMBOL 1
        SIZE 1
      END
      LABEL
        ANTIALIAS true
        FONT Vera
        TYPE truetype
        COLOR 51 51 51
        SIZE 10
      END
    END
  END

  LAYER
    NAME "grid_defaulthilight"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    METADATA
      "exported_values" "security_view,security_edit"
      "security_view" "admin"
      "security_edit" "admin,editors"
    
      "id_attribute_string" "FID|string"
      "mask_transparency" "50"
      "mask_color" "255, 255, 0"
    END
    DATA "grid"
    CLASSITEM "FID"
    TEMPLATE "ttt"
    TRANSPARENCY 30

    CLASS
      NAME "grid_class"
      STYLE
        COLOR 0 153 102
        OUTLINECOLOR 0 0 204
      END
    END
  END

  LAYER
    NAME "grid_classhilight"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    METADATA
      "id_attribute_string" "FID|string"
      "mask_transparency" "50"
      "mask_color" "255, 255, 0"
    END
    DATA "grid"
    CLASSITEM "FID"
    TEMPLATE "ttt"
    TRANSPARENCY 30

    CLASS
      EXPRESSION /_always_false_/
      NAME "hilight"
      STYLE
        COLOR 255 255 0 
        OUTLINECOLOR 255 255 0
      END
    END

    CLASS
      NAME "grid_class"
      STYLE
        COLOR 0 153 102
        OUTLINECOLOR 0 0 204
      END
    END
  END

  LAYER
    NAME "grid_layerhilight"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    METADATA
      "id_attribute_string" "FID|string"
      "outside_mask" "my_outside_mask"
    END
    DATA "grid"
    CLASSITEM "FID"
    TEMPLATE "ttt"
    TRANSPARENCY 30

    CLASS
      NAME "grid_class"
      STYLE
        COLOR 0 153 102
        OUTLINECOLOR 0 0 204
      END
    END
  END

  LAYER
    NAME "grid_layerhilight_hilight"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    METADATA
      "id_attribute_string" "FID|string"
    END
    DATA "grid"
    CLASSITEM "FID"
    TEMPLATE "ttt"
    TRANSPARENCY 90

    CLASS
      NAME "grid_class"
      STYLE
        COLOR 0 0 0
        OUTLINECOLOR 0 0 0
      END
    END
  END

  LAYER
    NAME "grid_layerhilight_mask"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    METADATA
      "id_attribute_string" "FID|string"
    END
    DATA "grid"
    CLASSITEM "FID"
    TEMPLATE "ttt"
    TRANSPARENCY 90

    CLASS
      NAME "grid_class"
      STYLE
        COLOR 255 255 255
        OUTLINECOLOR 255 255 255
      END
    END
  END

  LAYER
    NAME "my_outside_mask"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    DATA "gridmask"
    TEMPLATE "ttt"
    TRANSPARENCY 90

    CLASS
      NAME "grid_class"
      STYLE
        COLOR 255 255 255
        OUTLINECOLOR 255 255 255
      END
    END
  END

  LAYER
    NAME "default_outside_mask"
    TYPE POLYGON
    PROJECTION
      "init=epsg:4326"
    END
    STATUS DEFAULT
    DATA "gridmask"
    TEMPLATE "ttt"
    TRANSPARENCY 50

    CLASS
      NAME "grid_class"
      STYLE
        COLOR 255 255 0
        OUTLINECOLOR 255 255 0
      END
    END
  END

OUTPUTFORMAT
  NAME png
  DRIVER "GD/PNG"
  MIMETYPE "image/png"
  IMAGEMODE PC256
  EXTENSION "png"
  FORMATOPTION "INTERLACE=OFF"
END

END

