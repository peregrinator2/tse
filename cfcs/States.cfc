<cfcomponent name="States" initmethod="init" output="false">

<cfset variables.datasource = application.datasource />

<cffunction name="init" access="public" output="false" returntype="any">
    <cfquery name="local.get_states" datasource="#variables.datasource#" cachedwithin="1">
        SELECT state_cd, state_name FROM states
         ORDER BY state_name
    </cfquery>
    <cfset variables.get_states = local.get_states />
    <cfreturn this />
</cffunction>

<cffunction name="getStates" access="public" output="false" returntype="query">
    <cfreturn variables.get_states />
</cffunction>

</cfcomponent>
