<?php
/**
 * Zend_AMF entry site
 */ 
ini_set("include_path", "lib/zend/library");

require_once 'Zend/Amf/Server.php'; 
require_once 'QueryBrowser.php';

// Instantiate server 
$server = new Zend_Amf_Server();
$server->setProduction(false); 
$server->setClass('QueryBrowser');

// Handle request
$response = $server->handle();
echo $response;

?>
