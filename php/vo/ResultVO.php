<?php

/**
 * Value object class for a result
 */
class ResultVO {
	
	public $results = array();
	public $fields = array();
	public $query = "";
	public $datasets = 0;
	public $offset = 0;
	
	
	/**
	 * AS class type identification.
	 * 
	 * @return String
	 */
	public function getASClassName()
    {
        return 'vo.ResultVO';
    }
}

?>