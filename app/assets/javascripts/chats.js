post_chat_message = function(text)
{
	$.ajax({
		type: 'POST',
		url: '',
		dataType: 'json',
		data:{
			'chat_message[message]':text
		},
		success: function()
		{
			$('#chat_input_message').val('');
		},
		error: function()
		{
			console.warn("Problem sending chat message!");
		}
	});
}

scroll_chat = function()
{
	var chat = $("#chat_messages")[0];
	if(chat)chat.scrollTop = $("#chat_messages")[0].scrollHeight;
}

$(function()
{
	var keys = {};

	$(document).keydown(function (e) {
	    keys[(e.keyCode ? e.keyCode : e.which)] = true;
	});
	
	$(document).keyup(function (e) {
	    delete keys[(e.keyCode ? e.keyCode : e.which)];
	});
	
	$('#chat_input_message').keypress(function(e){
		
		var code = (e.keyCode ? e.keyCode : e.which);
		if(code == 13 && !keys[16]){ //Enter keycode and no shift
		   var text = $('#chat_input_message').val();
		   post_chat_message(text);
		}
	});
	
	faye.subscribe(window.location.pathname, function(data){
		$('#chat_messages').append(data);
		scroll_chat();
	});
	
	scroll_chat();
	
});
