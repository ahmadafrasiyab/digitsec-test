public with sharing class MetadataRetrieveController 
{
	
	public List<SelectOption> MetaDataTypes {get; set;}
	public String MetaDataType {get; set;}		
	public List<SelectOption> MetaDataItems {get; set;}
	public String MetaDataFolder {get; set;} 
	public String MetaDataItem {get; set;}	
	public Transient String MetadataFileName {get; set;}
	public Transient String MetadataFileData {get; set;}
	//public List<MetadataService.AsyncResult> AsyncResult {get; private set;}
	public MetadataService.AsyncResult AsyncResult {get; private set;}
	public Transient String MetaDataRetrieveZip { get; private set; }
	public List<MetaDataService.MetadataWithContent> MetadataFiles { get; set; }
	public String fullName {get; set;}
	public String content {get; set;}	
	public String[] apexPageNames{get; set;}
	public List<String> apexClassNames {get; set;}
	public String MetaDataFilenames {get; set;}	
	public List<Case> cas {get; set;}
	public List<Caso> casos {get; set;}
	public List<ApexClass> apxcls {get; set;}
	public Transient String status {get; set;}
	public String MetadataApexClass {get; set;}
	public List<String> customfields  = new List<String> {'Typeid__c', 'Objectid__c'};//,'Payload__c','URL__c'}; 
	public String custObjName = 'Security_Scan_oOlOo';
	public String FuzzedObjsnames {get; set;}
	public String fuzzedObjects {get; set;}
	public String RemoteSiteError {get; set;}	

	
	public Boolean found = false;
	
	public List<sObject> fuzzObjects {get; set;} // new List<sObject> {Case, Account, Asset, Campaign, CaseComment, CollaborationGroup, Contact, Event, Idea, Lead, Opportunity, Pricebook2, Product2, Task};
	public List<String> objectstoFuzz  = new List<String> {'Cases','Accounts','Assets','Campaigns','CaseComments','CollaborationGroups','Contacts','Events','Ideas','Leads','Opportunitys','Pricebook2s','Product2s','Tasks'};
	public List<String> payloads = new List<String> {'\'\';alert(\'oOlOo1\')','\';alert(\'oOlOo2\');//',';alert(\'oOlOo3\');//','*/\';alert(\'oOlOo4\'); /*','*/alert(\'oOlOo5\'); /*','%0A%0D\';alert(\'oOlOo6\');','" onload="alert(\'oOlOo7\')"><!--;','<img src="" onerror="alert(\'oOlOo8\');" /><!--','<script>alert(\'oOlOo9\');</script><!--','"><script>alert(\'oOlOo10\');</script><!--','"></textarea><script>alert(\'oOlOo11\');</script><!--','<img src="javascript:alert(\'oOlOo12\');">','<<SCRIPT>alert(\'oOlOo13\');//<</SCRIPT>','\\";alert(\'oOlOo14\');//','\\\';alert(\'oOlOo15\');//',' BACKGROUND="javascript:alert(\'oOlOo16\')"','<BASE HREF="javascript:alert(\'oOlOo17\');//">','"";alert(\'oOlOo18\')','";alert(\'oOlOo19\')//','";alert(\'oOlOo20\');//','*/";alert(\'oOlOo21\'); /*','*/alert(\'oOlOo22\'); /*','%0A%0D";alert(\'oOlOo23\');',' onload="alert(\'oOlOo24\')"><!--;','<img src="" onerror="alert(\'oOlOo25\');" /><!--','<script>alert(\'oOlOo26\');</script><!--','><script>alert(\'oOlOo27\');</script><!--','></textarea><script>alert(\'oOlOo28\');</script><!--','<img src="javascript:alert(\'oOlOo29\');">','<<SCRIPT>alert(\'oOlOo30\');//<</SCRIPT>','\\\';alert(\'oOlOo31\');//','\\";alert(\'oOlOo32\');//',' BACKGROUND="javascript:alert(\'oOlOo33\')"','<BASE HREF="javascript:alert(\'oOlOo34\');//">'};

	public List<Case> fizzCases= new List<Case>();
	public List<Account> fizzAccounts= new List<Account>();
	public List<Asset> fizzAssets= new List<Asset>();
	public List<Campaign> fizzCampaigns= new List<Campaign>();
	public List<CaseComment> fizzCaseComments= new List<CaseComment>();
	public List<Contact> fizzContacts= new List<Contact>();
	public List<Event> fizzEvents= new List<Event>();
	public List<Idea> fizzIdeas= new List<Idea>();
	public List<Lead> fizzLeads= new List<Lead>();
	public List<Opportunity> fizzOpportunitys= new List<Opportunity>();
	public List<Pricebook2> fizzPricebook2s= new List<Pricebook2>();
	public List<Product2> fizzProduct2s= new List<Product2>();
	public List<Task> fizzTasks= new List<Task>();
	public String scanCaseName = 'SecScanResults_oOlOo';
	public String baseSFURL {get; set;} 
	public String nmprefix {get; set;} 
	public String vfBaseURL {get; set;}
	
	public PageReference init()
	{
		baseSFURL = URL.getSalesforceBaseUrl().toExternalForm();
		
		baseSFURL = URL.getSalesforceBaseUrl().toExternalForm();
		List<String> parts = baseSFURL.split('\\.',10);
		
			if(parts[1].startsWith('na'))
			{
				baseSFURL ='https://' + parts[1]+ '.salesforce.com';
			}
		vfBaseURL = parts[1]+ '.visual.force.com/';
		
		RemoteSiteError = '0';
		MetaDataFilenames = '[]';
		fuzzedObjects = '[]';
		listMetadataItems();

		if(Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.fields.Subject.isAccessible() && Schema.sObjectType.Case.fields.Description.isAccessible()&& Schema.sObjectType.Case.fields.Status.isAccessible() && Schema.sObjectType.Case.fields.Priority.isAccessible() && Schema.sObjectType.Case.fields.CaseNumber.isAccessible())
		{
		cas = [ Select Id, Subject, Description, CaseNumber, Status, Priority from Case where 
		SuppliedName = :scanCaseName AND status <> 'Closed' ORDER BY LastModifiedDate DESC];
		System.debug(cas);
		}
		else
		{
			//Security Error
		}
		List<Caso> casost = new List<Caso>();
		for(Case cs: cas)
		{
		Integer hcount = 0;
		Integer mcount = 0;	
		Integer lcount = 0;
		Integer acount = 0;
		
		List<Case> relatedCases = new List<Case>();
		if(Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.fields.Subject.isAccessible() && Schema.sObjectType.Case.fields.Description.isAccessible()&& Schema.sObjectType.Case.fields.Status.isAccessible() && Schema.sObjectType.Case.fields.Priority.isAccessible()){
			relatedCases = [ Select Id, Subject, Description, CaseNumber, Status, Priority from Case where ParentId = :cs.Id];}
			for(Case rcs: relatedCases)
			{
				
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
			PageReference pr1 = Page.ScanDetails;
		String scanfileURL = pr1.getUrl();
			Caso crcs = new Caso(cs.Id, URL.getSalesforceBaseUrl().toExternalForm() + scanfileURL + '?id='+cs.Id, integer.valueof(cs.CaseNumber) + ' - ' + cs.Subject, String.valueOf(hcount),String.valueOf(mcount), String.valueOf(lcount), String.valueOf(acount));

			casost.add(crcs);
		}	
		casos = casost;
		if (Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Case.fields.Id.isAccessible() &&Schema.sObjectType.Case.fields.Description.isAccessible() )
		{
		List<Case> checkCase = [Select Id,Description from Case where SuppliedName = :custObjName LIMIT 1];		
	
	
	   // delete checkCase;
	   // clearAllMetadata();
		if(checkCase.isEmpty())
		{
			createFuzzedSObjects();
		}	
		else
		{
			fuzzedObjects = EncodingUtil.base64Encode(Blob.valueOf(checkCase[0].Description));
		}
		}
	
		return null;	
	}
	/*
	public void clearAllMetadata()
	{
		List<Case> lstCases = new List<Case>();
		List<Account> lstAccount = new List<Account>();
		List<CaseComment> lstCaseComment =  new List<CaseComment>();
		List<CollaborationGroup> lstCollaborationGroup = new List<CollaborationGroup>();
		List<Asset> lstAsset = new List<Asset>();
		List<Campaign> lstCampaign = new List<Campaign>();
		List<Contact> lstContact = new List<Contact>();
		List<Lead> lstLead = new List<Lead>();
		List<Opportunity> lstOpportunity = new List<Opportunity>();
		List<Event> lstEvent = new List<Event>();
		List<Product2> lstProduct2 = new List<Product2>();
		List<Pricebook2> lstPricebook2 = new List<Pricebook2>();
		List<Task> lstTask = new List<Task>();
		
		lstCases = [Select Id from Case];
		lstAccount = [Select Id, Name from Account];
		lstCaseComment = [Select Id from CaseComment];
		lstCollaborationGroup = [Select Id, Name from CollaborationGroup];
		lstAsset = [Select Id, Name from Asset];
		lstCampaign = [Select Id, Name from Campaign];
		lstContact = [Select Id, Name from Contact];
		lstLead = [Select Id, Name from Lead];
		lstOpportunity = [Select Id, Name from Opportunity];
		lstEvent = [Select Id from Event];
		lstProduct2 = [Select Id, Name from Product2];
		lstPricebook2 = [Select Id, Name from Pricebook2];
		lstTask = [Select Id from Task];
		
		delete lstCases;
		
		delete lstCaseComment;
		delete lstCollaborationGroup;
		delete lstAsset;
		delete lstCampaign;
		delete lstContact;
		delete lstLead;
		delete lstOpportunity;
		delete lstEvent;
		delete lstProduct2;
		delete lstPricebook2;
		delete lstTask;
		delete lstAccount;
	
		
	}*/
	public PageReference createFuzzedObject()
	{
		/*
	  List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
	  for(Schema.SObjectType f : gd)
    	{
    	if (f.getDescribe().isCustom())
    	{
    	if(f.getDescribe().getName() == custObjName)
    	found = true;
   		}
    	}
		
		if(!found)
		{
		// Create the custom Scan Object
		MetaDataItems = new List<SelectOption>();		
		MetadataService.MetadataPort service = createService();	
		MetadataService.CustomObject customObject = new MetadataService.CustomObject();
	    customObject.fullName = custObjName;
	    customObject.label = 'Test';
	    customObject.pluralLabel = 'Tests';
	    customObject.nameField = new MetadataService.CustomField();
	    customObject.nameField.type_x = 'Text';
	    customObject.nameField.label = 'Test Record';
	    customObject.deploymentStatus = 'Deployed';
	    customObject.sharingModel = 'ReadWrite';
	    customObjresults = service.create(new List<MetadataService.Metadata>{customObject});
	    
	    //Create the custom fields
	    
	    
	    ApexClass myClass = [select NamespacePrefix from ApexClass  where Name = 'MetadataRetrieveController'];
		  
		List<MetadataService.Metadata> mdagta = new List<MetadataService.Metadata>();
		for(String cf: customfields)
		{
			String fieldName = myClass.NamespacePrefix + '__' + custObjName +'.'+cf;
			    
		    MetadataService.CustomField customField = new MetadataService.CustomField();
		    customField.fullName = fieldName; //'Test__c.TestField__c';
		    customField.label = 'Testing';
		    customField.type_x = 'Text';
		    customField.length = 200;
		    mdagta.add(customField);
		    
		}
		
		customObjresults = service.create(mdagta);
		//createFuzzedSObjects();
		}
		*/
		
		return null;
	}
	
	
	public void createFuzzedSObjects()
	
	{
		try
		{
		

		// [{"name":"Case","id":""}]
		Account TempFuzzAccount = new Account();
				TempFuzzAccount.Description = 'SecurityTesting';
				TempFuzzAccount.BillingCountry = 'SecurityTesting';
				TempFuzzAccount.BillingState= 'SecurityTesting';
				TempFuzzAccount.ShippingStreet= 'SecurityTesting';
				TempFuzzAccount.ShippingState= 'SecurityTesting';
				TempFuzzAccount.ShippingCountry= 'SecurityTesting';
				TempFuzzAccount.Name= 'SecurityTesting';
				
				if('SecurityTesting'.length() < 40)
				{
				TempFuzzAccount.AccountNumber = 'SecurityTesting';
				TempFuzzAccount.BillingCity = 'SecurityTesting';
				TempFuzzAccount.BillingStreet = 'SecurityTesting';
				TempFuzzAccount.Fax = 'SecurityTesting';
				TempFuzzAccount.Phone = 'SecurityTesting';
				TempFuzzAccount.ShippingCity = 'SecurityTesting';
				}
				if(Schema.sObjectType.Account.isCreateable()
				&&	Schema.sObjectType.Account.fields.Description.isCreateable()
				&&	Schema.sObjectType.Account.fields.BillingCountry.isCreateable()
				&&	Schema.sObjectType.Account.fields.BillingState.isCreateable()
				&&	Schema.sObjectType.Account.fields.ShippingStreet.isCreateable()
				&&	Schema.sObjectType.Account.fields.ShippingState.isCreateable()
				&&	Schema.sObjectType.Account.fields.ShippingCountry.isCreateable()
				&&	Schema.sObjectType.Account.fields.Name.isCreateable()
				&&	Schema.sObjectType.Account.fields.AccountNumber.isCreateable()
				&&	Schema.sObjectType.Account.fields.BillingCity.isCreateable()
				&&	Schema.sObjectType.Account.fields.BillingStreet.isCreateable()
				&&	Schema.sObjectType.Account.fields.Fax.isCreateable()
				&&	Schema.sObjectType.Account.fields.Phone.isCreateable()
				&&	Schema.sObjectType.Account.fields.ShippingCity.isCreateable())
				{
					insert TempFuzzAccount;
				}
				
				Case TempFuzzcase = new Case();
				TempFuzzcase.Subject = 'SecurityTesting';
				TempFuzzcase.Description = 'SecurityTesting';
				TempFuzzcase.SuppliedName = 'SecurityTesting';
				if('SecurityTesting'.length() < 40)
				{
				TempFuzzcase.Origin = 'SecurityTesting';
				TempFuzzcase.Reason = 'SecurityTesting';
				
				TempFuzzcase.SuppliedPhone = 'SecurityTesting';
				TempFuzzcase.SuppliedCompany = 'SecurityTesting';
				}
				
				if(Schema.sObjectType.Case.isCreateable() && Schema.sObjectType.Case.fields.Subject.isCreateable() &&
				 Schema.sObjectType.Case.fields.Description.isCreateable()
				 && Schema.sObjectType.Case.fields.SuppliedName.isCreateable()
				 && Schema.sObjectType.Case.fields.Origin.isCreateable()
				 && Schema.sObjectType.Case.fields.Reason.isCreateable()
				 && Schema.sObjectType.Case.fields.SuppliedPhone.isCreateable()
				 && Schema.sObjectType.Case.fields.SuppliedCompany.isCreateable())
				{
					insert TempFuzzcase;
				}
				
		
		FuzzedObjsnames = '[';
	for(String payl: payloads)
	{
	
	
				//Case Creation
				Case Fuzzcase = new Case();
				Fuzzcase.Subject = payl;
				Fuzzcase.Description = payl;
				Fuzzcase.SuppliedName = payl;
				if(payl.length() < 40)
				{
				Fuzzcase.Origin = payl;
				Fuzzcase.Reason = payl;
				
				Fuzzcase.SuppliedPhone = payl;
				Fuzzcase.SuppliedCompany = payl;
				}
				
				fizzCases.add(Fuzzcase);
				
				
		
				//Account Creation
		
				Account FuzzAccount = new Account();
				FuzzAccount.Description = payl;
				FuzzAccount.BillingCountry = payl;
				FuzzAccount.BillingState= payl;
				FuzzAccount.ShippingStreet= payl;
				FuzzAccount.ShippingState= payl;
				FuzzAccount.ShippingCountry= payl;
				FuzzAccount.Name= payl;
				
				if(payl.length() < 40)
				{
				FuzzAccount.AccountNumber = payl;
				FuzzAccount.BillingCity = payl;
				FuzzAccount.BillingStreet = payl;
				FuzzAccount.Fax = payl;
				FuzzAccount.Phone = payl;
				FuzzAccount.ShippingCity = payl;
				}
				fizzAccounts.add(FuzzAccount);		
				
				//Asset Creation
				Asset FuzzAsset = new Asset();
				FuzzAsset.Description = payl;
				FuzzAsset.Name = payl;
				FuzzAsset.AccountId = TempFuzzAccount.Id;
				
				if(payl.length() < 40)
				{
				FuzzAsset.SerialNumber = payl;
				}
				fizzAssets.add(FuzzAsset);
				
				//Campaign Creation
				Campaign FuzzCampaign = new Campaign();
				FuzzCampaign.Description = payl;
				FuzzCampaign.Name = payl;
				if(payl.length() < 40)
				{
				}
				fizzCampaigns.add(FuzzCampaign);
					
				// CaseComment Creation
				CaseComment FuzzCaseComment = new CaseComment();
				FuzzCaseComment.CommentBody = payl;
				FuzzCaseComment.ParentId = TempFuzzcase.Id;
				if(payl.length() < 40)
				{
				}
				fizzCaseComments.add(FuzzCaseComment);
				
				
				
				
				//Contact Creation
				Contact FuzzContact = new Contact();
				
				FuzzContact.Description = payl;
				FuzzContact.Department = payl;
				
				FuzzContact.LastName= payl;
				FuzzContact.MailingStreet= payl;
				FuzzContact.OtherStreet= payl;
				FuzzContact.Title= payl;
				
				if(payl.length() < 40)
				{
					FuzzContact.FirstName = payl;
					FuzzContact.AssistantName = payl;
				}
				fizzContacts.add(FuzzContact);			
				
				
				//Event Creation
				Event FuzzEvent = new Event();
				FuzzEvent.Description = payl;
				FuzzEvent.Location = payl;
				FuzzEvent.Subject = payl;
				FuzzEvent.DurationInMinutes = 23;
				FuzzEvent.ActivityDate = Date.today();
				FuzzEvent.ActivityDateTime = DateTime.now();
				
				
				if(payl.length() < 40)
				{
				}
				fizzEvents.add(FuzzEvent);
				
					
				
				//Lead Creation
				Lead FuzzLead = new Lead();
				FuzzLead.Company = payl;
				FuzzLead.Country = payl;
				FuzzLead.Description = payl;
				FuzzLead.LastName= payl;
				FuzzLead.Street= payl;
				FuzzLead.Title= payl;
				
				if(payl.length() < 40)
				{
				FuzzLead.FirstName= payl;
				FuzzLead.City = payl;
				}
				fizzLeads.add(FuzzLead);
				
				
				//Opportunity Creation
				Opportunity FuzzOpportunity = new Opportunity();
				FuzzOpportunity.Description = payl;
				FuzzOpportunity.Name = payl;
				FuzzOpportunity.NextStep = payl;
				FuzzOpportunity.StageName = 'Introducted';
				FuzzOpportunity.CloseDate = Date.today();
				
				if(payl.length() < 40)
				{
				}
				fizzOpportunitys.add(FuzzOpportunity);
				
				//Pricebook2 Creation
				
				Pricebook2 FuzzPricebook2 = new Pricebook2();
				FuzzPricebook2.Name = payl;
				FuzzPricebook2.Description = payl;
				
				if(payl.length() < 40)
				{
				}
				fizzPricebook2s.add(FuzzPricebook2);
				//Product2 Creation
				
				Product2 FuzzProduct2 = new Product2();
				FuzzProduct2.Name = payl;
				FuzzProduct2.Description = payl;
				
				if(payl.length() < 40)
				{
				}
				fizzProduct2s.add(FuzzProduct2);
				
				//Task Creation
				Task FuzzTask = new Task();
				FuzzTask.CallDisposition = payl;
				FuzzTask.Description = payl;
				FuzzTask.CallObject = payl;
				FuzzTask.Subject =payl;
				FuzzTask.Priority = 'High';
				FuzzTask.Status = 'Closed';
				if(payl.length() < 40)
				{
				}
				fizzTasks.add(FuzzTask);
				
		
	}
	

	//do the inserts and create the JSON object
	if(Schema.sObjectType.Case.isCreateable()
	&& Schema.sObjectType.Case.fields.Subject.isCreateable() 
	&& Schema.sObjectType.Case.fields.Description.isCreateable()
	&& Schema.sObjectType.Case.fields.SuppliedName.isCreateable()
	&& Schema.sObjectType.Case.fields.Origin.isCreateable()
	&& Schema.sObjectType.Case.fields.Reason.isCreateable()
	&& Schema.sObjectType.Case.fields.SuppliedPhone.isCreateable()
	&& Schema.sObjectType.Case.fields.SuppliedCompany.isCreateable())
	{
		insert fizzCases;
		for(Case fCase: fizzCases)
		{
			FuzzedObjsnames = FuzzedObjsnames + '{"name":"Case","id":"'+ EncodingUtil.urlEncode(fCase.Id, 'UTF-8')  +'"},';
		}
	}
	
	if(Schema.sObjectType.Account.isCreateable()
	&&	Schema.sObjectType.Account.fields.Description.isCreateable()
	&&	Schema.sObjectType.Account.fields.BillingCountry.isCreateable()
	&&	Schema.sObjectType.Account.fields.BillingState.isCreateable()
	&&	Schema.sObjectType.Account.fields.ShippingStreet.isCreateable()
	&&	Schema.sObjectType.Account.fields.ShippingState.isCreateable()
	&&	Schema.sObjectType.Account.fields.ShippingCountry.isCreateable()
	&&	Schema.sObjectType.Account.fields.Name.isCreateable()
	&&	Schema.sObjectType.Account.fields.AccountNumber.isCreateable()
	&&	Schema.sObjectType.Account.fields.BillingCity.isCreateable()
	&&	Schema.sObjectType.Account.fields.BillingStreet.isCreateable()
	&&	Schema.sObjectType.Account.fields.Fax.isCreateable()
	&&	Schema.sObjectType.Account.fields.Phone.isCreateable()
	&&	Schema.sObjectType.Account.fields.ShippingCity.isCreateable())
	{
			insert fizzAccounts;
			for(Account fAccount: fizzAccounts)
			{
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Account","id":"'+ EncodingUtil.urlEncode(fAccount.Id, 'UTF-8')  +'"},';
			}
	}
	
	if(Schema.sObjectType.Asset.isCreateable() 
	&&Schema.sObjectType.Asset.fields.Description.isCreateable() 
	&&Schema.sObjectType.Asset.fields.Name.isCreateable() 
	&&Schema.sObjectType.Asset.fields.AccountId.isCreateable() 
	&&Schema.sObjectType.Asset.fields.SerialNumber.isCreateable())
	{
				insert fizzAssets;
				for(Asset fAsset: fizzAssets)
				{
					FuzzedObjsnames = FuzzedObjsnames + '{"name":"Asset","id":"'+ EncodingUtil.urlEncode(fAsset.Id, 'UTF-8')  +'"},';
				}
				
	}
	
	if(Schema.sObjectType.Campaign.isCreateable()
	&& Schema.sObjectType.Campaign.fields.Description.isCreateable() 
	&& Schema.sObjectType.Campaign.fields.Name.isCreateable())
	{
				insert fizzCampaigns;
				for(Campaign fCampaign: fizzCampaigns)
				{
					FuzzedObjsnames = FuzzedObjsnames + '{"name":"Campaign","id":"'+ EncodingUtil.urlEncode(fCampaign.Id, 'UTF-8')  +'"},';
				}
				
	}
	
	if(Schema.sObjectType.CaseComment.isCreateable()
	&& Schema.sObjectType.CaseComment.fields.CommentBody.isCreateable() 
	&& Schema.sObjectType.CaseComment.fields.ParentId.isCreateable())
	{
				insert fizzCaseComments;
				for(CaseComment fCaseComment: fizzCaseComments)
				{
					FuzzedObjsnames = FuzzedObjsnames + '{"name":"CaseComment","id":"'+ EncodingUtil.urlEncode(fCaseComment.Id, 'UTF-8')  +'"},';
				}
	}
	
		
	if(Schema.sObjectType.Contact.isCreateable()
	&&Schema.sObjectType.Contact.fields.Description.isCreateable() 
	&&Schema.sObjectType.Contact.fields.Department.isCreateable() 
	&&Schema.sObjectType.Contact.fields.LastName.isCreateable() 
	&&Schema.sObjectType.Contact.fields.MailingStreet.isCreateable() 
	&&Schema.sObjectType.Contact.fields.OtherStreet.isCreateable() 
	&&Schema.sObjectType.Contact.fields.Title.isCreateable() 
	&&Schema.sObjectType.Contact.fields.FirstName.isCreateable() 
	&&Schema.sObjectType.Contact.fields.AssistantName.isCreateable())
	{
				insert fizzContacts;
				for(Contact fContact: fizzContacts)
				{			
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Contact","id":"'+ EncodingUtil.urlEncode(fContact.Id, 'UTF-8')  +'"},';
				}
	}
	
	if(Schema.sObjectType.Event.isCreateable()
	&&Schema.sObjectType.Event.fields.Description.isCreateable() 
	&&Schema.sObjectType.Event.fields.Location.isCreateable() 
	&&Schema.sObjectType.Event.fields.Subject.isCreateable() 
	&&Schema.sObjectType.Event.fields.DurationInMinutes.isCreateable() 
	&&Schema.sObjectType.Event.fields.ActivityDate.isCreateable()
	&&Schema.sObjectType.Event.fields.ActivityDateTime.isCreateable())
	{
				insert fizzEvents;
				for(Event fEvent: fizzEvents)
				{
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Event","id":"'+ EncodingUtil.urlEncode(fEvent.Id, 'UTF-8')  +'"},';
				}
	}
				
	if(Schema.sObjectType.Lead.isCreateable()
	&&Schema.sObjectType.Lead.fields.Company.isCreateable() 
	&&Schema.sObjectType.Lead.fields.Country.isCreateable() 
	&&Schema.sObjectType.Lead.fields.Description.isCreateable() 
	&&Schema.sObjectType.Lead.fields.LastName.isCreateable() 
	&&Schema.sObjectType.Lead.fields.Street.isCreateable() 
	&&Schema.sObjectType.Lead.fields.Title.isCreateable() 
	&&Schema.sObjectType.Lead.fields.FirstName.isCreateable() 
	&&Schema.sObjectType.Lead.fields.City.isCreateable())
	{
				insert fizzLeads;
				for(Lead fLead: fizzLeads)
				{
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Lead","id":"'+ EncodingUtil.urlEncode(fLead.Id, 'UTF-8')  +'"},';
				}
	}
	
	if(Schema.sObjectType.Opportunity.isCreateable()
	&&Schema.sObjectType.Opportunity.fields.Description.isCreateable() 
	&&Schema.sObjectType.Opportunity.fields.Name.isCreateable() 
	&&Schema.sObjectType.Opportunity.fields.NextStep.isCreateable() 
	&&Schema.sObjectType.Opportunity.fields.StageName.isCreateable() 
	&&Schema.sObjectType.Opportunity.fields.CloseDate.isCreateable())
	{
				insert fizzOpportunitys;
				for(Opportunity fOpportunity: fizzOpportunitys)
				{
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Opportunity","id":"'+ EncodingUtil.urlEncode(fOpportunity.Id, 'UTF-8')  +'"},';
				}
	}
	
	if(Schema.sObjectType.Pricebook2.isCreateable()
	&&Schema.sObjectType.Pricebook2.fields.Name.isCreateable() 
	&&Schema.sObjectType.Pricebook2.fields.Description.isCreateable())
	{
				insert fizzPricebook2s;
				for(Pricebook2 fPricebook2: fizzPricebook2s)
				{
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Pricebook2","id":"'+ EncodingUtil.urlEncode(fPricebook2.Id, 'UTF-8')  +'"},';
				}
	}
	
	if(Schema.sObjectType.Product2.isCreateable()
	&&Schema.sObjectType.Product2.fields.Name.isCreateable()
	&&Schema.sObjectType.Product2.fields.Description.isCreateable())
	{
				insert fizzProduct2s;
				for(Product2 fProduct2: fizzProduct2s)
				{
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Product2","id":"'+ EncodingUtil.urlEncode(fProduct2.Id, 'UTF-8')  +'"},';
				}
	}
	
	if(Schema.sObjectType.Task.isCreateable()
	&&Schema.sObjectType.Task.fields.CallDisposition.isCreateable() 
	&&Schema.sObjectType.Task.fields.Description.isCreateable() 
	&&Schema.sObjectType.Task.fields.CallObject.isCreateable() 
	&&Schema.sObjectType.Task.fields.Subject.isCreateable() 
	&&Schema.sObjectType.Task.fields.Priority.isCreateable() 
	&&Schema.sObjectType.Task.fields.Status.isCreateable())
	{
				
				insert fizzTasks;
				for(Task fTask: fizzTasks){
				FuzzedObjsnames = FuzzedObjsnames + '{"name":"Task","id":"'+ EncodingUtil.urlEncode(fTask.Id, 'UTF-8')  +'"},';
				}
	}
	
	FuzzedObjsnames = FuzzedObjsnames +'{"name":"SecurityFuzzer","id":"oOlOo"}]';
	
	Case SecurityScanCase = new Case();
	SecurityScanCase.Description = FuzzedObjsnames;
	SecurityScanCase.SuppliedName = custObjName;
	SecurityScanCase.Subject = 'Security Fuzzed Objects';
	if(Schema.sObjectType.Case.isCreateable())
	{
	insert SecurityScanCase;
	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, SecurityScanCase.Id + 'objects: ' + FuzzedObjsnames));
	
	fuzzedObjects = EncodingUtil.base64Encode(Blob.valueOf(FuzzedObjsnames));
	}
	 
		}catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ex.getStackTraceString()));			
		}
	}
	
	@RemoteAction
	public static String deleteScan(ID scanID)
	{
		Case casedel = [Select Id,Description from Case where ID = :scanID];
		List<Case> vulnsdel = [Select Id,Description from Case where parentId = :scanID];
		
			
		if(Schema.sObjectType.Case.isDeletable())
		{
			
			delete vulnsdel;
			delete casedel; 
			return scanID;
		}
		else
		{
			return 'failure';
		}
		
	}
	@RemoteAction
	public static String logVulns(String vulns)	{
		try
		{
			
	String[] remediationguidance = new String[] {'nothing','We recommend the following techniques to prevent or mitigate the effects of SOQL injection: \n\t1. Do not use dynamic SOQL queries with Database.quert() function.\n\t 2. Use prepared statements like [Select Id from Account where id = :accountid];\n\t3. If you must use dynamic SOQL, use the escapeSingleQuotes method to sanitize user-supplied input.\n\t+Additional Resources: \n\thttps://www.salesforce.com/us/developer/docs/pages/Content/pages_security_tips_soql_injection.htm \n\thttps://salesforce.adobeconnect.com/_a13852757/writingsecureapps/',
	'We recommend the following techniques to prevent against authorization bypass:\n\t1. Implement access control checks such as isAccessible() prior to Select, isCreateable() prior to insert, isUpdateable() prior to update, isDeleteable() prior to delete as shown below: \n\t\t if(Schema.sObjectType.Case.isCreateable())\n\t\t{\n\t\tinsert SecurityScanCase;\n\t\t}\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_perms_enforcing.htm \n\thttps://salesforce.adobeconnect.com/_a13852757/writingsecureapps/',
	'We recommend the following techniques to prevent against cross-site scripting:\n\t1. Implement calls to appropriate encoding function prior to rending any user controlled input, such as:\n\t\t {!HTMLENCODE($Request.title)} or JSENCODE() or JSINHTMLENCODE() or URLENCODE()\n\t2. Set escape="true" for all apex: output tags\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/pages/Content/pages_security_tips_xss.htm \n\thttps://salesforce.adobeconnect.com/_a13852757/writingsecureapps/ ',
	'We recommend the following techniques to prevent against weak passwords:\n\t1. Go to Security Controls > Password Policies and set the password to require a mix alpha, numeric, and special characters\n\t\n\t+Additional Resources: \n\thttps://help.salesforce.com/htviewhelpdoc?id=admin_password.htm&siteLang=en_US',
	'We recommend the following techniques to prevent against persistent or stored cross-site scripting:\n\t1. Implement calls to appropriate encoding function prior to rending any user controlled input, such as:\n\t\t {!HTMLENCODE($Request.title)} or JSENCODE() or JSINHTMLENCODE() or URLENCODE()\n\t2. Set escape="true" for all apex: output tags\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/pages/Content/pages_security_tips_xss.htm \n\thttps://salesforce.adobeconnect.com/_a13852757/writingsecureapps/ ',
	'We recommend the following techniques to prevent against weak passwords:\n\t1. Go to Security Controls > Password Policies and set the password expiration to sixty days\n\t\n\t+Additional Resources: \n\thttps://help.salesforce.com/htviewhelpdoc?id=admin_password.htm&siteLang=en_US',
	'We recommend the following techniques to prevent against weak passwords:\n\t1. Go to Security Controls > Password Policies and set the password history to remember last 3 of more passwords\n\t\n\t+Additional Resources: \n\thttps://help.salesforce.com/htviewhelpdoc?id=admin_password.htm&siteLang=en_US',
	'We recommend the following techniques to prevent against brute force attacks:\n\t1. Go to Security Controls > Password Policies and set the account lockout time to 15 minutes (FifteenMinutes) due to failed login attempts\n\t\n\t+Additional Resources: \n\thttps://help.salesforce.com/htviewhelpdoc?id=admin_password.htm&siteLang=en_US',
	'We recommend the following techniques to prevent against brute force attacks:\n\t1. Go to Security Controls > Password Policies and set the maximum invalid login attempts to 10 attempts (TenAttempts) or less\n\t\n\t+Additional Resources: \n\thttps://help.salesforce.com/htviewhelpdoc?id=admin_password.htm&siteLang=en_US',
	'We recommend the following techniques to prevent against brute force attacks:\n\t1. Go to Security Controls > Password Policies and set the minimum password length to 10 characters\n\t\n\t+Additional Resources: \n\thttps://help.salesforce.com/htviewhelpdoc?id=admin_password.htm&siteLang=en_US',
	'We recommend the following techniques to prevent against weak authentication:\n\t1. Go to Security Controls > Password Policies and set the Password question requirement to Cannot contain password\n\t\n\t+Additional Resources: \n\thttps://help.salesforce.com/htviewhelpdoc?id=admin_password.htm&siteLang=en_US',
	'We recommend the following techniques to prevent against cross site request forgery(CSRF) attacks:\n\t1. Go to Security Controls > Session Settings and select Enable CSRF protection on GET requests on non-setup pages\n\t\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/securityImplGuide/Content/admin_sessions.htm',
	'We recommend the following techniques to prevent against cross site request forgery(CSRF) attacks:\n\t1. Go to Security Controls > Session Settings and select Enable CSRF protection on POST requests on non-setup pages\n\t\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/securityImplGuide/Content/admin_sessions.htm',
	'We recommend the following techniques to prevent against click jacking attacks:\n\t1. Go to Security Controls > Session Settings and select Enable clickjack protection for setup pages\n\t\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/securityImplGuide/Content/admin_sessions.htm',
	'We recommend the following techniques to prevent against click jacking attacks:\n\t1. Go to Security Controls > Session Settings and select Enable clickjack protection for non-setup Salesforce pages\n\t\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/securityImplGuide/Content/admin_sessions.htm',
	'We recommend the following techniques to prevent against click jacking attacks:\n\t1. Go to Security Controls > Session Settings and select Enable clickjack protection for non-setup customer Visualforce pages\n\t\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/securityImplGuide/Content/admin_sessions.htm',
	'We recommend the following techniques to prevent inactive session from being misued:\n\t1. Go to Security Controls > Session Settings and select 2 hours or less from the drop down\n\t\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/securityImplGuide/Content/admin_sessions.htm',
	'We recommend the following techniques to prevent sensitive data from cached:\n\t1. Go to Security Controls > Session Settings and de-select(uncheck) Enable caching and password autocomplete on login page\n\t\n\t+Additional Resources: \n\thttp://www.salesforce.com/us/developer/docs/securityImplGuide/Content/admin_sessions.htm'
	};
	
	Case ScanCase = new Case();
 		ScanCase.Subject = 'Security Scan at ' + Datetime.now().formatLong();//format('MM/dd/yyyy HH:mm:ss');
 		ScanCase.Description = 'Security Scanner found XXX issues';
		ScanCase.Origin = 'Security Scan';
		ScanCase.SuppliedName = 'SecScanResults_oOlOo';
		if(Schema.sObjectType.Case.isCreateable()
	&& Schema.sObjectType.Case.fields.Subject.isCreateable() 
	&& Schema.sObjectType.Case.fields.Description.isCreateable()
	&& Schema.sObjectType.Case.fields.SuppliedName.isCreateable()
	&& Schema.sObjectType.Case.fields.Origin.isCreateable()
	&& Schema.sObjectType.Case.fields.Status.isCreateable()
	&& Schema.sObjectType.Case.fields.Priority.isCreateable()
	&& Schema.sObjectType.Case.fields.SuppliedCompany.isCreateable()){
		insert ScanCase;}
		String Title;
		String Vulnexploit;
		String JSONvulns = '{"vulnerabilities":'+vulns+'}';
		//String JSONvulns = '{"vulnerabilities":[{"exploit":"The current password complexity is set to AlphaNumeric","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"4","code":"NA","severity":"Medium"},{"exploit":"The current password expiration policy is set to NinetyDays","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"6","code":"NA","severity":"Medium"},{"exploit":"The current setting only requires a password of EightCharacters characters.","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"10","code":"NA","severity":"High"},{"exploit":"Cross-Site Request Forgery (CSRF) protection on GET requests on non-setup pages is not enabled.","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"12","code":"NA","severity":"Low"},{"exploit":"Cross-Site Request Forgery (CSRF) protection on POST requests on non-setup pages is not enabled.","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"13","code":"NA","severity":"Medium"},{"exploit":"Clickjack protection for non-setup Salesforce pages is not enabled.","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"14","code":"NA","severity":"Low"},{"exploit":"Clickjack protection for non-setup customer pages is not enabled.","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"15","code":"NA","severity":"Low"},{"exploit":"Clickjack protection for setup pages is not enabled.","variable":"NA","url":"NA","file":"NA","line":"NA","typed":"16","code":"NA","severity":"Medium"},{"exploit":"Potential XXS due to disabled escaping @ pages/Security_Testing.page line 21","variable":"NA","url":"NA","file":"pages/Security_Testing.page","line":21,"typed":"3","code":"<apex:outputText id=testigis escape=false></apex:outputText>","severity":"Medium"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 159","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"159","typed":"2","code":"delete lstCases;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 161","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"161","typed":"2","code":"delete lstCaseComment;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 162","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"162","typed":"2","code":"delete lstCollaborationGroup;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 163","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"163","typed":"2","code":"delete lstAsset;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 164","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"164","typed":"2","code":"delete lstCampaign;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 165","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"165","typed":"2","code":"delete lstContact;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 166","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"166","typed":"2","code":"delete lstLead;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 167","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"167","typed":"2","code":"delete lstOpportunity;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 168","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"168","typed":"2","code":"delete lstEvent;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 169","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"169","typed":"2","code":"delete lstProduct2;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 170","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"170","typed":"2","code":"delete lstPricebook2;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 171","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"171","typed":"2","code":"delete lstTask;","severity":"High"},{"exploit":"CRUD or FLS: Authorization bypass issue found @ classes/MetadataRetrieveController.cls on line 172","variable":"NA","url":"NA","file":"classes/MetadataRetrieveController.cls","line":"172","typed":"2","code":"delete lstAccount;","severity":"High"},{"exploit":"SOQL Injection found @ classes/SecurityTesting.cls at line 40","variable":"NA","url":"NA","file":"classes/SecurityTesting.cls","line":40,"typed":"1","code":"\t\tString goo = 'Select Name from Account where ID=' + '\\'' + v + '\\'';","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable foo.bar","variable":"foo.bar","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?foo.bar=*/alert('213'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable foo.bar","variable":"foo.bar","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?foo.bar=*/alert('247'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable xsddsid","variable":"xsddsid","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?xsddsid=*/alert('281'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable xsddsid","variable":"xsddsid","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?xsddsid=*/alert('315'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable foo.bar","variable":"foo.bar","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?foo.bar=*/alert('417'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable foo.bar","variable":"foo.bar","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?foo.bar=*/alert('451'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable xsddsid","variable":"xsddsid","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?xsddsid=*/alert('485'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"},{"exploit":"Cross-site Scripting issue found @ https://digitsec.na11.visual.force.com/apex/Security_Testing via variable xsddsid","variable":"xsddsid","url":"https://digitsec.na11.visual.force.com/apex/Security_Testing?xsddsid=*/alert('519'); /*","file":"NA","line":"NA","typed":"3","code":"NA","severity":"High"}]}';
		JSONParser parser = JSON.createParser(JSONvulns);
        List<Case> relatedVulns = new List<Case>();
        while (parser.nextToken() != null) {
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        while (parser.nextToken() != null) {
        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        Case cvulns = new Case();
        Vuln inv = (Vuln)parser.readValueAs(Vuln.class);
        cvulns.ParentId = ScanCase.Id;
        cvulns.Subject = inv.exploit;
                    if(inv.url == 'NA'){
                    	Title = '' + EncodingUtil.base64Decode(inv.code).toString() + '';
                    //cvulns.SuppliedName = inv.code;
                    }else{
                    	Title = '' + EncodingUtil.base64Decode(inv.url).toString() + '';
                    //cvulns.SuppliedName = inv.url;
                    }
                    cvulns.Status = 'Active';
                    cvulns.Priority = inv.severity;
                    cvulns.SuppliedName =  inv.typed ;
                    cvulns.Description = Title;
                    
                   
                    
                   // cvulns.Type = inv.file;
                    cvulns.Origin = 'Security Scan';
                    relatedVulns.Add(cvulns);
                   
                    String s = JSON.serialize(inv);
                    Vulnexploit = Vulnexploit + s;
                    parser.skipChildren();
                }
            }
        }
    }
	if(Schema.sObjectType.Case.isCreateable()
	&& Schema.sObjectType.Case.fields.Subject.isCreateable() 
	&& Schema.sObjectType.Case.fields.Description.isCreateable()
	&& Schema.sObjectType.Case.fields.SuppliedName.isCreateable()
	&& Schema.sObjectType.Case.fields.Origin.isCreateable()
	&& Schema.sObjectType.Case.fields.Priority.isCreateable()
	&& Schema.sObjectType.Case.fields.Status.isCreateable()
	&& Schema.sObjectType.Case.fields.SuppliedCompany.isCreateable())
	{
    insert relatedVulns;
	}
	List<CaseComment> lstvulncomment = new List<CaseComment>();
	for(Case cvs: relatedVulns)
	{
		 CaseComment vulncomment = new CaseComment();
		 vulncomment.ParentId = cvs.Id;
         vulncomment.CommentBody = remediationguidance[integer.valueof(cvs.SuppliedName)];
         lstvulncomment.Add(vulncomment);          
		
	}
	if(Schema.sObjectType.CaseComment.isCreateable()){insert lstvulncomment;}
    String userName = UserInfo.getUserName();
    String return_result;
            
      if(Schema.sObjectType.User.isCreateable()) {
          User activeUser = [Select Email From User where Username = :userName limit 1];
           String userEmail = activeUser.Email;
        PageReference pr1 = Page.ScanDetails;
		String scanfileURL = pr1.getUrl();
    String[] userEmails = new String[] {userEmail};					
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setSubject('S3: Salesforce Security Scan Complete');
		email.setToAddresses(userEmails)	;
		email.setPlainTextBody('Review results here: ' + URL.getSalesforceBaseUrl().toExternalForm() + scanfileURL +'?id='+ScanCase.Id);
		email.setHtmlBody('<html><head></head><body style=""><div style="background-color: #CADBE4; margin-top: 5px; padding:10px; font-size: 16px; color: #666666;" width="100%" height="40px;">Salesforce Security Scan (S3)</div><div style="background-color:#f0f0f0;" width="100%"><div style="font-family: Helvetica; font-size: 14px; color: #333;text-align: center; height:100px;"><br><br><br> Salesforce Security Scan Completed <br><span style="color: #5a7b93;"> <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + scanfileURL +'?id='+ScanCase.Id +' "> View Results </a> <br><br>' + URL.getSalesforceBaseUrl().toExternalForm() + scanfileURL+ '?id='+ScanCase.Id +'</span><br><br><br></div></div><div align="center" width="100%" style="font-family: Helvetica; margin-top: 10px;background-color: #CADBE4; padding:10px;"><a href="https://www.digitsec.com" tabindex="0">© DigitSec</a> </div><div style="font-family: Helvetica; margin-top: 5px; font-size: 11px; color: #666666;" align="center">This email was generated by your Salesforce sandbox to notify you about the completion of a security scan</div></div></body></html>');
		//Messaging.SendEmailResult [] r = 
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
          return_result = URL.getSalesforceBaseUrl().toExternalForm() + scanfileURL +'?id='+ScanCase.Id;
      }
        
      
     
		return return_result;
    
		}
		catch(Exception ex)
		{
			return 'failure : ' + ex.getMessage();
		}
	}

	public String getReferer()
	{
    return ApexPages.currentPage().getHeaders().get('referer');
	}
	
	public PageReference listMetadataItems()
	{
		try
		{
		// List Metadata items for the selected Metadata Type
		MetaDataItems = new List<SelectOption>();		
		MetadataService.MetadataPort service = createService();				
		List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
		MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
		queryLayout.folder = MetaDataFolder;
		queryLayout.type_x = 'ApexPage';
		queries.add(queryLayout);		
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
		// Sort
		List<String> fullNames = new List<String>();
		if(fileProperties!=null)
		{
			MetaDataFilenames = '[';
			Integer i = 0;
			for(MetadataService.FileProperties fileProperty : fileProperties){
				i++;
				if(!(fileProperty.fullName.endsWith('metadataretrieve')))
				if(!(fileProperty.fullName.endsWith('SecurityScan')))
				if(!(fileProperty.fullName.endsWith('ScanDetails')))
				if(!(fileProperty.fullName.endsWith('SecurityFuzzer')))
			    if (!(fileProperty.fullName.endsWith('Test'))){
				fullNames.add(fileProperty.fullName);
				if(fileProperty.namespacePrefix == null)
				{
					nmprefix = 'c.';
				}else
				{
				nmprefix = fileProperty.namespacePrefix+'.';
				}
				MetaDataFilenames = MetaDataFilenames + '{"id":"' + EncodingUtil.urlEncode(fileProperty.fullName, 'UTF-8') + '", "file":"'+ 'pages/'+EncodingUtil.urlEncode(fileProperty.fullName, 'UTF-8')+'.page' + '",' + '"fileid":"' + EncodingUtil.urlEncode(fileProperty.id, 'UTF-8') +'","isApexPage": "1"  , "apexControllers": [],"nmprefix":"'+nmprefix+'"}';
				if(i>0 && i<=fileProperties.size()){
					MetaDataFilenames = MetaDataFilenames + ',';
				}
				
				}
				//MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
			}
		}
						
			fullNames.sort();
			apexPageNames = fullNames;
			List<String> axlNames = new List<String>();
            if(Schema.sObjectType.ApexClass.isAccessible()) 
            {
                
            }
            
            apxcls =[Select Id, Name from ApexClass];
                Integer i = 0;
                for(ApexClass apxcl : apxcls){
				i++;
				if(!(apxcl.Name.endsWith('MetadataService')))
				if(!(apxcl.Name.endsWith('SecurityScan')))
				if(!(apxcl.Name.endsWith('ScanDetails')))
				if(!(apxcl.Name.endsWith('MetadataRetrieveController')))  
				if(!(apxcl.Name.endsWith('Test'))){
					axlNames.add(apxcl.Name);
			//apexClassNames.add(apxcl.Name);
				MetaDataFilenames = MetaDataFilenames + '{"id":"' + EncodingUtil.urlEncode(apxcl.Name, 'UTF-8') + '","file":"'+ 'classes/'+EncodingUtil.urlEncode(apxcl.Name, 'UTF-8')+'.cls' + '",' + '"fileid":"' + EncodingUtil.urlEncode(apxcl.id, 'UTF-8') +'","isApexPage": "0" , "apexControllers": [],"nmprefix":""}';
				
				
				if(i>0 && i<= apxcls.size())
				{
					MetaDataFilenames = MetaDataFilenames + ',';
				}
				}
				
			}

            
            
			
			
			apexClassNames = axlNames;
			if(MetaDataFilenames.endsWith(','))
			{
				MetaDataFilenames = MetaDataFilenames.substring(0, MetaDataFilenames.length()-1);
			}
			MetaDataFilenames = MetaDataFilenames + ']';
			MetaDataFilenames = EncodingUtil.base64Encode(Blob.valueOf(MetaDataFilenames));
		
		
		
				
	//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'List MetatdataItems called...'));
	//	listMetadataApexClass();
	}catch(Exception e)
	{
		RemoteSiteError = e.getMessage() +' session: ' + UserInfo.getSessionId();
	}
		return null;	
	}
	
	
	/*
	public PageReference checkAsyncRequest()
	{
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
					
		MetadataService.AsyncResult[] aysncResults = service.checkStatus(new String[] { AsyncResult.Id });
		if(aysncResults[0].done)
		{
			// Errors?
			if(aysncResults[0].state == 'Error')
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, aysncResults[0].message));
				AsyncResult = null;				
			}
			else
			{
				// Place Base64 encoded zip data onto the page for the JSZip library to handle
				MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(AsyncResult.id);
				//MetaDataRetrieveZip = retrieveResult.zipFile;
				//Attachment a = retrieveResult.zipFile;
				//MetadataService.RetrieveResult.zipFile.
				MetaDataRetrieveZip = retrieveResult.zipFile;

				MetadataFiles = new List<MetaDataService.MetadataWithContent>();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
				AsyncResult = null;
			}
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
		}	
			
		
				
		

		return null;
	}*/
	
	/*public PageReference receiveMetadataZipFile()
	{
		// In this example the retrieved metadata is stored in viewstate in production cases you would probably use a custom object / attachment
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding Files ...'));
		/*
		MetaDataService.MetadataWithContent metaDataFile = new MetaDataService.MetadataWithContent();
		fullName = MetaDataFileName;
		content = MetaDataFileData;
		metaDataFile.content = MetaDataFileData;
		MetadataFiles.add(metaDataFile);
		return null;
	}*/
	
	//The new remote functions to paginate the requests
		
	
	
	/*public PageReference receiveComplete()
	{
		// Completed, cleared Base64 encoded zip data from viewstate
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Metadata retrieve completed'));
		MetaDataRetrieveZip = null;		
		return null;
	}*/
	
	private static MetadataService.MetadataPort createService(){ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		List<String> parts = baseURL.split('\\.',10);
		
			if(parts[1].startsWith('na'))
			{
				baseURL ='https://' + parts[1]+ '.salesforce.com';
			}
		service.endpoint_x = baseURL+'/services/Soap/m/29.0';
		
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}	
	
	/**
	 * Simple container class for retrieve metadata file, may as well leverage the Metadata API class for this
	 **/
	//public class MetadataFile extends MetadataService.MetadataWithContent
	//{
		public String getFullname()
		{
			return fullName;
		}
		
		public String getContent()
		{
			return content;
		}
	//}
	public class Vuln
{
	public String url;
	public String variable;
	public String exploit;
	public String file;
	public String line;
	public String typed;
	public String code;
	public String severity;
	
