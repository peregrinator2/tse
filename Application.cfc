<cfcomponent name="Application" output="false">

<cfset this.name = "SoftEdge Assessment" />

<cffunction name="onApplicationStart" access="public" output="false" returntype="boolean">
    <cfset application.datasource = "softedge" />

    <cfreturn true />
</cffunction>

</cfcomponent>
