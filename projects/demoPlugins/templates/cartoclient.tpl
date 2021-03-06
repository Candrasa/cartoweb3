<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
  <meta http-equiv="Content-Type" content="text/html; charset={$charset}" />
  <link rel="stylesheet" type="text/css" href="{r type=css}cartoweb.css{/r}" title="stylesheet" />
  <link rel="stylesheet" type="text/css" href="{r type=css}folders.css{/r}" title="stylesheet" />
  {if $layers|default:''}<link rel="stylesheet" type="text/css" href="{r type=css plugin=layers}layers.css{/r}" />{/if}
  <link rel="stylesheet" type="text/css" href="{r type=css plugin=tables}tables.css{/r}" />
  {if $outline_active|default:''}<link rel="stylesheet" type="text/css" href="{r type=css plugin=outline}outline.css{/r}" />{/if}
  {if $toolpicker_active|default:''}<link rel="stylesheet" type="text/css" href="{r type=css}toolPicker.css{/r}" title="stylesheet" />{/if}
  {if $collapsibleKeymap|default:''}<link rel="stylesheet" type="text/css" href="{r type=css}keymap.css{/r}" />{/if}
  {if $layerReorder|default:''}<link rel="stylesheet" type="text/css" href="{r type=css plugin=layerReorder}layerReorder.css{/r}" />{/if}
  {if $locate_active|default:''}<link rel="stylesheet" type="text/css" href="{r type=css plugin=locate}locate.css{/r}" />{/if}
  
  <link rel="icon" href="{r type=gfx/layout}cw3.png{/r}" type="image/png" />

  <title>{t}CartoWeb3 - Demonstration{/t}</title>

  <script type="text/javascript" src="{r type=js}EventManager.js{/r}"></script>
  <script type="text/javascript" src="{r type=js}carto.js{/r}"></script>
  {if $layers|default:''}<script type="text/javascript" src="{r type=js plugin=layers}layers.js{/r}"></script>{/if}
  {if $exportPdf|default:''}<script type="text/javascript" src="{r type=js plugin=exportPdf}exportPdf.js{/r}"></script>{/if}
  {if $layerReorder|default:''}<script type="text/javascript" src="{r type=js plugin=layerReorder}layerReorder.js{/r}"></script>{/if}
  {if $collapsibleKeymap|default:''}<script type="text/javascript" src="{r type=js}keymap.js{/r}"></script>
  <script language="JavaScript" type="text/javascript">
    <!--
    var hideKeymapMsg = "{t}Collapse keymap{/t}";
    var showKeymapMsg = "{t}Show keymap{/t}";
    var hideKeymap = {$collapseKeymap};
    //-->
  </script>
  {/if}
  {if $views|default:'' || $viewsList|default:''}<script type="text/javascript" src="{r type=js plugin=views}views.js{/r}"></script>{/if}
  {if $locate_active|default:''}<script type="text/javascript" src="{r type=js}prototype.js{/r}"></script>{/if}
  {include file="dhtmlcode.tpl"}
</head>

<body>

<!-- header begins here -->
<table border="0"  cellpadding="0" cellspacing="0" width="100%">
<tr><td>
<table>
<tr><td>
<table id="topbanner" border="0"  cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td id="logo"><img src="{r type=gfx/layout}logoc2c.gif{/r}" alt="camptocamp" border="0"/></td>
    <td id="title" nowrap="nowrap">{t}CartoWeb3 - Demonstration{/t}</td>
  </tr>
</table>
</td></tr>
<tr><td>
<!-- header ends here -->

<form method="post" action="{$selfUrl}" name="carto_form"  onsubmit="doSubmit();">
  <input type="image" name="dummy" alt="" id="dummy" />
  <input type="hidden" name="posted" value="1" />
  <input type="hidden" name="js_folder_idx" value="{$jsFolderIdx}" />
  <input type="hidden" name="js_toolbar_idx" value="{$jsToolbarIdx}" />
  <input type="hidden" name="selection_type" />
  <input type="hidden" name="selection_coords" />
  <input type="hidden" name="features" />
  <input type="hidden" name="project" value="{$project}" />
  {if $collapsibleKeymap|default:''}
    <input type="hidden" name="collapse_keymap" value="{$collapseKeymap}" />
  {/if}
  <input type="hidden" id="fake_reset" name="fake_reset" />
  {if $outline_active|default:''}
    {$outlinelabel}
  {/if}

