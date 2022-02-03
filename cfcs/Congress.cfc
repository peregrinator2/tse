<cfcomponent name="Congress" initmethod="init" output="false">

<cfset variables.datasource = application.datasource />

<cffunction name="init" access="public" output="false" returntype="any">
    <cfset variables.all_congress_people = getCongressPeopleQ() />
    <cfreturn this />
</cffunction>

<cffunction name="getCongressPeopleQ" access="private" output="false" returntype="query">
    <!--- We can get all of the congress people and cache the result - it won't change often --->
    <cfquery name="local.all_congress_people" datasource="#variables.datasource#" cachedwithin="1">
        SELECT congress_id, title, fname, lname, chamber, party, state_cd, district_id
          FROM congress_person
         ORDER BY chamber, lname, fname, state_cd, district_id
    </cfquery>

    <cfreturn local.all_congress_people />
</cffunction>

<cffunction name="getCongressPeople" access="remote" output="false" returntype="array">
    <cfargument name="state_cd" type="string" required="true" default="" />
    <cfargument name="name_filter" type="string" required="true" default="" />

    <cfif !structKeyExists(variables, "all_congress_people")>
        <cfset variables.all_congress_people = getCongressPeopleQ() />
    </cfif>
 
    <cfset local.name_filter = trim(arguments.name_filter) />
    <cfset local.state_cd = ucase(trim(arguments.state_cd)) />
 
    <!---
    Loop through cached query and produce an array. We're using this method because QoQ ==> a lot of overhead
    AND we want to put the results in an array of structs anyway to make it JSON-friendly.
    --->
    <cfset local.congress_people_list = [] />
    <cfloop query="variables.all_congress_people">
        <cfif (!len(local.name_filter) || findNoCase(local.name_filter, variables.all_congress_people.lname)  || findNoCase(local.name_filter, variables.all_congress_people.fname))
           && (!len(local.state_cd) || local.state_cd EQ ucase(variables.all_congress_people.state_cd))
        >
            <cfset arrayAppend(
                local.congress_people_list, {
                    "title": variables.all_congress_people.title,
                    "fname": variables.all_congress_people.fname,
                    "lname": variables.all_congress_people.lname,
                    "chamber": variables.all_congress_people.chamber,
                    "party": variables.all_congress_people.party,
                    "state_cd": variables.all_congress_people.state_cd,
                    "district_id": variables.all_congress_people.district_id
               }
           ) />
        </cfif>
    </cfloop>

    <cfreturn local.congress_people_list />
</cffunction>

</cfcomponent>
