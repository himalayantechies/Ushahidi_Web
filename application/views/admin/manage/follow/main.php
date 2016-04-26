<?php 
/**
 * Follow view page.
 *
 * PHP version 5
 * LICENSE: This source file is subject to LGPL license 
 * that is available through the world-wide-web at the following URI:
 * http://www.gnu.org/copyleft/lesser.html
 * @author     Ushahidi Team <team@ushahidi.com> 
 * @package    Ushahidi - http://source.ushahididev.com
 * @module     API Controller
 * @copyright  Ushahidi - http://www.ushahidi.com
 * @license    http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL) 
 */
?>
			<div class="bg">
				<h2>
					<?php admin::manage_subtabs("follow"); ?>
				</h2>				
				<!-- tabs -->
				<div class="tabs">
					<!-- tabset -->
					<ul class="tabset">
						<li><a href="<?php echo url::site()."admin/manage/follow/"; ?>" <?php if ($type == '0' OR empty($type) ) echo "class=\"active\""; ?>><?php echo Kohana::lang('ui_main.show_all');?></a></li>
						<li><a href="<?php echo url::site()."admin/manage/follow/index/"; ?>?type=1" <?php if ($type == '1') echo "class=\"active\""; ?>><?php echo Kohana::lang('ui_main.sms');?></a></li>
						<li><a href="<?php echo url::site()."admin/manage/follow/index/"; ?>?type=2" <?php if ($type == '2') echo "class=\"active\""; ?>><?php echo Kohana::lang('ui_main.email');?></a></li>
					</ul>
					
					<!-- tab -->
					<div class="tab">
						<?php print form::open(NULL,array('method'=>'get', 'id' => 'followSearch', 'name' => 'followSearch')); ?>
							<input type="hidden" name="action" id="action" value="s"/>
							<input type="hidden" name="type" value="<?php echo $type; ?>"/>
							<ul>
								<li>
									<a href="#" onclick="followAction('d','<?php echo strtoupper(Kohana::lang('ui_main.delete')); ?>', '');">
									<?php echo strtoupper(Kohana::lang('ui_main.delete'));?></a>
								</li>
								<li style="float:right;">
									<?php print form::input('fk', $keyword, ' class="text" style="float:left;height:20px;"'); ?>
									<a href="#" onclick="javascript:followSearch.submit();">
									<?php echo Kohana::lang('ui_main.search');?></a>
								</li>
							</ul>
						<?php print form::close(); ?>
					</div>
				</div>
				<?php if ($form_error): ?>
					<!-- red-box -->
					<div class="red-box">
						<h3><?php echo Kohana::lang('ui_main.error');?></h3>
						<ul>
						<?php
						foreach ($errors as $error_item => $error_description)
						{
							// print "<li>" . $error_description . "</li>";
							print (!$error_description) ? '' : "<li>" . $error_description . "</li>";
						}
						?>
						</ul>
					</div>
				<?php endif; ?>
				
				<?php if ($form_saved): ?>
					<!-- green-box -->
					<div class="green-box">
						<h3><?php echo Kohana::lang('ui_main.follow_has_been');?> <?php echo $form_action; ?>!</h3>
					</div>
				<?php endif; ?>
				
				<!-- report-table -->
				<div class="report-form">
					<?php print form::open(NULL,array('id' => 'followMain', 'name' => 'followMain')); ?>
						<input type="hidden" name="action" id="action" value="">
						<input type="hidden" name="follow_id[]" id="follow_single" value="">
						<div class="table-holder">
							<table class="table">
								<thead>
									<tr>
										<th class="col-1"><input id="checkallfollows" type="checkbox" class="check-box" onclick="CheckAll( this.id, 'follow_id[]' )" /></th>
										<th class="col-2"><?php echo Kohana::lang('ui_admin.follow');?></th>
										<th class="col-3"><?php echo Kohana::lang('ui_main.sent');?></th>
										<th class="col-4"><?php echo Kohana::lang('ui_main.actions');?></th>
									</tr>
								</thead>
								<tfoot>
									<tr class="foot">
										<td colspan="4"><?php echo $pagination; ?></td>
									</tr>
								</tfoot>
								<tbody>
									<?php if ($total_items == 0): ?>
										<tr>
											<td colspan="4" class="col">
												<h3><?php echo Kohana::lang('ui_main.no_results');?></h3>
											</td>
										</tr>
									<?php endif; ?>
									<?php
									foreach ($follows as $follow)
									{?>
										<tr>
											<td class="col-1"><input name="follow_id[]" id="follow" value="<?php echo $follow->id; ?>" type="checkbox" class="check-box"/></td>
											<td class="col-2">
												<div class="post">
													<h4><?php echo $follow->follower; ?></h4>
												</div>
												<ul class="info">
													<li class="none-separator">
														<?php echo Kohana::lang('ui_main.report');?>: 
														<strong><a href="<?php echo url::site().'reports/view/'.$follow->incident_id; ?>"><?php echo '#'.$follow->incident_id; ?></a></strong>
													</li>
												</ul>
											</td>
											<td><?php echo $follow->follow_sent->count(); ?></td>
											<td class="col-4">
												<ul>
													<li class="none-separator"><a href="javascript:followAction('d','DELETE','<?php echo(rawurlencode($follow->id)); ?>')" class="del"><?php echo Kohana::lang('ui_main.delete');?></a></li>
												</ul>
											</td>
										</tr>
										<?php
									}
									?>
								</tbody>
							</table>
						</div>
					<?php print form::close(); ?>
				</div>
			</div>
