public with sharing class ContactController {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [SELECT Id, Name, Title, Phone, Email FROM Contact LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> findContacts(String searchKey) {
        if (String.isBlank(searchKey)) {
            return new List<Contact>();
        }
        String key = '%' + searchKey + '%';
        //return [SELECT Id, Name, Title, Phone, Email FROM Contact WHERE Name LIKE :key LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static Contact getSingleContact(){
        return [SELECT Id, Name, Title, Phone, Email FROM Contact LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static string echoInput(String exploit){
        if(exploit != '')
        {
            return exploit;
        }else {
            return 'empty string';
        }
        
    }

}
