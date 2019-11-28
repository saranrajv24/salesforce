@isTest
private class RecurringBusinessController_Test{

      
    private static final String RB_NAME = 'RB - Encajonado + Paletizado Valente';
    private static final String RB_NAME_CPBP = 'RB - CPBP';
    private static final String OPP_NAME = 'Test Opp'; 
    private static final String REC_OPP_NAME = 'Test RecOpp'; 
    private static List<String> applnDomain = MasterDataManager.getDomainActiveCode(Label.MDE_Application);
    private static  List<String> buDomain = MasterDataManager.getActiveCodes(Label.MDE_ApplicationDomain);
    private static List<MDPicklistValueDomainBase__mdt> mdt = MasterDataManager.getActiveDomainBaseCodeRecords(Label.MDE_BusinessLine);
    private static List<String> industryUsageList = MasterDataManager.getNActiveCodes(Label.MDE_IndustryUsageLevel1, 3);
    private static List<String> channelLevel1List = MasterDataManager.getNActiveCodes(Label.MDE_ChannelClassLevel1, 2);
    private static List<String> channelLevel2List = MasterDataManager.getNActiveCodes(Label.MDE_ChannelClassLevel2, 2);
    private static string serviceCategoryVal = MasterdataManager.getActiveCode(Label.MDE_ServiceCatergory1,'S65');  
         
    @testSetup
    static private void testSetup(){

    ClsAccountUtil.isAccMergeFlag = true;
    ClsAccountUtil.isUpdate = false;
    
    //Account acc = (Account)DataLoaderUtil.createObject('Account',true);      
    Map<String, Object> accParams1 = new Map<String, Object>();
    accParams1.put('Name', 'TestAccount');
    Account acc1 = (Account) DataLoaderUtil.createObject('Account', true, accParams1);
                
    User user = DataLoaderUtil.createUser('SalesUser','ABB Sales Standard Profile');
    User u2 = DataLoaderUtil.createUser('stdUser','Standard User');     
    User uDataMig = DataLoaderUtil.createUser('data.mig','Standard User');     
         
    /*Map<String, Object> endUsrParams = new Map<String, Object>();
    endUsrParams.put('Account_End_User__c', acc.Id);
    End_User_Project__c endUser= (End_User_Project__c) DataLoaderUtil.createObject('End_User_Project__c', true, endUsrParams);*/
    
    Opportunity oppy = RbTestDataFactory.createTestOpportunity(OPP_Name);   
    
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];        
    
    Map<String, Object> conParams = new Map<String, Object>();
    conParams.put('AccountId', acc.Id);
    Contact con= (Contact) DataLoaderUtil.createObject('Contact', true, conParams);
    RbTestDataFactory.createTestOppLineItem();
    RbTestDataFactory.createTestRBWIthAllPickListFields(RB_NAME);  
    RbTestDataFactory.createTestRBWIthAllPickListFields(RB_NAME_CPBP);  
    RbTestDataFactory.createTestProductGroup();
    RbTestDataFactory.createTestRecurringOpp();
    RbTestDataFactory.createTestRBProduct();
        
    oppy.StageName = 'Negotiation';
    oppy.Account_End_User__c = acc1.Id;
    oppy.RFQ_Issue_Date__c = System.today();   
    update oppy;   
    
