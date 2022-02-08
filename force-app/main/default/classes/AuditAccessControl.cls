 global with sharing class AuditAccessControl {
    public Integer NumberofUsers{get; set;}
    public Integer NumberofProfiles{get; set;}
    public Integer NumberofRoles{get; set;}
    public Integer NumberofPermissionSets{get; set;}
    public String dotPrefix {get; set;} 
    public List<User> ActiveUsers; 
    private static final String PERMISSIONS = 'permissions';
    private static final String CREATE = 'permissionscreate';
    private static final String READ = 'permissionsread';
    private static final String EDIT = 'permissionsedit';
    private static final String DELET = 'permissionsdelete';
    private static final String VAR = 'permissionsviewallrecords';
    private static final String MAR = 'permissionsmodifyallrecords';

    public PageReference init()
    {
        if(Schema.sObjectType.User.isaccessible() &&  Schema.sObjectType.UserRole.isaccessible() && Schema.sObjectType.Profile.isaccessible() && Schema.sObjectType.PermissionSetAssignment.isaccessible())
        {
            NumberofUsers = [Select count() from User Where isActive = true LIMIT 50000];
            NumberofRoles = [Select count() from UserRole LIMIT 50000];
            NumberofProfiles = [Select count() from Profile LIMIT 50000];
            NumberofPermissionSets = [Select count() from PermissionSetAssignment LIMIT 50000];
        }
        if(Schema.sObjectType.Organization.isaccessible() && Schema.sObjectType.Organization.fields.NamespacePrefix.isAccessible())
        {
         Organization orx = [SELECT NamespacePrefix FROM Organization] ;// SecurityScan.class.getName().substringBefore('SecurityScan');
            
         if(!(String.isBlank(orx.NamespacePrefix)))
         {dotPrefix = orx.NamespacePrefix+'.';}
        }
        return null;
    }
    
    @RemoteAction
    public static List<User> getUsers(Integer offset, Integer xlimit)
    {
    if(Schema.sObjectType.User.isaccessible())
        {
        return [Select Id, Username, Name, Email, UserRoleId, ProfileId, SmallPhotoUrl, Profile.Name, UserRole.Name From User Where IsActive = true LIMIT :xlimit OFFSET :offset];
        }
        return null;
    }
    @RemoteAction   
    public static List<ObjectPermissions> getObjects()
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<String> entities = new List<String>(schemaMap.keySet());
        entities.sort();
        
        if(Schema.sObjectType.ObjectPermissions.isaccessible()){
        return [SELECT Id, SObjectType FROM ObjectPermissions WHERE Parent.Profile.Name = 'System Administrator' LIMIT 50000];
        }
        return null;
    //return entities;
    }   
    
    @RemoteAction
    public static List<LoginGeo> getUserLoginGeos()
    {
        if(Schema.sObjectType.LoginGeo.isaccessible()){
        return [Select l.SystemModstamp, l.Subdivision, l.CountryIso, l.Country, l.City From LoginGeo l WHERE l.SystemModstamp > LAST_MONTH];
        }
         return null;
    }
    
    @RemoteAction
    public static List<PermissionSet> getObjectPerms(List<String> userfilter, List<Id> objectfilter, String accesstype) { 
    if(Schema.sObjectType.ObjectPermissions.isaccessible() && Schema.sObjectType.User.isaccessible()  && Schema.sObjectType.Profile.isaccessible() && Schema.sObjectType.PermissionSet.isaccessible() && Schema.sObjectType.PermissionSetAssignment.isaccessible())
    {
        List<ID> permId = new List<ID>();
        List<PermissionSetAssignment> permIds = [SELECT PermissionSet.Id FROM PermissionSetAssignment p WHERE p.AssigneeId in :userfilter];
        for(PermissionSetAssignment p : permIds)
        {
            permId.add(p.PermissionSet.Id);
        }
        
        //if(accesstype == '1' ) /{insert SecurityScanCase;}
        if((Schema.sObjectType.PermissionSet.isAccessible()))
        { //CRUD + FLS
            
    //    return [Select p.ProfileId, p.Profile.Name, p.PermissionsViewEncryptedData, p.PermissionsViewAllUsers, p.PermissionsViewAllData, p.PermissionsManageUsers, p.PermissionsManageUnlistedGroups, 
    //         (Select Id, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, AuthSessionId, PermissionSetId, UserId, Description From SessionActivations), 
    //         (Select Id, PermissionSetId, AssigneeId, SystemModstamp From Assignments where AssigneeId in :userfilter), 
    //         (Select Id, ParentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp From ObjectPerms Where SobjectType in :objectfilter), 
    //         (Select Id, ParentId, SobjectType, Field, PermissionsEdit, PermissionsRead, SystemModstamp From FieldPerms Where SobjectType in :objectfilter) From PermissionSet p Where p.Id in :permId];
        
		
		}
        else if((Schema.sObjectType.PermissionSet.isAccessible())) 
        {
            //CRUD ONLY
            // return [Select p.ProfileId, p.Profile.Name, p.PermissionsViewEncryptedData, p.PermissionsViewAllUsers, p.PermissionsViewAllData, p.PermissionsManageUsers, p.PermissionsManageUnlistedGroups, 
            // (Select Id, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, AuthSessionId, PermissionSetId, UserId, Description From SessionActivations), 
            // (Select Id, PermissionSetId, AssigneeId, SystemModstamp From Assignments where AssigneeId in :userfilter), 
            // (Select Id, ParentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp From ObjectPerms Where SobjectType in :objectfilter) From PermissionSet p Where p.Id in :permId];
        
		
		}
        else if((Schema.sObjectType.PermissionSet.isAccessible()))
        {
            // return [Select p.ProfileId, p.Profile.Name, p.PermissionsViewEncryptedData, p.PermissionsViewAllUsers, p.PermissionsViewAllData, p.PermissionsManageUsers, p.PermissionsManageUnlistedGroups, 
            // (Select Id, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, AuthSessionId, PermissionSetId, UserId, Description From SessionActivations), 
            // (Select Id, PermissionSetId, AssigneeId, SystemModstamp From Assignments where AssigneeId in :userfilter), 
            // (Select Id, ParentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp From ObjectPerms Where SobjectType in :objectfilter), 
            // (Select Id, ParentId, SobjectType, Field, PermissionsEdit, PermissionsRead, SystemModstamp From FieldPerms Where SobjectType in :objectfilter) From PermissionSet p Where p.Id in :permId];
			
					}
        
        // deleted the block 
    }
    return null;
    }
    
    @RemoteAction
    public static List<User> getDuplicateUsers()
    {
        if(Schema.sObjectType.User.isaccessible() &&  Schema.sObjectType.UserRole.isaccessible() && Schema.sObjectType.Profile.isaccessible())
        {
        List<AggregateResult> lstAggUser = [Select Email from User Group By Email];// Having Count(Id) > 1 Where isActive = true LIMIT 5000];
        List<String> lstUser = new List<String>();
        for(AggregateResult ar: lstAggUser)
        {
            lstUser.add((String)ar.get('Email'));
        }
        return [Select u.Id, u.Name, u.Email, u.UserRoleId, u.ProfileId, u.SmallPhotoUrl, Profile.Name, UserRole.Name from User u Where u.Email in :lstUser LIMIT 50000];
        }
        return null;
    }
    
    @RemoteAction
    public static List<Organization> getOWDs()
    {
        if(Schema.sObjectType.User.isaccessible() &&  Schema.sObjectType.UserRole.isaccessible() && Schema.sObjectType.Profile.isaccessible())
        {
            return [Select o.DefaultPricebookAccess, o.DefaultOpportunityAccess, o.DefaultLocaleSidKey, o.DefaultLeadAccess, o.DefaultContactAccess, o.DefaultCaseAccess, o.DefaultCampaignAccess, o.DefaultCalendarAccess, o.DefaultAccountAccess From Organization o LIMIT 50000];
            
        }
        return null;
    }
    
    @RemoteAction
    public static List<User> AuditAccessBasedOnProfile(List<String> lstProfiles, List<String> lstObjects, List<String> lstPermSets, String auditType, Integer offset, Integer cnt)
    {
        if(Schema.sObjectType.User.isaccessible() &&  Schema.sObjectType.UserRole.isaccessible() && Schema.sObjectType.Profile.isaccessible())
        {
        List<AggregateResult> lstAggUser = [Select Email from User Group By Email];// Having Count(Id) > 1 LIMIT 5000];
        List<String> lstUser = new List<String>();
        for(AggregateResult ar: lstAggUser)
        {
            lstUser.add((String)ar.get('Email'));
        }
        return [Select u.Id, u.Name, u.Email, u.UserRoleId, u.ProfileId, Profile.Name, UserRole.Name from User u Where u.Email in :lstUser LIMIT 50000];
        }
        return null;
    }
    
    @RemoteAction
    public static List<User> AuditAccessBasedOnUsers(List<String> lstUsers, List<String> lstObjects, List<String> lstPermSets, String auditType, Integer offset, Integer cnt)
    {
        if(Schema.sObjectType.User.isaccessible() &&  Schema.sObjectType.UserRole.isaccessible() && Schema.sObjectType.Profile.isaccessible())
        {
        List<AggregateResult> lstAggUser = [Select Email from User Group By Email];// Having Count(Id) > 1 LIMIT 5000];
        List<String> lstUser = new List<String>();
        for(AggregateResult ar: lstAggUser)
        {
            lstUser.add((String)ar.get('Email'));
        }
        return [Select u.Id, u.Name, u.Email, u.UserRoleId, u.ProfileId, Profile.Name, UserRole.Name from User u Where u.Email in :lstUser LIMIT 50000];
        }
        return null;
    }
    
    @RemoteAction
    public static List<User> GetUsersProfile(List<String> lstProfiles, List<String> lstObjects, List<String> lstPermSets, String auditType, Integer offset, Integer cnt)
    {
        if(Schema.sObjectType.User.isaccessible() &&  Schema.sObjectType.UserRole.isaccessible() && Schema.sObjectType.Profile.isaccessible())
        {
        List<AggregateResult> lstAggUser = [Select Email from User Group By Email];// Having Count(Id) > 1 LIMIT 5000];
        List<String> lstUser = new List<String>();
        for(AggregateResult ar: lstAggUser)
        {
            lstUser.add((String)ar.get('Email'));
        }
        return [Select u.Id, u.Name, u.Email, u.UserRoleId, u.ProfileId, Profile.Name, UserRole.Name from User u Where u.Email in :lstUser LIMIT 50000];
        }
        return null;
    }
    
     @RemoteAction
    public static List<User> GetUsersRole(List<String> lstRoles, List<String> lstObjects, List<String> lstPermSets, String auditType, Integer offset, Integer cnt)
    {
        if(Schema.sObjectType.User.isaccessible() &&  Schema.sObjectType.UserRole.isaccessible() && Schema.sObjectType.Profile.isaccessible())
        {
        List<AggregateResult> lstAggUser = [Select Email from User Group By Email];// Having Count(Id) > 1 LIMIT 5000];
        List<String> lstUser = new List<String>();
        for(AggregateResult ar: lstAggUser)
        {
            lstUser.add((String)ar.get('Email'));
        }
        return [Select u.Id, u.Name, u.Email, u.UserRoleId, u.ProfileId, Profile.Name, UserRole.Name from User u Where u.Email in :lstUser LIMIT 50000];
        }
        return null;
    }
    
    
}
