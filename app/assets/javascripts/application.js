// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.ui.autocomplete
//= require jquery_ujs
//= require cleditor/cleditor
//= require cleditor/jquery.cleditor.advancedtable
//= require_tree .

notifications_queue = [];


close_notification = function()
{
	$('#notification').hide();
}

notify = function(notification)
{
	var image = "/assets/info.png";
	if(notification['severity'])$('#notification').attr('class', notification['severity']);
	$('#notification-message').html(notification['message']);
	$('#notification').show();
	
}

$(document).ready(function(){
	$('#notification-close').click(function(){
		close_notification();
	});
	
	$('legend.toggle').click(function()
	{
		console.log("hi");
		$(this).parents('fieldset').find('div.toggle').toggle();
	});
	
});