    /*ABB_Location__c loc = MasterdataManager.createABBLocation(); 
    
    Product_Group__c pg = MasterdataManager.createProductGroup(); 

    Map<String, Object> oppParams = new Map<String, Object>();
    oppParams.put('Name', OPP_NAME);
    oppParams.put('AccountId', acc.id);    
    oppParams.put('StageName', 'Closed Won');  
    oppParams.put('End_User_Project__c',  endUser.Id);        
    oppParams.put('Application__c',applnDomain[0]);
    oppParams.put('BU__c', buDomain[2]);
    oppParams.put('ABB_Domain__c',mdt[0].LastSuccessorDomain__c);
    oppParams.put('Business_Line__c', mdt[0].LastSuccessor__c);
    oppParams.put('Channel_Class_Level1__c', MasterDataManager.getActiveCode(Label.MDE_ChannelClassLevel1));
    oppParams.put('Channel_Class_Level1__c', MasterDataManager.getActiveCode(Label.MDE_ChannelClassLevel2,MasterDataManager.getActiveCode(Label.MDE_ChannelClassLevel1)));
    oppParams.put('ABB_Industry_Usage_Level1__c', MasterDataManager.getActiveCode(Label.MDE_IndustryUsageLevel1));
    oppParams.put('ABB_Industry_Usage_Level2__c', MasterDataManager.getActiveCode(Label.MDE_IndustryUsageLevel2,MasterDataManager.getActiveCode(Label.MDE_IndustryUsageLevel1)));
    oppParams.put('ABB_Industry_Usage_Level2__c', MasterDataManager.getActiveCode(Label.MDE_IndustryUsageLevel3,MasterDataManager.getActiveCode(Label.MDE_IndustryUsageLevel2)));
    oppParams.put('ABB_Location__c', loc.id);  
    oppParams.put('Product_Group__c', pg.Id);    
    oppParams.put('Local_Product_Group__c', pg.Id);    
    oppParams.put('Opportunity_Value__c', 1.00);
    oppParams.put('CurrencyIsoCode','USD'); 
    oppParams.put('ABB_Probability__c', 0.0);  
    ClsAccountUtil.isAccMergeFlag = true;
    ClsTriggerFactory.isSkipOpptyTrigger=true; 
    Opportunity oppy = (Opportunity) DataLoaderUtil.createObject('Opportunity', true, oppParams);   
        
    RecordType recType = [Select Id From RecordType  Where SobjectType = 'Product2' and DeveloperName = 'APTS_Global_Products'];   
    Map<String,Object> prodParams = new Map<String,Object>();
    prodParams.put('Description','Aluminium Solutions');
    prodParams.put('Name','Desc Aluminium Solutions');
    prodParams.put('Product_Group__c',Decimal.valueOf(4104));
    prodParams.put('RecordTypeId',recType.id);
    prodParams.put('CID__c','ABCD1234');
    prodParams.put('IsActive',true);    
    Product2 prod = (Product2)DataLoaderUtil.createObject('Product2',true,prodParams);
    
    Map<String,Object> priceBookParams = new Map<String,Object>();
    priceBookParams.put('Pricebook2Id',Test.getStandardPricebookId());
    priceBookParams.put('UnitPrice',Decimal.valueOf(20));
    priceBookParams.put('IsActive',true);
    priceBookParams.put('Product2Id',prod.id);
    priceBookParams.put('CurrencyIsoCode',oppy.CurrencyIsoCode);
    PricebookEntry pbe = (PricebookEntry)DataLoaderUtil.createObject('PricebookEntry',true,priceBookParams);  
     
    List<Map<String, Object>> oliList = new List<Map<String, Object>>();
    
    Map<String,Object> oliParams = new Map<String,Object>();  
    oliParams.put('OpportunityId' ,oppy.Id);
    oliParams.put('PricebookEntryId' ,pbe.Id);
    oliParams.put('Quantity' ,2.03);
    oliParams.put('TotalPrice' ,221.1);    
    oliParams.put('Primary_Product_Group__c' ,true);
    oliParams.put('Product_Group__c' ,4104);    
    oliList.add(oliParams);
    ClsTriggerFactory.isSkipOpptyProductTrigger = false;
    OpportunityLineitem oLineItems = (OpportunityLineitem)DataLoaderUtil.createObject('OpportunityLineitem',true,oliParams);    

    Map<String,Object> oliParams1 = new Map<String,Object>();  
    oliParams1.put('OpportunityId' ,oppy.Id);
    oliParams1.put('PricebookEntryId' ,pbe.Id);
    oliParams1.put('Quantity' ,2.03);
    oliParams1.put('TotalPrice' ,221.1);
    oliParams1.put('Primary_Product_Group__c' ,false);
    oliParams1.put('Product_Group__c' ,4104);    
    oliList.add(oliParams1);
    ClsTriggerFactory.isSkipOpptyProductTrigger = false;
    OpportunityLineitem oLineItems1 = (OpportunityLineitem)DataLoaderUtil.createObject('OpportunityLineitem',true,oliParams1);    
   
    List<OpportunityLineitem> oliList1 = DataLoaderUtil.createObjects('OpportunityLineitem', true, 2, oliList); */

    Id recordTypeId = [Select Id,name From RecordType Where SobjectType = 'Apttus__APTS_Agreement__c' and Recordtype.DeveloperName = 'Frame_Agreement'].Id;
    Map<String, Object> agmtParams1 = new Map<String, Object>();
    agmtParams1.put('name' ,'Test Agreement');  
    agmtParams1.put('Apttus__Primary_Contact__c',con.id);
    agmtParams1.put('APTS_Primary_Contact__c',con.id);
    agmtParams1.put('Apttus__Status_Category__c','Request');
    agmtParams1.put('Apttus__Status__c','Request');
    agmtParams1.put('Apttus__Contract_Start_Date__c',system.today()); 
    agmtParams1.put('Apttus__Contract_End_Date__c',system.today());
    agmtParams1.put('Apttus__Related_Opportunity__c', oppy.id);
    agmtParams1.put('RecordTypeId', recordTypeId);
    clsAgreementHelper_CLM.IsExecuted = True;   
    Apttus__APTS_Agreement__c apts1 = (Apttus__APTS_Agreement__c) DataLoaderUtil.createObject('Apttus__APTS_Agreement__c', true, agmtParams1);    
    clsAgreementHelper_CLM.IsExecuted = False;
        