<table>
  <tr>
    <td></td>
    <td>
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td width="30%" align="center">
          {if $scales_active|default:''}
            {$scales}
          {/if}
        </td>
        <td width="40%" align="center">
          {if $viewsList|default:''}
            <h1>{t}Views :{/t}</h1>
            <select name="viewBrowseId" onchange="javascript:loadView();">
            {html_options options=$viewsList selected=$selectedView}
            </select>
            <input type="hidden" name="viewBrowse" value="0" />
            {if !$views}
            <input type="hidden" name="handleView" value="0" />
            {/if}
          {/if}
        </td>
        <td width="30%" align="center">
          {if $mapsizes_active|default:''}
            {$mapsizes}
          {/if}
        </td>
      </tr>
    </table>
    </td>
    <td></td>
  </tr>
  <tr valign="top">  
    <td id="toolbar_row" valign="top" width="30px" align="center">
      <br /><br />
      <table cellpadding="0" cellspacing="1" border="0">
        <tr><td>
          {include file="toolbar.tpl" group="2"}
          {include file="toolbar.tpl" group="1" header="1"}
          <a href="javascript:ontop(6);">
            <img src="{r type=gfx/layout}help.gif{/r}"
                 title="{t}Help{/t}" alt="{t}help{/t}"style="padding:4px;" />
          </a>
          <a href="javascript:resetSession();">
            <img src="{r type=gfx/layout}reset_session.gif{/r}"
                 alt="{t}reset session{/t}" title="{t}Reset session{/t}" style="padding:3px;"/>
          </a>
        </td></tr>
      </table>
    </td>
    <td>
    <div id="content">
    <table id="mapframe" cellpadding="0" cellspacing="0">
      <tr>
        <td><input type="image" src="{r type=gfx/layout}north_west.gif{/r}" name="pan_nw" alt="NW" /></td>
        <td align="center"><input type="image" src="{r type=gfx/layout}north.gif{/r}" name="pan_n" alt="N" /></td>
        <td><input type="image" src="{r type=gfx/layout}north_east.gif{/r}" name="pan_ne" alt="NE" /></td>
      </tr>
      <tr>
        <td><input type="image" src="{r type=gfx/layout}west.gif{/r}" name="pan_w" alt="W" /></td>
         <td valign="top">
          {include file="mainmap.tpl"}
        </td>
        <td><input type="image" src="{r type=gfx/layout}east.gif{/r}" name="pan_e" alt="E" /></td>
      </tr> 
      <tr>
        <td></td>
        <td>
          <table width="100%"><tr>
            <td width="50%"><div id="floatGeo" class="locationInfo">{t}Coord (m):{/t} %s / %s</div></td>
            <td width="50%" align="right">
              <div id="floatDistance" class="locationInfo">{t}Approx. distance :{/t} %s{if $factor == 1000} km{else} m{/if}</div>
              <div id="floatSurface" class="locationInfo">{t}Approx. area :{/t} %s{if $factor == 1000} km&sup2;{else} m&sup2;{/if}</div></td>
          </tr></table>
        </td>
        <td></td>
      </tr>
      <tr>
        <td>
          <input type="image" src="{r type=gfx/layout}south_west.gif{/r}" name="pan_sw" alt="SW" />
        </td>
        <td align="center">
          <input type="image" src="{r type=gfx/layout}south.gif{/r}" name="pan_s" alt="S" />
        </td>
        <td>
          <input type="image" src="{r type=gfx/layout}south_east.gif{/r}" name="pan_se" alt="SE" />
        </td>
      </tr>
      <tr>
        <td  colspan="3"><br /></td>
      </tr>
      <tr>
        <td colspan="3" valign="top" align="center">
          {if $scalebar_path|default:''}
          <img src="{$scalebar_path}" 
          alt="{t}scalebar_alt{/t}" width="{$scalebar_width}"
          height="{$scalebar_height}" title="" />
          {/if}
        </td>
      </tr>
      <tr>
        <td  colspan="3"><br /></td>
      </tr>
      
      {if $tables_result|default:''}
      <tr>
        <td colspan ="3">
        <table style="border:1px solid black;" width="100%">
          {if $selection_result|default:''}
          <tr>
            <td colspan ="3">
              <center>
                {$selection_result}
              </center>
            </td>
          </tr>
          {/if}
          <tr>
            <td>
              <center>
                {$tables_result}
              </center>
            </td>
          </tr>
       
          {if $query_result|default:''}
          <tr>
            <td colspan ="3">
              <center>
                {$query_result}
              </center>
            </td>
          </tr>
          {/if}
        </table>
        </td>
      </tr>
      {/if}
      {if $developer_messages|default:''}
      <tr>
       <td colspan="3" align="center">
       <table id="user_message" width="100%" border="0" cellpadding="0" cellspacing="0">
         <tr>
           <th align="left" class="messages">
             <span style="color: green; border: 10px; background-color: yellow;">{t} Developer messages {/t}</span>
           </th>
         </tr>
         <tr>
           <td>
             <ul>
               {foreach from=$developer_messages item=message}
                 <li>{$message}</li>
               {/foreach}   
             </ul>
           </td>
         </tr> 
       </table>
       </td>
     </tr>
     {/if}
       
     {if $user_messages|default:''}
     <tr>
       <td colspan="3" align="center">
         <table id="user_message" width="100%" border="0" cellpadding="0" cellspacing="0">
           <tr>
             <th align="left" class="messages">{t}User messages{/t}</th>
           </tr>
           <tr>
             <td>
               <ul>
                 {foreach from=$user_messages item=message}
                   <li>{$message}</li>
                 {/foreach}   
               </ul>
             </td>
           </tr> 
         </table>
         </td>
       </tr>
     {/if}
     <tr>
       <td  colspan="3"><br /></td>
     </tr>
   </table>
   </div>
   </td>
   <td width="330px" valign="top" nowrap="nowrap" rowspan="2">
     <div>
       <ul id="tabnav2">
         {if $layerReorder|default:''}<li id="label9"><a href="javascript:ontop(9)">{t}Layers reorder{/t}</a></li>{/if}
         {if $wmsBrowserLight|default:''}<li id="label7"><a href="javascript:ontop(7)">{t}WMS layers{/t}</a></li>{/if}
         {if $exportRtf|default:''}<li id="label10"><a href="javascript:ontop(10)">{t}RTF{/t}</a></li>{/if}
       </ul>
       <ul id="tabnav1">
         <li id="label1"><a href="javascript:ontop(1)">{t}Themes{/t}</a></li>
         <li id="label3"><a href="javascript:ontop(3)">{t}Search{/t}</a></li>
         <li id="label5"><a href="javascript:ontop(5)">{t}Outline{/t}</a></li>
         {if $views|default:''}<li id="label8"><a href="javascript:ontop(8)">{t}Views{/t}</a></li>{/if} 
         <li id="label6"><a href="javascript:ontop(6)">{t}Help Viewer{/t}</a></li>      
       </ul>
     </div>

     <div id="container">
     <!-- folder 1 starts here -->
     <div id="folder1" class="folder">
       <br />
       {$layers}
       <center>
         <input type="submit" id="refresh" name="refresh" value="{t}Refresh{/t}" class="form_button" />
       </center>
     </div>
     <!-- end of folder 1 -->
    
     <!-- folder 3 starts here -->
     <div id="folder3" class="folder">
       <br />
       {if $routing_active|default:''}
       <fieldset>
       <legend>{t}A route{/t}</legend>
         {$routing}
       </fieldset>
       <br />
       {/if}
       {if $id_recenter_active|default:''}
       <fieldset>
       <legend>{t}A geographic object{/t}</legend>
       <br />
         {if $locate_active|default:''}
           {$locate_form}
         {/if}
         {$id_recenter}
       </fieldset>
       {/if}
       
       {if $exporthtml_active|default:''}
         <a href="{$exporthtml_url}" target="print">{t}Print{/t}</a>
       {/if}
     </div>
     <!-- end of folder 3 -->
    
     <!-- folder 5 starts here -->
     <div id="folder5" class="folder">
       <br />
       <center>
       <table cellpadding="0" cellspacing="1" border="0">
         <tr><td>
           {include file="toolbar.tpl" group="3"}
         </td></tr>
       </table>
       {$outline}
       {if $exportDxf}{$exportDxf}{/if}
       </center>
     </div>
     <!-- end of folder 5 -->
    
     <!-- folder 8 starts here -->
     {if $views|default:''}
       <div id="folder8" class="folder">
         <br />
         {$viewsForm}
       </div>
     {/if}
     <!-- end of folder 8 -->
    
     <!-- folder 9 starts here -->
     {if $layerReorder|default:''}
       <div id="folder9" class="folder">
         <br />
         <center>
           {$layerReorder}
         </center>
       </div>
     <!-- end of folder 9 -->
     {/if}
    
     <!-- folder 6 starts here -->
     <div id="folder6" class="folder" style="height:{$mainmap_height}px;">
       <p><i>{t}This demo is an overview of the new functionalities, that are available since the last version of Cartoweb. To get the most out of it, read through this Help guide before starting to explore.{/t}</i></p>
       <br />
       <table class="table_help" cellpadding="0" cellspacing="0">
         <tr><td>
           <img src="{r type=gfx/layout/help}tab.gif{/r}" alt="{t}Search tab{/t}" /><strong>&nbsp;{t}Search tab{/t}</strong><br />
         </td></tr>
       </table>
       <p class="help_viewer">
         {t}This tab allows you to do a search on :{/t}<br />
         <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" /><span class="s">{t}a route{/t}</span> :
         {t} this option allows you to find the shortest route between two european towns. You simply need to select a town from where to start and 
         an other to finish.{/t}<br />
         <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" /><span class="s">{t}a geographic object{/t}</span> :
         {t}if you want to move to an european district, suburb, town or airport, simply select this geographic layer
         and type the corresponding name.{/t}
       </p><br />
       <table class="table_help" cellpadding="0" cellspacing="0">
         <tr><td>
           <img src="{r type=gfx/layout/help}tab.gif{/r}" alt="{t}Views tab{/t}" /><strong>&nbsp;{t}Views tab{/t}</strong><br />
         </td></tr>
       </table>
       <p class="help_viewer">    
         {t}Views are recordings of CartoWeb maps states at a given moment. 
         One may see them as a kind of bookmarks : while browsing maps in CartoWeb interface, you can save the current state (map extent, selected layers, queries, annotations, etc.) under a label of your choice. 
         It is then possible to access later those saved states.{/t}<br />
         <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" /><span class="s">{t}Load a view{/t}</span> :
         {t}any defined view may be loaded. Loading a view may be achieved selecting it among a dropdown views list.{/t}<br />
         <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" /><span class="s">{t}Save a view{/t}</span> :
         {t} to save the current map state as a view, simply fill in the form fields with matching metadata. 
         To make the view "visible" to others users, check the "Show view" option. 
         Finally push the "save" button.
         You may also save a new view using an existing view. To do so, load the desired view, modify it and push the "Save as new view" button.{/t}<br /> 
         <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" /><span class="s">{t}Delete a view{/t}</span> :
         {t}load the view you want to delete and push the "Delete" button. A confirmation message pops before irreversible deletion.{/t}<br />
         <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" /><span class="s">{t}Update a view{/t}</span> :
         {t}to modify a view map properties (selected layers, annotations, map extent, etc.) as well as its metadata (title, "visibility", etc.), load it.
         If your changes only concern metadata, simply update the dedicated form fields and push the "Update" button.
         To update the view map properties, check the "Memorize form" option. Metadata and selected view ID are then memorized while you perform your changes (pans, zooms, annotations, layers selections, etc.). Eventually push the "Update" button.{/t}
      </p><br />
      <table  class="table_help" cellpadding="0" cellspacing="0">
        <tr><td>
          <img src="{r type=gfx/layout/help}tab.gif{/r}"   alt="{t}Layers reorder tab{/t}" /><strong>&nbsp;{t}Layers reorder tab{/t}</strong><br />
        </td></tr>
      </table>
      <p class="help_viewer">
        {t} You can well design your map with largest features layers on bottom and smallest on top, and/or even with well used transparent properties. 
        This tab allows you to :{/t}<br />
        <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" />{t} reorder layers on the displayed stack to improve visibility of one layer, and/or{/t}<br />
        <img src="{r type=gfx/layout/help}endturn.gif{/r}" alt="{t}pet{/t}" />{t} add a transparency value on each layer displayed.{/t}
      </p><br />
      <hr />
      <p class="help_viewer">
        {t}For more information, you can have a look to the {/t}<a href="http://www.cartoweb.org/documentation.html" target="_blank">{t}Cartoweb documentation{/t}</a>
      </p>
      <br /><br />
    </div>
    <!-- end of floder 6 -->
    {if $wmsBrowserLight|default:''}
    <div id="folder7" class="folder">
      <br />
      <center>
        {$wmsBrowserLight}
        {$ogcLayerLoader}
      </center> 
    </div>
    {/if}
    <!-- end of folder10 -->
    {if $exportRtf|default:''}
    <div id="folder10" class="folder">
      {$exportRtf}
    </div>
    <!-- end of folder8 -->
    {/if}
    </div> <!--container-->
  </td>
   </tr>  
