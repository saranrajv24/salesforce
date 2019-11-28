@isTest(SeeAllData = false)
public class APTS_ABB_LP_SAP_Integration_Util_Test {
   
    private static Apttus_Config2__ProductConfiguration__c oProductConfig;
    private static APTS_GenericGetSAPPricingController objGetPricing;
   
    private static Apttus_Proposal__Proposal__c oProposal;
    private static Apttus__APTS_Agreement__c oAgreement;
    static Apttus_Config2__PriceList__c testPriceList;
    
//    public static Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];   
    private static List<APTS_Common_Config_Settings__c> lstCommonConfigCustomSettings;
    public static  Id userRoleId   = [SELECT Id FROM UserRole WHERE Name = 'ABB>CRM/SystemAdmin'].Id;

            
    public static testmethod void testMSPAIntegration() {
        
        User user = APTS_LP_TestUtility.getAdminUser('Spain','es_ES','EP');
        ClsTriggerFactory.isExecuteUserTrigger = false;
        insert user;
        System.runAs(user) {
            lstCommonConfigCustomSettings = APTS_PG_TEST_Utility.createCustomSettingData();
            insert lstCommonConfigCustomSettings;
        
            APTS_LP_TestUtility.getsapintegrationlist(); 
            APTS_LP_TestUtility.getsubtypelst ();
            APTS_LP_TestUtility.getDiscountConfig();
            APTS_LP_TestUtility.getCustomSetting_QuoteNProposal();
            APTS_LP_TestUtility.getCommonConfigSetting();
            APTS_LP_TestUtility.getSAPIntegrationTokens();
            APTS_LP_TestUtility.mspaRefData('Spain');
            APTS_LP_TestUtility.mspaRefData('France');
            APTS_LP_TestUtility.mspaRefData('Italy');
            APTS_LP_TestUtility.getCountryDefaults();
            
            Account acc = APTS_LP_TestUtility.getNewAccount('Apttus Inc','Spain');
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GIS Approved').getRecordTypeId();
            acc.ShippingCountry='Spain';
            acc.ShippingState = 'Araba';            
            acc.ShippingStreet= 'XYSFH';
            acc.ShippingCity= 'Valencia';
            acc.ShippingPostalCode='A122222';
            ClsAccountUtil.isAccMergeFlag = true;
            ClsAccountUtil.isUpdate = false;
            insert acc;
                      
            Opportunity oppy = new Opportunity();
            oppy.AccountId = acc.Id;
            oppy.recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Initial').getRecordTypeId();
            oppy.Name = 'TestOpportunity';
            oppy.StageName = 'Prospecting';
            oppy.CloseDate = system.today();
            oppy.Customer_Buying_Path__c = 'Awareness';
            oppy.Sales_Pursuit_Progress__c = 'Opportunity Is Captured';
            oppy.ABB_Location__c = APTS_LP_TestUtility.getABBLocation().id;     
            ClsTriggerFactory.isSkipOpptyTrigger=true;        
            insert oppy;
            
            oAgreement = APTS_LP_TestUtility.getAgreement('Test Agreement');
            oAgreement.APTS_LP_AccountCustomer__c = acc.Id;            
            oAgreement.APTS_SAP_Customer_ID__c = '0080003494';
            oAgreement.Apttus__Contract_Start_Date__c = System.today();
            oAgreement.Apttus__Contract_End_Date__c = System.today().addDays(2);
            oAgreement.APTS_Max_Order_Amount__c = 123.45;
            insert oAgreement;
            
            oProductConfig = APTS_LP_TestUtility.getProductConfiguration('Test');
            oProductConfig.Apttus_CMConfig__AgreementId__c = oAgreement.id;
            
            insert oProductConfig;
            
            Product2 product = APTS_LP_TestUtility.getProduct();
            product.APTS_Hierarchy_Level_3_Code__c ='00996';
            product.APTS_Product_ID__c = '1SDA052340R1';
            product.APTS_LP_Is_Hierarchy__c = true;
            product.APTS_LP_Product_Hierarchy__c='1SDA052340R1';
            insert product;
            
            List<Apttus_Config2__LineItem__c> listLineItem = APTS_LP_TestUtility.getLineItemListWithPriceOveride(oProductConfig.id,2,product,100);
            insert listLineItem;
            
            List<Apttus__AgreementLineItem__c> listALI = APTS_LP_TestUtility.getAgreementLineItemList(oAgreement.Id, 1);
            listALI[0].Apttus_CMConfig__ConfigurationId__c = oProductConfig.Id;
            listALI[0].Apttus_CMConfig__DerivedFromId__c = listLineItem[0].Id;
            listALI[0].Apttus_CMConfig__ItemSequence__c = 1;
            listALI[0].Apttus_CMConfig__LineNumber__c = 1;
            listALI[0].Apttus__ProductId__c = product.Id;
            listALI[0].Apttus__ListPrice__c = 15;
            listALI[0].Apttus__NetPrice__c = 15;
            listALI[0].Apttus__Quantity__c = 1;
            listALI[0].APTS_Discount_Type__c = 'Substitute Discount';
            listALI[0].APTS_Discount_Percentage__c = 10;
            insert listALI;
            
            oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
            
            
            oAgreement = [Select Id, (Select Id from Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c limit 1];
            System.assert(oAgreement.Apttus__AgreementLineItems__r.size() > 0);                
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new APTPS_SAPCalloutMockTest());
            
            APTS_ABB_SAPIntegrationServiceBaseImpl mspaIntObject = new APTS_ABB_SAPIntegrationServiceBaseImpl();
            mspaIntObject.invoke(oAgreement.Id, 'true'); 
            APTS_ABB_LP_SAP_Integration_Util.getSasToken();
            Test.stopTest();
            
        }
    }
    public static testmethod void testMSPAIntegration_Net() {
        
        User user = APTS_LP_TestUtility.getAdminUser('Spain','es_ES','EP');
        ClsTriggerFactory.isExecuteUserTrigger = false;
        insert user;
        System.runAs(user) {
            lstCommonConfigCustomSettings = APTS_PG_TEST_Utility.createCustomSettingData();
            insert lstCommonConfigCustomSettings;
        
            APTS_LP_TestUtility.getsapintegrationlist(); 
            APTS_LP_TestUtility.getsubtypelst();          
            APTS_LP_TestUtility.getDiscountConfig();
            APTS_LP_TestUtility.getCustomSetting_QuoteNProposal();
            APTS_LP_TestUtility.getCommonConfigSetting();
            APTS_LP_TestUtility.getSAPIntegrationTokens();
            APTS_LP_TestUtility.mspaRefData('Spain');
            APTS_LP_TestUtility.mspaRefData('France');
            APTS_LP_TestUtility.mspaRefData('Italy');
            APTS_LP_TestUtility.getCountryDefaults();
            
            Account acc = APTS_LP_TestUtility.getNewAccount('Apttus Inc','Spain');
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GIS Approved').getRecordTypeId();
            acc.ShippingCountry='Spain';
            acc.ShippingState = 'Araba';            
            acc.ShippingStreet= 'XYSFH';
            acc.ShippingCity= 'Valencia';
            acc.ShippingPostalCode='A122222';
            ClsAccountUtil.isAccMergeFlag = true;
            ClsAccountUtil.isUpdate = false;
            insert acc;
                      
            Opportunity oppy = new Opportunity();
            oppy.AccountId = acc.Id;
            oppy.recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Initial').getRecordTypeId();
            oppy.Name = 'TestOpportunity';
            oppy.StageName = 'Prospecting';
            oppy.CloseDate = system.today();
            oppy.Customer_Buying_Path__c = 'Awareness';
            oppy.Sales_Pursuit_Progress__c = 'Opportunity Is Captured';
            oppy.ABB_Location__c = APTS_LP_TestUtility.getABBLocation().id;   
            ClsTriggerFactory.isSkipOpptyTrigger=true;        
            insert oppy;
            
            oAgreement = APTS_LP_TestUtility.getAgreement('Test Agreement');
            oAgreement.APTS_LP_AccountCustomer__c = acc.Id;            
            oAgreement.APTS_SAP_Customer_ID__c = '0080003494';
            oAgreement.Apttus__Contract_Start_Date__c = System.today();
            oAgreement.Apttus__Contract_End_Date__c = System.today().addDays(2);
            oAgreement.APTS_Max_Order_Amount__c = 123.45;
            insert oAgreement;
            
            oProductConfig = APTS_LP_TestUtility.getProductConfiguration('Test');
            oProductConfig.Apttus_CMConfig__AgreementId__c = oAgreement.id;
            
            insert oProductConfig;
            
            Product2 product = APTS_LP_TestUtility.getProduct();
            product.APTS_Hierarchy_Level_3_Code__c ='00996';
            product.APTS_Product_ID__c = '1SDA052340R1';
            product.APTS_LP_Is_Hierarchy__c = true;
            product.APTS_LP_Product_Hierarchy__c='1SDA052340R1';
            insert product;
            
            List<Apttus_Config2__LineItem__c> listLineItem = APTS_LP_TestUtility.getLineItemListWithPriceOveride(oProductConfig.id,2,product,100);
            insert listLineItem;
            
            List<Apttus__AgreementLineItem__c> listALI = APTS_LP_TestUtility.getAgreementLineItemList(oAgreement.Id, 1);
            listALI[0].Apttus_CMConfig__ConfigurationId__c = oProductConfig.Id;
            listALI[0].Apttus_CMConfig__DerivedFromId__c = listLineItem[0].Id;
            listALI[0].Apttus_CMConfig__ItemSequence__c = 1;
            listALI[0].Apttus_CMConfig__LineNumber__c = 1;
            listALI[0].Apttus__ProductId__c = product.Id;
            listALI[0].Apttus__ListPrice__c = 15;
            listALI[0].Apttus__NetPrice__c = 15;
            listALI[0].Apttus__Quantity__c = 1;
            listALI[0].APTS_Discount_Type__c = 'Net Price';
            listALI[0].APTS_Discount_Percentage__c = 10;
            insert listALI;
            
            oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
            
              
            oAgreement = [Select Id,APTS_Country__c, (Select Id from Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c limit 1];
            System.assert(oAgreement.Apttus__AgreementLineItems__r.size() > 0);    
             
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new APTPS_SAPCalloutMockTest());
            
            APTS_ABB_SAPIntegrationServiceBaseImpl mspaIntObject = new APTS_ABB_SAPIntegrationServiceBaseImpl();
            mspaIntObject.invoke(oAgreement.Id, 'true'); 
            APTS_ABB_LP_SAP_Integration_Util.getSasToken();
            Test.stopTest();
            
        }
    }   
    public static testmethod void testMSPAIntegration_AB() {
        User user = APTS_LP_TestUtility.getAdminUser('Spain','es_ES','EP');
        ClsTriggerFactory.isExecuteUserTrigger = false;
        insert user;
        System.runAs(user) {
            lstCommonConfigCustomSettings = APTS_PG_TEST_Utility.createCustomSettingData();
            insert lstCommonConfigCustomSettings;
            APTS_LP_TestUtility.getsapintegrationlist(); 
            APTS_LP_TestUtility.getsubtypelst ();           
            APTS_LP_TestUtility.getDiscountConfig();
            APTS_LP_TestUtility.getCustomSetting_QuoteNProposal();
            APTS_LP_TestUtility.getCommonConfigSetting();
            APTS_LP_TestUtility.getSAPIntegrationTokens();
            APTS_LP_TestUtility.mspaRefData('Spain');
            APTS_LP_TestUtility.mspaRefData('France');
            APTS_LP_TestUtility.mspaRefData('Italy');
            APTS_LP_TestUtility.getCountryDefaults();
            
            Account acc = APTS_LP_TestUtility.getNewAccount('Apttus Inc','Spain');
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GIS Approved').getRecordTypeId();
            acc.ShippingCountry='Spain';
            acc.ShippingState = 'Araba';            
            acc.ShippingStreet= 'XYSFH';
            acc.ShippingCity= 'Valencia';
            acc.ShippingPostalCode='A122222';
            ClsAccountUtil.isAccMergeFlag = true;
            ClsAccountUtil.isUpdate = false;
            insert acc;
                      
            Opportunity oppy = new Opportunity();
            oppy.AccountId = acc.Id;
            oppy.recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Initial').getRecordTypeId();
            oppy.Name = 'TestOpportunity';
            oppy.StageName = 'Prospecting';
            oppy.CloseDate = system.today();
            oppy.Customer_Buying_Path__c = 'Awareness';
            oppy.Sales_Pursuit_Progress__c = 'Opportunity Is Captured';
            oppy.ABB_Location__c = APTS_LP_TestUtility.getABBLocation().id;             
            insert oppy;
            
            oAgreement = APTS_LP_TestUtility.getAgreement('Test Agreement');
            oAgreement.APTS_LP_AccountCustomer__c = acc.Id;            
            oAgreement.APTS_SAP_Customer_ID__c = '0080003494';
            oAgreement.Apttus__Contract_Start_Date__c = System.today();
            oAgreement.Apttus__Contract_End_Date__c = System.today().addDays(2);
            oAgreement.APTS_Max_Order_Amount__c = 123.45;
            
            insert oAgreement;
            
            oProductConfig = APTS_LP_TestUtility.getProductConfiguration('Test');
            oProductConfig.Apttus_CMConfig__AgreementId__c = oAgreement.id;
            
            insert oProductConfig;
            
            Product2 product = APTS_LP_TestUtility.getProduct();
            product.APTS_Hierarchy_Level_3_Code__c ='00996';
            product.APTS_Product_ID__c = '1SDA052340R1';
            product.APTS_LP_Is_Hierarchy__c = true;
            product.APTS_LP_Product_Hierarchy__c='1SDA052340R1';
            insert product;
            
            List<Apttus_Config2__LineItem__c> listLineItem = APTS_LP_TestUtility.getLineItemListWithPriceOveride(oProductConfig.id,2,product,100);
            insert listLineItem;
            
            List<Apttus__AgreementLineItem__c> listALI = APTS_LP_TestUtility.getAgreementLineItemList(oAgreement.Id, 1);
            listALI[0].Apttus_CMConfig__ConfigurationId__c = oProductConfig.Id;
            listALI[0].Apttus_CMConfig__DerivedFromId__c = listLineItem[0].Id;
            listALI[0].Apttus_CMConfig__ItemSequence__c = 1;
            listALI[0].Apttus_CMConfig__LineNumber__c = 1;
            listALI[0].Apttus__ProductId__c = product.Id;
            listALI[0].Apttus__ListPrice__c = 15;
            listALI[0].Apttus__NetPrice__c = 15;
            listALI[0].Apttus__Quantity__c = 1;
            listALI[0].APTS_Discount_Type__c = 'Additional Discount';
            listALI[0].APTS_Discount_Percentage__c = 10;
            insert listALI;
            
            oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
         
            
            oAgreement = [Select Id, (Select Id from Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c limit 1];
            System.assert(oAgreement.Apttus__AgreementLineItems__r.size() > 0);                
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new APTPS_SAPCalloutMockTest());
            
            APTS_ABB_SAPIntegrationServiceBaseImpl mspaIntObject = new APTS_ABB_SAPIntegrationServiceBaseImpl();
            mspaIntObject.invoke(oAgreement.Id, 'true'); 
            APTS_ABB_LP_SAP_Integration_Util.getSasToken();
            Test.stopTest();
            
        }
    } 
    