    /*Map<String, Object> rbParams = DataLoaderUtil.createRecurringBusiness(oppy);
    Date startDate = Date.today();
    Date endDate = startDate.addDays(3);    
    rbParams.put('Account_End_User__c',acc.id);
    rbParams.put('All_Target_vs_All_Commit__c','Others');
    rbParams.put('Award_Date__c',endDate);    
    //rbParams.put('BU__c',buDomain[2]);
    //rbParams.put('Application__c',applnDomain[5]);
    rbParams.put('ABB_Location__c',loc.id);    
    rbParams.put('CurrencyIsoCode',oppy.CurrencyIsoCode);
    rbParams.put('Opportunity__c',oppy.Id);
    rbParams.put('End_Date__c',endDate);
    rbParams.put('End_User_Project__c',endUser.Id);
    rbParams.put('Frequency__c','Monthly');
    rbParams.put('Name',RB_NAME);
    rbParams.put('Source_Agreement__c',apts1.Id);
    rbParams.put('OwnerId',u2.Id);
    rbParams.put('Parent__c',oppy.Id);
    rbParams.put('Periods__c','1');
    rbParams.put('Quantity__c',250.00);        
    rbParams.put('Start_Date__c',startDate);
    rbParams.put('Status__c','In Progress');
    rbParams.put('TotalRBValue__c',25000);
    rbParams.put('Type__c','Value');
    rbParams.put('Value__c',354528);
    rbParams.put('BU_PickVal__c',buDomain[2]);
    rbParams.put('Application_PickVal__c',applnDomain[5]);
    rbParams.put('ABB_Domain_PickVal__c',oppy.ABB_Domain__c);
    rbParams.put('Business_Line_PickVal__c',oppy.Business_Line__c);
    rbParams.put('Channel_Class_Level1_PickVal__c',oppy.Channel_Class_Level1__c);
    rbParams.put('Channel_Class_Level2_Pickval__c',oppy.Channel_Class_Level2__c);
    rbParams.put('Industry_Usage_Level1_PickVal__c',oppy.ABB_Industry_Usage_Level1__c);
    rbParams.put('Industry_Usage_Level2_PickVal__c',oppy.ABB_Industry_Usage_Level2__c);
    rbParams.put('Industry_Usage_Level3_PickVal__c',oppy.ABB_Industry_Usage_Level3__c);
    ClsTriggerFactory.isSkipRBTrigger = true;
    Recurring_Business__c rbObj = (Recurring_Business__c) DataLoaderUtil.createObject('Recurring_Business__c', true, rbParams);   
        
    List<RecurringBusinessWrapperClasses.RoLineItems> listRBlineitems = new List<RecurringBusinessWrapperClasses.RoLineItems>();        
        listRBlineitems.add(new RecurringBusinessWrapperClasses.RoLineItems('RO1',oLineItems.Product2Id,oLineItems.Name,
                            oLineItems.UnitPrice,oLineItems.Quantity,oLineItems.TotalPrice/2,oLineItems.TotalPrice,0.00,'test',True,True,null,false));//RB-6458
    
    List<Map<String, Object>> rbrefList = new List<Map<String, Object>>();

    Map<String, Object> rbRefParams1 = new Map<String, Object>();        
    rbRefParams1.put('EAD__c',system.today().addDays(30));
    rbRefParams1.put('RO_Name__c','RO1');
    rbRefParams1.put('Fulfill__c','Yes');
    rbRefParams1.put('Total_Value__c',1100);
    rbRefParams1.put('RB_ID__c',rbobj.id);
    rbRefParams1.put('Reason_For_Cancellation__c','Political decision');    
    rbRefParams1.put('Status__c','Draft'); 
    rbRefParams1.put('Products_1__c',Json.serialize(listRBlineitems));
    rbRefParams1.put('Products_2__c',Json.serialize(listRBlineitems));
    rbrefList.add(rbRefParams1);
    RB_Reference__c rbRefr = (RB_Reference__c) DataLoaderUtil.createObject('RB_Reference__c', true,rbRefParams1);
    
    Map<String, Object> rbRefParams = new Map<String, Object>();        
    rbRefParams.put('EAD__c',system.today().addDays(30));
    rbRefParams.put('RO_Name__c','RO2');
    rbRefParams.put('Fulfill__c','No');
    rbRefParams.put('Total_Value__c',1100);
    rbRefParams.put('RB_ID__c',rbobj.id);
    rbRefParams.put('Reason_For_Cancellation__c','Political decision');    
    rbRefParams.put('Status__c','Draft'); 
    rbRefParams.put('Products_1__c',Json.serialize(listRBlineitems));
    rbRefParams.put('Products_2__c',Json.serialize(listRBlineitems));
    rbrefList.add(rbRefParams);
    RB_Reference__c rbRef = (RB_Reference__c) DataLoaderUtil.createObject('RB_Reference__c', true,rbRefParams);
    
    List<RB_Reference__c> rbRefList1 = DataLoaderUtil.createObjects('RB_Reference__c', true, 2, rbrefList); 
    
    String roId = [Select Id, Name, RO_ID__c from RB_Reference__c where RO_Name__c='RO1' LIMIT 1].RO_ID__c;
    
    RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];     
    Map<String, Object> opptyParams = new Map<String, Object>();
    opptyParams.put('Name', REC_OPP_NAME);
    opptyParams.put('AccountId', acc.id);
    opptyParams.put('RecordTypeId',Rec.Id);
    opptyParams.put('CloseDate',system.today().addDays(30));
    opptyParams.put('StageName',  'Negotiation'); 
    opptyParams.put('OwnerId', user.Id);    
    opptyParams.put('Actual_Bid_Submission_Date_Comm__c',  system.today().addDays(1));  
    opptyParams.put('Requested_Bid_Submission_Date_Comm__c',  system.today().addDays(3));  
    opptyParams.put('RB_Reference_ID__c',roId); 
    opptyParams.put('End_User_Project__c',  endUser.Id); 
    opptyParams.put('ABB_Location__c', APTS_LP_TestUtility.getABBLocation().id);
    ClsTriggerFactory.isSkipOpptyTrigger = true;   
    ClsTriggerFactory.isSkipOpptyTrigger = true;
    Opportunity o1 = (Opportunity) DataLoaderUtil.createObject('Opportunity', true, opptyParams);*/
       
