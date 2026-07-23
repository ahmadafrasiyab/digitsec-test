@RestResource(urlMapping='/user_defined_type_example/*')
global without sharing class RestEscalationOrPrivs {

    @HttpPost
    global static boolean updateUserRestPost(String profileName, ID userId){
        Profile prf = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User usr = [Select ProfileId FROM User Where ID = :userId];
        if(prf.id != NULL){
            System.Debug('Final Stuff: ' + usr + prf);
        usr.ProfileId = prf.id;
        update usr;
        return true;
        }else {
            return false;
        }                    
    }

  
    @HttpGet
    global static boolean updateUserRestGet(){
        RestRequest req = RestContext.request;
        ID profileName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Profile prf = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User usr = [Select ProfileId FROM User Where Name = 'Test'];
        if(prf.id != NULL){
            System.Debug('Final Stuff: ' + usr + prf);
        usr.ProfileId = prf.id;
        update usr;
        return true;
        }else {
            return false;
        }
                           

    }

    @HttpPatch
    global static boolean updateUserRestPatch(String profileName, ID userId){
        Profile prf = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User usr = [Select ProfileId FROM User Where ID = :userId];
        if(prf.id != NULL){
            System.Debug('Final Stuff: ' + usr + prf);
        usr.ProfileId = prf.id;
        update usr;
        return true;
        }else {
            return false;
        }
                           

    }

    @HttpPut
    global static boolean updateUserRestPut(User usr){
        insert usr;
        return true;                   
    }
}