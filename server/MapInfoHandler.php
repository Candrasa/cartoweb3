<?php
/**
 * @package Server
 * @version $Id$
 */

/**
 * @package Server
 */
class MapInfoHandler {
    private $log;
    private $serverContext;

    public $configMapPath;

    public $mapInfo;
    
    private $projectHandler;

    function __construct($serverContext, $mapId, $projectHandler) {
        $this->log =& LoggerManager::getLogger(__CLASS__);
        $this->serverContext = $serverContext;
        $this->projectHandler = $projectHandler;
        $this->loadMapInfo($mapId);
    }

    /**
     * Process mapInfo after being loaded from the configuration.
     * Does some basic consistency checks, fills some information.
     */
    private function fixupMapInfo(MapInfo $mapInfo) {
        foreach ($mapInfo->layers as $layer) {
            if (empty($layer->label))
                $layer->label = $layer->id; 
            if ($layer instanceof Layer && empty($layer->msLayer))
                $layer->msLayer = $layer->id; 
        }
        
        return $mapInfo;
    }

    function getIniPath() {

        $mapName = $this->projectHandler->getMapName();
        $path = $this->projectHandler->getPath(CARTOSERVER_HOME,
                                'server_conf/' . $mapName . '/', $mapName . '.ini');
        return CARTOSERVER_HOME . $path . $mapName . '.ini';
    }

    private function loadMapInfo($mapId) {

        $mapName = $this->projectHandler->getMapName();
        $iniPath = $this->getIniPath();
        $configStruct = StructHandler::loadFromIni($iniPath);
        $this->mapInfo = new MapInfo();
        $this->mapInfo->unserialize($configStruct->mapInfo);
        $this->mapInfo = $this->fixupMapInfo($this->mapInfo);
        return $this->mapInfo;
    }

    function getMapInfo() {
        return $this->mapInfo;
    }

    private function fillDynamicLayers($serverContext) {
        $mapInfo = $this->mapInfo;
        $layers = $mapInfo->getLayers();
        $msMapObj = $serverContext->msMapObj;

        foreach ($layers as $layer) {
            if (!$layer instanceof Layer)
                continue;

            $msLayer = $msMapObj->getLayerByName($layer->msLayer);
            if (!$msLayer)
                throw new CartoserverException('Could not find msLayer ' 
                                               . $layer->msLayer);
            
            for ($i = 0; $i < $msLayer->numclasses; $i++) {
                $msClass = $msLayer->GetClass($i);
                if (isset($msClass->name) && 
                    strlen(trim($msClass->name)) != 0) { 
                    $layerClass = new LayerClass();

                    copy_vars($msClass, $layerClass);
                    $layerClass->id = $layer->id . '_class_' . $i;
                    $layerClass->label = utf8_encode($msClass->name);
                
                    $mapInfo->addChildLayerBase($layer, $layerClass);
                }
            }
        }
        
    }

    private function fillDynamicKeymap($serverContext) {
        
        $msMapObj = $serverContext->msMapObj;
        $referenceMapObj = $msMapObj->reference;

        $serverContext->checkMsErrors();

        $dim = new Dimension($referenceMapObj->width, $referenceMapObj->height);
        $bbox = new Bbox();
        $bbox->setFromMsExtent($referenceMapObj->extent);
        
        $mapInfo = $this->mapInfo;
        $mapInfo->keymapGeoDimension = new GeoDimension();
        $mapInfo->keymapGeoDimension->dimension = $dim;
        $mapInfo->keymapGeoDimension->bbox = $bbox;
    }

    function fillDynamic($serverContext) {
        $this->mapInfo->timeStamp = $serverContext->getTimeStamp();
        $this->fillDynamicLayers($serverContext);
        $this->fillDynamicKeymap($serverContext);
    }
}
?>
