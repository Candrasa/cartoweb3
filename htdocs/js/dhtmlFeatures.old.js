/**
 * Create a polygon
 * @return polygonObj object created
 */
function Polygon() {
  var feature = new Feature();
  feature.type = "polygon";
  
  return feature;
};

/**
 * Create a polyline
 * @return polylineObj object created (
 */
function Polyline() {
  var feature = new Feature();
  feature.type = "polyline";
  
  return feature;
};

/**
 * Create a point
 * @return Point object created
 */
function Point() {
  var feature = new Feature();
  feature.type = "point";
  
  return feature;
};

/**
 * Create a feature
 * @param wktString coords given using WKT format
 * @return the CW3 feature object created
 */
function Feature(wktString) {
  this.vertices = Array();

  if (wktString)
    this.parseWKT(wktString);
  if (typeof this.type != "undefined") {
    switch(this.type){
      case "POINT":
        this.type = "point";
        break;
      case "LINESTRING":
        this.type = "polyline";
        break;
      case "POLYGON":
        this.type = "polygon";
        break;
    }
  }
  
  var now = new Date();
  this.id = now.getTime() + "" + Math.round(Math.random() * 1000);

  return this;
};
Feature.prototype.getArea = function() {
  if (this.vertices.length > 1) {
    //surface calculation
    var measure = 0;
    for (var i = 0; i<this.vertices.length - 1;i++)
      measure += this.vertices[i].x * this.vertices[i+1].y - this.vertices[i+1].x * this.vertices[i].y;
    measure += this.vertices[this.vertices.length -1].x * this.vertices[0].y - this.vertices[0].x * this.vertices[this.vertices.length -1].y;
    return Math.abs(measure) / 2;
  } else {
    return 0;
  }
};
Feature.prototype.getLength = function() {
  var measure = 0;
  for (var i = 0; i<this.vertices.length - 1; i++) {
    var dist_x = this.vertices[i].x - this.vertices[i+1].x;
    var dist_y = this.vertices[i].y - this.vertices[i+1].y;
    measure += Math.sqrt(dist_x * dist_x + dist_y * dist_y);
  }
  return measure;
};
Feature.prototype.getBbox = function() {
  var xmin = this.vertices[0].x;
  var xmax = this.vertices[0].x;
  var ymin = this.vertices[0].y;
  var ymax = this.vertices[0].y;
  for (var i = 1; i < this.vertices.length; i++) {
    xmin = (this.vertices[i].x < xmin) ? this.vertices[i].x : xmin;
    xmax = (this.vertices[i].x > xmax) ? this.vertices[i].x : xmax;
    ymin = (this.vertices[i].y < ymin) ? this.vertices[i].y : ymin;
    ymax = (this.vertices[i].y > ymax) ? this.vertices[i].y : ymax;
  }
  var bbox = new Rectangle2D(xmin, ymin, xmax, ymax);
  return bbox;
};

Feature.prototype.isWithinRectangle2D = function(rectangle) {
  this.bbox = this.getBbox();
  return this.bbox.isWithin(rectangle);
};
/**
 * Converts a featureObj to a WKT string
 * @param aFeature
 * @return WKT string
 */
Feature.prototype.getWKT = function() {
  var coords = new String();
  for (i=0;i<this.vertices.length;i++) {
    coords += this.vertices[i].x + " " + this.vertices[i].y + ",";
  }
  coords = coords.substring(0, coords.length -1);
  switch (this.type) {
    case "point" :
      var WKTString = "POINT(" + coords + ")";
      break;
    case "polyline" :
      var WKTString = "LINESTRING(" + coords + ")";
      break;
    case "polygon" :
      var WKTString = "POLYGON((" + coords + "))";
      break;
  }
  return WKTString;
};

/**
 * Parse a WKTString and fill the vertices array
 * @param wktString
 */
Feature.prototype.parseWKT = function(wktString) {
  // regular expression to manipulate WKT strings
  var r = new RegExp("(POINT|LINESTRING|POLYGON)[(](.*)[)]", "i");
  
  var ret = wktString.match(r);
  
  this.type = ret[1];
  var coords = ret[2];
  
  r = new RegExp("[(]+(.*)[)]+|(.*)", "i");
  ret = coords.match(r);

  coords = (ret[1]) ? ret[1] : ret[2];
  
  r = new RegExp("([^,|^(|^)])+", "g");
  ret = coords.match(r);
  
  if (ret) {
    for (var i = 0; i < ret.length; i++) {
      r = new RegExp("[^ ]+", "g");
      ret2 = ret[i].match(r);
      var vertex = new Vertex(ret2[0], ret2[1]);
      vertex.index = i;
      this.vertices.push(vertex);
    }
  } else {
    alert (_m_bad_object + "\n" + wktString);
  }
}

