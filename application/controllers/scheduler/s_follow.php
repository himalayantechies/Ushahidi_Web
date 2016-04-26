<?php defined('SYSPATH') or die('No direct script access.');
/**
 * Follows Scheduler Controller
 *
 * PHP version 5
 * LICENSE: This source file is subject to LGPL license 
 * that is available through the world-wide-web at the following URI:
 * http://www.gnu.org/copyleft/lesser.html
 * @author	   Ushahidi Team <team@ushahidi.com> 
 * @package	   Ushahidi - http://source.ushahididev.com
 * @subpackage Scheduler
 * @copyright  Ushahidi - http://www.ushahidi.com
 * @license	   http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL) 
*/

class S_Follow_Controller extends Controller {
	
	public $table_prefix = '';
	
	// Cache instance
	protected $cache;
	
	function __construct()
	{
		parent::__construct();

		// Load cache
		$this->cache = new Cache;
		
		// *************************************
		// ** SAFEGUARD DUPLICATE SEND-OUTS **
		// Create A 15 Minute SEND LOCK
		// This lock is released at the end of execution
		// Or expires automatically
		$follow_lock = $this->cache->get(Kohana::config('settings.subdomain')."_follow_lock");
		if ( ! $follow_lock)
		{
			// Lock doesn't exist
			$timestamp = time();
			$this->cache->set(Kohana::config('settings.subdomain')."_follow_lock", $timestamp, array("follow"), 900);
		}
		else
		{
			// Lock Exists - End
			exit("Other process is running - waiting 15 minutes!");
		}
		// *************************************
	}
	
	function __destruct()
	{
		$this->cache->delete(Kohana::config('settings.subdomain')."_follow_lock");
	}
	
	public function index() 
	{
		$settings = kohana::config('settings');
		$site_name = $settings['site_name'];
		$alerts_email = ($settings['alerts_email']) ? $settings['alerts_email']
			: $settings['site_email'];
		$unsubscribe_message = Kohana::lang('follow.unsubscribe')
								.url::site().'follow/unsubscribe/';

		$database_settings = kohana::config('database'); //around line 33
		$this->table_prefix = $database_settings['default']['table_prefix']; //around line 34

		$settings = NULL;
		$sms_from = NULL;

		$db = new Database();
		
		$comment_query = "SELECT c.id, c.incident_id, c.comment_active, c.comment_description, c.comment_spam
			FROM ".$this->table_prefix."comment c
			WHERE c.comment_spam = 0 AND c.comment_active = 1 AND c.comment_follow_status = 1";
			
		$comments = $db->query($comment_query);
		/* Find All Follow with the following parameters
		- comment_active = 1 -- An approved comment
		- comment_spam = 0 -- Not a spam comment
		*/
		
		foreach ($comments as $comment)
		{
			// ** Pre-Formatting Message ** //
			
			$email_message = text::auto_p(Kohana::lang('notifications.member_new_comment.message')
						. "\n" .url::site('reports/view/'.$comment->incident_id)
						. "\n\n".Kohana::lang('notifications.member_new_comment.comment').
						"\n".$comment->comment_description."\n");
			$sms_message = html::clean(Kohana::lang('notifications.member_new_comment.message')
							. "\n" .url::site('reports/view/'.$comment->incident_id)
							. "\n\n".Kohana::lang('notifications.member_new_comment.comment').
							"\n".$comment->comment_description."\n");
			$sms_message = str_replace("\n", " ", $sms_message);
			$sms_message = text::limit_chars($sms_message, 150, "...");
			
						
			// HT: New Code
			$follow_sent = ORM::factory('follow_sent')->where('comment_id', $comment->id)->select_list('id', 'follow_id');
			$followObj = ORM::factory('follow')->where('incident_id', $comment->incident_id);
			
			if(!empty($follow_sent)) {
				$followObj->notin('id', $follow_sent);
			}

			$followers = $followObj->find_all();
			// End of new code
			
			foreach ($followers as $follower)
			{
				// HT: check same follower multi subscription does not get multiple alert
				if($this->_multi_subscribe($follower, $comment)) {
					continue;
				}
				$follow_type = (int) $follower->follow_type;

					if ($follow_type == 1) // SMS follower
					{
						// Get SMS Numbers
						if (Kohana::config("settings.sms_no3"))
							$sms_from = Kohana::config("settings.sms_no3");
						elseif (Kohana::config("settings.sms_no2"))
							$sms_from = Kohana::config("settings.sms_no2");
						elseif (Kohana::config("settings.sms_no1"))
							$sms_from = Kohana::config("settings.sms_no1");
						else
							$sms_from = "12053705050";		// Admin needs to set up an SMS number	
						
						
						
						if ($response = sms::send($follower->follower, $sms_from, $sms_message) === true)
						{
							$follow = ORM::factory('follow_sent');
							$follow->follow_id = $follower->id;
							$follow->comment_id = $comment->id;
							$follow->follow_date = date("Y-m-d H:i:s");
							$follow->save();
						}
						else
						{
							// The gateway couldn't send for some reason
							// in future we'll keep a record of this
						}
					}

					elseif ($follow_type == 2) // Email follower
					{
						$to = $follower->follower;
						$from = array();
						$from[] = $alerts_email;
						$from[] = $site_name;
						$subject = "[".$site_name."] ".Kohana::lang('notifications.member_new_comment.subject');
						
						$message = text::auto_p($email_message
									. "\n\n".$unsubscribe_message
									. $follower->follow_code . "\n");

						//if (email::send($to, $from, $subject, $message, FALSE) == 1)
						if (email::send($to, $from, $subject, $message, TRUE) == 1) // HT: New Code
						{
							$follow = ORM::factory('follow_sent');
							$follow->follow_id = $follower->id;
							$follow->comment_id = $comment->id;
							$follow->follow_date = date("Y-m-d H:i:s");
							$follow->save();
						}
					}
				}

			// Update Comment - All Follows Have Been Sent!
			$update_comment = ORM::factory('comment', $comment->id);
			if ($update_comment->loaded)
			{
				$update_comment->comment_follow_status = 2;
				$update_comment->save();
			}
		}
	}

	
	/**
	 * HT: Function to verify that follow is not sent to same follower being subscribed multiple time
	 * @param Follow_Model $follower
	 * @param integer $comment_id
	 * @return boolean
	 */
	private function _multi_subscribe(Follow_Model $follower, $comment) {
		$multi_subscribe_ids = ORM::factory('follow')->where('follower', $follower->follower)->where('incident_id', $comment->incident_id)->select_list('id', 'id');
		$subscription_alert = ORM::factory('follow_sent')->where('comment_id', $comment->id)->in('follow_id', $multi_subscribe_ids)->find();
		return ((boolean) $subscription_alert->id);
	}

}
