<?php defined('SYSPATH') OR die('No direct access allowed.');
/**
 * Follow helper class
 *
 * @package     Ushahidi
 * @category    Helpers
 * @author      HT Team
 * @copyright   (c) 2008 Ushahidi Team
 * @license     http://www.ushahidi.com/license.html
 */

class follow_Core {

	const MOBILE_ALERT = 1;
	const EMAIL_ALERT = 2;

	/**
	 * Sends an follow to a mobile phone
	 *
	 * @param Validation_Core $post
	 * @param Follow_Model $follow
	 * @return bool
	 */
	public static function _send_mobile_alert($post, $follow, $notify = TRUE)
	{
		if ( ! $post instanceof Validation_Core AND !$follow instanceof Follow_Model)
		{
			throw new Kohana_Exception('Invalid parameter types');
		}

		// Should be 8 distinct characters
		$follow_code = text::random('distinct', 8);
		
		if($notify === FALSE) {
			$follow->follow_type = self::MOBILE_ALERT;
			$follow->follower = $post->follow_mobile;
			$follow->incident_id = $post->incident_id;
			$follow->follow_code = $follow_code;
			$follow->save();
			return TRUE;
		}
				
		// HT: Mobile follow for link
		$follow_mobile = $post->follow_mobile;
		$sms_from = self::_sms_from();

		$message = Kohana::lang('follow.follow_mobile_subscribed')."(".$post->incident_id.").<br>";
		$message .= Kohana::lang('follow.mobile_unsubscribe').url::site().'follow/unsubscribe?c='.$follow_code;

		if (sms::send($post->follow_mobile, $sms_from, $message) === true)
		{
			$follow->follow_type = self::MOBILE_ALERT;
			$follow->follower = $post->follow_mobile;
			$follow->incident_id = $post->incident_id;
			$follow->follow_code = $follow_code;
			/*if (isset($_SESSION['auth_user']))
			{
				$follow->user_id = $_SESSION['auth_user']->id;
			}*/
			$follow->save();
			
			// HT: follow mail notification to admin
			$settings = kohana::config('settings'); // HT Fix associated with sms
			$from[] = ($settings['alerts_email'])
			? $settings['alerts_email']
			: $settings['site_email'];
			
			$from[] = $settings['site_name'];
			$subject = Kohana::lang('follow.follow_subscription_subject');
			$msg = Kohana::lang('follow.subscription_mobile').$post->follow_mobile."<br><br>";
			$msg .= Kohana::lang('follow.subscription_request')."<br><br>";
			$msg .= url::site().'reports/view/'.$post->incident_id;

			// HT: follow mail notification to admin
			email::send($settings['site_email'], $from, $subject, $msg, TRUE);

			return TRUE;
		}

		return FALSE;
    }

	/**
	 * Sends an email follow
	 *
	 * @param Validation_Core $post
	 * @param Follow_Model $follow
	 * @return bool 
	 */
	public static function _send_email_alert($post, $follow, $notify = TRUE)
	{
		if ( ! $post instanceof Validation_Core AND !$follow instanceof Follow_Model)
		{
			throw new Kohana_Exception('Invalid parameter types');
		}

		// Email follow, Confirmation Code
		$follow_email = $post->follow_email;
		$follow_code = text::random('alnum', 20);

		// HT: force update without notification
		if($notify === FALSE) {
			$follow->follow_type = self::EMAIL_ALERT;
			$follow->follower = $follow_email;
			$follow->follow_code = $follow_code;
			$follow->incident_id = $post->incident_id;
			$follow->save();
			return TRUE;
		}

		$settings = kohana::config('settings');

		$to = $follow_email;
		$from = array();
		
		$from[] = ($settings['alerts_email']) 
			? $settings['alerts_email']
			: $settings['site_email'];
		
		$from[] = $settings['site_name'];
		$subject = $settings['site_name']." ".Kohana::lang('follow.follow_subscription_subject');
		

		$message = Kohana::lang('follow.follow_subscribed')."<br>";
		$message .= url::site().'reports/view/'.$post->incident_id."<br><br>";
		$message .= Kohana::lang('follow.unsubscribe').url::site().'follow/unsubscribe?c='.$follow_code;
		
		// HT: follow mail notification to admin
		$msg = Kohana::lang('follow.subscription_email').$to."<br><br>";

		if (email::send($to, $from, $subject, $message, TRUE) == 1)
		{
			$follow->follow_type = self::EMAIL_ALERT;
			$follow->follower = $follow_email;
			$follow->follow_code = $follow_code;
			$follow->incident_id = $post->incident_id;
			/*if (isset($_SESSION['auth_user']))
			{
				$follow->user_id = $_SESSION['auth_user']->id;
			}*/
			$follow->save();

			// HT: follow mail notification to admin
			$subject = Kohana::lang('follow.follow_subscription_subject');
			email::send($settings['site_email'], $from, $subject, $msg, TRUE);
			return TRUE;
		}

		return FALSE;
	}   


