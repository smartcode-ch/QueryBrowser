<?php

/**
 *  QueryBrowser service
 *  
 *	Copyright (C) 2011  Rico Leuthold // rico.leuthold@to-fuse.ch
 *	
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *	
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *	
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 */

ini_set("include_path", "lib/zend/library");
require_once("Zend/Loader.php");
require_once("DBHandler.php");

class QueryBrowser {
	
	protected static $class_paths = array('vo');	// include paths
	private $dbhandler;

	/**
	 * Constructor
	 *
	 * @return unknown_type
	 */
	public function QueryBrowser() {
		$this->dbhandler = new DBHandler();
	}
	
	/**
	 * Kill a query.
	 * 
	 * A rather basic and brutal implementation - I'm sure you can do better ;-) 
	 * 
	 * This one works but leads to a segmentation fault - not very nice :-(
	 * 
	 * @param String $query
	 * @return Boolean true if kill sucessful else false
	 */
	public function killQuery( $query ) {
		
		
		$query_base = preg_replace('/SELECT/i','',$query);
		$processes = $this->dbhandler->dbh->query( "SHOW PROCESSLIST" );
		
	 	while ( $process = $processes->fetch_object() ) {
	 		
        	if( $process->User == DBHandler::DB_USER && preg_match("/$query_base/i", $process->Info) ) {
        		$this->dbhandler->dbh->query( "KILL " . $process->Id );
        		return true;
        	}
    	}
    	
		return false;
	}

	/**
	 * Get table info as an xml
	 *
	 * @param $asDom bool if to return the XML as a DOMDocument (or a SimpleXML)
	 * @return obj of type XML
	 */
	public function getTableInfo( $asDom = true) {
		
		$table_info_xml = new SimpleXMLElement("<tables db='" . DBHandler::DB_NAME . "'></tables>");

		$tables = $this->dbhandler->fetch_array( "SHOW TABLES FROM " . DBHandler::DB_NAME);

		// tables
		foreach($tables as $table) {
			$table_xml = $table_info_xml->addChild( 'table');
			$table_xml->addAttribute('name', $table[0]);
			
			$datasets_count = $this->dbhandler->fetch_row( "SELECT COUNT(*) FROM " . $table[0] );
			$table_xml->addAttribute('datasets', $datasets_count[0]);
			
			
			// fields
			$fields = $this->dbhandler->fetch_array( "DESCRIBE " . $table[0] );
			
			foreach ( $fields as $field ) {
				$field_xml = $table_xml->addChild('field');
				$field_xml->addAttribute('table', $table[0]);
				$field_xml->addAttribute('name', $field[0]);
				$field_xml->addAttribute('type', strtoupper($field[1]));
				$field_xml->addAttribute('null', $field[2] );
				$field_xml->addAttribute('key', $field[3]);
				$field_xml->addAttribute('default', $field[4]);
			}
			
		}

		if( $asDom ) {
			return dom_import_simplexml($table_info_xml)->ownerDocument;	
		} 
		
		return $table_info_xml;
		
	}
	
	public function getResultIds( $query ) {
		
		$primary_key = $this->getPrimaryKey( $query );
		
		// datasets
		try {
			$query_result = $this->dbhandler->exec_query( $query );
		} catch (Exception $e) {
			Zend_Loader::loadClass('ErrorVO', self::$class_paths);
			$error = new ErrorVO();
			$error->message = $e->getMessage();
			
			return $error;
		}
	}
	
	/**
	 * Execute simple select statement on a table with non consecutive primary keys
	 * 
	 * !Performance issues on large tables!
	 *
	 * @param string $query the query string
	 * @param int $start index to start
	 * @param count $count how many datasets to get
	 * @param boolean $new_query if this is a new query (relevant to get info about dataset count)
	 * @return array of Result objects or an Error object
	 */
	public function executeSimpleQueryNonConsecutive( $query, $start, $count, $new_query) {
		
		$primary_key = $this->getPrimaryKey( $query );
		
		if( is_null($primary_key) ) {
			return $this->executeComplexQuery($query, $start, $count, $new_query);
		}
		
		$id_query_result = array();
		$table_name = '';
		
		try {
			$table_name = $this->getTableName( $query );
			$id_query_result = $this->dbhandler->fetch_row( "SELECT (SELECT " . $primary_key . " FROM " . $table_name . " ORDER BY " . $primary_key . " LIMIT " . $start . ", 1) as start, (SELECT " . $primary_key . " FROM " . $table_name . " ORDER BY " . $primary_key . " LIMIT " . ($start + $count) . ", 1) as end" );
		} catch (Exception $e) {
			Zend_Loader::loadClass('ErrorVO', self::$class_paths);
			$error = new ErrorVO();
			$error->message = $e->getMessage();
			
			return $error;
		}
		
		$datasets = 0;
		
		if( $new_query ) {
			$datasets = $this->countDatasets( $table_name , $primary_key );
		}
		
		$query .= " WHERE " . $primary_key . " >= " .  $id_query_result[0] . " AND " . $primary_key . " < " . $id_query_result[1];
		
		try {
			$query_result = $this->dbhandler->exec_query( $query );
		} catch (Exception $e) {
			Zend_Loader::loadClass('ErrorVO', self::$class_paths);
			$error = new ErrorVO();
			$error->message = $e->getMessage();
			
			return $error;
		}
		
		// results
		$results_arr = array();
		while ( $obj = $query_result->fetch_object() ) {
			$results_arr[] = $obj;
		}
		
		// result object
		Zend_Loader::loadClass('ResultVO', self::$class_paths);
		$result = new ResultVO();
		$result->results = $results_arr;
		$result->datasets = $datasets;
		$result->offset = $start;
		$result->query = $query;
		
		if( $new_query ) {
			$result->fields = $this->dbhandler->getFieldNames( $query_result );	
		}
		
		$this->dbhandler->freeResults();
		return $result;
		
		
	}
	
