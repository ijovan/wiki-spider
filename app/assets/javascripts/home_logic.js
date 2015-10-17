function guid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
  }

  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
      s4() + '-' + s4() + s4() + s4();
}

var session_id;

function run_search(){
  clear_table();

  pusher_subscribe();

  var start_node = document.getElementById("start_node").value;
  var end_node = document.getElementById("end_node").value;

  send_search_request(start_node, end_node);
};

function send_search_request(start_node, end_node){
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.open("POST", "/home/create", true);
  xmlhttp.setRequestHeader("Content-type", "application/json");

  xmlhttp.send(JSON.stringify({startNode: start_node, endNode: end_node, channel: session_id}));
};

function clear_table(){
  var table = document.getElementById("results");
  table.innerHTML = "";
};

var pusher = new Pusher('3228ba1837099414741a', {
  encrypted: true
});

function pusher_subscribe(){
  if (session_id) {
    pusher.unsubscribe(session_id);
  }

  session_id = guid();

  var channel = pusher.subscribe(session_id);

  channel.bind('message', function(data) {
    var parsed = JSON.parse(data.message);
    var table = document.getElementById("results");

    table.insertRow(-1).insertCell(0).innerHTML = get_output(parsed);

    document.getElementById( 'bottom' ).scrollIntoView();
  });
};

function get_output(parsed){
  var output = "";

  switch(parsed.type) {
    case "CONNECTING":
      output = "Connecting " + create_link(parsed.start) + " and " +
        create_link(parsed.target) + ".";
      break;
    case "ITER":
      output = parsed.iter + ": " + parsed.path.map(create_link);
      break;
    case "FOUND":
      output = "FOUND IT: " + parsed.path.map(create_link) +
        " in " + parsed.time + " seconds, " + parsed.iter + " iterations" +
        " and " + Math.max(0, (parsed.path.length - 2)) + " connecting nodes.";
      break;
    case "FAILED":
      output = "Search failed.";
      if (parsed.iter == 0) {
        output += " Check the ending article link.";
      } else if (parsed.iter == 1) {
        output += " Check the starting article link.";
      }
      break;
    case "FAILED_MAX_ITER":
      output = "Search failed to complete in " + parsed.max_iter +
        " iterations.";
      break;
  }

  return output;
}

function create_link(node){
  return " <a href=\"https://en.wikipedia.org/wiki/" + node + "\">" + node.split("_").join(" ") + "</a>";
}