	/**
	 * This handles sms follow subscription via phone
	 *
	 * @param string $message_from follower MSISDN (mobile phone number)
	 * @param string $message_description Message content
	 * @return bool
	 */
	public static function mobile_follow_register($message_from, $message_description)
	{
		// Preliminary validation
		if (empty($message_from) OR empty($message_description))
		{
			// Log the error
			Kohana::log('info', 'Insufficient data to proceed with subscription via mobile phone');
			
			// Return
			return FALSE;
		}

		//Get the message details (location, category, distance)
		$message_details = explode(" ",$message_description);
		$message = $message_details[1].",".Kohana::config('settings.default_country');
		$geocoder = map::geocode($message);
			
		// Generate follow code
		$follow_code = text::random('distinct', 8);

		// POST variable with items to save
		$post = array(
			'follow_type'=> self::MOBILE_ALERT,
			'follow_mobile'=>$message_from,
			'follow_code'=>$follow_code
		);

		// Create ORM object for the follow and validate
		$follow_orm = new Follow_Model();
		if ($follow_orm->validate($post))
		{
			return self::_send_mobile_alert($post, $follow_orm);
		}

		return FALSE;

	}

	/**
	 * This handles unsubscription from follow via the mobile phone
	 * 
	 * @param string $message_from Phone number of follower
	 * @param string $message_description Message content
	 * @return bool
	 */
	public static function mobile_follow_unsubscribe($message_from, $message_description)
	{
		// Validate parameters
		
		if (empty($message_from) OR empty($message_description))
		{
			// Log the error
			Kohana::log('info', 'Cannot unsubscribe from subscribe via the mobile phone - insufficient data');
			
			// Return
			return FALSE;
		}

		$sms_from = self::_sms_from();

		$site_name = $settings->site_name;
		$message = Kohana::lang('ui_admin.unsubscribe_message').' ' .$site_name;

		if (sms::send($message_from, $sms_from, $message) === true)
		{
			// Fetch all follows with the specified code
			$follows = ORM::factory('follow')
					->where('follower', $message_from)
					->find_all();
		
			foreach ($follows as $follow)
			{
				$follows->delete();
			}
			return TRUE;
		}
		return FALSE;	
	}

	private static function _sms_from()
	{
		
		$settings = Kohana::config('settings');
		
		// Get SMS Numbers
		if ( ! empty($settings['sms_no3'])) 
		{
			$sms_from = $settings['sms_no3'];
		}
		elseif ( ! empty($settings['sms_no2'])) 
		{
			$sms_from = $settings['sms_no2'];
		}
		elseif ( ! empty($settings['sms_no1'])) 
		{
			$sms_from = $settings['sms_no1'];
		}
		else
		{
			$sms_from = "000";// User needs to set up an SMS number
		}
		
		return $sms_from;
	}

}
