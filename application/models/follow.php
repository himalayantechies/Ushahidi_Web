<?php defined('SYSPATH') or die('No direct script access.');

/**
 * Model for Follow
 *
 * PHP version 5
 * LICENSE: This source file is subject to LGPL license 
 * that is available through the world-wide-web at the following URI:
 * http://www.gnu.org/copyleft/lesser.html
 * @author     HT Team 
 * @package    Ushahidi - http://source.ushahididev.com
 * @subpackage Models
 * @copyright  Ushahidi - http://www.ushahidi.com
 * @license    http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL) 
 */

class Follow_Model extends ORM {
	
	/**
	 * Many-to-one relationship definition
	 * @var array
	 */
	protected $belongs_to = array('incident');
	
    /**
	 * One-to-many relationship definition
	 * @var array
	 */
	protected $has_many = array('comment' => 'follow_sent');
	
	/**
	 * Database table name
	 * @var string
	 */
	protected $table_name = 'follow';

	/**
	 * Ignored columns - follow_mobile & follow_email will be replaced with follower
	 * These are columns not contained in the Model itself
	 * @var array
	 */
	protected $ignored_columns = array('follow_mobile', 'follow_email'); 	

	/**
	 * Method that provides the functionality of the magic method, __set, without the overhead
	 * of having to instantiate a Reflection class to realize it, and provides for object chaining
	 * 
	 * @param string $column
	 * @param mixed $value
	 * @return Follow_Model
	 */
	public function set($column, $value)
	{
		// CALL the magic method __set, with the parameters provided
		$this->__set($column, $value);

		// RETURN $this for a fluent interface
		return $this;

	} // END function set
    
    
	/**
	 * Method that allows for the use of the set method, en masse
	 * 
	 * @param array $params
	 * @return Follow_Model
	 */
	public function assign(array $params = array())
	{
		// ITERATE through all of the column/value pairs provided ...
		foreach ($params as $column => $value)
		{
			// CALL the set method with the column/value pair
			$this->set($column, $value);
		}
        
		// RETURN $this for a fluent interface
		return $this;

	} // END function assign


	/**
	 * Model Validation
	 * 
	 * @param array $array values to check
	 * @param boolean $save save[Optional] the record when validation succeeds
	 * @return bool TRUE when validation succeeds, FALSE otherwise
	 */
	public function validate(array & $post, $save = FALSE)
	{
		// Initialise the validation library and setup some rules
		$post = Validation::factory($post)
			->pre_filter('trim')
			->add_rules('follow_mobile', 'numeric', 'length[6,20]')
			->add_rules('follow_email', 'email', 'length[3,64]');
				
		// TODO Callbacks to check for duplicate follow subscription - same
		// follower for the same incident_id
		$post->add_callbacks('follow_mobile', array($this, '_mobile_check'));
		$post->add_callbacks('follow_email', array($this, '_email_check'));

		// Check if a recipient mobile phone no. or email address has been
		// specified	
		if (empty($post->follow_mobile) AND empty($post->follow_email))
		{
			$post->add_rules('follower', 'required');
		}


		return parent::validate($post, $save);
		
	} // END function validate


    /**
     * Callback tests if a mobile number exists in the database for this follow
	 * @param   mixed mobile number to check
	 * @return  boolean
     */
    public function _mobile_check(Validation $post)
    {
		// If add->rules validation found any errors, get me out of here!
        if (array_key_exists('follow_mobile', $post->errors()) 
            OR array_key_exists('incident_id', $post->errors()))
            return;

        if ($post->follow_mobile AND (bool) $this->db
			->where(array(
				'follow_type' => 1,
				'follower' => $post->follow_mobile,
				'incident_id' => $post->incident_id
				))
			->count_records($this->table_name) )
		{
			$post->add_error( 'follow_mobile', 'mobile_check');
		}
    } // END function _mobile_check

	
	/**
	 * Callback tests if an email accounts exists in the database for this follow
	 * @param   mixed mobile number to check
	 * @return  boolean
	 */
	public function _email_check(Validation $post)
	{
		// If add->rules validation found any errors, get me out of here!
		if (array_key_exists('follow_email', $post->errors())  
			OR array_key_exists('incident_id', $post->errors()))
			return;

		if ( $post->follow_email AND (bool) $this->db
			->where(array(
					'follow_type' => 2,
					'follower' => $post->follow_email,
					'incident_id' => $post->incident_id
				))
			->count_records($this->table_name) )
		{
			$post->add_error('follow_email', 'email_check');
		}
	} // END function _email_check

	
	/**
	 * Checks if the follow subscription in @param $follow_code exists
	 *
	 * @param string $follow_code
	 * @return bool TRUE if the follow code exists, FALSE otherwise
	 */
	public static function follow_code_exists($follow_code)
	{
		return (ORM::factory('follow')
					->where('follow_code', $follow_code)
					->count_all() > 0
				);
	}
	
	/**
	 * Removes the follow code in @param $follow_code from the list of follow
	 *
	 * @param string $follow_code
	 * @return bool TRUE if succeeds, FALSE otherwise
	 */
	public static function unsubscribe($follow_code)
	{
		// Fetch the follow with the specified code
		$follow = ORM::factory('follow')
			->where('follow_code', $follow_code)
			->find();
		
		// Check if the follow exists
		if ($follow->loaded)
		{
			// Delete the follow
			$follow->delete();

			// Success!
			return TRUE;
		}
		else
		{
			// follow code not found. FAIL
			return FALSE;
		}
	}

} // END class Follow_Model
