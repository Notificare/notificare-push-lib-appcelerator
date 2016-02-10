function createListView(inbox) {
	items = [];
	inbox.forEach(function(item){
		var time = new Date(item.time);
		var options = {
		    weekday: "long", year: "numeric", month: "short",
		    day: "numeric", hour: "2-digit", minute: "2-digit"
		};
		items.push({
            template : (item.opened) ? "templateInboxOpened" : "templateInbox",
            textMessage : {
                text : item.message
            },
            textDate : {
                text : time.toLocaleDateString("nl-NL", options)
            },
            msg :{
	            id : item.id,
	            notification : item.notification,
	            message : item.message,
	            time : item.time
            },
            properties : {
              canEdit : true,
              inboxId : item.id
           }

        });
	});
    $.section.setItems(items);
    
    $.list.addEventListener('itemclick', function(e){
    	var item = $.section.getItemAt(e.itemIndex);
    	notificare.openInboxItem(item.msg);
    	setTimeout(function(){
    		loadInbox();
    	}, 2000);
    });
    
    $.list.addEventListener("delete", function(e) {
		notificare.removeFromInbox(items[e.itemIndex].msg, function(){
			setTimeout(function(){
	    		loadInbox();
	    	}, 2000);
		});
	});
}

function loadInbox(){
	
	notificare.fetchInbox(function(e){
		createListView(e.inbox);
	});
}

$.index.open();
var notificare = Alloy.Globals.notificare, items;

notificare.addEventListener('badge', function(e) {
	loadInbox();
});

loadInbox();