    Map<String, Object> cmcParams = new Map<String, Object>();  
    cmcParams.put('name','Test Channel');
    //cmcParams.put('Primary_Channel_Class__c','Panel Builder (PBL)');
    //cmcParams.put('Secondary_Channel_Class_2__c','Distributor (DIS)');
    cmcParams.put('Division__c' , MasterDataManager.getActiveCode(Label.MDE_Division)); 
    cmcParams.put('Account__c',acc.id);
    ClsAccountUtil.isSkipMarketScopeTrigger = true;
    Channel_Market_Coverage__c cmc = (Channel_Market_Coverage__c) DataLoaderUtil.createObject('Channel_Market_Coverage__c',true,cmcParams);  
    
    Map<String, Object> jbp = new Map<String, Object>();    
    jbp.put('Channel_Market_Coverage__c',cmc.id);
    jbp.put('Account__c',acc.id);
    jbp.put('Status__c','Active');
    jbp.put('Start_Date__c', date.today());
    jbp.put('End_Date__c', date.today()+2);
    ClsAccountUtil.isSkipBusinessPlanTrigger = true;    
    Joint_Business_Plan__c jointBusPlan = (Joint_Business_Plan__c) DataLoaderUtil.createObject('Joint_Business_Plan__c',true,jbp); 
    
    Map<String, Object> campaingParams = new Map<String, Object>();
    campaingParams.put('Name', 'China Test Campaign');
    campaingParams.put('IsActive', true);
    campaingParams.put('Division__c',  MasterDataManager.getActiveCode(Label.MDE_Division)); 
    campaingParams.put('Type', 'Seminar');
    campaingParams.put('Country__c', 'China');
    campaingParams.put('Status', 'On Hold');    
    Campaign c = (Campaign)DataLoaderUtil.createObject('Campaign', true, campaingParams);    
    
    
    Id strRecordTypeId = [Select Id,name From RecordType Where SobjectType = 'Apttus_Proposal__Proposal__c' and Recordtype.DeveloperName = 'APTS_Frame_Agreement'].Id;
    Map<String, Object> proposalParams = new Map<String, Object>();
    proposalParams.put('Apttus_Proposal__Opportunity__c',oppy.id);
    proposalParams.put('Apttus_QPComply__MasterAgreementId__c',apts1.id);
    proposalParams.put('RecordTypeId' ,strRecordTypeId);
    proposalParams.put('APTS_Active_Version__c', TRUE);
    proposalParams.put('Apttus_Proposal__Primary__c',TRUE);
    ClsTriggerFactory.isSkipQuoteTrigger=false;
    APTS_ProposalTriggerHandler.ExecuteTriggers=false;
    Apttus_Proposal__Proposal__c proposal = (Apttus_Proposal__Proposal__c) DataLoaderUtil.createObject('Apttus_Proposal__Proposal__c', true, proposalParams);
    
