import consumer from "./consumer"

consumer.subscriptions.create("GameChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("connected_game")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("game data received");
    console.log(`game_id: ${data.id}`);
    
    // ゲームIDを取得
    var gameID = document.getElementById("GameID");
    if((gameID != null) && (data.game_id != gameID.textContent))
    {
      console.log("game page update");
      console.log(`userID: ${gameID.textContent}`);
      console.log(`data.user_id:${data.user_id}`);
      
      window.location.href = `/games/${gameID}`;
    }
    else
    {
      console.log("game page not update");
    }
  }
});