Feature.prototype.clipLeft = function(bbox) {
  var outFeature = new Feature();
  
  outFeature.type = this.type;

  for (var i = 0; i < this.vertices.length - 1; i++) {
    v1 = this.vertices[i];
    v2 = this.vertices[i + 1];
    var outVertex1 = undefined;
    var outVertex2 = undefined;
    var outVertex3 = undefined;
    // ********** OK ************
    if (v1.x >= bbox.xmin && v2.x >= bbox.xmin) {
      outVertex1 = new Vertex(v1.x, v1.y);
      if (i == this.vertices.length - 2) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    }
    // *********LEAVING**********
    else if ( (v1.x >= bbox.xmin) && (v2.x < bbox.xmin) ) {
      outVertex1 = new Vertex(v1.x, v1.y);
      outVertex2 = new Vertex(bbox.xmin, v1.y + slope(v1, v2) * (bbox.xmin - v1.x));
      if (this.type == "polygon" && i == this.vertices.length - 2) {
        outVertex3 = new Vertex(outFeature.vertices[0].x,
          outFeature.vertices[0].y);
      }
    }
    // ********ENTERING*********
    else if ( (v1.x < bbox.xmin) && (v2.x >= bbox.xmin) ) {
      outVertex1 = new Vertex(bbox.xmin, v1.y + slope(v1, v2) * (bbox.xmin - v1.x));
      if (i == this.vertices.length - 2) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    } else if (this.type == "polygon" && i == this.vertices.length - 2) {
      outVertex1 = new Vertex(outFeature.vertices[0].x,
        outFeature.vertices[0].y);
    }
    
    if (typeof outVertex1 != "undefined") {
      outVertex1.index = v1.index;
      outFeature.vertices[outFeature.vertices.length] = outVertex1;
    }
    if (typeof outVertex2 != "undefined") {
      outVertex2.index = v2.index;
      outFeature.vertices.push(outVertex2);
    }
    if (typeof outVertex3 != "undefined") {
      outFeature.vertices.push(outVertex3);
    }
  }
  
  return outFeature;
};

Feature.prototype.clipRight = function(bbox) {
  var outFeature = new Feature();
  
  outFeature.type = this.type;

  for (var i = 0; i < this.vertices.length - 1; i++) {
    v1 = this.vertices[i];
    v2 = this.vertices[i + 1];
    var outVertex1 = undefined;
    var outVertex2 = undefined;
    var outVertex3 = undefined;
    // ********** OK ************
    if (v1.x <= bbox.xmax && v2.x <= bbox.xmax) {
      outVertex1 = new Vertex(v1.x, v1.y);
      if (i == this.vertices.length - 2) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    }
    // *********LEAVING**********
    else if ( (v1.x <= bbox.xmax) && (v2.x > bbox.xmax) ) {
      outVertex1 = new Vertex(v1.x, v1.y);
      outVertex2 = new Vertex(bbox.xmax, v1.y + slope(v1, v2) * (bbox.xmax - v1.x));
      if (this.type == "polygon" && i == this.vertices.length - 2) {
        outVertex3 = new Vertex(outFeature.vertices[0].x,
          outFeature.vertices[0].y);
      }
    }
    // ********ENTERING*********
    else if ( (v1.x > bbox.xmax) && (v2.x <= bbox.xmax) ) {
       outVertex1 = new Vertex(bbox.xmax, v1.y + slope(v1, v2) * (bbox.xmax - v1.x));
      if (i == this.vertices.length - 1) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    } else if (this.type == "polygon" && i == this.vertices.length - 2) {
      outVertex1 = new Vertex(outFeature.vertices[0].x,
        outFeature.vertices[0].y);
    }

    if (typeof outVertex1 != "undefined") {
      outVertex1.index = v1.index;
      outFeature.vertices[outFeature.vertices.length] = outVertex1;
    }
    if (typeof outVertex2 != "undefined") {
      outVertex2.index = v2.index;
      outFeature.vertices.push(outVertex2);
    }
    if (typeof outVertex3 != "undefined") {
      outFeature.vertices.push(outVertex3);
    }
  }
  return outFeature;
};

