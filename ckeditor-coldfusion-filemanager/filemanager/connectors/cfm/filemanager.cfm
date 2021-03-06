<!---
 *	Filemanager CFM connector
 *
 *	filemanager.cfm
 *	use for ckeditor filemanager plug-in by Core Five - http://labs.corefive.com/Projects/FileManager/
 *
 *	@license	MIT License
 *	@author		Paul Klinkenberg, www.railodeveloper.com/post.cfm/ckeditor-3-with-coldfusion-filemanager-version-2-0-for-free
 *  @date		March 19, 2011
 *  @version	2.1: Added support for network share storage; merged setting files into one Application.cfm; revised some internal functions (path checking etc.); fixed a bug with non-displayed error output when using Quick Upload (i.e. when uploading wrong file type, no error msg was returned) 
 				2.0.1 February 26, 2011: Added debug text to the json output, if an error occured.
 				2.0 November 17, 2010: see change list at http://www.railodeveloper.com/post.cfm/ckeditor-3-with-coldfusion-filemanager-version-2-0-for-free
 				1.1 April 25, 2010: Fixed some bugs and added some functionality
 *	@copyright	Authors
--->
<cfif not isAllowed()>
	<cfset application.filemanager_obj.returnError(application.filemanager_obj.translate('AUTHORIZATION_REQUIRED')) />
</cfif>

<cfif structKeyExists(form, "mode")>
	<cfset url.mode = form.mode />
</cfif>

<cfif structKeyExists(url, "mode") and len(url.mode)>
	<cftry>
		<cfswitch expression="#url.mode#">
			<cfcase value="add">
				<cfif structKeyExists(form, "currentpath") and len(form.currentpath)>
					<cfset application.filemanager_obj.addFile(path=form.currentpath, formfieldname="newfile") />
				<!--- quick uploads --->
				<cfelseif structKeyExists(url, "currentfolder") and len(url.currentfolder)>
					<cfset application.filemanager_obj.addFile(path=url.currentfolder, formfieldname="upload", textarea=false) />
				<cfelse>
					<cfset application.filemanager_obj.returnError("Path was not given for the 'add' function.") />
				</cfif>
			</cfcase>
			<cfcase value="addfolder">
				<cfif structKeyExists(url, "path") and structKeyExists(url, "name")>
					<cfset application.filemanager_obj.addFolder(path=url.path, dirname=url.name) />
				</cfif>	
			</cfcase>
			<cfcase value="rename">
				<cfif structKeyExists(url, "old") and structKeyExists(url, "new")>
					<cfset application.filemanager_obj.rename(oldPath=url.old, newName=url.new) />
				</cfif>
			</cfcase>
			<cfcase value="getfolder,getinfo,delete,download">
				<cfif structKeyExists(url, "path")>
					<cfinvoke component="#application.filemanager_obj#" method="#url.mode#">
						<cfinvokeargument name="path" value="#url.path#" />
						<cfloop list="getsize,getsizes" index="key">
							<cfif structKeyExists(url, key)>
								<cfinvokeargument name="#key#" value="#iif(listfindNoCase('1,true,yes', url[key]), 1, 0)#" />
							</cfif>
						</cfloop>
					</cfinvoke>
				<cfelse>
					<cfset application.filemanager_obj.returnError("Path was not given for the requested function.") />
				</cfif>
			</cfcase>
			<cfdefaultcase>
				<cfset application.filemanager_obj.returnError(application.filemanager_obj.translate('MODE_ERROR')) />
			</cfdefaultcase>
		</cfswitch>
		<cfcatch>
			<!---<cfmail to="paul@ongevraagdadvies.nl" from="paul@frinky.nl" subject="error filemanager" type="html">
				<cfdump var="#url#" />
				<cfdump var="#cfcatch#" />
			</cfmail>--->
			<cfrethrow />
		</cfcatch>
	</cftry>
<cfelse>
	<cfset application.filemanager_obj.returnError(application.filemanager_obj.translate('MODE_ERROR')) />
</cfif>