<?php
/**
 * Follow js file.
 *
 * Handles javascript stuff related  to follow function
 *
 * PHP version 5
 * LICENSE: This source file is subject to LGPL license
 * that is available through the world-wide-web at the following URI:
 * http://www.gnu.org/copyleft/lesser.html
 * @author     HT Team <team@ushahidi.com>
 * @package    Ushahidi - https://github.com/ushahidi/Ushahidi_Web
 * @copyright  Ushahidi - http://www.ushahidi.com
 * @license    http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)
 */
?>


jQuery(function($) {
	$(window).load(function(){




	// Some Default Values
	$("#follow_mobile").focus(function() {
		$("#follow_mobile_yes").attr("checked",true);
	}).blur(function() {
		if(!this.value.length) {
			$("#follow_mobile_yes").attr("checked",false);
		}
	});

	$("#follow_email").focus(function() {
		$("#follow_email_yes").attr("checked",true);
	}).blur(function() {
		if( !this.value.length ) {
			$("#follow_email_yes").attr("checked",false);
		}
	});

});