    /*Map<String, Object> rbParams1 = DataLoaderUtil.createRecurringBusiness(oppy);
    Date startDate1 = Date.today();
    Date endDate1 = startDate.addDays(3);    
    rbParams1.put('Account_End_User__c',acc.id);
    rbParams1.put('All_Target_vs_All_Commit__c','Others');
    rbParams1.put('Award_Date__c',endDate1);    
    //rbParams1.put('BU__c',buDomain[2]);
    //rbParams1.put('Application__c',applnDomain[5]);
    rbParams1.put('ABB_Location__c',loc.id);    
    rbParams1.put('CurrencyIsoCode',oppy.CurrencyIsoCode);
    rbParams1.put('ChannelPartner_BusinessPlan__c',jointBusPlan.Id);
    rbParams1.put('End_Date__c',endDate1);
    rbParams1.put('End_User_Project__c',endUser.Id);
    rbParams1.put('Frequency__c','Monthly');
    rbParams1.put('Name',RB_NAME_CPBP);
    rbParams1.put('OwnerId',u2.Id);
    rbParams1.put('Parent__c',jointBusPlan.Id);
    rbParams1.put('Periods__c','1');
    rbParams1.put('Quantity__c',250.00);        
    rbParams1.put('Start_Date__c',startDate1);
    rbParams1.put('Status__c','In Progress');
    rbParams1.put('TotalRBValue__c',25000);
    rbParams1.put('Type__c','Value');
    rbParams1.put('Value__c',354528);
    rbParams1.put('BU_PickVal__c',buDomain[2]);    
    rbParams1.put('Application_PickVal__c',applnDomain[5]);
    rbParams1.put('ABB_Domain_PickVal__c',oppy.ABB_Domain__c);
    rbParams1.put('Business_Line_PickVal__c',oppy.Business_Line__c);
    rbParams1.put('Channel_Class_Level1_PickVal__c',oppy.Channel_Class_Level1__c);
    rbParams1.put('Channel_Class_Level2_Pickval__c',oppy.Channel_Class_Level2__c);
    rbParams1.put('Industry_Usage_Level1_PickVal__c',oppy.ABB_Industry_Usage_Level1__c);
    rbParams1.put('Industry_Usage_Level2_PickVal__c',oppy.ABB_Industry_Usage_Level2__c);
    rbParams1.put('Industry_Usage_Level3_PickVal__c',oppy.ABB_Industry_Usage_Level3__c); 
    ClsTriggerFactory.isSkipRBTrigger = true;
    Recurring_Business__c rbObj1 = (Recurring_Business__c) DataLoaderUtil.createObject('Recurring_Business__c', true, rbParams1);
    
    List<Map<String, Object>> rbrefList2 = new List<Map<String, Object>>();

    Map<String, Object> rbRefParams2 = new Map<String, Object>();        
    rbRefParams2.put('EAD__c',system.today().addDays(30));
    rbRefParams2.put('RO_Name__c','RO1');
    rbRefParams2.put('Fulfill__c','Yes');
    rbRefParams2.put('Total_Value__c',1100);
    rbRefParams2.put('RB_ID__c',rbobj1.id);
    rbRefParams2.put('Reason_For_Cancellation__c','Political decision');    
    rbRefParams2.put('Status__c','Draft'); 
    rbRefParams2.put('Products_1__c',Json.serialize(listRBlineitems));
    rbRefParams2.put('Products_2__c',Json.serialize(listRBlineitems));
    rbrefList2.add(rbRefParams2);
    RB_Reference__c rbRefr1 = (RB_Reference__c) DataLoaderUtil.createObject('RB_Reference__c', true,rbRefParams2);
    
    Map<String, Object> rbRefParams3 = new Map<String, Object>();        
    rbRefParams3.put('EAD__c',system.today().addDays(30));
    rbRefParams3.put('RO_Name__c','RO2');
    rbRefParams3.put('Fulfill__c','No');
    rbRefParams3.put('Total_Value__c',1100);
    rbRefParams3.put('RB_ID__c',rbobj.id);
    rbRefParams3.put('Reason_For_Cancellation__c','Political decision');    
    rbRefParams3.put('Status__c','Draft'); 
    rbRefParams3.put('Products_1__c',Json.serialize(listRBlineitems));
    rbRefParams3.put('Products_2__c',Json.serialize(listRBlineitems));
    rbrefList2.add(rbRefParams3);
    RB_Reference__c rbRef1 = (RB_Reference__c) DataLoaderUtil.createObject('RB_Reference__c', true,rbRefParams3);*/
 }
    
    public static testmethod void controller_Test(){   
        
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
        Opportunity oppy = [SELECT id,Name,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Opportunity recOppy = [SELECT id,Name,StageName,RB_Reference_ID__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];              
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];        
        
        Test.StartTest();                
        RecurringBusinessController.createRecurringOpportunity(rb.Id,'Opportunity');
        RecurringBusinessController.updateRO(rb.Id);
        RecurringBusinessController.cancelRBByUser(rb.Id,'',false);
        RecurringBusinessController.processReopenRB(rb.Id,oppy.Id,'Opportunity');
        RecurringBusinessController.processReopenRB(rb.Id,acc.Id,'Account');
        RecurringBusinessController.processReopenRB(rb.Id,jbp.Id,'CPBP');                       
        Test.StopTest(); 
        
        
    }  
     public static testmethod void updateRBRef(){   
        
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
        Opportunity oppy = [SELECT id,Name,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Opportunity recOppy = [SELECT id,Name,StageName,RB_Reference_ID__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];              
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];
        
        Test.StartTest();       
        RecurringBusinessController.updateRBReferenceAndSyncRO(lstrbref);       
        RecurringBusinessController.fetchSchedulePeriod();        
        RecurringBusinessController.updateRBReference(JSON.serialize(lstrbref));
        RecurringBusinessController.updateRecurringBusinessObject(rb,rb.Id);
        RecurringBusinessController.getDependentOptionsImpl('','','');                 
        Test.StopTest(); 
        
        
    }  
     public static testmethod void refreshSplit(){   
        
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
        Opportunity oppy = [SELECT id,Name,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Opportunity recOppy = [SELECT id,Name,StageName,RB_Reference_ID__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];              
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];
        
        
        Test.StartTest();        
        RecurringBusinessController.refreshSplitTable(oppy.Id,rb.Id,'Opportunity',rb);
        RecurringBusinessController.refreshSplitTable(acc.Id,rb.Id,'Account',rb);
        RecurringBusinessController.refreshSplitTable(jbp.Id,rb.Id,'CPBP',rb);             
        Test.StopTest();        
        
    }  
    
    public static testmethod void getAllROs_Test(){
        User u = [SELECT Id, Name FROM User WHERE Name = 'SalesUser' LIMIT 1];  
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];   
        Opportunity recOppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];       
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];       
        System.runas(u){
        Test.StartTest();        
        RecurringBusinessController.fetchCancellationReasons();
        RecurringBusinessController.getAllROsForRB(rb.Id);
        RecurringBusinessController.getRBDetails(rb.Id);
        RecurringBusinessController.getExistingRBRefData(rb.Id);
        RecurringBusinessController.fetchCancellationReasonsFromSourceOpp();                  
        Test.StopTest();
        }
        
        }
    public static testmethod void getProductSplit_Test(){
        User u = [SELECT Id, Name FROM User WHERE Name = 'SalesUser' LIMIT 1];   
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
        Opportunity recOppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];        
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];        
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];       
        System.runas(u){
        Test.StartTest();          
        RecurringBusinessController.getProductSplitFullFillData(oppy.Id,rb.Id,'Opportunity');
        RecurringBusinessController.getProductSplitFullFillData(acc.Id,rb.Id,'Account');
        RecurringBusinessController.getProductSplitFullFillData(jbp.Id,rb.Id,'CPBP');       
        RecurringBusinessController.getProductSplitPageLoad(oppy.Id,rb.Id,'Opportunity');
        RecurringBusinessController.getProductSplitPageLoad(acc.Id,rb.Id,'Account');
        RecurringBusinessController.getProductSplitPageLoad(jbp.Id,rb.Id,'CPBP');            
        Test.StopTest();
        }
        
        }
    public static testmethod void getRefreshedData_Test(){
            User u = [SELECT Id, Name FROM User WHERE Name = 'SalesUser' LIMIT 1];   
            RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
            Opportunity recOppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
            WHERE RecordTypeId =: Rec.Id LIMIT 1];
            Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
            Recurring_Business__c rb = [SELECT Id,Source_Agreement__c,BU_PickVal__c,Application_PickVal__c,ABB_Domain_PickVal__c,Business_Line_PickVal__c,Channel_Class_Level1_PickVal__c,Channel_Class_Level2_Pickval__c,Industry_Usage_Level1_PickVal__c,Industry_Usage_Level2_PickVal__c,Industry_Usage_Level3_PickVal__c,ABB_Domain__c, ABB_Industry_Usage_Level1__c, ABB_Industry_Usage_Level2__c, ABB_Industry_Usage_Level3__c, ABB_Location__c, Account_Customer__c, Account_End_User__c, All_Target_vs_All_Commit__c, Application__c, Award_Date__c, Business_Line__c, BU__c, Channel_Class_Level1__c, Channel_Class_Level2__c, CreatedById, CreatedDate, CurrencyIsoCode, End_Date__c, End_User_Project__c, Frequency__c, IsDeleted, LastModifiedById, LastModifiedDate, Name, Opportunity__c, OwnerId, Parent__c, Periods__c, Quantity__c, Start_Date__c, Status__c, SystemModstamp, TotalRBValue__c, Type__c, Value__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
            Account acc = [SELECT Id FROM Account LIMIT 1];        
            Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];        
            List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];       
            System.runas(u){
            Test.StartTest();            
            //RecurringBusinessController.getRefreshedData(oppy.Id,rb.Id,'Opportunity');
            RecurringBusinessController.getRefreshedData(acc.Id,rb.Id,'Account');
            RecurringBusinessController.getRefreshedData(jbp.Id,rb.Id,'CPBP');
            RecurringBusinessController.checkForScopeChange(rb.Id,oppy.Id,'Opportunity');
            RecurringBusinessController.checkForScopeChange(rb.Id,acc.Id,'Account');
            RecurringBusinessController.checkForScopeChange(rb.Id,jbp.Id,'CPBP');
            RecurringBusinessController.getPreviewData(oppy.Id,rb.Id);              
            Test.StopTest();
        
        }
        
    }
    public static testmethod void getRBRefData_test(){
            User u = [SELECT Id, Name FROM User WHERE Name = 'SalesUser' LIMIT 1]; 
            RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];    
            Opportunity recOppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
            WHERE RecordTypeId =: Rec.Id LIMIT 1];
            Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
            Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
            Account acc = [SELECT Id FROM Account LIMIT 1];        
            Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];        
            List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];       
            System.runas(u){
            Test.StartTest();           
            RecurringBusinessController.getExistingRBRefData(rb.Id);
            RecurringBusinessController.updateRBStatusBasedOnRO(rb.Id,rb);
            RecurringBusinessController.syncRBAndROOwners(rb.Id);
            RecurringBusinessController.checkForMissingABBLocOnOppLineItems(oppy.id);
            RecurringBusinessController.checkForMissingABBLocOnOppLineItems(acc.id);
            RecurringBusinessController.checkForMissingABBLocOnOppLineItems(jbp.id);        
            Test.StopTest();
        
        }
        
    }
     public static testmethod void updateRBStatus(){
     
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Apttus__APTS_Agreement__c agmt = [SELECT Id,Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement'];
        Account acc = [SELECT Id FROM Account LIMIT 1];              
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];        
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];
        String myString = JSON.serialize(rb);
        String  myString1 = JSON.serialize(lstrbref);
        
        oppy.StageName = 'Closed Lost (Cancelled)';
        ClsTriggerFactory.isSkipOpptyTrigger = true;    
        update oppy;
        
        Test.StartTest();
        RecurringBusinessController.updateRBStatusBasedOnRO(rb.Id,rb);
        oppy.StageName = 'Closed Won';
        ClsTriggerFactory.isSkipOpptyTrigger = true;
        update oppy;
        agmt.Apttus__Status_Category__c = 'In Effect';
        clsAgreementHelper_CLM.IsExecuted = true; 
        update agmt;
        clsAgreementHelper_CLM.IsExecuted = false; 
        
        RecurringBusinessController.updateRBStatusBasedOnRO(rb.Id,rb);
        RecurringBusinessController.getOnLoadData(oppy.Id,rb.Id,'Opportunity');
        RecurringBusinessController.getOnLoadData(acc.Id,rb.Id,'Account');
        RecurringBusinessController.getOnLoadData(jbp.Id,rb.Id,'CPBP');       
        RecurringBusinessController.processCreateRO(rb.Id,oppy.Id,'Opportunity',myString);
        RecurringBusinessController.processCreateRO(rb.Id,acc.Id,'Account',myString);
        RecurringBusinessController.processCreateRO(rb.Id,jbp.Id,'CPBP',myString);          
        Test.StopTest();
        System.assertEquals(agmt.Apttus__Status_Category__c,'In Effect');
    }
     public static testmethod void processUpdateRO_Test(){
     
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Apttus__APTS_Agreement__c agmt = [SELECT Id,Name,Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement'];
        Account acc = [SELECT Id FROM Account LIMIT 1];              
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];       
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,RB_ID__c,Fulfill__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];
        lstrbref [0].Fulfill__c = 'No';
        update lstrbref ;
        String myString = JSON.serialize(rb);
        String  myString1 = JSON.serialize(lstrbref);  
        
        Test.StartTest();        
        RecurringBusinessController.processUpdateRO(rb.Id,'In Progress',oppy.Id,'Opportunity',myString,myString1); 
        RecurringBusinessController.processUpdateRO(rb.Id,'In Progress',acc.Id,'Account',myString,myString1); 
        RecurringBusinessController.processUpdateRO(rb.Id,'In Progress',jbp.Id,'CPBP',myString,myString1);       
        Test.StopTest();
        
    }
    public static testmethod void processUpdateRO_Test1(){
     
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];  
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1];         
        Account acc = [SELECT Id FROM Account LIMIT 1];              
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];        
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,Fulfill__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];         
        lstrbref [0].Fulfill__c = 'No';
        update lstrbref ;
        String myString = JSON.serialize(rb);
        String  myString1 = JSON.serialize(lstrbref); 
        Test.StartTest();        
        RecurringBusinessController.processUpdateRO(rb.Id,'Draft',oppy.Id,'Opportunity',myString,myString1); 
        RecurringBusinessController.processUpdateRO(rb.Id,'Draft',acc.Id,'Account',myString,myString1); 
        RecurringBusinessController.processUpdateRO(rb.Id,'Draft',jbp.Id,'CPBP',myString,myString1);        
        Test.StopTest();
    }
    
    public static testmethod void fetchLookUpVal_Test(){
        User u = [SELECT Id, Name FROM User WHERE Name = 'SalesUser' LIMIT 1];  
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];        
        Opportunity recOppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];              
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];      
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,Fulfill__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];  
        
        System.runas(u){
        Test.StartTest();
        RecurringBusinessController.fetchLookUpValues('test','Product_Group__c'); 
        RecurringBusinessController.fetchLookUpValues('test','End_User_Project__c');         
        RecurringBusinessController.fetchLookUpValues('test','Campaign');         
        RecurringBusinessController.fetchLookUpValues('test','Recurring_Business__c');       
        RecurringBusinessController.fetchLocationLookUpValues('test','Product_Group__c');   
        RecurringBusinessController.fetchLocationLookUpValues('test','ABB_Location__c');    
        RecurringBusinessController.fetchLocationLookUpValues('test','End_User_Project__c');    
        RecurringBusinessController.fetchLocationLookUpValues('test','Opportunity');            
        Test.StopTest();
        }
        
    }
    public static testmethod void updateRBRefWithStatus_Test(){     
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];             
        Opportunity recOppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Recurring_Business__c rb = [SELECT id,BU__c,OwnerId,Target__c,Commit__c,Account_Customer__c,Campaign__c,Source_Agreement__c,Frequency__c,ABB_Domain__c,Application__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,Business_Line__c,Name,End_Date__c,Periods__c,TotalRBValue__c,Channel_Class_Level1__c,Channel_Class_Level2__c,ABB_Location__c,Account_End_User__c,End_User_Project__c,Offering_Primary_PG__c,Start_Date__c,Status__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,Fulfill__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];  
        lstrbref[0].Fulfill__c = 'No';
        update lstrbref;
        
        Test.StartTest();     
        RecurringBusinessController.updateRBRefWithStatusAndROName(lstrbref,rb);
        Test.StopTest();     
        
    }
    public static testmethod void getExistingRB_Test(){
        User u = [SELECT Id, Name FROM User WHERE Name = 'SalesUser' LIMIT 1];   
        RecordType Rec = [Select Id,Name From RecordType WHERE DeveloperName = 'Recurring_Opportunity'];       
        Opportunity recOppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity //WHERE Name =: REC_OPP_NAME 
        WHERE RecordTypeId =: Rec.Id LIMIT 1];
        Opportunity oppy = [SELECT id,Name,OwnerId,StageName,Main_Reason_For_Close__c FROM Opportunity WHERE Name =: OPP_NAME LIMIT 1];
        Joint_Business_Plan__c jbp = [SELECT Id,Status__c,Account__c FROM Joint_Business_Plan__c LIMIT 1];
        Recurring_Business__c rb = [SELECT Id,Name, BU_PickVal__c,Application_PickVal__c,ABB_Domain_PickVal__c,Business_Line_PickVal__c,Channel_Class_Level1_PickVal__c,Channel_Class_Level2_Pickval__c,Industry_Usage_Level1_PickVal__c,Industry_Usage_Level2_PickVal__c,Industry_Usage_Level3_PickVal__c,ABB_Domain__c, ABB_Industry_Usage_Level1__c, ABB_Industry_Usage_Level2__c, ABB_Industry_Usage_Level3__c, ABB_Location__c, Account_Customer__c, Account_End_User__c, All_Target_vs_All_Commit__c, Application__c, Award_Date__c, Business_Line__c, BU__c, Channel_Class_Level1__c, Channel_Class_Level2__c, CreatedById, CreatedDate, CurrencyIsoCode, End_Date__c, End_User_Project__c, Frequency__c,IsDeleted, LastModifiedById, LastModifiedDate, Opportunity__c, OwnerId, Parent__c, Periods__c, Quantity__c, Start_Date__c, Status__c, SystemModstamp, TotalRBValue__c, Type__c, Value__c FROM Recurring_Business__c WHERE Name =: RB_NAME LIMIT 1 ]; 
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<RB_Reference__c> lstrbref = [SELECT Id,Name,Status__c,Fulfill__c,RB_ID__c,RO_Name__c,RO_Custom_Name__c,EAD__c FROM RB_Reference__c LIMIT 2];
        System.runas(u){
        Test.StartTest();           
        //RecurringBusinessController.getExistingRBData(rb.Id);
        RecurringBusinessController.getOnLoadData(oppy.Id,'','Opportunity');
        RecurringBusinessController.getOnLoadData(acc.Id,'','Account');
        RecurringBusinessController.getOnLoadData(jbp.Id,'','CPBP'); 
        Test.StopTest();
        }
        
    }
}