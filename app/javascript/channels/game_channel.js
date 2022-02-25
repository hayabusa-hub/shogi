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
    
    // ゲームIDを取得
    var gameID = document.getElementById("GameID");
    console.log(`userID: ${gameID.textContent}`);
    console.log(`game_id: ${data.game_id}`);
    
    if((gameID != null) && (data.game_id == gameID.textContent))
    {
      console.log("game page update");
      
      window.location.href = `/games/${gameID.textContent}`;
    }
    else
    {
      console.log("game page not update");
    }
  }
});