<input type="hidden" id="openNodes" name="openNodes" />
{literal}
<style type="text/css">
#layersroot {text-align:left;margin-left:10px; font-size:0.8em;}
#layersroot table {padding:0;margin:0;width:100%}
#layersroot table + table {margin-top:-2px;}
#layersroot td {/*border:red 1px dotted;*/vertical-align:top;font-size:0.8em;padding-top:3px;}
#layersroot .inp {padding:0;width:15px;} 
#layersroot .node {padding:0;} 
#layersroot .lk {width:8px;text-align:center;}
#layersroot .lk a {text-decoration:none;color:black;font-family:courier;font-size:1em;}
#layersroot .nov { display:none;}
</style>
<script type="text/javascript">
  <!--
  function writeOpenNodes(shortcut) {
    if (shortcut) {
      document.carto_form.elements.openNodes.value = openNodes;
      return;
    }
    
    var nodesList = new Array();
    for (var i = 0; i < openNodes.length; i++) {
      if(!isNaN(openNodes[i])) nodesList.push(openNodes[i]);
    }
    document.carto_form.elements.openNodes.value = nodesList;
  }

  function isInOpenNodes(id) {
    for (var i = 0; i < openNodes.length; i++) {
      if (openNodes[i] == id) return i + 1;
    }
    return false;
  }
  
  function updateOpenNodes(id, open) {
    var isModified = false;
    if (open) { 
      if (!isInOpenNodes(id)) {
        // adds node to list
        openNodes.push(id);
        isModified = true;
      }
    } else {
      var i = isInOpenNodes(id);
      if (i > 0) {
        // removes node from list
        delete(openNodes[i - 1]);
        isModified = true;
      }
    }
    if(isModified) writeOpenNodes();
  }
  
  function shift(id) {
    var obj = document.getElementById(id);
    var key = document.getElementById('x' + id);
    var iid = id.substr(2);
    
    if (key.innerHTML == '-') { 
      key.innerHTML = '+';
      obj.style.display = 'none';
      updateOpenNodes(iid);
    }
    else {
      key.innerHTML = '-';
      obj.style.display = 'block';
      updateOpenNodes(iid,true);
    }
  }

  function expandAll(id) {
    var mydiv = document.getElementById(id);
    var divs = mydiv.getElementsByTagName('div');
    var key;
    
    openNodes = new Array();
    
    for (var i = 0; i < divs.length; i++) {
      divs[i].style.display = 'block';
      var nid = divs[i].id;
      openNodes.push(nid.substr(2));
      key = document.getElementById('x' + nid);
      if (key) key.innerHTML = '-';
    }

    writeOpenNodes(true);
  }

  function closeAll(id) {
    var mydiv = document.getElementById(id);
    var divs = mydiv.getElementsByTagName('div');
    var key;
    
    for (var i = 0; i < divs.length; i++) {    
      key = document.getElementById('x' + divs[i].id);
      if (key) key.innerHTML = '+';
        
      if (divs[i].getAttribute('id')) {
          divs[i].style.display = 'none';    
      }
    }

    openNodes = new Array();
    writeOpenNodes(true);
  }

  function checkChildren(id,val) {
    var mydiv = document.getElementById(id);
    if (!mydiv) return;
    
    var divs = mydiv.getElementsByTagName('input');
    if (val != false) val = true;

    for (var i = 0; i < divs.length; i++) {
      if (divs[i].name.substring(0, 6) == 'layers')
        divs[i].checked = val;
    }
  }
  
  function isChildrenChecked(id) {
    var dparent = document.getElementById(id);
    var celts = dparent.getElementsByTagName('input');
    for (var i = 0; i < celts.length; i++) {
      if (!celts[i].checked) return false;
    }
    return true;
  }

  function updateChecked(id,skipChildren) {
    var obj = document.getElementById('in' + id);
    if (!obj) return;
    var val = obj.checked;
    
    if (!skipChildren) checkChildren('id' + id, val);
    
    var pid = obj.parentNode.getAttribute('id');
    var iid = pid.substr(2);
    var iparent = document.getElementById('in' + iid);
   
    if (!iparent) return;

    // if node has been unchecked, makes sure parents are unchecked too
    if (val == false) {
      iparent.checked = false;
      updateChecked(iid, true);
    }
    // if all siblings are checked, makes sure parents are checked too
    else if (isChildrenChecked(pid)) {
      iparent.checked = true;
      updateChecked(iid, true);
    }
  }
//-->
</script>
{/literal}
<script type="text/javascript">
  <!--
  var openNodes = new Array('{$startOpenNodes}');
  writeOpenNodes(true);
  //-->
</script>
<div id="layerscmd"><a href="javascript:expandAll('layersroot');">{$expand}</a> -
<a href="javascript:closeAll('layersroot');">{$close}</a><br />
<a href="javascript:checkChildren('layersroot');">{$check}</a> -
<a href="javascript:checkChildren('layersroot',false);">{$uncheck}</a></div>
<div id="layersroot">
{$layerlist}
</div>
