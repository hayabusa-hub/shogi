import consumer from "./consumer"

const appMatch = consumer.subscriptions.create("MatchChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("connected")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    
    /*global $*/
    if(true == data.data["reload"]){
      console.log(` /matches/update_info${data.data["reload"]}`);
      window.location.href = 'matchs';
    }
    else{
      console.log(` /matches/update_info`);
      $.ajax({url: `/matches/update_info`, type: "GET", data: {from_id: data.data["from_id"]}, id: data.data["to_id"] });
    }
    
    
    
  },

  speak: function() {
    return this.perform('speak');
  }
});
