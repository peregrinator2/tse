<cfsilent>
<cfset the_title = "The Soft Edge - Members of Congress Search" />

<!--- We might try using geolocation to get the user's state to use as the default --->
<cfset default_state_cd = "NJ" />
<cfset states_obj = new cfcs.States() />
<cfset get_states = states_obj.getStates() />
</cfsilent>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" />
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</head>
<body>
<cfoutput><h1>#the_title#</h1></cfoutput>
<form id="searchForm" method="post">
    <strong>State:</strong>
    <select id="search_state" name="state_cd">
        <option value="">All</option>
        <cfloop query="get_states">
            <cfset isselected = state_cd EQ default_state_cd ? "selected" : "" />
            <cfoutput><option value="#state_cd#" #isselected#>#state_name#</option></cfoutput>
        </cfloop>
    </select>
    <strong>Last Name:</strong>
    <input id="search_lname" name="last_name" type="text" />
    <input type="submit" value=" Search " />
</form>
<table border="1" cellpadding="2" cellspacing="0">
<tbody id="result_header">
    <th align="left">Title</th>
    <th align="left">Name</th>
    <th align="left">Chamber</th>
    <th align="left">Party</th>
    <th>State</th>
    <th>District</th>
</tbody>
<tbody id="results">
</tbody>
</table>
</body>
<script>
const getCongressPeople = (stateCode, lastName) => {
    var congress_people = $.getJSON({
        url: '/tse/cfcs/Congress.cfc?method=getCongressPeople',
        data: {
            "state_cd": stateCode,
            "lname_filter": lastName,
        },
    });
    return congress_people.promise();
}

const refreshResults = (stateCode, lastName) => {
    var congress_people = getCongressPeople(stateCode, lastName);
    $("#results").html("");
    congress_people.then(function(data) {
        $.each(data, function(i, item) {
            var congress_id = item.congress_id;
            var title = item.title;
            var name = item.lname.toUpperCase() + ', ' + item.fname;
            var chamber = item.chamber == 'H' ? 'House of Representatives' : 'Senate';
            var party = item.party == 'D' ? 'Democratic' : 'Republican';
            var state_cd = item.state_cd;
            var district_id = ('000' + item.district_id).slice(-3);

            var $tr = $(
                `<tr id="row-${congress_id}">`
            ).append(
                $('<td>').text(title),
                $('<td>').text(name),
                $('<td>').text(chamber),
                $('<td>').text(party),
                $('<td align="center">').text(state_cd),
                $('<td align="center">').text(district_id),
            ).appendTo("#results");
        });
    },
    function(status) {
        alert("Fail: " + JSON.stringify(status));
    });
}

$(function() {
    refreshResults("<cfoutput>#default_state_cd#</cfoutput>", "");
});

$("#searchForm").submit(function(e) {
    e.preventDefault();
    var values = {};
    $.each($(this).serializeArray(), function(i, field) {
        values[field.name] = field.value;
    });
    var stateCode = values.state_cd || "";
    var lastName = values.last_name || "";
    refreshResults(stateCode, lastName);
});
</script>
</html>
