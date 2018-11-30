import {Socket} from "phoenix"

let details_socket = new Socket("/socket", {params: {token: window.userToken}})

details_socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = details_socket.channel("aircraft:details", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

function renderAircraft(aircraft) {
  console.log(aircraft);
  return "<h1>" + aircraft.icoa + "</h1>";
}

setInterval(function() {

  channel.push("details", {})
    .receive("ok", resp => {
      console.log(resp.aircraft);

      d3.select(".aircraft_details")
        .selectAll("div")
          .data(resp.aircraft)
        .enter().append("div")
          .html(function(d) { return renderAircraft(d); });

    });



}, 3000);

export default details_socket
