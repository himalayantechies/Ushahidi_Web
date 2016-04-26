<!-- start submit comments block -->
<div class="follow-block">
	
	<h5><?php echo Kohana::lang('ui_main.follow_incident');?></h5>
	<?php
	if ($form_error)
	{
		?>
		<!-- red-box -->
		<div class="red-box">
			<h3><?php echo Kohana::lang('ui_main.error');?></h3>
			<ul>
				<?php
					foreach ($errors as $error_item => $error_description)
					{
						print (!$error_description) ? '' : "<li>" . $error_description . "</li>";
					}
				?>
			</ul>
		</div>
		<?php
	}
	?>
	<?php print form::open(NULL, array('id' => 'followForm', 'name' => 'followForm')); ?>


	<?php if ($show_mobile == TRUE): ?>
	<div class="report_row">
		<strong>
			<?php $checked = ($form['follow_mobile_yes'] == 1); ?>
			<?php print form::checkbox('follow_mobile_yes', '1', $checked); ?>
			<span>
				<?php echo Kohana::lang('ui_main.alerts_mobile_phone'); ?><br />
				<?php echo Kohana::lang('ui_main.alerts_enter_mobile'); ?>
			</span>
		</strong><br />
		<span><?php print form::input('follow_mobile', $form['follow_mobile'], ' class="text long"'); ?></span>
	</div>
	<?php endif; ?>
			
	<div class="report_row">
	<?php
	if ( ! $user)
	{
		?>
		<strong>
			<?php $checked = ($form['follow_email_yes'] == 1) ?> 
			<?php print form::checkbox('follow_email_yes', '1', $checked); ?>
			<span>
				<?php echo Kohana::lang('ui_main.email'); ?><br />
				<?php echo Kohana::lang('ui_main.alerts_enter_email'); ?>
			</span>
		</strong>
		<div class="report_row">
			<strong><?php echo Kohana::lang('ui_main.email'); ?>:</strong><br />
			<?php print form::input('follow_email', $form['follow_email'], ' class="text"'); ?>
		</div>
		<?php
	}
	else
	{
		?>
		<label>
			<?php $checked = ($form['follow_email_yes'] == 1) ?> 
			<?php print form::checkbox('follow_email_yes', '1', $checked); ?>
			<span>
				<strong><?php echo Kohana::lang('ui_main.email'); ?></strong><br />
			</span>
		</label>
		<div class="report_row">
			<strong><?php echo $user->email; ?></strong>
			<input type="hidden" id="follow_email" name="follow_email" value="<?php echo $user->email; ?>">
		</div>
		<?php
	}
	?>
	</div>
	<?php
	// Action::follow_form - Runs right before the end of the follow submit form
	Event::run('ushahidi_action.follow_form');
	?>
	<div class="report_row">
		<input name="submit" type="submit" value="<?php echo Kohana::lang('ui_main.follow'); ?> <?php echo Kohana::lang('ui_main.report'); ?>" class="btn_blue" />
	</div>
	<?php print form::close(); ?>
	
</div>
<!-- end submit follow block -->