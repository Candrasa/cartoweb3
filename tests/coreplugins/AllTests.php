<?php
/**
 * @package Tests
 * @version $Id$
 */

/**
 * Abstract test suite
 */
require_once 'PHPUnit2/Framework/TestSuite.php';

/**
 * All coreplugins tests
 */
require_once 'coreplugins/location/server/ServerLocationTest.php';
require_once 'coreplugins/location/server/RemoteServerLocationTest.php';

// !!WARNING: reactivate this when new unit tests are written for Query
// require_once 'coreplugins/query/server/RemoteServerQueryTest.php';

/**
 * @package Tests
 * @author      Sylvain Pasche <sylvain.pasche@camptocamp.com>
 */
class coreplugins_AllTests {
    
    public static function suite() {
    
        $suite = new PHPUnit2_Framework_TestSuite;

        $suite->addTestSuite('coreplugins_location_server_ServerLocationTest');
        $suite->addTestSuite('coreplugins_location_server_RemoteServerLocationTest');

// !!WARNING: reactivate this when new unit tests are written for Query
//        $suite->addTestSuite('coreplugins_query_server_RemoteServerQueryTest');

        return $suite;
    }
}

?>