	public Vuln(String rl, String vari, String ploit, String ile, String ine, String ype, String ode, String everity)
	{
		url = rl;
		variable = vari;
		exploit=ploit;
		file = ile;
		line = ine;
		typed = ype;
		code = ode;
		severity = everity;
		
	}
}



public class PkgNames
{
	public String packagetype;
	public String filename;
	
	public PkgNames(String ptype, String fname)
	{
		packagetype = ptype;
		filename = fname;
		
	}
}

public class apexcodeObject
{
	public String apxclassname {get; set;}
	public String linecount{get; set;}
	public String methodcount{get; set;}
	public List<apexcodeObjectblock> methodnames{get; set;}
}

public class apexcodeObjectblock
{
	public String methodname{get; set;}
	public Integer startline{get; set;}
	public Integer endline{get; set;}
}
public  class Caso
{
	public String Id{get; set;}
	public String Subject {get; set;}
	public String highcount{get; set;} 
 	public String mediumcount{get; set;}
	public String lowcount{get; set;}
	public String activecount{get; set;}
	public String cId{get; set;}

	public Caso(String Id, String d, String ubject, String ighcount, String ediumcount, String owcount, String ctivecount)
	{
		this.cId = Id;
		this.Id = d;
		this.Subject = ubject;
		this.highcount = ighcount;
		this.mediumcount=ediumcount;
		this.lowcount=owcount;
		this.activecount=ctivecount;
	}
}