</table>
</form>

</td></tr>
</table>

</td></tr>
<tr><td align="right">
<img src="{r type=gfx/layout}logoc2c2.gif{/r}" alt="logo" border="0" style="vertical-align:bottom"/>
</td></tr>
<tr id="downbanner" style="height:50px;">
  <td valign='top'>
  <table width='100%' >
    <tr>
    <td align='left'>
      {foreach from=$locales item=lang}
      {if $lang == $currentLang}
      <img class="lang_on" name="{$lang}" src="{r type=gfx/layout}language_{$lang}.gif{/r}" alt="{$lang}" />
      {else}
      <a href="javascript:document.carto_form.action='{$selfUrl}?lang={$lang}';FormItemSelected();" onclick="javascript:doSubmit();"><img class="lang_off" name="{$lang}" src="{r type=gfx/layout}language_{$lang}.gif{/r}" alt="{$lang}" /></a>
      {/if}
      {/foreach}</td>
    <td align="right" class="mini" valign='top'>
    Powered by <a href="http://www.cartoweb.org/" target="_blank">CartoWeb {$cw_version.version}</a>
    &copy; <a href="http://www.camptocamp.com/"  target="_blank">Camptocamp SA</a>
    </td>
    </tr>
  </table>
  </td>
</tr>

</table>

{if $toolpicker_active|default:''}
{include file="toolPicker.tpl"}
{/if}

</body>
</html>