Feature.prototype.clipTop = function(bbox) {
  var outFeature = new Feature();
  
  outFeature.type = this.type;

  for (var i = 0; i < this.vertices.length - 1; i++) {
    v1 = this.vertices[i];
    v2 = this.vertices[i + 1];
    var outVertex1 = undefined;
    var outVertex2 = undefined;
    var outVertex3 = undefined;
    
    var dx = v2.x - v1.x;
    // ********** OK ************
    if (v1.y <= bbox.ymax && v2.y <= bbox.ymax) {
      outVertex1 = new Vertex(v1.x, v1.y);
      if (i == this.vertices.length - 2) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    }
    // *********LEAVING**********
    else if (v1.y <= bbox.ymax && v2.y > bbox.ymax) {
      outVertex1 = new Vertex(v1.x, v1.y);
      outVertex2 = new Vertex();
      if (dx)
        outVertex2.x = v1.x+(bbox.ymax-v1.y)/ slope (v1, v2);
      else
        outVertex2.x = v1.x;
      outVertex2.y = bbox.ymax;
      if (this.type == "polygon" && i == this.vertices.length - 2) {
        outVertex3 = new Vertex(outFeature.vertices[0].x,
          outFeature.vertices[0].y);
      }
    }
    // ********ENTERING*********
    else if ( (v1.y > bbox.ymax) && (v2.y <= bbox.ymax) ) {
      outVertex1 = new Vertex();
      if(dx)
        outVertex1.x = v1.x+(bbox.ymax-v1.y)/ slope (v1, v2);
      else
        outVertex1.x = v1.x;
      outVertex1.y = bbox.ymax;
      if (i == this.vertices.length - 2) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    } else if (this.type == "polygon" && i == this.vertices.length - 2) {
      outVertex1 = new Vertex(outFeature.vertices[0].x,
        outFeature.vertices[0].y);
    }

    if (typeof outVertex1 != "undefined") {
      outVertex1.index = v1.index;
      outFeature.vertices[outFeature.vertices.length] = outVertex1;
    }
    if (typeof outVertex2 != "undefined") {
      outVertex2.index = v2.index;
      outFeature.vertices.push(outVertex2);
    }
    if (typeof outVertex3 != "undefined") {
      outFeature.vertices.push(outVertex3);
    }
  }
  return outFeature;
};

Feature.prototype.clipBottom = function(bbox) {
  var outFeature = new Feature();
  
  outFeature.type = this.type;

  for (var i = 0; i < this.vertices.length - 1; i++) {
    v1 = this.vertices[i];
    v2 = this.vertices[i + 1];
    var outVertex1 = undefined;
    var outVertex2 = undefined;
    var outVertex3 = undefined;
    
    var dx = v2.x - v1.x;
    // ********** OK ************
    if (v1.y >= bbox.ymin && v2.y >= bbox.ymin) {
      outVertex1 = new Vertex(v1.x, v1.y);
      if (i == this.vertices.length - 2) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    }
    // *********LEAVING**********
    else if ( (v1.y >= bbox.ymin) && (v2.y < bbox.ymin) ) {
      outVertex1 = new Vertex(v1.x, v1.y);
      outVertex2 = new Vertex();
      if (dx)
        outVertex2.x = v1.x+(bbox.ymin-v1.y)/ slope (v1, v2);
      else
        outVertex2.x = v1.x;
      outVertex2.y = bbox.ymin;
      if (this.type == "polygon" && i == this.vertices.length - 2) {
        outVertex3 = new Vertex(outFeature.vertices[0].x,
          outFeature.vertices[0].y);
      }
    }
    // ********ENTERING*********
    else if ( (v1.y < bbox.ymin) && (v2.y >= bbox.ymin) ) {
      outVertex1 = new Vertex();
      if(dx)
        outVertex1.x = v1.x + (bbox.ymin - v1.y)/ slope (v1, v2);
      else
         outVertex1.x = v1.x;
      outVertex1.y = bbox.ymin;
      if (i == this.vertices.length - 2) {
        outVertex2 = new Vertex(v2.x, v2.y);
      }
    } else if (this.type == "polygon" && i == this.vertices.length - 2) {
      outVertex1 = new Vertex(outFeature.vertices[0].x,
        outFeature.vertices[0].y);
    }
    
    if (typeof outVertex1 != "undefined") {
      outVertex1.index = v1.index;
      outFeature.vertices[outFeature.vertices.length] = outVertex1;
    }
    if (typeof outVertex2 != "undefined") {
      outVertex2.index = v2.index;
      outFeature.vertices.push(outVertex2);
    }
    if (typeof outVertex3 != "undefined") {
      outFeature.vertices.push(outVertex3);
    }
  }
  return outFeature;
};

