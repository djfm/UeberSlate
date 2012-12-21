
function post_translation(url, message_id, key, language_id, previous_translation_id)
{
	var string = $('#string_'+message_id).val();
	console.log(string);
	
	var icon = $('#icon_'+message_id);
	
	icon.attr('src','/assets/working.png')
	
	function problem(text)
	{	
		icon.attr('src','/assets/sad.png');
	}
	
	function success(text)
	{
		icon.attr('src','/assets/happy.png');
	}
	
	function success_handler(response, status, xhr)
	{
		
		if(response.success)
		{
			console.log("ok");
			success(response.text)
		}
		else
		{
			console.log("nok");
			problem(response.text);
		}
	}
	
	function error_handler(obj)
	{
		console.warn("Error posting translation!");
		problem("Sorry, a server error happended - this is not your fault.");
	}
	
	$.ajax({
	  type: 'POST',
	  url: url,
	  data: {
				'message_id': message_id,
				'language_id': language_id,
				'translation[string]': string,
				'translation[previous_translation_id]': previous_translation_id
			},
	  success: success_handler,
	  error: error_handler,
	  dataType: 'json'
	});
}

function text_changed(message_id)
{
	var icon = $('#icon_'+message_id);
	if(icon.attr('src') != '/assets/send.png')icon.attr('src','/assets/send.png');
}

function copyMessageHTMLToTranslation(message_id)
{
	var doc = $('#html_'+message_id).attr('srcdoc');
	$('#string_'+message_id).cleditor()[0].clear().execCommand("inserthtml",doc);
}


$(document).ready(function()
{
	$("div.message").each(function(i,div){
		/*faye.subscribe('/'+$(div).id,function(data){
			
		});*/
		$(div).find('textarea.translation').focus(function(){
			var id = $(div).attr('id');
			console.log("Message "+id+" got focus!");
		}).focusout(function()
		{
			var id = $(div).attr('id');
			console.log("Message "+id+" lost focus!");
			if($(div).find('textarea.translation').val().length > 0)
			{
				$(div).find('img.submit').click();
			}
		});
	});
});
