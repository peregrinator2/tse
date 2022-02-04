<cfsilent>
<cfset the_title = "The Soft Edge - Search Members of Congress" />

<!--- We might try using geolocation to get the user's state to use as the default --->
<cfset default_state_cd = structKeyExists(url, "state_cd") ? ucase(trim(url.state_cd)) : "NJ" />
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
    <input id="search_name" name="name_filter" type="text" />
    <input type="submit" value=" Search " />
</form>
<table border="1" cellpadding="2" cellspacing="0">
<tbody id="result_header">
    <th align="left">Title</th>
    <th align="left">Name</th>
    <th align="left">Chamber</th>
    <th align="left">Party</th>
    <th align="left">State</th>
    <th>District</th>
</tbody>
<tbody id="results">
</tbody>
</table>
</body>
<script>
var states = [];
<cfoutput query="get_states">
    states["#state_cd#"] = "#state_name#";
</cfoutput>
const getCongressPeople = (stateCode, nameFilter) => {
    var congress_people = $.getJSON({
        url: '/tse/cfcs/Congress.cfc?method=getCongressPeople',
        data: {
            "state_cd": stateCode,
            "name_filter": nameFilter,
        },
    });
    return congress_people.promise();
}

const refreshResults = (stateCode, nameFilter) => {
    var re = new RegExp(`(${nameFilter})`, 'gi');
    var congressPeople = getCongressPeople(stateCode, nameFilter);
    $("#results").html("");
    congressPeople.then(function(data) {
        $.each(data, function(i, item) {
            var congressId = item.congress_id;
            var title = item.title;
            var name = item.lname.toUpperCase() + ', ' + item.fname;
            var chamber = item.chamber == 'H' ? 'House of Representatives' : 'Senate';
            var party = 'Independent';
            if (item.party == 'D') {
                party = 'Democratic';
            } else if (item.party == 'R') {
                party = 'Republican';
            }
            var stateName = states[item.state_cd] || item.state_cd;
            var districtId = ('000' + item.district_id).slice(-3);

            if (nameFilter) {
                name = name.replace(re, '<strong>$1</strong>');
            }
            var $tr = $(
                `<tr id="row-${congressId}">`
            ).append(
                $('<td>').text(title),
                $('<td>').html(name),
                $('<td>').text(chamber),
                $('<td>').text(party),
                $('<td>').text(stateName),
                $('<td align="center">').text(districtId),
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
    var nameFilter = values.name_filter || "";
    if (stateCode || nameFilter) {
        refreshResults(stateCode, nameFilter);
    } else {
        alert("State or name filter required.");
    }
});
</script>
</html>
