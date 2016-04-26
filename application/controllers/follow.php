<?php defined('SYSPATH') or die('No direct script access.');
/**
 * This controller handles requests for SMS/ Email follow
 *
 * PHP version 5
 * LICENSE: This source file is subject to LGPL license
 * that is available through the world-wide-web at the following URI:
 * http://www.gnu.org/copyleft/lesser.html
 * @author     HT Team
 * @package    Ushahidi - http://source.ushahididev.com
 * @subpackage Controllers
 * @copyright  Ushahidi - http://www.ushahidi.com
 * @license    http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
 */

class Follow_Controller extends Main_Controller {

	public function __construct()
	{
		parent::__construct();
	}

	/**
	 * Unsubscribes follower using follower's confirmation code
	 *
	 * @param string $code
	 */
	public function unsubscribe($code = NULL)
	{
		$this->template->content = new View('follow/unsubscribe');
		$this->template->header->this_page = 'follow';
		$this->template->content->unsubscribed = FALSE;

		// XXX Might need to validate $code as well
		if ($code != NULL)
		{
			Follow_Model::unsubscribe($code);
			$this->template->content->unsubscribed = TRUE;
		}

    }

}
