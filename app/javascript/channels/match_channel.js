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
    
    var userID = document.getElementById("UserID");
    
    //console.log(` match.user_id:${data.content.user_id}`);
    //console.log(` opponent_id:${data.content.opponent_id}`);
    //console.log(` status:${data.content.status}`);
    
    if((userID != null) && (data.user_id.to_s != userID.textContent.to_s))
    {
      console.log("match page update");
      console.log(`userID: ${userID.textContent}`);
      console.log(`data.user_id:${data.user_id}`);
      
      window.location.href = '/matchs';
      //$.ajax({url: '/matchs', type: "GET"});
    }
    else
    {
      console.log("match page not update");
      
      if(userID != null)
      {
        console.log(`userID: ${userID.textContent}`);
        console.log(`data.user_id:${data.user_id}`);
        console.log(` condetion1: ${userID != null}`);
        console.log(` condetion2: ${data.user_id != userID.textContent}`);
        
        console.log(` **********condetion3: ${1 != 1}`);
      }
      else
      {
        console.log(`userID: null`);
        console.log(`data.user_id:${data.user_id}`);
      }
    }
    
    
    //messages.insertAdjacentHTML('afterbegin', html);
    //return alert(data['message']);
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