	/**
	 * Execute simple select statement
	 * 
	 * This method is very fast in terms of paging data, since the query uses the primary key to fetch the result page
	 *
	 * @param string $query the query string
	 * @param int $start index to start
	 * @param count $count how many datasets to get
	 * @param boolean $new_query if this is a new query (relevant to get info about dataset count)
	 * @return array of Result objects or an Error object
	 */
	public function executeSimpleQuery($query, $start, $count, $new_query) {
		
		$primary_key = $this->getPrimaryKey( $query );
		$datasets = 0;
		$offset = 0;
		
		if( is_null($primary_key) ) {
			return $this->executeComplexQuery($query, $start, $count, $new_query);
		}
		
		if( $new_query ) {
			
			$table_name = $this->getTableName( $query );
			$start = $this->getStart( $table_name, $primary_key );
			
			$datasets = $this->countDatasets( $table_name , $primary_key );
			
		}
		 
		$query .= " WHERE " . $primary_key . " >= " .  $start . " AND " . $primary_key . " < " . ($start + $count);
		
		try {
			$query_result = $this->dbhandler->exec_query( $query );
		} catch (Exception $e) {
			Zend_Loader::loadClass('ErrorVO', self::$class_paths);
			$error = new ErrorVO();
			$error->message = $e->getMessage();
			
			return $error;
		}
		
		// results
		$results_arr = array();
		while ( $obj = $query_result->fetch_object() ) {
			$results_arr[] = $obj;
		}
		
		// result object
		Zend_Loader::loadClass('ResultVO', self::$class_paths);
		$result = new ResultVO();
		$result->results = $results_arr;
		$result->datasets = $datasets;
		$result->offset = $start;
		$result->query = $query;
		
		if( $new_query ) {
			$result->fields = $this->dbhandler->getFieldNames( $query_result );	
		}
		
		$this->dbhandler->freeResults();
		return $result;
		
	}
	
	/**
	 * Execute a complex select statement
	 * 
	 * This method is slow for very large tables, since it makes use of the LIMIT and OFFSET parameters to fetch the result page
	 *
	 * @param string $query the query string
	 * @param int $start index to start
	 * @param count $count how many datasets to get
	 * @param boolean $new_query if this is a new query (relevant to get info about dataset count)
	 * @return array of Result objects or an Error object
	 */
	public function executeComplexQuery($query, $start, $count, $new_query) {
		
		$datasets = 0;
		$offset = 0;
		
		// refactor query to count datasetes
		if($new_query ) {
			$query = $this->refactorQueryForDatasetCount( $query );
		}
		
		// order column
		// !!! Performance issues with large tables !!!
		//$key = $this->getOrderField($query);
		
		// check for limit clause
		$matches = array();
		$pattern = '/LIMIT\s+(?P<limit>\d+)\s?,?\s?(?P<offset>\d+)?/i';
		
		if( preg_match( '/LIMIT\s+(?P<limit>\d+)\s+OFFSET\s+(?P<offset>\d+)?/i', $query ) ) {
			$pattern = '/LIMIT\s+(?P<limit>\d+)\s+OFFSET\s+(?P<offset>\d+)?/i';
		} 
		
		preg_match($pattern,$query,$matches);
		
		// limit and offset
		if( isset( $matches['limit'] ) && isset( $matches['offset'] ) ) {
			if( $matches['offset'] > $count ) {
				$pattern = '/(LIMIT\s+\d+\s?,?\s?\d+)/i';
				if( $new_query ) {
					// !!! Performance issues with large tables !!!
					//$replacement = "ORDER BY " . $key . " ASC LIMIT " . ($start + $matches['limit']) . ", " . $count;
					$replacement = "LIMIT " . ($start + $matches['limit']) . ", " . $count;	
				} else {
					// !!! Performance issues with large tables !!!
					//$replacement = "ORDER BY " . $key . " ASC LIMIT " . $start . ", " . $count;
					$replacement = "LIMIT " . $start . ", " . $count;
				}
				
				$query = preg_replace( $pattern, $replacement, $query );
				$datasets = $matches['offset'];
				$offset = $matches['limit'];
			}
		// limit
		} else if ( isset( $matches['limit'] ) ) {
			if( $matches['limit'] > $count ) {
				$pattern = '/(LIMIT\s+\d+)/i';
				// !!! Performance issues with large tables !!!
				//$replacement = "ORDER BY " . $key . " ASC LIMIT " . $start . ", " . $count;
				$replacement = "LIMIT " . $start . ", " . $count;
				$query = preg_replace( $pattern, $replacement, $query );
				$datasets = $matches['limit'];
			}
		// none	
		} else {
			// !!! Performance issues with large tables !!!			
			//$query .= " ORDER BY " . $key ." ASC LIMIT " . $start . ", " . $count;
			$query .= " LIMIT " . $start . ", " . $count;
		}
		
		try {
			$query_result = $this->dbhandler->exec_query( $query );
		} catch (Exception $e) {
			Zend_Loader::loadClass('ErrorVO', self::$class_paths);
			$error = new ErrorVO();
			$error->message = $e->getMessage();
			
			return $error;
		}
		
		// results
		$results_arr = array();
		while ( $obj = $query_result->fetch_object() ) {
			$results_arr[] = $obj;
		}
		
		// datasets count
		if( $new_query && $datasets == 0 ) { 
			try {
				$count_obj = $this->dbhandler->exec_query("SELECT FOUND_ROWS() AS row_count")->fetch_object();
			} catch (Exception $e) {
				Zend_Loader::loadClass('ErrorVO', self::$class_paths);
				$error = new ErrorVO();
				$error->message = $e->getMessage();
				
				return $error;
			}
			
			$datasets = $count_obj->row_count;
			
		} 
		
		// result object
		Zend_Loader::loadClass('ResultVO', self::$class_paths);
		$result = new ResultVO();
		$result->results = $results_arr;
		$result->datasets = $datasets;
		$result->offset = $offset;
		$result->query = $query;
		
		if( $new_query ) {
			$result->fields = $this->dbhandler->getFieldNames( $query_result );	
		}
		
		$this->dbhandler->freeResults();
		return $result;
		
	}
	
	

