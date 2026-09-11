public without sharing class escalationOfPrivs {
    public escalationOfPrivs() {
        System.Debug('System Called Final Stuff: ');
    }

    @AuraEnabled
    public static boolean updateUser(String profileName){
        Profile prf = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        ID userId = UserInfo.getUserId();
        ID CurrentUserProfile = userinfo.getProfileId();
        User usr = [Select ProfileId FROM User Where ID = '005G0000006xqKC'];
        if([select name from profile where id = :CurrentUserProfile].name != 'System Administrator')
        {
            return false;
        }else {
        if(prf.id != NULL){
            System.Debug('Final Stuff: ' + usr + prf);
        usr.ProfileId = prf.id;
        update usr;
        return true;
        }
        else {
            return false;
        }
    }
              
    

    }

    @RemoteAction
    public static boolean updateUserRemoteAction(String profileName, ID userId){
        Profile prf = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User usr = [Select ProfileId FROM User Where ID = :userId];
        if(prf.id != NULL){
            System.Debug('Final Stuff: ' + usr + prf);
            if([select name from profile where id = :userinfo.getProfileId()].name == 'System Administrator')
            {
        usr.ProfileId = prf.id;
        update usr;
        
        return true;
        }
        else {
            return false;
        }
        }else {
            return false;
        }
                           

    }

    @AuraEnabled
    public static boolean createUser(User newUser){
        insert newUser;
        return true;           
    }

    
}