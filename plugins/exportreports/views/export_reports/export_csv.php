<?php
ob_start();
	echo "#,INCIDENT TITLE,INCIDENT DATE,LOCATION,DESCRIPTION,CATEGORY,LATITUDE,LONGITUDE";
	foreach(location_filter::$admLevels as $key => $admLvl) {
		echo ",".$admLvl['label'];
	}
	$custom_titles = customforms::get_custom_form_fields(FALSE, NULL, FALSE, "filter");
	foreach($custom_titles as $field_name) {
		echo ",".$field_name['field_name'];
	}
	echo ",FIRST NAME,LAST NAME,EMAIL,APPROVED,VERIFIED,ACTIONABLE,URGENT,ACTION TAKEN,CLOSED,ACTION SUMMARY,COMMENT,COMMENT DATE";

	// Incase a plugin would like to add some custom fields
	Event::run('ushahidi_filter.report_download_csv_header', $custom_headers);

	echo "\n";
	foreach ($incidents as $incident) {
		
		$incident_id = $incident->incident_id;
		echo '"'.$incident->incident_id.'"';
		echo ',"'.exportreports_helper::_csv_text($incident->incident_title).'"';
		echo ',"'.$incident->incident_date.'"';
		echo ',"'.exportreports_helper::_csv_text($incident->location_name).'"';
		echo ',"'.exportreports_helper::_csv_text($incident->incident_description).'"';
		echo ',"';
		$incident->incident_category = ORM::Factory('category')->join('incident_category', 'category_id', 'category.id')->where('incident_id', $incident_id)->find_all();
		foreach($incident->incident_category as $category) {
			if ($category->category_title) {
				echo exportreports_helper::_csv_text($category->category_title) . ", ";
			}
		}
		echo '"';
		echo ',"'.exportreports_helper::_csv_text($incident->latitude).'"';
		echo ',"'.exportreports_helper::_csv_text($incident->longitude).'"';
		$admList = location_filter::get_adm_levels($incident->adm_level, $incident->pcode);
		foreach(location_filter::$admLevels as $key => $admLvl) {
			if(isset($admList[$key])) echo ',"'.$admList[$key]->name.'"';
			else echo ',""';
		}
		
		$custom_fields = customforms::get_custom_form_fields($incident_id, NULL, FALSE, "filter");
		if ( ! empty($custom_fields)) {
			foreach($custom_fields as $custom_field) {
				echo ',"'.exportreports_helper::_csv_text($custom_field['field_response']).'"';
			}
		} else {
			$custom_field = customforms::get_custom_form_fields(FALSE, NULL, FALSE, "filter");
			foreach ($custom_field as $custom) {
				echo ',"'.exportreports_helper::_csv_text("").'"';
			}
		}
		$incident_orm = ORM::factory('incident', $incident_id);
		$incident_person = $incident_orm->incident_person;
		if($incident_person->loaded) {
			echo ',"'.exportreports_helper::_csv_text($incident_person->person_first).'"'.',"'.exportreports_helper::_csv_text($incident_person->person_last).'"'.
					',"'.exportreports_helper::_csv_text($incident_person->person_email).'"';
		} else {
			echo ',"'.exportreports_helper::_csv_text("").'"'.',"'.exportreports_helper::_csv_text("").'"'.',"'.exportreports_helper::_csv_text("").'"';
		}
		echo ($incident->incident_active) ? ",YES" : ",NO";
		echo ($incident->incident_verified) ? ",YES" : ",NO";
		if($incident->actionable == 1) echo ",Actionable";
		else if($incident->actionable == 2) echo ",Actionable+Urgent";
		else if($incident->actionable == 0) echo ",Unactionable";
		else echo ",";
		echo ($incident->action_urgent) ? ",YES" : ",NO";
		echo ($incident->action_taken) ? ",YES" : ",NO";
		echo ($incident->action_closed) ? ",YES" : ",NO";
		echo ',"'.exportreports_helper::_csv_text($incident->action_summary).'"';
		echo ',"'.exportreports_helper::_csv_text($incident->comment_description).'"';
		echo ',"'.exportreports_helper::_csv_text($incident->comment_date).'"';
		// Incase a plugin would like to add some custom data for an incident
		Event::run('ushahidi_filter.report_download_csv_incident', $incident->incident_id);
		echo "\n";
	}
	$report_csv = ob_get_clean();
	header("Content-Encoding: UTF-8");
	header("Content-type: text/x-csv; charset=utf-8");
	header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
	header("Content-Disposition: attachment; filename=" . time() . ".csv");
	header("Content-Length: " . strlen($report_csv));
	echo "\xEF\xBB\xBF"; // UTF-8 BOM
	echo $report_csv;
?>
