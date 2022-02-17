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

    //const html = `<p>${data.content.id}</p>`;
    //console.log(html);
    //const messages = document.getElementById("samples");
    
    //var messages = document.getElementById("samples");
    //console.log(messages);
    console.log(`id:${data.content.id}\n user_id:${data.content.user_id}`);
    console.log(` opponent_id:${data.content.opponent_id}`);
    console.log(` status:${data.content.status}`);
    
    window.location.href = 'matchs';
    
    //messages.insertAdjacentHTML('afterbegin', html);
    return alert(data['message']);
  },

  speak: function() {
   //alert("speak")
    return this.perform('speak');
  }
});


// window.addEventListener("keypress", function(e) {
//   if (e.keyCode === 13) {
//     appMatch.speak();
//     e.target.value = '';
//     e.preventDefault();
//   }
// })

// setTimeout(function(){
//     appMatch.speak()
// },3000);

//appMatch.speak("sample");

// setInterval(function(){
//     appMatch.speak()
// },3000);

//const link = document.getElementById('matchRoom')
// var link = document.getElementById('matchRoom');
// link.addEventListener('click', function() {
//   appMatch.speak();
// })