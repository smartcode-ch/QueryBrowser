<?php

/**
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

/**
 * Handles database queries.
 * 
 * @author rico.leuthold@to-fuse.ch 
 */
class DBHandler {
	
	// Set database connection parameters
	const DB_HOST = 'localhost';
	const DB_NAME = 'imdb';
	const DB_USER = 'imdb';
	const DB_PASS = '*imdb*';

	public $dbh;
	private $results;
	
	/**
	 * Constructor
	 */
	public function __construct() {
		
		$this->dbh = new mysqli(self::DB_HOST, self::DB_USER, self::DB_PASS, self::DB_NAME);
		
		if ( $this->dbh->connect_error ) {
    		throw( new Exception( 'Connect Error (' . $this->dbh->connect_errno . ') '. $this->dbh->connect_error, 1) );
		}
	}
	
	
	/**
	 * Execute a real mysql query.
	 * 
	 * @param $sql
	 * @return boolean true or false
	 */
	public function exec_real_query($sql) {
		
		$this->results = $this->dbh->real_query( $sql );
		if ( !$this->results ) {
    		throw( new Exception($this->dbh->error, 1) );
		}
		
		return $this->results;
		
	}
	
	/**
	 * Execute a mysql query.
	 * 
	 * @param $sql
	 * @return mysql result resource
	 */
	public function exec_query($sql) {
		
		$this->results = $this->dbh->query( $sql );
		if ( !$this->results ) {
    		throw( new Exception($this->dbh->error, 1) );
		}
		
		return $this->results;
		
	}
	
	/**
	 * Fetch row
	 * 
	 * @param $sql query
	 * @return array
	 */
	public function fetch_row($sql) {
		
		return $this->exec_query( $sql )->fetch_row();
			
	}
	
	/**
	 * Fetch array
	 * 
	 * @param $sql query
	 * @return array
	 */
	public function fetch_array($sql) {
		
		$arr = array();
		$res = $this->exec_query($sql);

		while ( $itm = $res->fetch_array(MYSQLI_NUM) ) {
			$arr[] = $itm;
		}
		
		return $arr;
	}
			
	/**
	 * Free mysqli results
	 */
	public function freeResults() {
		if( $this->results ) {
			$this->results->close();
		}
	}
	
	/**
	 * Get field names for actual result object 
	 * 
	 * @return array of field names
	 */
	public function getFieldNames( $result ) {
		$field_names = array();
	
		foreach ( $result->fetch_fields() as $field_info ) {
	        $field_names[] = $field_info->name;
		}
		
		return $field_names;
	}
	
}


?>