Feature.prototype.clipByRectangle2D = function(rectangle) {
  var tmpPoly = this.clipLeft(rectangle);
 var clippedPoly = tmpPoly.clipRight(rectangle);

  var tmpPoly = clippedPoly.clipBottom(rectangle);
  var clippedPoly = tmpPoly.clipTop(rectangle);
  clippedPoly.type = this.type;
//  return tmpPoly;
  return clippedPoly;
};

/**
 * Create a vertex
 */
function Vertex(x, y) {
  this.x = x;
  this.y = y;
};

/**
 * Create a raster
 * @return Raster object created
 */
function Raster(imageUrl) {
  this.img = imageUrl;
};

/**
 * 
 */
function Rectangle2D(xmin, ymin, xmax, ymax) {
  this.xmin = parseFloat(xmin);
  this.ymin = parseFloat(ymin);
  this.xmax = parseFloat(xmax);
  this.ymax = parseFloat(ymax);
  this.width = this.getWidth();
  this.height = this.getHeight();
};

Rectangle2D.prototype.getWidth = function() {
  return Math.abs(this.xmax - this.xmin);
};
Rectangle2D.prototype.getHeight = function() {
  return Math.abs(this.ymax - this.ymin);
};
Rectangle2D.prototype.intersects = function(rect) {
  return rect.width > 0 && rect.height > 0 && this.width > 0 && this.height > 0
      && rect.xmin < this.xmin + this.width
      && rect.xmin + rect.width > this.xmin
      && rect.ymin < this.ymin + this.height
      && rect.ymin + rect.height > this.ymin;
};
Rectangle2D.prototype.isWithin = function(rect) {
  return rect.width > 0 && rect.height > 0
      && this.width > 0
      && this.height > 0
      && rect.xmin <= this.xmin
      && rect.xmax >= this.xmax
      && rect.ymin <= this.ymin
      && rect.ymax >= this.ymax;
};

function slope(v1, v2) {
  // check for vertical line (prevent div by 0 - return big number)
  if (v1.x == v2.x) return Math.pow(10, 100);
  // calculate and return slope
  return (v2.y - v1.y) / (v2.x - v1.x);
};

function Line(v1, v2) {
  this.v1 = v1;
  this.v2 = v2;
};

Line.prototype.intersectsWith = function(line) {
  // calculate slopes
  var m1 = slope( this.v1, this.v2 );
  var m2 = slope( line.v1, line.v2 );
 
  // check if lines are parallel
  if ( m1 == m2 ) return false;

  // calculate the intercepts
  var b1 = intercept( this.v1.x, this.v1.y, m1 );
  var b2 = intercept( line.v1.x, line.v1.y, m2 );

  // calculate common x coordinate
  var nCommonX = ( b2 - b1 ) / ( m1 - m2 );
        
  // calculate the y coordinate of the non-vertical line
  var nCommonY = m2*nCommonX + b2;
  if ( this.v1.x != this.v2.x )
    nCommonY = m1*nCommonX + b1;

  // check that the common x & y coordinates are on both lines
  return ( isBetween( nCommonX, this.v1.x, this.v2.x ) &&
           isBetween( nCommonX, line.v1.x, line.v2.x ) &&
           isBetween( nCommonY, this.v1.y, this.v2.y ) &&
           isBetween( nCommonY, line.v1.y, line.v2.y ));
};

function intercept(x, y, m){
  // calculate the intercept
  return y-m*x;
};

function isBetween(nValue, nPoint1, nPoint2) {
  // determine if point is between based on which way the range goes
  if ( nPoint1 < nPoint2 )
    return ( nValue > nPoint1 && nValue < nPoint2 );
  else
    return ( nValue > nPoint2 && nValue < nPoint1 );
};