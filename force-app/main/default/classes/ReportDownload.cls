public with sharing class ReportDownload {
    public List<Case> cas {get; set;}
    transient public Integer hcount {get; set;}
    transient public Integer mcount {get; set;}
    transient public Integer lcount {get; set;}
    transient public Integer acount {get; set;}
    transient public Integer ccount {get; set;}
    transient public Integer total {get; set;}
    transient public String usernm {get; set;}
    transient public Integer offset {get; set;}
    transient public Integer reccount {get; set;}
    public String dotPrefix {get; set;} 
    
    public class AssignComment        // This class will be used to store the corresponding input from the user and the Case Comment
    {  
        public CaseComment comment {get; set;}        //This will store the case Comment
        public Boolean published {get; set;}          //This will store the input from the user
        public AssignComment(){}                      //Empty constructor
    }    
    public List<assignComment> Records {get; set;}    //This will store the list of case comments as well as the corresponding user inputs
    public ReportDownload(ApexPages.StandardController controller)
    {
    	{
        if(Schema.sObjectType.Organization.isaccessible() && Schema.sObjectType.Organization.fields.NamespacePrefix.isAccessible())
    	{
         Organization orx = [SELECT NamespacePrefix FROM Organization] ;// SecurityScan.class.getName().substringBefore('SecurityScan');
            
         if(!(String.isBlank(orx.NamespacePrefix)))
         {dotPrefix = orx.NamespacePrefix+'.';}
    	}
    	}
        if(ApexPages.currentPage().getParameters().get('Id') != null)
        {
        Records = new List<AssignComment>(); 
        if(controller !=null)
        {       
        Case Record = (Case) controller.getRecord();    //Get case from controller
        reccount = 0;
        offset = 0;
        if(ApexPages.currentPage().getParameters().get('offset') != null)
        {
        offset = Integer.valueOf(ApexPages.currentPage().getParameters().get('offset')); 
        }
       if(Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.fields.Subject.isAccessible() && Schema.sObjectType.Case.fields.Description.isAccessible()&& Schema.sObjectType.Case.fields.Status.isAccessible() && Schema.sObjectType.Case.fields.Priority.isAccessible() && Schema.sObjectType.Case.fields.CaseNumber.isAccessible() && Schema.sObjectType.User.fields.Name.isAccessible()){
           if (Schema.sObjectType.CaseComment.isAccessible()){
              

           	cas = [Select (Select Id, ParentId, IsPublished, CommentBody, CreatedById, CreatedDate, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted From CaseComments) Id, Subject, Description, CaseNumber, SuppliedName, Priority, Status from Case where parentId = :Record.Id ORDER BY Priority ASC NULLS LAST];


               
           }
       Case c = [Select CreatedById from Case where Id = :Record.Id];
       
       User users = [SELECT Name FROM User where Id =:c.CreatedById LIMIT 1];
       usernm = users.Name;
       reccount = cas.size();
       hcount = 0;
       mcount =0;
       lcount = 0;
       acount = 0;
       ccount = 0;
       total = 0;
       if (Schema.sObjectType.Case.isAccessible()){
         if (Schema.sObjectType.CaseComment.isAccessible())
         {
            List<Case> cass = [Select (Select Id, ParentId, IsPublished, CommentBody, CreatedById, CreatedDate, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted From CaseComments) Id, Subject, Description, CaseNumber, SuppliedName, Priority, Status from Case where parentId = :Record.Id];
			for(Case rcs: cass)
            {
                total++;
                if (rcs.Priority == 'High')
                {
                    hcount++;
                }
                if(rcs.Priority == 'Medium')
                {
                    mcount++;
                }
                if(rcs.Priority == 'Low')
                {
                    lcount++;
                }
                if(rcs.Status == 'Active')
                {
                    acount++;
                }
            }
           
                   
         }
       }
 ccount = total-acount;
        }
        }
        }
        
        
    }
    
   
    
    @RemoteAction
    public static String closeVulns(String vuln_id)
    {
        Case cs = [Select Id, Status from Case where Id = :vuln_id];
        if(cs!=null){
        cs.Status = 'Closed';
        if(Schema.sObjectType.Case.isUpdateable()
        && Schema.sObjectType.Case.fields.Status.isUpdateable()){
            update cs;
        }
        else
        {
            return 'failure';
        }
        }
        return cs.Id;
    }


}
