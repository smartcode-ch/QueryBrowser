<?php
/**
 * Value object class for an error
 * 
 * @author rico.leutholdgto-fuse.ch
 *
 */
class ErrorVO {
	
	public $message = '';
	
	/**
	 * AS class type identification.
	 * 
	 * @return String
	 */
	public function getASClassName()
    {
        return 'vo.ErrorVO';
    }
}

?>