    public static testmethod void testMSPAIntegrationBlockCode() {
        
        User user = APTS_LP_TestUtility.getAdminUser('Spain','es_ES','EP');
        ClsTriggerFactory.isExecuteUserTrigger = false;
        insert user;
        System.runAs(user) {
            APTS_LP_TestUtility.SAPMSPACreationTokens(); 
            APTS_LP_TestUtility.getsapOAuthToken(); 
            APTS_LP_TestUtility.getDiscountConfig();
            APTS_LP_TestUtility.getCustomSetting_QuoteNProposal();
            APTS_LP_TestUtility.getCommonConfigSetting();
            APTS_LP_TestUtility.mspaRefData('Spain');
            APTS_LP_TestUtility.mspaRefData('France');
            APTS_LP_TestUtility.mspaRefData('Italy');
            
            Account acc = APTS_LP_TestUtility.getNewAccount('Apttus Inc','Spain');
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GIS Approved').getRecordTypeId();
            acc.ShippingCountry='Spain';
            acc.ShippingState = 'Araba';            
            acc.ShippingStreet= 'XYSFH';
            acc.ShippingCity= 'Valencia';
            acc.ShippingPostalCode='A122222';
            ClsAccountUtil.isAccMergeFlag = true;
            ClsAccountUtil.isUpdate = false;
            insert acc;
                      
            Opportunity oppy = new Opportunity();
            oppy.AccountId = acc.Id;
            oppy.recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Initial').getRecordTypeId();
            oppy.Name = 'TestOpportunity';
            oppy.StageName = 'Prospecting';
            oppy.CloseDate = system.today();
            oppy.Customer_Buying_Path__c = 'Awareness';
            oppy.Sales_Pursuit_Progress__c = 'Opportunity Is Captured';
            oppy.ABB_Location__c = APTS_LP_TestUtility.getABBLocation().id;             
            insert oppy;
            
            oAgreement = APTS_LP_TestUtility.getAgreement('Test Agreement');
            oAgreement.APTS_LP_AccountCustomer__c = acc.Id;            
            oAgreement.APTS_SAP_Customer_ID__c = '0080003494';
            oAgreement.Apttus__Contract_Start_Date__c = System.today();
            oAgreement.Apttus__Contract_End_Date__c = System.today().addDays(2);
            insert oAgreement;
            
            system.assertEquals('Test Agreement',oAgreement.Name);
            oProductConfig = APTS_LP_TestUtility.getProductConfiguration('Test');
            oProductConfig.Apttus_CMConfig__AgreementId__c = oAgreement.id;
           
            
            insert oProductConfig;
            
            Product2 product = APTS_LP_TestUtility.getProduct();
            product.APTS_Hierarchy_Level_3_Code__c ='00996';
            product.APTS_Product_ID__c = '1SDA052340R1';
            insert product;
            
            List<Apttus_Config2__LineItem__c> listLineItem = APTS_LP_TestUtility.getLineItemListWithPriceOveride(oProductConfig.id,2,product,100);
            insert listLineItem;
            
            List<Apttus__AgreementLineItem__c> listALI = APTS_LP_TestUtility.getAgreementLineItemList(oAgreement.Id, 1);
            listALI[0].Apttus_CMConfig__ConfigurationId__c = oProductConfig.Id;
            listALI[0].Apttus_CMConfig__ItemSequence__c = 1;
            listALI[0].Apttus_CMConfig__LineNumber__c = 1;
            listALI[0].Apttus__ProductId__c = product.Id;
            listALI[0].Apttus__ListPrice__c = 15;
            listALI[0].Apttus__NetPrice__c = 15;
            listALI[0].Apttus__Quantity__c = 1;
            insert listALI;
            
        
            
            Test.startTest();
            
            
            APTS_ABB_SAPIntegrationServiceBaseImpl mspaIntObject = new APTS_ABB_SAPIntegrationServiceBaseImpl();
            mspaIntObject.invoke(oAgreement.Id, 'false');                      
            
            Test.stopTest();
            
        }
        
        
    }
    
    
    
