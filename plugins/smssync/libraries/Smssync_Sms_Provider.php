<?php defined('SYSPATH') or die('No direct script access.');

/**
 * The smssync sender
 */
class Smssync_Sms_Provider implements Sms_Provider_Core {
	
	public function send($to = NULL, $from = NULL, $message = NULL)
	{
		if(strlen(trim($to)) < 10) {
			return TRUE;
		}	
		if(strlen(trim($to)) == 10) $to = '977'.trim($to);
		$smssync = ORM::factory("smssync_message");
		$smssync->smssync_to = "+".$to;
		$smssync->smssync_from = $from;
		$smssync->smssync_message = $message;
		$smssync->smssync_message_date = date("Y-m-d H:i:s",time());
		$smssync->save();
		return TRUE;
	}
	
}