	/**
	 * Refactor the query for dataset count
	 * 
	 * @param $query String the query to refactor for the dataset count call
	 * @return String the query which allows for dataset count
	 */
	private function refactorQueryForDatasetCount( $query ) {
		$pattern = '/^(SELECT)/i';
		$replacement = 'SELECT SQL_CALC_FOUND_ROWS';
		return preg_replace($pattern, $replacement, $query);
	}
	
	/**
	 * Dataset count
	 * 
	 * @return int dataset count
	 */
	private function getTableName( $query ) {
		
		$pattern = '/\sFROM\s+(\w+).*/i';
		preg_match($pattern,$query,$matches);
		
		return $matches[1];
		
	}
	
	/**
	 * Get primary key field of the query
	 * 
	 * @param $query String
	 * @return String
	 */
	private function getPrimaryKey( $query ) {
		
		$primary_key_field = $this->getTableInfo(false)->xpath("//table[@name='". $this->getTableName( $query ) ."']/field[@key='PRI']");
		
		if( (!$primary_key_field)||(!isset($primary_key_field[0])) ) {
			return null;			
		} else {
			return $primary_key_field[0]['name'];
		}
		
		
	}
	
	/**
	 * Get a reasonable field for a table to order on
	 * 
	 * !!! Performance issues with large tables !!!
	 * 
	 * @param $query String
	 * @return String
	 */
	private function getOrderField( $query ) {
		
		$primary_key = $this->getPrimaryKey( $query );
		
		// return primary key if available
		if( isset($primary_key) ) {
			return $primary_key;
		}
		
		$fields = $this->getTableInfo(false)->xpath("//table[@name='". $this->getTableName( $query ) ."']/field");
		
		$int_size = 0;
		$reasonable_key_field = $this->getTableInfo(false)->xpath("//table[@name='". $this->getTableName( $query ) ."']/field[0][@name]");
		
		foreach($fields as  $field) {
			if( preg_match('/int.*(\d+)/i', $field['type'], $matches ) ) {
				if( $matches[1] > $int_size ) {
					$reasonable_key_field = $field['name'];
				}
			}
		}
		
		return $reasonable_key_field;
	}
	
	/**
	 * Get primary key min value 
	 * 
	 * @param $query String
	 * @return int
	 */
	private function getStart( $table, $primary_key ) {
		
		try {
			$start_obj = $this->dbhandler->exec_query("SELECT MIN(" . $primary_key. ") AS start FROM " . $table)->fetch_object();
		} catch (Exception $e) {
			Zend_Loader::loadClass('ErrorVO', self::$class_paths);
			$error = new ErrorVO();
			$error->message = $e->getMessage();
			
			return $error;
		}
		
		return $start_obj->start;
		
	}
	
	/**
	 * Get number of results for a query
	 * @param String $query
	 * @return int $datasets
	 */
	private function countDatasets( $table, $primary_key ) {
	
		try {
			$query_result = $this->dbhandler->fetch_row( "SELECT count(" . $primary_key . ") FROM " . $table );
		} catch (Exception $e) {
			Zend_Loader::loadClass('ErrorVO', self::$class_paths);
			$error = new ErrorVO();
			$error->message = $e->getMessage();
			
			return $error;
		}
		
		return $query_result[0];
		
	}
	
}
?>