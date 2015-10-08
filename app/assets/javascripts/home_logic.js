function guid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
        .toString(16)
        .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
      s4() + '-' + s4() + s4() + s4();
}

var session_id = guid();

function run_search(){
  clear_table();

  var start_node = document.getElementById("start_node").value;
  var end_node = document.getElementById("end_node").value;

  send_search_request(start_node, end_node);
};

function send_search_request(start_node, end_node){
  var xmlhttp = new XMLHttpRequest();

  xmlhttp.open("POST", "/home/create", true);
  xmlhttp.setRequestHeader("Content-type", "application/json");
  xmlhttp.onreadystatechange = function () {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      document.getElementById("searching").innerHTML = "Searching...";
    }
  }

  xmlhttp.send(JSON.stringify({startNode: start_node, endNode: end_node, channel: session_id}));
};

function clear_table(){
  var table = document.getElementById("results");
  table.innerHTML = "";
};

var pusher = new Pusher('3228ba1837099414741a', {
  encrypted: true
});

var channel = pusher.subscribe(session_id);

channel.bind('message', function(data) {
  var table = document.getElementById("results");
  table.insertRow(-1).insertCell(0).innerHTML = data.message;
});