    private static testmethod void testgetSASTokens(){
    
      User user = new User(alias = 'test123', email='test123+invalid@abb.com', emailencodingkey='UTF-8',UserRoleId = userRoleId,
                              lastname='Testing', languagelocalekey='fr', localesidkey='fr_FR', APTS_Locale__c = 'fr_FR',
                              profileid = APTS_LP_TestUtility.getAdminProfile().Id, country = 'France', countryCode = 'FR', IsActive = true,
                              Division = 'LP', Division_DIV__c = 'LP', timezonesidkey='America/Los_Angeles',
                              username = 'test123+invalid@abb.com' );
        ClsTriggerFactory.isExecuteUserTrigger = false;
        insert user;
        System.runAs(user) {
        lstCommonConfigCustomSettings = APTS_PG_TEST_Utility.createCustomSettingData();
        insert lstCommonConfigCustomSettings;
        
        APTS_Master_Picklist_Table__c localChannel = new APTS_Master_Picklist_Table__c();
            
        localChannel.Name = 'Distribution General';
        localChannel.APTS_Code__c = 'P5';
        localChannel.APTS_Code_Description__c = 'Distribution General';
        localChannel.APTS_Code_Used_For__c = 'Local Channel';
        localChannel.APTS_Locale__c = 'fr_FR';
        localChannel.APTS_Country__c = 'France';
        insert localChannel;
        
        APTS_LP_TestUtility.getCommonConfigSetting();
        APTS_LP_TestUtility.getCustomSetting_QuoteNProposal();
        APTS_LP_TestUtility.mspaRefData('France');
        APTS_LP_TestUtility.getCountryDefaults();    
        APTS_LP_TestUtility.getIntegrationParameters();
        APTS_LP_TestUtility.getSAPIntegrationTokens();
        APTS_LP_TestUtility.getCommonConfigSetting();
        APTS_LP_TestUtility.getLODConfigSetting();
        
        APTS_Country_Defaults__c cd=[Select id,APTS_DefaultProductDiscSAP__c from APTS_Country_Defaults__c where Name='France' Limit 1];
        cd.APTS_DefaultProductDiscSAP__c ='N';
        update cd;
        LSO_Field_Entries__c salesOffice = new LSO_Field_Entries__c();
        salesOffice.Active__c = TRUE;
        salesOffice.PickList_Code__c = 'Z111';
        salesOffice.PickList_Description__c = 'BT/Niessen Barcelona';
        salesOffice.Controlling_Field__c = 'LSO Reference Data.Country';
        salesOffice.Value__c = 'France';
        salesOffice.Country__c = 'France';
        salesOffice.LSO_Pick_List_Value_Name__c = 'LSO Reference Data. Sales Office';
        salesOffice.Manual_Unique__c = 'Test9999';                
        insert salesOffice;
        
       List<APTS_Discounts_Config__c> listDiscountConfig = new List<APTS_Discounts_Config__c>();
        APTS_Discounts_Config__c quoteConfig = new APTS_Discounts_Config__c();
        //quoteConfig.name = 'France/Quotation-LP/P5/LP';
        quoteConfig.APTS_Country__c = 'France';
        quoteConfig.APTS_Subtype__c = 'Project';
        quoteConfig.APTS_Quote_Record_Type__c = 'LP';
        quoteConfig.APTS_Division__c = 'LP';
        quoteConfig.APTS_Hierarchy_Level_MS__c = '3';
        quoteConfig.APTS_IsActive__c = TRUE;
        quoteConfig.APTS_Additional_Discount__c = TRUE;
        quoteConfig.APTS_Substitute_Discount__c = TRUE;
        quoteConfig.APTS_Additional_Discounts_Hierarchy__c = TRUE;
        quoteConfig.APTS_Net_Discount_Hierarchy__c = TRUE;
        quoteConfig.APTS_Substitutional_Discounts_Hierarchy__c = TRUE;
        quoteConfig.APTS_Net_Discount__c = TRUE;
        quoteConfig.APTS_Local_Channel__c = localChannel.id;
    
        APTS_Discounts_Config__c agreementConfig = new APTS_Discounts_Config__c();
        
        agreementConfig.APTS_Country__c = 'France';
        agreementConfig.APTS_Subtype__c = 'Project';
        agreementConfig.APTS_Record_Type__c = 'MSPA';
        agreementConfig.APTS_Division__c = 'LP';
        agreementConfig.APTS_Hierarchy_Level_MS__c = '3';
        agreementConfig.APTS_IsActive__c = TRUE;
        agreementConfig.APTS_Additional_Discount__c = TRUE;
        agreementConfig.APTS_Substitute_Discount__c = TRUE;
        agreementConfig.APTS_Additional_Discounts_Hierarchy__c = TRUE;
        agreementConfig.APTS_Net_Discount_Hierarchy__c = TRUE;
        agreementConfig.APTS_Substitutional_Discounts_Hierarchy__c = TRUE;
        agreementConfig.APTS_Net_Discount__c = TRUE;
        agreementConfig.APTS_Local_Channel__c = localChannel.id;
        agreementConfig.APTS_Hierarchy_in_Cart__c = '3';
        listDiscountConfig.add(quoteConfig);
        listDiscountConfig.add(agreementConfig);
        insert listDiscountConfig;
        APTS_Master_Picklist_Table__c master = new APTS_Master_Picklist_Table__c();
        master.Name = 'Account Canale';
        master.APTS_Code__c = '02';
        master.APTS_Code_Description__c = 'Account Canale';
        master.APTS_Code_Used_For__c = 'Market';
        master.APTS_Locale__c = 'fr_FR';
        master.APTS_Country__c = 'France';
        insert master;

        APTS_Master_Picklist_Table__c paymentTerm = new APTS_Master_Picklist_Table__c();
        paymentTerm.Name = 'Cobro a 30 das';
        paymentTerm.APTS_Code__c = 'Z004';
        paymentTerm.APTS_Code_Description__c = 'Cobro a 30 das';
        paymentTerm.APTS_Code_Used_For__c = 'Payment Term';
        paymentTerm.APTS_Locale__c = 'fr_FR';
        paymentTerm.APTS_Country__c = 'France';
        insert paymentTerm;

        APTS_Master_Picklist_Table__c incoterm = new APTS_Master_Picklist_Table__c();
        incoterm.Name = 'Porte pagado';
        incoterm.APTS_Code__c = 'CPT';
        incoterm.APTS_Code_Description__c = 'Porte pagado';
        incoterm.APTS_Code_Used_For__c = 'Incoterm';
        incoterm.APTS_Locale__c = 'fr_FR';
        incoterm.APTS_Country__c = 'France';
        insert incoterm;

        APTS_Master_Picklist_Table__c distributionChannel = new APTS_Master_Picklist_Table__c();
        distributionChannel.Name = 'BT';
        distributionChannel.APTS_Locale__c = 'fr_FR';
        distributionChannel.APTS_Code__c = 'BT';
        distributionChannel.APTS_Code_Used_For__c = 'Distribution Channel';
        distributionChannel.APTS_Code_Description__c = 'BT';
        distributionChannel.APTS_Country__c = 'France';
        insert distributionChannel;
        
        
        Account acc = APTS_LP_TestUtility.getNewAccount('Apttus Inc','Spain');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GIS Approved').getRecordTypeId();
        acc.ShippingCountry='Spain';
        acc.ShippingState = 'Araba';            
        acc.ShippingStreet= 'XYSFH';
        acc.ShippingCity= 'Valencia';
        acc.ShippingPostalCode='A122222';
        ClsAccountUtil.isAccMergeFlag = true;
        ClsAccountUtil.isUpdate = false;
        insert acc;
        oAgreement = APTS_LP_TestUtility.getAgreement('Test Agreement');
        oAgreement.APTS_LP_AccountCustomer__c = acc.Id;            
        oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
        oAgreement.APTS_Locale__c = 'fr_FR';
        oAgreement.APTS_Country__c = 'France';
        oAgreement.APTS_LP_Sales_Organization__c = 'FR15';
        oAgreement.APTS_Distribution_Channel__c =distributionChannel.id;
        oAgreement.APTS_Local_Channel__c=localChannel.id;
        oAgreement.APTS_Incoterms__c= incoterm.id;
        oAgreement.APTS_Payment_Terms__c =paymentTerm.id;
        oAgreement.Market__c = master.Id;
        
        insert oAgreement;
        
        oProductConfig = APTS_LP_TestUtility.getProductConfiguration('Test');
        oProductConfig.Apttus_CMConfig__AgreementId__c = oAgreement.id;
        
        insert oProductConfig;
        
        Product2 product = APTS_LP_TestUtility.getProduct();
        product.APTS_Hierarchy_Level_3_Code__c ='00996';
        product.APTS_Product_ID__c = '1SDA052340R1';
        product.APTS_LP_Product_Hierarchy__c='15';
        insert product;
        
        List<Apttus_Config2__LineItem__c> listLineItem = APTS_LP_TestUtility.getLineItemListWithPriceOveride(oProductConfig.id,2,product,100);
        insert listLineItem;
                   
        
        List<Apttus__AgreementLineItem__c> listALI = APTS_LP_TestUtility.getAgreementLineItemList(oAgreement.Id, 1);
        listALI[0].Apttus_CMConfig__ConfigurationId__c = oProductConfig.Id;
        listALI[0].Apttus_CMConfig__ItemSequence__c = 1;
        listALI[0].Apttus_CMConfig__LineNumber__c = 1;
        listALI[0].Apttus__ProductId__c = product.Id;
        listALI[0].Apttus__ListPrice__c = 15;
        listALI[0].Apttus__NetPrice__c = 15;
        listALI[0].APTS_Total_Net_Sales_Price__c = 15;
        listALI[0].Apttus__Quantity__c = 1;
        insert listALI;
        
        oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
        oAgreement.Apttus__Contract_Start_Date__c = System.today();
        oAgreement.Apttus__Contract_End_Date__c = System.today().addDays(2);
        oAgreement.APTS_Max_Order_Amount__c = 1235.45;
        oAgreement.Apttus_CMConfig__PricingDate__c = System.today();
        update oAgreement;
        
        
            
        APTS_Configurator_Cart_Summary__c objCartSummary = new APTS_Configurator_Cart_Summary__c();
        objCartSummary.APTS_Base_Price__c = 482.7;
        objCartSummary.APTS_Configuration_Reference_Id__c = 'ABB_LP__983';
        objCartSummary.APTS_Configure_Status__c = 'Initial Load';
        objCartSummary.APTS_Cust_Requested_Disc__c = 20;
        objCartSummary.APTS_Discount_Percentage__c = 40;
        objCartSummary.APTS_Discount_Type__c = 'Substitute Discount';
        objCartSummary.APTS_Has_Scale_Type__c = false;
        objCartSummary.APTS_Local_Configurator_System_Id__c = 'PDC';
        objCartSummary.APTS_LP_Standard_Discount__c = 10;
        objCartSummary.APTS_LP_Unit_Of_Measure__c = 'UN';
        objCartSummary.APTS_LP_Unit_Of_Price__c = '1';
        objCartSummary.APTS_Market_Price__c = 224.5;
        objCartSummary.APTS_Min_Delivery_Qty__c = 2;
        objCartSummary.APTS_Min_Order_Qty__c = 2;
        objCartSummary.APTS_Net_Price__c = 123;
        objCartSummary.APTS_Net_Price_Override__c = 234;
        objCartSummary.APTS_Product__c = product.Id;
        objCartSummary.APTS_Qty__c = 2;
        objCartSummary.APTS_Agreement__c = oAgreement.Id;
        objCartSummary.APTS_Third_Party__c = 'false';
        objCartSummary.APTS_Total_List_Price__c = 123;
        objCartSummary.APTS_Total_Net_Sales_Price__c = 230;
        insert objCartSummary;

        APTS_Product_Item_Scale_Data__c prod = new APTS_Product_Item_Scale_Data__c();
        prod.APTS_Agreement__c = oAgreement.Id;
        prod.APTS_Parent_Configurator_Cart_Summary_ID__c = objCartSummary.Id;
        prod.APTS_Cost__c = 100;
        prod.APTS_Discount_Type__c = 'Net Price';
        prod.APTS_Discount_Value__c = 10;
         
        prod.APTS_Quantity__c = 3;
        prod.APTS_Scale_Types__c = 'No Scale';
        insert prod;
        
        APTS_ABB_LP_SAP_Integration_Util.getSasToken();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new APTPS_SAPCalloutMockTest());
        
        APTS_ABB_SAPIntegrationServiceBaseImpl mspaIntObject = new APTS_ABB_SAPIntegrationServiceBaseImpl();
        mspaIntObject.invoke(oAgreement.Id, 'true');  
        Test.stopTest();
        
        }
        }
     private static testmethod void testgetSASTokens_Italy(){
    
      
      User user = new User(alias = 'test123', email='test123+invalid@abb.com', emailencodingkey='UTF-8',UserRoleId = userRoleId,
                              lastname='Testing', languagelocalekey='fr', localesidkey='it_IT', APTS_Locale__c = 'it_IT',
                              profileid = APTS_LP_TestUtility.getAdminProfile().Id, country = 'Italy', countryCode = 'IT', IsActive = true,
                              Division = 'LP', Division_DIV__c = 'LP', timezonesidkey='America/Los_Angeles',
                              username = 'test123+invalid@abb.com' );
      ClsTriggerFactory.isExecuteUserTrigger = false;
        insert user;
      System.runAs(user) {
        lstCommonConfigCustomSettings = APTS_PG_TEST_Utility.createCustomSettingData();
        insert lstCommonConfigCustomSettings;
        
        APTS_Master_Picklist_Table__c localChannel = new APTS_Master_Picklist_Table__c();
            
        localChannel.Name = 'Distribution General';
        localChannel.APTS_Code__c = 'P5';
        localChannel.APTS_Code_Description__c = 'Distribution General';
        localChannel.APTS_Code_Used_For__c = 'Local Channel';
        localChannel.APTS_Locale__c = 'it_IT';
        localChannel.APTS_Country__c = 'Italy';
        insert localChannel;
        
        APTS_LP_TestUtility.getCommonConfigSetting();
        APTS_LP_TestUtility.getCustomSetting_QuoteNProposal();
        APTS_LP_TestUtility.mspaRefData('Italy');
        APTS_LP_TestUtility.getCountryDefaults();    
        APTS_LP_TestUtility.getIntegrationParameters();
        APTS_LP_TestUtility.getSAPIntegrationTokens();
        APTS_LP_TestUtility.getCommonConfigSetting();
        APTS_LP_TestUtility.getLODConfigSetting();
        
        APTS_Country_Defaults__c cd=[Select id,APTS_DefaultProductDiscSAP__c from APTS_Country_Defaults__c where Name='Italy' Limit 1];
        cd.APTS_DefaultProductDiscSAP__c ='N';
        update cd;
        LSO_Field_Entries__c salesOffice = new LSO_Field_Entries__c();
        salesOffice.Active__c = TRUE;
        salesOffice.PickList_Code__c = 'Z111';
        salesOffice.PickList_Description__c = 'BT/Niessen Barcelona';
        salesOffice.Controlling_Field__c = 'LSO Reference Data.Country';
        salesOffice.Value__c = 'Italy';
        salesOffice.Country__c = 'Italy';
        salesOffice.LSO_Pick_List_Value_Name__c = 'LSO Reference Data. Sales Office';
        salesOffice.Manual_Unique__c = 'Test9999';                
        insert salesOffice;
        
        List<APTS_Discounts_Config__c> listDiscountConfig = new List<APTS_Discounts_Config__c>();
        APTS_Discounts_Config__c quoteConfig = new APTS_Discounts_Config__c();
        
        quoteConfig.APTS_Country__c = 'Italy';
        quoteConfig.APTS_Subtype__c = 'Project';
        quoteConfig.APTS_Quote_Record_Type__c = 'LP';
        quoteConfig.APTS_Division__c = 'LP';
        quoteConfig.APTS_Hierarchy_Level_MS__c = '3';
        quoteConfig.APTS_IsActive__c = TRUE;
        quoteConfig.APTS_Additional_Discount__c = TRUE;
        quoteConfig.APTS_Substitute_Discount__c = TRUE;
        quoteConfig.APTS_Additional_Discounts_Hierarchy__c = TRUE;
        quoteConfig.APTS_Net_Discount_Hierarchy__c = TRUE;
        quoteConfig.APTS_Substitutional_Discounts_Hierarchy__c = TRUE;
        quoteConfig.APTS_Net_Discount__c = TRUE;
        quoteConfig.APTS_Local_Channel__c = localChannel.id;
    
        APTS_Discounts_Config__c agreementConfig = new APTS_Discounts_Config__c();
        
        agreementConfig.APTS_Country__c = 'Italy';
        agreementConfig.APTS_Subtype__c = 'Project';
        agreementConfig.APTS_Record_Type__c = 'MSPA';
        agreementConfig.APTS_Division__c = 'LP';
        agreementConfig.APTS_Hierarchy_Level_MS__c = '3';
        agreementConfig.APTS_IsActive__c = TRUE;
        agreementConfig.APTS_Additional_Discount__c = TRUE;
        agreementConfig.APTS_Substitute_Discount__c = TRUE;
        agreementConfig.APTS_Additional_Discounts_Hierarchy__c = TRUE;
        agreementConfig.APTS_Net_Discount_Hierarchy__c = TRUE;
        agreementConfig.APTS_Substitutional_Discounts_Hierarchy__c = TRUE;
        agreementConfig.APTS_Net_Discount__c = TRUE;
        agreementConfig.APTS_Local_Channel__c = localChannel.id;
        agreementConfig.APTS_Hierarchy_in_Cart__c = '3';
        listDiscountConfig.add(quoteConfig);
        listDiscountConfig.add(agreementConfig);
        insert listDiscountConfig;
        
        APTS_Master_Picklist_Table__c master = new APTS_Master_Picklist_Table__c();
        master.Name = 'Account Canale';
        master.APTS_Code__c = '02';
        master.APTS_Code_Description__c = 'Account Canale';
        master.APTS_Code_Used_For__c = 'Market';
        master.APTS_Locale__c = 'it_IT';
        master.APTS_Country__c = 'Italy';
        insert master;

        APTS_Master_Picklist_Table__c paymentTerm = new APTS_Master_Picklist_Table__c();
        paymentTerm.Name = 'Cobro a 30 das';
        paymentTerm.APTS_Code__c = 'Z004';
        paymentTerm.APTS_Code_Description__c = 'Cobro a 30 das';
        paymentTerm.APTS_Code_Used_For__c = 'Payment Term';
        paymentTerm.APTS_Locale__c = 'it_IT';
        paymentTerm.APTS_Country__c = 'Italy';
        insert paymentTerm;

        APTS_Master_Picklist_Table__c incoterm = new APTS_Master_Picklist_Table__c();
        incoterm.Name = 'Porte pagado';
        incoterm.APTS_Code__c = 'CPT';
        incoterm.APTS_Code_Description__c = 'Porte pagado';
        incoterm.APTS_Code_Used_For__c = 'Incoterm';
        incoterm.APTS_Locale__c = 'it_IT';
        incoterm.APTS_Country__c = 'Italy';
        insert incoterm;

        APTS_Master_Picklist_Table__c distributionChannel = new APTS_Master_Picklist_Table__c();
        distributionChannel.Name = 'BT';
        distributionChannel.APTS_Locale__c = 'it_IT';
        distributionChannel.APTS_Code__c = 'BT';
        distributionChannel.APTS_Code_Used_For__c = 'Distribution Channel';
        distributionChannel.APTS_Code_Description__c = 'BT';
        distributionChannel.APTS_Country__c = 'Italy';
        insert distributionChannel;
        
        
        Account acc = APTS_LP_TestUtility.getNewAccount('Apttus Inc','Spain');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GIS Approved').getRecordTypeId();
        acc.ShippingCountry='Spain';
        acc.ShippingState = 'Araba';            
        acc.ShippingStreet= 'XYSFH';
        acc.ShippingCity= 'Valencia';
        acc.ShippingPostalCode='A122222';
        ClsAccountUtil.isAccMergeFlag = true;
        ClsAccountUtil.isUpdate = false;
        insert acc;
        oAgreement = APTS_LP_TestUtility.getAgreement('Test Agreement');
        oAgreement.APTS_LP_AccountCustomer__c = acc.Id;            
        oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
        oAgreement.APTS_Locale__c = 'it_IT';
        oAgreement.APTS_Country__c = 'Italy';
        oAgreement.APTS_LP_Sales_Organization__c = 'FR15';
        oAgreement.APTS_Distribution_Channel__c =distributionChannel.id;
        oAgreement.APTS_Local_Channel__c=localChannel.id;
        oAgreement.APTS_Incoterms__c= incoterm.id;
        oAgreement.APTS_Payment_Terms__c =paymentTerm.id;
        oAgreement.Market__c = master.Id;
        
        insert oAgreement;
        
        oProductConfig = APTS_LP_TestUtility.getProductConfiguration('Test');
        oProductConfig.Apttus_CMConfig__AgreementId__c = oAgreement.id;
        
        insert oProductConfig;
        
        Product2 product = APTS_LP_TestUtility.getProduct();
        product.APTS_Hierarchy_Level_3_Code__c ='00996';
        product.APTS_Product_ID__c = '1SDA052340R1';
        product.APTS_LP_Product_Hierarchy__c='15';
        insert product;
        
        List<Apttus_Config2__LineItem__c> listLineItem = APTS_LP_TestUtility.getLineItemListWithPriceOveride(oProductConfig.id,2,product,100);
        insert listLineItem;
                   
        
        List<Apttus__AgreementLineItem__c> listALI = APTS_LP_TestUtility.getAgreementLineItemList(oAgreement.Id, 1);
        listALI[0].Apttus_CMConfig__ConfigurationId__c = oProductConfig.Id;
        listALI[0].Apttus_CMConfig__ItemSequence__c = 1;
        listALI[0].Apttus_CMConfig__LineNumber__c = 1;
        listALI[0].Apttus__ProductId__c = product.Id;
        listALI[0].Apttus__ListPrice__c = 15;
        listALI[0].Apttus__NetPrice__c = 15;
        listALI[0].APTS_Total_Net_Sales_Price__c = 15;
        listALI[0].Apttus__Quantity__c = 1;
        insert listALI;
        
        oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
        oAgreement.Apttus__Contract_Start_Date__c = System.today();
        oAgreement.Apttus__Contract_End_Date__c = System.today().addDays(2);
        oAgreement.APTS_Max_Order_Amount__c = 1235.45;
        oAgreement.Apttus_CMConfig__PricingDate__c = System.today();
        update oAgreement;
        
        
            
        APTS_Configurator_Cart_Summary__c objCartSummary = new APTS_Configurator_Cart_Summary__c();
        objCartSummary.APTS_Base_Price__c = 482.7;
        objCartSummary.APTS_Configuration_Reference_Id__c = 'ABB_LP__983';
        objCartSummary.APTS_Configure_Status__c = 'Initial Load';
        objCartSummary.APTS_Cust_Requested_Disc__c = 20;
        objCartSummary.APTS_Discount_Percentage__c = 40;
        objCartSummary.APTS_Discount_Type__c = 'Substitute Discount';
        objCartSummary.APTS_Has_Scale_Type__c = false;
        objCartSummary.APTS_Local_Configurator_System_Id__c = 'PDC';
        objCartSummary.APTS_LP_Standard_Discount__c = 10;
        objCartSummary.APTS_LP_Unit_Of_Measure__c = 'UN';
        objCartSummary.APTS_LP_Unit_Of_Price__c = '1';
        objCartSummary.APTS_Market_Price__c = 224.5;
        objCartSummary.APTS_Min_Delivery_Qty__c = 2;
        objCartSummary.APTS_Min_Order_Qty__c = 2;
        objCartSummary.APTS_Net_Price__c = 123;
        objCartSummary.APTS_Net_Price_Override__c = 234;
        objCartSummary.APTS_Product__c = product.Id;
        objCartSummary.APTS_Qty__c = 2;
        objCartSummary.APTS_Agreement__c = oAgreement.Id;
        objCartSummary.APTS_Third_Party__c = 'false';
        objCartSummary.APTS_Total_List_Price__c = 123;
        objCartSummary.APTS_Total_Net_Sales_Price__c = 230;
        insert objCartSummary;

        APTS_Product_Item_Scale_Data__c prod = new APTS_Product_Item_Scale_Data__c();
        
        prod.APTS_Parent_Configurator_Cart_Summary_ID__c = objCartSummary.Id;
        prod.APTS_Cost__c = 100;
        prod.APTS_Discount_Type__c = 'Net Price';
        prod.APTS_Discount_Value__c = 10;
         prod.APTS_Agreement__c = oAgreement.Id;
        prod.APTS_Quantity__c = 3;
        prod.APTS_Scale_Types__c = 'No Scale';
        insert prod;
        
        APTS_ABB_LP_SAP_Integration_Util.getSasToken();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new APTPS_SAPCalloutMockTest());
        
        APTS_ABB_SAPIntegrationServiceBaseImpl mspaIntObject = new APTS_ABB_SAPIntegrationServiceBaseImpl();
        mspaIntObject.invoke(oAgreement.Id, 'true');  
        Test.stopTest();
       
        }
        }   
    private static testmethod void testgetSASTokens_China(){
    
      
        User user = new User(alias = 'test123', email='test123+invalid@abb.com', emailencodingkey='UTF-8',UserRoleId = userRoleId,
                              lastname='Testing', languagelocalekey='fr', localesidkey='zh_CN', APTS_Locale__c = 'zh_CN',
                              profileid = APTS_LP_TestUtility.getAdminProfile().Id, country = 'China', countryCode = 'CN', IsActive = true,
                              Division = 'LP', Division_DIV__c = 'LP', timezonesidkey='America/Los_Angeles',
                              username = 'test123+invalid@abb.com' );
        ClsTriggerFactory.isExecuteUserTrigger = false;
        insert user;
        System.runAs(user) {
        lstCommonConfigCustomSettings = APTS_PG_TEST_Utility.createCustomSettingData();
        insert lstCommonConfigCustomSettings;
        
        APTS_Master_Picklist_Table__c localChannel = new APTS_Master_Picklist_Table__c();
            
        localChannel.Name = 'Distribution General';
        localChannel.APTS_Code__c = 'P5';
        localChannel.APTS_Code_Description__c = 'Distribution General';
        localChannel.APTS_Code_Used_For__c = 'Local Channel';
        localChannel.APTS_Locale__c = 'zh_CN';
        localChannel.APTS_Country__c = 'China';
        insert localChannel;
        
        APTS_LP_TestUtility.getCommonConfigSetting();
        APTS_LP_TestUtility.getCustomSetting_QuoteNProposal();
        APTS_LP_TestUtility.mspaRefData('China');
        APTS_LP_TestUtility.getCountryDefaults();    
        APTS_LP_TestUtility.getIntegrationParameters();
        APTS_LP_TestUtility.getSAPIntegrationTokens();
        APTS_LP_TestUtility.getCommonConfigSetting();
        APTS_LP_TestUtility.getLODConfigSetting();
        
        APTS_Country_Defaults__c cd=[Select id,APTS_DefaultProductDiscSAP__c from APTS_Country_Defaults__c where Name='China' Limit 1];
        cd.APTS_DefaultProductDiscSAP__c ='N';
        update cd;
        LSO_Field_Entries__c salesOffice = new LSO_Field_Entries__c();
        salesOffice.Active__c = TRUE;
        salesOffice.PickList_Code__c = 'Z111';
        salesOffice.PickList_Description__c = 'BT/Niessen Barcelona';
        salesOffice.Controlling_Field__c = 'LSO Reference Data.Country';
        salesOffice.Value__c = 'China';
        salesOffice.Country__c = 'China';
        salesOffice.LSO_Pick_List_Value_Name__c = 'LSO Reference Data. Sales Office';
        salesOffice.Manual_Unique__c = 'Test9999';                
        insert salesOffice;
        
       List<APTS_Discounts_Config__c> listDiscountConfig = new List<APTS_Discounts_Config__c>();
        APTS_Discounts_Config__c quoteConfig = new APTS_Discounts_Config__c();
        
        quoteConfig.APTS_Country__c = 'China';
        quoteConfig.APTS_Subtype__c = 'Order';
        quoteConfig.APTS_Quote_Record_Type__c = 'LP';
        quoteConfig.APTS_Division__c = 'LP';
        quoteConfig.APTS_Hierarchy_Level_MS__c = '3';
        quoteConfig.APTS_IsActive__c = TRUE;
        quoteConfig.APTS_Additional_Discount__c = TRUE;
        quoteConfig.APTS_Substitute_Discount__c = TRUE;
        quoteConfig.APTS_Additional_Discounts_Hierarchy__c = TRUE;
        quoteConfig.APTS_Net_Discount_Hierarchy__c = TRUE;
        quoteConfig.APTS_Substitutional_Discounts_Hierarchy__c = TRUE;
        quoteConfig.APTS_Net_Discount__c = TRUE;
        quoteConfig.APTS_Local_Channel__c = localChannel.id;
    
        APTS_Discounts_Config__c agreementConfig = new APTS_Discounts_Config__c();
        
        agreementConfig.APTS_Country__c = 'China';
        agreementConfig.APTS_Subtype__c = 'Order';
        agreementConfig.APTS_Record_Type__c = 'MSPA';
        agreementConfig.APTS_Division__c = 'LP';
        agreementConfig.APTS_Hierarchy_Level_MS__c = '3';
        agreementConfig.APTS_IsActive__c = TRUE;
        agreementConfig.APTS_Additional_Discount__c = TRUE;
        agreementConfig.APTS_Substitute_Discount__c = TRUE;
        agreementConfig.APTS_Additional_Discounts_Hierarchy__c = TRUE;
        agreementConfig.APTS_Net_Discount_Hierarchy__c = TRUE;
        agreementConfig.APTS_Substitutional_Discounts_Hierarchy__c = TRUE;
        agreementConfig.APTS_Net_Discount__c = TRUE;
        agreementConfig.APTS_Local_Channel__c = localChannel.id;
        agreementConfig.APTS_Hierarchy_in_Cart__c = '3';
        listDiscountConfig.add(quoteConfig);
        listDiscountConfig.add(agreementConfig);
        insert listDiscountConfig;
        
        APTS_Master_Picklist_Table__c master = new APTS_Master_Picklist_Table__c();
        master.Name = 'Account Canale';
        master.APTS_Code__c = '02';
        master.APTS_Code_Description__c = 'Account Canale';
        master.APTS_Code_Used_For__c = 'Market';
        master.APTS_Locale__c = 'zh_CN';
        master.APTS_Country__c = 'China';
        insert master;

        APTS_Master_Picklist_Table__c paymentTerm = new APTS_Master_Picklist_Table__c();
        paymentTerm.Name = 'Cobro a 30 das';
        paymentTerm.APTS_Code__c = 'Z004';
        paymentTerm.APTS_Code_Description__c = 'Cobro a 30 das';
        paymentTerm.APTS_Code_Used_For__c = 'Payment Term';
        paymentTerm.APTS_Locale__c = 'zh_CN';
        paymentTerm.APTS_Country__c = 'China';
        insert paymentTerm;

        APTS_Master_Picklist_Table__c incoterm = new APTS_Master_Picklist_Table__c();
        incoterm.Name = 'Porte pagado';
        incoterm.APTS_Code__c = 'CPT';
        incoterm.APTS_Code_Description__c = 'Porte pagado';
        incoterm.APTS_Code_Used_For__c = 'Incoterm';
        incoterm.APTS_Locale__c = 'zh_CN';
        incoterm.APTS_Country__c = 'China';
        insert incoterm;

        APTS_Master_Picklist_Table__c distributionChannel = new APTS_Master_Picklist_Table__c();
        distributionChannel.Name = 'BT';
        distributionChannel.APTS_Locale__c = 'zh_CN';
        distributionChannel.APTS_Code__c = 'BT';
        distributionChannel.APTS_Code_Used_For__c = 'Distribution Channel';
        distributionChannel.APTS_Code_Description__c = 'BT';
        distributionChannel.APTS_Country__c = 'China';
        insert distributionChannel;
        
        
        Account acc = APTS_LP_TestUtility.getNewAccount('Apttus Inc','Spain');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('GIS Approved').getRecordTypeId();
        acc.ShippingCountry='Spain';
        acc.ShippingState = 'Araba';            
        acc.ShippingStreet= 'XYSFH';
        acc.ShippingCity= 'Valencia';
        acc.ShippingPostalCode='A122222';
        ClsAccountUtil.isAccMergeFlag = true;
        ClsAccountUtil.isUpdate = false;
        insert acc;
        oAgreement = APTS_LP_TestUtility.getAgreement('Test Agreement');
        oAgreement.APTS_LP_AccountCustomer__c = acc.Id;            
        oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
        oAgreement.APTS_Locale__c = 'zh_CN';
        oAgreement.APTS_Country__c = 'China';
        oAgreement.Apttus__Subtype__c= 'Order';
        oAgreement.APTS_LP_Sales_Organization__c = 'FR15';
        oAgreement.APTS_Distribution_Channel__c =distributionChannel.id;
        oAgreement.APTS_Local_Channel__c= localChannel.id;
        oAgreement.APTS_Incoterms__c= incoterm.id;
        oAgreement.APTS_Payment_Terms__c =paymentTerm.id;
        oAgreement.Market__c = master.Id;
        
        insert oAgreement;
        
        oProductConfig = APTS_LP_TestUtility.getProductConfiguration('Test');
        oProductConfig.Apttus_CMConfig__AgreementId__c = oAgreement.id;
        
        insert oProductConfig;
        
        Product2 product = APTS_LP_TestUtility.getProduct();
        product.APTS_Hierarchy_Level_3_Code__c ='00996';
        product.APTS_Product_ID__c = '1SDA052340R1';
        product.APTS_LP_Product_Hierarchy__c='15';
        insert product;
        
        List<Apttus_Config2__LineItem__c> listLineItem = APTS_LP_TestUtility.getLineItemListWithPriceOveride(oProductConfig.id,2,product,100);
        insert listLineItem;
                   
        
        List<Apttus__AgreementLineItem__c> listALI = APTS_LP_TestUtility.getAgreementLineItemList(oAgreement.Id, 1);
        listALI[0].Apttus_CMConfig__ConfigurationId__c = oProductConfig.Id;
        listALI[0].Apttus_CMConfig__ItemSequence__c = 1;
        listALI[0].Apttus_CMConfig__LineNumber__c = 1;
        listALI[0].Apttus__ProductId__c = product.Id;
        listALI[0].Apttus__ListPrice__c = 15;
        listALI[0].Apttus__NetPrice__c = 15;
        listALI[0].APTS_Total_Net_Sales_Price__c = 15;
        listALI[0].Apttus__Quantity__c = 1;
        insert listALI;
        
        oAgreement.APTS_SAP_Customer_ID__c = '0080000413';
        oAgreement.Apttus__Contract_Start_Date__c = System.today();
        oAgreement.Apttus__Contract_End_Date__c = System.today().addDays(2);
        oAgreement.APTS_Max_Order_Amount__c = 1235.45;
        oAgreement.Apttus_CMConfig__PricingDate__c = System.today();
        update oAgreement;
        
        
            
        APTS_Configurator_Cart_Summary__c objCartSummary = new APTS_Configurator_Cart_Summary__c();
        objCartSummary.APTS_Base_Price__c = 482.7;
        objCartSummary.APTS_Configuration_Reference_Id__c = 'ABB_LP__983';
        objCartSummary.APTS_Configure_Status__c = 'Initial Load';
        objCartSummary.APTS_Cust_Requested_Disc__c = 20;
        objCartSummary.APTS_Discount_Percentage__c = 40;
        objCartSummary.APTS_Discount_Type__c = 'Substitute Discount';
        objCartSummary.APTS_Has_Scale_Type__c = false;
        objCartSummary.APTS_Local_Configurator_System_Id__c = 'PDC';
        objCartSummary.APTS_LP_Standard_Discount__c = 10;
        objCartSummary.APTS_LP_Unit_Of_Measure__c = 'UN';
        objCartSummary.APTS_LP_Unit_Of_Price__c = '1';
        objCartSummary.APTS_Market_Price__c = 224.5;
        objCartSummary.APTS_Min_Delivery_Qty__c = 2;
        objCartSummary.APTS_Min_Order_Qty__c = 2;
        objCartSummary.APTS_Net_Price__c = 123;
        objCartSummary.APTS_Net_Price_Override__c = 234;
        objCartSummary.APTS_Product__c = product.Id;
        objCartSummary.APTS_Qty__c = 2;
        objCartSummary.APTS_Agreement__c = oAgreement.Id;
        objCartSummary.APTS_Third_Party__c = 'false';
        objCartSummary.APTS_Total_List_Price__c = 123;
        objCartSummary.APTS_Total_Net_Sales_Price__c = 230;
        insert objCartSummary;

        APTS_Product_Item_Scale_Data__c prod = new APTS_Product_Item_Scale_Data__c();
        //prod.APTS_Agreement_Id__c = oAgreement.Id;
        prod.APTS_Parent_Configurator_Cart_Summary_ID__c = objCartSummary.Id;
        prod.APTS_Cost__c = 100;
        prod.APTS_Discount_Type__c = 'Net Price';
        prod.APTS_Discount_Value__c = 10;
         prod.APTS_Agreement__c = oAgreement.Id;
        prod.APTS_Quantity__c = 3;
        prod.APTS_Scale_Types__c = 'No Scale';
        insert prod;
        
        APTS_ABB_LP_SAP_Integration_Util.getSasToken();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new APTPS_SAPCalloutMockTest());
        
        APTS_ABB_SAPIntegrationServiceBaseImpl mspaIntObject = new APTS_ABB_SAPIntegrationServiceBaseImpl();
        mspaIntObject.invoke(oAgreement.Id, 'true');  
        Test.stopTest();
        
        }
        }
    private static testmethod void testTokenWrapper(){
            lstCommonConfigCustomSettings = APTS_PG_TEST_Utility.createCustomSettingData();
            insert lstCommonConfigCustomSettings;
            APTS_ABB_LP_SAP_Tokens.AgreementLineItems aLines = new APTS_ABB_LP_SAP_Tokens.AgreementLineItems();
            aLines.ProductHierarchy = '00M0';
            aLines.ProductCode = '0200M';
            
            APTS_ABB_LP_SAP_Tokens.IntegrationError err = new APTS_ABB_LP_SAP_Tokens.IntegrationError();
            err.Code = '502';
            
            APTS_ABB_LP_SAP_Tokens.MSPASAPResponseWrapper res = new APTS_ABB_LP_SAP_Tokens.MSPASAPResponseWrapper();
            res.Errors = new List<APTS_ABB_LP_SAP_Tokens.IntegrationError>{err};
            res.SalesDealItems = new List<APTS_ABB_LP_SAP_Tokens.AgreementLineItems>{aLines};
            
            APTS_ABB_LP_SAP_Tokens.oAuthIntegrationToken token = new APTS_ABB_LP_SAP_Tokens.oAuthIntegrationToken();
            token.token_type = '1';
            token.expires_in = 2;
            token.refresh_token = '3';
            
            APTS_ABB_LP_SAP_Tokens.AgreementLineItems agmtLineItem = new APTS_ABB_LP_SAP_Tokens.AgreementLineItems();
            agmtLineItem.ConditionPricingUnit = 'ConditionPricingUnit';
            agmtLineItem.DealCalculationType = 'DealCalculationType';
            agmtLineItem.DealCode = 'DealCode';
            agmtLineItem.DealCurrency = 'DealCurrency';
            agmtLineItem.DealType = 'DealType';
            agmtLineItem.DealValue = '2345';
            agmtLineItem.ItemNumber = 'ItemNumber';
            agmtLineItem.MaxOrdQty = '234';
            agmtLineItem.MaxOrdVal = '234553';
            agmtLineItem.Maxconval = 'Maxconval';
            agmtLineItem.MinOrdQty = 'MinOrdQty';
            agmtLineItem.MinOrdVal = 'MinOrdVal';
            agmtLineItem.OrderQty = 'OrderQty';
            agmtLineItem.OrderVal = 'OrderVal';
            agmtLineItem.PricingUnit = 'PricingUnit';
            agmtLineItem.Custom01 = 'Custom01';
            agmtLineItem.ProductGroup = 'ProductGroup';
            agmtLineItem.SalesOrganization = 'SalesOrganization';
            agmtLineItem.ScaleQuantity = 'ScaleQuantity';
            agmtLineItem.DistributionChannel = 'DistributionChannel';
            agmtLineItem.BraketType = 'BraketType';
            
            APTS_ABB_LP_SAP_Tokens.SAPRequestAuthHeader sapReqAuth = new APTS_ABB_LP_SAP_Tokens.SAPRequestAuthHeader();
            sapReqAuth.AuthToken = 'AuthToken';
            sapReqAuth.BauCode = 'BauCode';
            sapReqAuth.Currency1 = 'Currency1';
            sapReqAuth.CustomerCode = 'CustomerCode';            
            
            APTS_ABB_LP_SAP_Tokens.AgreementHeader agmtHeader = new APTS_ABB_LP_SAP_Tokens.AgreementHeader();
            agmtHeader.Action = 'Action';
            agmtHeader.Block = 'Block';
            agmtHeader.CustomerGroup = 'CustomerGroup';
            agmtHeader.DealCode = 'DealCode';
            agmtHeader.DealType = 'DealType';
            agmtHeader.DealValue = 'DealValue';
            agmtHeader.MaxOrdVal = 'MaxOrdVal';
            agmtHeader.MinOrdVal = 'MinOrdVal';
            agmtHeader.ResidualAmount = 'ResidualAmount';
            agmtHeader.SalesMan = 'SalesMan';
            agmtHeader.SalesOffice = 'SalesOffice';
            agmtHeader.SalesOrganization = 'SalesOrganization';
            agmtHeader.DistributionChannel = 'DistributionChannel';
            agmtHeader.ValidFrom = 'ValidFrom';
            agmtHeader.ValidTo = 'ValidTo';
            agmtHeader.Incoterms1 = 'Incoterms1';
            agmtHeader.Incoterms2 = 'Incoterms2';
            agmtHeader.PaymentTerms = 'PaymentTerms';
            
                
            APTS_ABB_LP_SAP_Tokens.MSPASAPRequestWrapper mspaSAPReqWrap = new APTS_ABB_LP_SAP_Tokens.MSPASAPRequestWrapper();
            mspaSAPReqWrap.globalParams = sapReqAuth;
            mspaSAPReqWrap.createSalesDealRequest = agmtHeader;
        }
           public static Product2 getProduct(){
        
        Product2 oProduct  = new Product2();
        oProduct.name = 'Test Prod';
        oProduct.APTS_Product_ID__c = 'P1234';
        oProduct.APTS_Country_Code__c = 'EN';
        oProduct.APTS_GTV_Level__c = 'TestGTV';
        oProduct.Description = 'Test Desc';
        oProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Local Hierarchy').getRecordTypeId();
        oProduct.APTS_Hierarchy_Level_2_Code__c = 'RA';
        oProduct.APTS_Hierarchy_Level__c = 2;
        oProduct.IsActive = true;
        oProduct.APTS_Product_ID__c = 'P123';
        return oProduct;
    }
    
}