@RemoteAction
public static String jsretrieveMetadataClass(List<String> files)
	{		
		if(files.size() > 0)
		{
		MetadataService.MetadataPort service = createService();				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = 25;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers packageType2 = new MetadataService.PackageTypeMembers();
		packageType2.name = 'ApexClass'; 
		packageType2.members = files;
	 	retrieveRequest.unpackaged.types.add(packageType2);
		MetadataService.AsyncResult AsyncResult = service.retrieve_x(retrieveRequest);
		return AsyncResult.id;	
		}
		else {return '0';}	
	}

@RemoteAction
public static String jsretrieveSecuritySettings(String test)
	{
			
		// Construct unmanaged package with list of desired components to retrieve in zip
		MetadataService.MetadataPort service = createService();				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = 25;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers packageType3 = new MetadataService.PackageTypeMembers();
		packageType3.name = 'Settings'; 
		List<String> tempSettings = new List<String>();
		tempSettings.add('Security');
		packageType3.members = tempSettings;
		retrieveRequest.unpackaged.types.add(packageType3);
		MetadataService.AsyncResult AsyncResult = service.retrieve_x(retrieveRequest);
		return AsyncResult.id;	
		
	}
	
	@RemoteAction
public static void hearbeat()
{
	return;
}

@RemoteAction
public static String jsretrieveMetadataPage(List<String> files)
	{		

		
		if(files.size() > 0)
		{
		

		MetadataService.MetadataPort service = createService();				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = 25;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
		packageType.name = 'ApexPage'; 
		packageType.members = files;
		retrieveRequest.unpackaged.types.add(packageType);
		MetadataService.AsyncResult AsyncResult = service.retrieve_x(retrieveRequest);
								
		return AsyncResult.id;
		}
		else {return '0';}	
	}
	
	
@RemoteAction
public static String jscheckAsyncRequest(String Asyncid)
	{
		String MetaDataRetrieveZips;
		MetadataService.MetadataPort service = createService();
		MetadataService.AsyncResult[] aysncResults = service.checkStatus(new String[] { Asyncid });

		if(aysncResults[0].done)
		{
			if(aysncResults[0].state == 'Error')
			{
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, aysncResults[0].message));
				MetaDataRetrieveZips ='0';
			}
			else
			{
				MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(Asyncid);
				MetaDataRetrieveZips = retrieveResult.zipFile;
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
			}
		}
		else
		{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
			MetaDataRetrieveZips = '0';
		}	
		return MetaDataRetrieveZips;
	}

}