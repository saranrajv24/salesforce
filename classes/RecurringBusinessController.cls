/**
 *
 @author  Lavanya Krishnan
 @created 2018-03-26
 @version 1.0 
 **/
global class RecurringBusinessController {

    public static final String VAR_EMPTY = '';
    public static final String VAR_YES = 'Yes';
    public static final String VAR_NO = 'No';
    public static final String VAR_FRAMEAGMT = 'Frame_Agreement';
    public static final String VAR_BUYING = 'Buying';
    public static final String VAR_WON = 'Closed Won';
    public static final String AGMT_STATUS_INEFFECT = 'In Effect';
    public static final String AGMT_STATUS_ACTIVATED = 'Activated';
    public static final String MSG_SUCCESS = 'SUCCESS';
    public static final String VAR_MAILSUBJECT = 'Recurring Opportunity Cancellation Status';
    public static final String MSG_FAILURE_1 = 'Frame Agreement must be active to proceed with RO creation/updation';
    public static final String MSG_FAILURE_2 = 'Recurring Business can be initiated only when source opportunity is closed as WON';
    public static final String VAR_SELECT = '--Select--';
    public static final String VAR_ZERO = '0';
    public static final String VAR_MONTHLY = 'Monthly';
    public static final String VAR_QUARTERLY = 'Quarterly';
    public static final String VAR_YEARLY = 'Yearly';
    public static final String VAR_INSERTRO = 'INSERT_RO';
    public static final String VAR_UPDATERO = 'UPDATE_RO';
    public static final String VAR_DELETERO = 'DELETE_RO';
    public static final string VAR_CANCELRB = 'CANCELRB';
    public static final string VAR_REOPENRB = 'REOPENRB';
    public static final String VAR_DRAFT = 'Draft';
    public static final String VAR_CLOSEDWON = 'Closed Won';
    public static final String VAR_LOSTCANCELLED = 'Closed Lost (Cancelled)';
    public static final String VAR_CANCELLED = 'Cancelled';
    public static final String VAR_INAPPROVAL = 'In Approval';
    public static final String VAR_ACTIVE = 'Active';
    public static final String VAR_SCOPECHANGE = 'Scope is modified , Please click on Refresh button';
    public static final String VAR_ERROR1 = 'An error occurred during RO Creation';
    public static final String VAR_ERROR2 = 'An error occurred during RO Updation';
    public static final String VAR_ERROR3 = 'An error occurred during update RbRef and sync RO';
    public static final String VAR_ERROR4 = 'An error occurred during RB Updation';
    public static final String VAR_ERROR5 = 'Recurring Opportunity can be created only when active Business Plan';
    public static final String VAR_ROSUCCESS = 'Recurring Opportunities have been synced and saved successfully!';
    public static final String VAR_DEALAGMT = 'Deal_Agreement_Products_and_or_Services';
    public static final Map<String, String> DESTINATION_FIELDS = new Map<String, String> {
    'Application__c' => 'Application_PickVal__c',
    'BU__c' => 'BU_PickVal__c',
    'Business_Line__c' => 'Business_Line_PickVal__c',
    'ABB_Domain__c' => 'ABB_Domain_PickVal__c',
    'Channel_Class_Level1__c' => 'Channel_Class_Level1_PickVal__c',
    'Channel_Class_Level2__c' => 'Channel_Class_Level2_PickVal__c',
    'ABB_Industry_Usage_Level1__c' => 'Industry_Usage_Level1_PickVal__c',
    'ABB_Industry_Usage_Level2__c' => 'Industry_Usage_Level2_PickVal__c',
    'ABB_Industry_Usage_Level3__c' => 'Industry_Usage_Level3_PickVal__c'};
    
    public static final String VAR_VALUE = 'Value';    
    public static final String VAR_NONE = '--- None ---';
    
    /* SAVE RB */
    /**
     @author  Lavanya Krishnan
     @created 2018-03-26
     @Method Name:  saveRB 
     **/
    @AuraEnabled
    public static List < RB_Reference__c > saveRB(String rbObj, String items, String recBid, String splitType, String periods, String roList, String sourceType) {         
       system.debug('rbObjLine67>>'+rbObj);
       system.debug('itemsLine68>>'+items);
       system.debug('recBidLine69>>'+recBid);
       system.debug('splitTypeLine67>>'+splitType);
       system.debug('periodsLine71>>'+periods);
       system.debug('roListLine72>>'+roList);
       system.debug('sourceTypeLine73>>'+sourceType);
       //system.debug('splitTypeLine67>>'+splitType);
       //system.debug('splitTypeLine67>>'+splitType);
        Recurring_Business__c rbObject = (Recurring_Business__c) JSON.deserialize(rbObj, Recurring_Business__c.class);          
        rbObject = updateRBRecordsForPicklistFields(rbObject);
        String rbobjupdated = JSON.serialize(rbObject);
        system.debug('rbobjupdatedTypeLine67>>'+rbobjupdated);
        List < RB_Reference__c > result = RecurringBusinessHelper.saveRB(rbobjupdated, items, recBid, splitType, periods, sourceType, roList);
        return result;
    }

    /* CREATE RECURRING OPPORTUNITY */
    /**
     @author  Lavanya Krishnan
     @created 2018-03-26
     @Method Name:  createRecurringOpportunity
     **/
    @AuraEnabled
    public static List < RecurringBusinessWrapperClasses.FullFillItems > createRecurringOpportunity(String recBuId, String sourceType) {
        List < RecurringBusinessWrapperClasses.FullFillItems > lstFullFillItems = new List < RecurringBusinessWrapperClasses.FullFillItems > ();
        lstFullFillItems = RecurringBusinessHelper.createRecurringOpportunity(recBuId, sourceType);
        return lstFullFillItems;
    }

    /* UPDATE RECURRING OPPORTUNITY */
    /**
    @author  Lavanya
    @created 2018-03-26
    @Method Name:  updateRO
    **/
    @AuraEnabled
    public static boolean updateRO(String recBid) {
        boolean result = false;
        result = RecurringBusinessHelper.updateRO(recBid);
        return result;

    }

    /* USER CANCEL RB  */
    /**
    @author  Lavanya
    @created 2018-01-17
    @Method Name:  cancelRBByUser
    **/
    @AuraEnabled
    public static boolean cancelRBByUser(String rbId, String reasonForCancel, boolean IsAutomaticCancellation) {
        boolean result = false;
        result = RecurringBusinessHelper.closeOrCancelRB(rbId, reasonForCancel, IsAutomaticCancellation);
        return result;
    }

    /* REOPEN RB*/
    /**
    @author  Lavanya
    @created 2017-03-08
    @Method Name:  processReopenRB
    **/
    @AuraEnabled
    public static boolean processReopenRB(String rbId, String sourceId, String sourceType) {
        Boolean result = false;
        Opportunity opp = null;
        Account acc = null;
        List < Joint_Business_Plan__c > objcpbp = null;


        if (sourceType.equals('Opportunity')) {
            opp = [SELECT StageName FROM Opportunity where id =: sourceId];
            if (opp != null && (opp.StageName.equals('Bidding') || opp.StageName.equals('Negotiation') || opp.StageName.equals(VAR_WON))) {
                result = RecurringBusinessHelper.genericReopenRB(rbId);
            }
        } else if (sourceType.equals('Account')) {
            acc = [SELECT Active__c, GUID__c FROM Account where id =: sourceId];
            if (acc != null && (acc.Active__c && acc.GUID__c != null)) {
                result = RecurringBusinessHelper.genericReopenRB(rbId);
            }
        } else if (sourceType.equals('CPBP')) {
            objcpbp = [SELECT Name, Status__c FROM Joint_Business_Plan__c where id =: sourceId LIMIT 1];
            if (!objcpbp.IsEmpty() && (objcpbp[0].Status__c.equals(VAR_DRAFT) || objcpbp[0].Status__c.equals(VAR_INAPPROVAL) || objcpbp[0].Status__c.equals(VAR_ACTIVE))) {
                result = RecurringBusinessHelper.genericReopenRB(rbId);
            }
        }
        return result;
    }


    /* UPDATE RB REFERENCE AND SYNC RO*/
    /**
    @author  Lavanya Krishnan
    @created 2017-03-08
    @Method Name:  updateRBReferenceAndSyncRO
    **/
    @AuraEnabled
    public static List < RB_Reference__c > updateRBReferenceAndSyncRO(List < RB_Reference__c > rbRefItems) {
        system.debug('rbRefItems===' + rbRefItems);
        ClsTriggerFactory.RBREFAUTOSYNC = VAR_UPDATERO;
        List < Database.SaveResult > srList = Database.update(rbRefItems, false);
        for (Database.SaveResult sr: srList) {
            system.debug('update status : ' + sr.isSuccess());
        }

        return rbRefItems;
    }

    /* REFRESH SPLIT TABLE */
    /**
    @author  Thenmozhi
    @created 2017-21-11
    @Method Name:  refreshSplitTable
    **/
    @AuraEnabled
    public static void refreshSplitTable(String setSourceIds, String rbId, String sourceType, Recurring_Business__c rbObject) {
        Set < Id > sourceIds = new Set < Id > ();
        sourceIds.add(setSourceIds);
        Savepoint databaseSavepoint = Database.setSavepoint();
        try {
            updateRecurringBusinessObject(rbObject,rbId);
            if (sourceType.equals('Opportunity')) {
                RefreshProductSplitFromSourceHelper.reConfigureRBandRBRefsMap(sourceIds);
            } else if (sourceType.equals('Account')) {
                RefreshProductSplitFromSourceHelper.reConfigureRBandRBRefsAccountMap(sourceIds, rbId);
            } else if (sourceType.equals('CPBP')) {
                RefreshProductSplitFromSourceHelper.reConfigureRBandRBRefsCPBPMap(sourceIds);
            }
        } catch (DmlException ex) {
            Database.rollback(databaseSavepoint);
            throw new AuraHandledException(ex.getDmlMessage(0));
        }

    }


    /* FETCH SCHEDULE PERIOD*/
    /**
    @author  Lavanya Krishnan
    @created 2018-01-08
    @Method Name:  fetchSchedulePeriod
    **/
    @AuraEnabled
    public static Map < String, String > fetchSchedulePeriod() {
        Map < String, String > options = new Map < String, String > ();
        Schema.DescribeFieldResult fieldResult = Recurring_Business__c.Schedule_Period__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.put(f.getValue(), f.getLabel());
        }
        system.debug(options);
        return options;
    }



    /* GET PREVIEW DATA */
    /**
    @author  Lavanya
    @created 2017-03-08
    @Method Name:  getPreviewData
    **/
    @AuraEnabled
    public static List < RecurringBusinessWrapperClasses.FullFillItems > getPreviewData(String sourceId, String rbRecid) {

        List < RecurringBusinessWrapperClasses.FullFillItems > result = new List < RecurringBusinessWrapperClasses.FullFillItems > ();
        List < RB_Reference__c > rbReflst = null;
        List < RecurringBusinessWrapperClasses.RoLineItems > lstROlines = new List < RecurringBusinessWrapperClasses.RoLineItems > ();
        List < OpportunityLineItem > lstROlineItems = null;
        List < Opportunity > lstOpportunity = null;
        Set < String > rbRefIdList = new Set < String > ();
        Map < String, RB_Reference__c > mapRBReference = new Map < String, RB_Reference__c > ();
        rbReflst = [SELECT Actual_Value__c, CreatedById, CreatedDate, CurrencyIsoCode, Start_Date__c, End_Date__c,
            EAD__c, Fulfill__c, Id, IsDeleted, Is_Delete__c, LastModifiedById,RO_Custom_Name__c,
            LastModifiedDate, Name, Products_1__c, Products_2__c, RB_ID__c,
            RO_ID__c, RO_Name__c, Status__c, SystemModstamp, Total_Value__c
            FROM RB_Reference__c where RB_ID__c =: rbRecid order by EAD__c asc
        ];

        for (RB_Reference__c rbrefObj: rbReflst) {
            rbRefIdList.add(rbrefObj.RO_ID__c);
            mapRBReference.put(rbrefObj.RO_ID__c, rbrefObj);
        }

        // query Opportunities 
        lstOpportunity = [SELECT CloseDate, Amount, Opportunity_Value__c, Id,
            Name, StageName, CurrencyIsoCode, AccountId, RB_Reference_ID__c,
            Main_Reason_For_Close__c FROM Opportunity where RB_Reference_ID__c in: rbRefIdList LIMIT 50000
        ];
        // query line items 

        Set < Id > oppIdset = new Set < Id > ();

        for (Opportunity opp: lstOpportunity) {
            oppIdset.add(opp.Id);
        }

        lstROlineItems = [SELECT Actual_Value__c, CurrencyIsoCode, Id,
            ListPrice, Name, OpportunityId, PricebookEntryId,
            Primary_Product_Group__c, Product2Id, Product2_Tree_Path__c,
            ProductCode, Product_Group__c, Product_Line__c, Product_Type_Code__c,
            Quantity, Quotation__c, Subtotal, TotalPrice, UnitPrice, Value__c, Product2.Name
            FROM OpportunityLineItem where OpportunityId in: oppIdset LIMIT 50000
        ];
        if (lstOpportunity.size() > 0) {
            for (Opportunity opp: lstOpportunity) {
                List < OpportunityLineItem > lstOppLineitemsPerRo = new List < OpportunityLineItem > ();
                for (OpportunityLineItem oppLineItem: lstROlineItems) {
                    if (oppLineItem.OpportunityId == opp.Id) {
                        lstOppLineitemsPerRo.add(oppLineItem);
                    }
                }


                result.add(new RecurringBusinessWrapperClasses.FullFillItems(opp, mapRBReference.get(opp.RB_Reference_ID__c), lstOppLineitemsPerRo, 'SUCCESS'));
            }
        } else {

            for (RB_Reference__c rr: rbReflst) {
                result.add(new RecurringBusinessWrapperClasses.FullFillItems(null, rr, null, 'SUCCESS'));
            }

        }

        return result;
    }



    /* UPDATE RB REFERENCE */
    /**
    @author  Lavanya
    @created 2017-12-10
    @Method Name:  updateRBReference
    **/
    @AuraEnabled
    public static List < RB_Reference__c > updateRBReference(String rbRefItems) {
        List < RB_Reference__c > lstItems = (List < RB_Reference__c > ) JSON.deserialize(rbRefItems, List < RB_Reference__c > .class);
        system.debug(lstItems);
        try {
            List < Database.SaveResult > sr = Database.update(lstItems, false);
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
        return lstItems;
    }


    /* UPDATE RB OBJECT */
    /**
    @author  Lavanya
    @created 2017-03-08
    @Method Name:  updateRecurringBusinessObject
    **/
    @AuraEnabled
    public static boolean updateRecurringBusinessObject(Recurring_Business__c rbObject, String recBid) {
        try {
           // system.debug(rbObj + '@rbObj');
            system.debug(recBid + '@recBid');
            //Recurring_Business__c rbObject = (Recurring_Business__c) JSON.deserialize(rbObj, Recurring_Business__c.class);
            Recurring_Business__c objRec = new Recurring_Business__c();
            system.debug('rbObject =' + rbObject);
            if (recBid != VAR_EMPTY) {

                objRec.id = recBid;
                objRec.Name = rbObject.Name;
                objRec.Award_Date__c = rbObject.Start_Date__c;
                objRec.Start_Date__c = rbObject.Start_Date__c;
                objRec.End_Date__c = rbObject.End_Date__c;
                // objRec.ChannelPartner_BusinessPlan__c = rbObject.Parent__c;
                objRec.Periods__c = rbObject.Periods__c;
                // objRec.Type__c = splitType;
                objRec.Status__c = rbObject.Status__c;
                objRec.TotalRBValue__c = rbObject.TotalRBValue__c;
                objRec.ABB_Location__c = rbObject.ABB_Location__c;
                objRec.Account_End_User__c = rbObject.Account_End_User__c;
                objRec.End_User_Project__c = rbObject.End_User_Project__c;
                objRec.Offering_Primary_PG__c = rbObject.Offering_Primary_PG__c;
                objRec.BU__c = rbObject.BU__c;
                objRec.Application__c = rbObject.Application__c;
                objRec.ABB_Industry_Usage_Level1__c = rbObject.ABB_Industry_Usage_Level1__c;
                objRec.Channel_Class_Level1__c = rbObject.Channel_Class_Level1__c == VAR_SELECT ? VAR_EMPTY : rbObject.Channel_Class_Level1__c;
                objRec.Channel_Class_Level2__c = rbObject.Channel_Class_Level2__c == VAR_SELECT ? VAR_EMPTY : rbObject.Channel_Class_Level2__c;
                String valCheck = rbObject.ABB_Domain__c == VAR_SELECT ? VAR_EMPTY : rbObject.ABB_Domain__c;
                objRec.ABB_Domain__c = valCheck;
                objRec.Business_Line__c = rbObject.Business_Line__c == VAR_SELECT ? VAR_EMPTY : rbObject.Business_Line__c;
                objRec.ABB_Industry_Usage_Level2__c = rbObject.ABB_Industry_Usage_Level2__c;
                objRec.ABB_Industry_Usage_Level3__c = rbObject.ABB_Industry_Usage_Level3__c;
                objRec.Target__c = rbObject.Target__c;
                objRec.Commit__c = rbObject.Commit__c;
                objRec.Account_Customer__c = rbObject.Account_Customer__c;
                objRec.Campaign__c = rbObject.Campaign__c;//Req-6466
                objRec.Source_Agreement__c = rbObject.Source_Agreement__c;
                objRec.Frequency__c = rbObject.Frequency__c;
                objRec.Value__c = rbObject.Value__c;
                /*****Added by Swedha for PickList Migration  Changes *****/
                /**Start of PickList Migration Changes **/
                objRec.Application_PickVal__c = rbObject.Application_PickVal__c;
                objRec.BU_PickVal__c = rbObject.BU_PickVal__c;
                objRec.Business_Line_PickVal__c = rbObject.Business_Line_PickVal__c;
                objRec.ABB_Domain_PickVal__c = rbObject.ABB_Domain_PickVal__c;
                objRec.Channel_Class_Level1_PickVal__c = rbObject.Channel_Class_Level1_PickVal__c;
                objRec.Channel_Class_Level2_Pickval__c = rbObject.Channel_Class_Level2_Pickval__c;
                objRec.Industry_Usage_Level1_PickVal__c = rbObject.Industry_Usage_Level1_PickVal__c;
                objRec.Industry_Usage_Level2_PickVal__c = rbObject.Industry_Usage_Level2_PickVal__c;
                objRec.Industry_Usage_Level3_PickVal__c = rbObject.Industry_Usage_Level3_PickVal__c; 
                /**End of PickList Migration Changes **/
                objRec = updateRBRecordsForPicklistFields(objRec);
            }
            system.debug('objRec=' + objRec);
            // Database.SaveResult sr = Database.update(objRec,false);  
            update objRec;
            //updateROCusName(objRec);
            return true;
        } catch (Exception ex) {
            system.debug('Exception occured while update rb object=' + ex.getMessage());
            return false;
        }
        //return sr.isSuccess();    
    }

    /* GET DEPENDENT PICKLISTS IMPLEMENTATION */
    /**
    @author  Jaroslaw Kondrat
    @created 2017-03-08
    @Method Name:  getDependentOptionsImpl
    **/
    @AuraEnabled
    public static Map < String, List < String >> getDependentOptionsImpl(string objApiName, string contrfieldApiName, string depfieldApiName) {
        system.debug(objApiName + '##' + contrfieldApiName + '###' + depfieldApiName);
        
        String objectName = objApiName.toLowerCase();
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();

        Map < String, List < String >> objResults = new Map < String, List < String >> ();
        //get the string to sobject global map
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();

        if (!Schema.getGlobalDescribe().containsKey(objectName)) {
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map < String, Schema.SObjectField > objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;
        }

        List < Schema.PicklistEntry > contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List < Schema.PicklistEntry > depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List < Integer > controllingIndexes = new List < Integer > ();
        system.debug('contrEntries = '+contrEntries);
        for (Integer contrIndex = 0; contrIndex < contrEntries.size(); contrIndex++) {
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            system.debug('ctrlentry.isActive() = '+ctrlentry.isActive());
            if(ctrlentry.isActive()){
            String label = ctrlentry.getLabel();
            objResults.put(label, new List < String > ());
            controllingIndexes.add(contrIndex);
        }
        }
        List < Schema.PicklistEntry > objEntries = new List < Schema.PicklistEntry > ();
        List < BitSet.PicklistEntryWrapper > objJsonEntries = new List < BitSet.PicklistEntryWrapper > ();
        system.debug('depEntries=>>'+depEntries);
        for (Integer dependentIndex = 0; dependentIndex < depEntries.size(); dependentIndex++) {
            Schema.PicklistEntry depentry = depEntries[dependentIndex];
            system.debug('depentry.isActive() = '+depentry.isActive());
            if(depentry.isActive()){
            objEntries.add(depentry);
          system.debug('AFTERdepEntries=>>'+depEntries);
        }
        }
        objJsonEntries = (List < BitSet.PicklistEntryWrapper > ) JSON.deserialize(JSON.serialize(objEntries), List < BitSet.PicklistEntryWrapper > .class);
        List < Integer > indexes;
        for (BitSet.PicklistEntryWrapper objJson: objJsonEntries) {
            if (objJson.validFor == null || objJson.validFor == '') {
                continue;
            }
            system.debug('Lavanya index = ' + objJson.validFor);
            indexes = bitSetObj.testBits(objJson.validFor, controllingIndexes);
            for (Integer idx: indexes) {
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
                system.debug('objResultsLINE460--->' +objResults);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        system.debug('objResultsLine465>>'+objResults);
        return objResults;
    }

    /* GET EXISTING RB DATA */
    /**
    @author  Rajesh
    @created 2017-03-08
    @Method Name:  getExistingRBData
    **/
    @AuraEnabled
    public static Recurring_Business__c getExistingRBData(String rbId) {
        Recurring_Business__c result = null;
        result = [SELECT BU_PickVal__c,Application_PickVal__c,ABB_Domain_PickVal__c,Business_Line_PickVal__c,Channel_Class_Level1_PickVal__c,Channel_Class_Level2_Pickval__c,Industry_Usage_Level1_PickVal__c,Industry_Usage_Level2_PickVal__c,Industry_Usage_Level3_PickVal__c,ABB_Domain__c, ABB_Industry_Usage_Level1__c, ABB_Industry_Usage_Level2__c, ABB_Industry_Usage_Level3__c, ABB_Location__c, Account_Customer__c, Account_End_User__c, All_Target_vs_All_Commit__c, Application__c, Award_Date__c, Business_Line__c, BU__c, Channel_Class_Level1__c, Channel_Class_Level2__c, CreatedById, CreatedDate, CurrencyIsoCode, End_Date__c, End_User_Project__c, Frequency__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, Opportunity__c, OwnerId, Parent__c, Periods__c, Quantity__c, Start_Date__c, Status__c, SystemModstamp, TotalRBValue__c, Type__c, Value__c FROM Recurring_Business__c where Id =: rbId];
        return result;
    }

    /* GET EXISTING RB REFERENCE DATA */
    /**
    @author  Rajesh
    @created 2017-03-08
    @Method Name:  getExistingRBRefData
    **/
    @AuraEnabled
    public static List < RB_Reference__c > getExistingRBRefData(String rbId) {
        List < RB_Reference__c > result = null;
        result = [SELECT Actual_Value__c, CreatedById, CreatedDate, CurrencyIsoCode, EAD__c, Fulfill__c, Id, IsDeleted, Is_Delete__c, LastModifiedById, LastModifiedDate, Name, Products_1__c, Products_2__c, RB_ID__c, RO_ID__c, RO_Name__c, Status__c, SystemModstamp, Total_Value__c FROM RB_Reference__c where RB_ID__c =: rbId];
        return result;
    }


    /* FETCH LOOKUP VALUES*/
    /**
    @author  Thenmozhi Arasu
    @created 2017-12-10
    @Method Name:  fetchLookUpValues
    **/
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        String searchKey = '\'%' + searchKeyWord + '%\''; //'%' + searchKeyWord + '%';
        String PGdataLoadYear = '\'' + Label.Product_Group_Data_Load_Year_Filter + '\'';
        String LocdataLoadYear = '\'' + Label.ABB_Location_Data_Load_Year_Filter + '\'';
        List < sObject > returnList = new List < sObject > ();
        String sQuery = null;

        User usr = [SELECT Id, Name, Alias, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

        if (ObjectName.equalsIgnoreCase('Product_Group__c')) {
            if (('data.mig').equals(usr.Alias)) {
                sQuery = 'select id, Name from Product_Group__c where Name LIKE ' + searchKey + ' LIMIT 20';
            } else {
                sQuery = 'select id, Name from Product_Group__c where Name LIKE ' + searchKey + ' AND recordType.Name = \'Product Group\' AND ';
                //sQuery += 'Data_Load_Year__c = \'2017\' AND Non_Searchable__c = false LIMIT 20';
                sQuery += 'IsActive__c = True AND Non_Searchable__c = false LIMIT 20';
            }
        } else if (ObjectName.equalsIgnoreCase('ABB_Location__c')) {
            if (('data.mig').equals(usr.Alias) || ('ABB CCP Integration').equals(usr.Profile.Name)) {
                sQuery = 'select id, Name from ABB_Location__c where Name LIKE ' + searchKey + ' LIMIT 20';
            } else {
                List < String > str1 = new List < String > {
                    'ZCCO',
                    'ZCRE',
                    'ZCVA'
                };
                List < String > str2 = new List < String > {
                    'Admin/Corporate',
                    'Other',
                    'R&D',
                    'Warehouse or Logistics',
                    'Training'
                };

                sQuery = 'select id, Name from ABB_Location__c where Name LIKE ' + searchKey + ' AND IsActive__c = true AND ';
              //  sQuery += 'Data_Load_Year__c != \'2015\' AND BU__c NOT IN :str1 AND (NOT DIV__c LIKE \'ZC%\') AND ';
                sQuery += 'BU__c NOT IN :str1 AND (NOT DIV__c LIKE \'ZC%\') AND ';
                sQuery += 'Activity__c NOT IN :str2 AND Activity__c != \'\' LIMIT 20';
            }
        } else if (ObjectName.equalsIgnoreCase('End_User_Project__c')) {
            List < String > str1 = new List < String > {
                'Cancelled',
                'Completed'
            };
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE ' + searchKey + ' AND End_User_Project_Status__c NOT IN :str1 LIMIT 20 ';
        }else if(ObjectName.equalsIgnoreCase('Campaign')){
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE ' + searchKey + 'AND IsActive = true ' +' LIMIT 20';
        } else {
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE ' + searchKey + ' LIMIT 20';
        }

        //     String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE '+searchKey+' LIMIT 20';

        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }


    /* FETCH CANCELLATION REASONS */
    /**
    @author  Lavanya
    @created 2017-03-08
    @Method Name:  fetchCancellationReasons
    **/
    @AuraEnabled
    public static Map < String, String > fetchCancellationReasons() {
        Map < String, String > options = new Map < String, String > ();
        Schema.DescribeFieldResult fieldResult = Recurring_Business__c.Reason_For_Cancellation__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.put(f.getValue(), f.getLabel());
        }
        system.debug(options);
        return options;
    }


    /* GET ALL RO'S FOR RB */
    /**
    @author  Lavanya
    @created 2017-03-08
    @Method Name:  getAllROsForRB
    **/
    @AuraEnabled
    public static List < Opportunity > getAllROsForRB(String rbId) {

        Database.SaveResult sr = null;
        List < Opportunity > roList = null;
        String query = null;
        try {
            List < RB_Reference__c > rbRefList = [SELECT RO_ID__c FROM RB_Reference__c where RB_ID__c =: rbId];
            List < String > rbRefIdList = new List < String > ();
            for (RB_Reference__c r: rbRefList) {
                rbRefIdList.add(r.RO_ID__c);
            }

            query = 'SELECT Id,Name, StageName,RB_Reference_ID__c FROM Opportunity where RB_Reference_ID__c IN :rbRefIdList';

            roList = Database.query(query);
        } catch (Exception ex) {
            system.debug(ex.getMessage());
        }

        return roList;
    }

    /* GET RB DETAILS */
    /**
    @author  Lavanya
    @created 2017-03-08
    @Method Name:  getRBDetails
    **/
    @AuraEnabled
    public static Recurring_Business__c getRBDetails(String rbId) {

        Recurring_Business__c rbObj = null;
        try {
            rbObj = [SELECT ABB_Domain__c, ABB_Industry_Usage_Level1__c, ABB_Industry_Usage_Level2__c, ABB_Industry_Usage_Level3__c, ABB_Location__c,
                Account_Customer__c, Account_End_User__c, All_Target_vs_All_Commit__c, Application__c, Award_Date__c, Business_Line__c, BU__c,
                CancelledByAgreementTermination__c, Channel_Class_Level1__c, Channel_Class_Level2__c, CurrencyIsoCode, End_Date__c,
                End_User_Project__c, Frequency__c, Id, IsAutomaticCancellation__c, Name, Opportunity__c, OwnerId, Parent__c, Periods__c,
                Quantity__c, Reason_For_Cancellation__c, SourceOppStageName__c, Source_Agreement__c, Start_Date__c, Status__c,
                TotalRBValue__c, Type__c, Value__c, Source_Agreement__r.Id, Account_Customer__r.Name, Offering_Primary_PG__c,
                Offering_Primary_PG__r.Name, Account_End_User__r.Name, End_User_Project__r.Name, ABB_Location__r.Name, Schedule_Period__c,
                ChannelPartner_BusinessPlan__r.Status__c, ChannelPartner_BusinessPlan__c, ChannelPartner_BusinessPlan__r.Name,
                Scheduler_Day__c, Scheduler_Month__c, Scheduler_Repeat_On__c, Opportunity__r.Name, Opportunity__r.StageName, Commit__c,
                CreatedById, CreatedDate, isAllFulfilled__c, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate, Owner__c,
                RecordTypeId, SystemModstamp, Target__c,Campaign__c,Campaign__r.Name,Source_Agreement__r.Name,Service_Category__c,Application_PickVal__c,
                BU_PickVal__c,Business_Line_PickVal__c,ABB_Domain_PickVal__c,Channel_Class_Level1_PickVal__c,Channel_Class_Level2_Pickval__c,
                Industry_Usage_Level1_PickVal__c,Industry_Usage_Level2_PickVal__c ,Industry_Usage_Level3_PickVal__c FROM Recurring_Business__c where id =: rbId
            ];//Req-6466
        } catch (Exception ex) {
            system.debug(ex.getMessage());
        }

        return rbObj;
    }


    /* FETCH CANCELLATION REASONS FROM SOURCE OPPORTUNITIES */
    /**
    @author  Lavanya
    @created 2017-03-08
    @Method Name:  fetchCancellationReasonsFromSourceOpp
    **/
    @AuraEnabled
    public static Map < String, String > fetchCancellationReasonsFromSourceOpp() {
        Map < String, String > options = new Map < String, String > ();
        Schema.DescribeFieldResult fieldResult = Opportunity.Main_Reason_For_Close__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.put(f.getValue(), f.getLabel());
        }
        system.debug(options);
        return options;
    }

    /* FETCH LOCATION LOOKUP VALUES */
    /**
    @author  Thenmozhi Arasu
    @created 2017-12-10
    @Method Name:  fetchLocationLookUpValues
    **/
    @AuraEnabled
    public static List < sObject > fetchLocationLookUpValues(String searchKeyWord, String ObjectName) {
        String searchKey = '\'%' + searchKeyWord + '%\''; //'%' + searchKeyWord + '%';
        String PGdataLoadYear = '\'' + Label.Product_Group_Data_Load_Year_Filter + '\'';
        String LocdataLoadYear = '\'' + Label.ABB_Location_Data_Load_Year_Filter + '\'';
        List < sObject > returnList = new List < sObject > ();
        String sQuery = null;

        User usr = [SELECT Id, Name, Alias, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];

        if (ObjectName.equalsIgnoreCase('Product_Group__c')) {
            if (('data.mig').equals(usr.Alias)) {
                sQuery = 'select id, Name,Business_Unit__c,Product_Group_Name__c from Product_Group__c where Name LIKE ' + searchKey + ' LIMIT 20';
            } else {
                sQuery = 'select id, Name,Business_Unit__c,Product_Group_Name__c from Product_Group__c where Name LIKE ' + searchKey + ' AND recordType.Name = \'Product Group\' AND ';
                // sQuery += 'Data_Load_Year__c = \''+Label.Product_Group_Data_Load_Year_Filter+'\' AND Non_Searchable__c = false LIMIT 20';
                sQuery += 'IsActive__c = True AND Non_Searchable__c = false LIMIT 20';
            }
        } else if (ObjectName.equalsIgnoreCase('ABB_Location__c')) {
            if (('data.mig').equals(usr.Alias) || ('ABB CCP Integration').equals(usr.Profile.Name) || ('ABB External Competitive Sales Agent Profile').equals(usr.Profile.Name)) {
                sQuery = 'select id, Name,Address__c,Company__c from ABB_Location__c where Name LIKE ' + searchKey + ' LIMIT 20';
            } else {
                List < String > str1 = new List < String > {
                    'ZCCO',
                    'ZCRE',
                    'ZCVA'
                };

                Set < String > str2 = new Set < String > {
                    'Admin/Corporate',
                    'Other',
                    'R&D',
                    'Warehouse or Logistics',
                    'Training'
                };


                sQuery = 'select id, Name,Address__c,Company__c from ABB_Location__c where Name LIKE ' + searchKey + ' AND IsActive__c = true AND ';
                //sQuery += 'Data_Load_Year__c != \'' + Label.ABB_Location_Data_Load_Year_Filter + '\' AND (NOT DIV__c LIKE \'ZC%\') AND ';
                sQuery += '(NOT DIV__c LIKE \'ZC%\') AND ';
                // sQuery += 'BU__c NOT IN :str1 AND ';
                sQuery += 'BU__c != \'ZCCO\' AND BU__c != \'ZCRE\' AND BU__c != \'ZCVA\' AND ';
                sQuery += 'Activity__c NOT IN :str2 AND Activity__c != \'\' LIMIT 20';
            }
        } else if (ObjectName.equalsIgnoreCase('End_User_Project__c')) {
            List < String > str1 = new List < String > {
                'Cancelled',
                'Completed'
            };
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE ' + searchKey + ' AND End_User_Project_Status__c NOT IN :str1 LIMIT 20 ';
        } else {
            sQuery = 'select id, Name from ' + ObjectName + ' where Name LIKE ' + searchKey + ' LIMIT 20';
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    /**
    @author  Lavanya Krishnan
    @created 2017-03-08
    @Method Name:  getOnLoadData
    **/
    @AuraEnabled
    public static RecurringBusinessWrapperClasses.OnLoadWrapper getOnLoadData(String sourceId, String recBuId, String sourceType) {

        RecurringBusinessWrapperClasses.OnLoadWrapper returnObj;
        String SourceAgreementId = VAR_EMPTY;
        String SourceAgreementName = VAR_EMPTY;
        String abbLocationName = VAR_EMPTY;
        String offeringPGName = VAR_EMPTY;
        String accEndUserName = VAR_EMPTY;
        String endUserProjName = VAR_EMPTY;
        String sourceObjectName = VAR_EMPTY;
        String accountCustomerName = VAR_EMPTY;
        String sourceObjectStatus = VAR_EMPTY;
        Decimal rbCount;
        Map < String, String > mapChannelClassLevel1 = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('Channel_Class_Level1__c', 'Desc');
        String channelClass1 = '';
        Map < String, String > mapChannelClassLevel2 = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('Channel_Class_Level2__c', 'Desc');
        String channelClass2 = '';
        Map < String, String > mapApplication = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('Application__c', 'Desc');
        String application = '';
        Map < String, String > mapBusinessLine = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('Business_Line__c', 'Desc');
        String businessLine = '';
        Map < String, String > mapABBDomain = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('ABB_Domain__c', 'Desc');
        String abbDomain = '';
        Map < String, String > mapBU = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('BU__c', 'Desc');
        String buVal = '';
        Map < String, String > mapIndUsage1 = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('ABB_Industry_Usage_Level1__c', 'Desc');
        String indUsage1 = '';
        Map < String, String > mapIndUsage2 = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('ABB_Industry_Usage_Level2__c', 'Desc');
        String indUsage2 = '';
        Map < String, String > mapIndUsage3 = RecurringBusinessHelper.fetchOpportunityPickListDescValueMap('ABB_Industry_Usage_Level3__c', 'Desc');
        String indUsage3 = '';
        List < RecurringBusinessWrapperClasses.FullFillItems > lstFulfillItems = new List < RecurringBusinessWrapperClasses.FullFillItems > ();
        Recurring_Business__c objRB = new Recurring_Business__c();
        List < Recurring_Business__c > lstRBcount = [Select id from Recurring_Business__c where Parent__c =: sourceId];
        if (recBuId != '') {
            lstFulfillItems = getPreviewData(sourceId, recBuId); // should pass sourcetype to make it common for all sources 
            objRB = getRBDetails(recBuId);
            rbCount = lstRBcount.size() + 1;
            /*if (mapChannelClassLevel1.containskey(objRB.Channel_Class_Level1__c)) {
                channelClass1 = mapChannelClassLevel1.get(objRB.Channel_Class_Level1__c);
            } else {
                channelClass1 = objRB.Channel_Class_Level1__c != null ? objRB.Channel_Class_Level1__c : VAR_EMPTY;
            }

            if (mapChannelClassLevel2.containskey(objRB.Channel_Class_Level2__c)) {
                channelClass2 = mapChannelClassLevel2.get(objRB.Channel_Class_Level2__c);
            } else {
                channelClass2 = objRB.Channel_Class_Level2__c != null ? objRB.Channel_Class_Level2__c : VAR_EMPTY;
            }

            if (mapApplication.containskey(objRB.Application__c)) {
                application = mapApplication.get(objRB.Application__c);
            } else {
                application = objRB.Application__c != null ? objRB.Application__c : VAR_EMPTY;
            }

            if (mapBusinessLine.containskey(objRB.Business_Line__c)) {
                businessLine = mapBusinessLine.get(objRB.Business_Line__c);
            } else {
                businessLine = objRB.Business_Line__c != null ? objRB.Business_Line__c : VAR_EMPTY;
            }

            if (mapIndUsage1.containskey(objRB.ABB_Industry_Usage_Level1__c)) {
                indUsage1 = mapIndUsage1.get(objRB.ABB_Industry_Usage_Level1__c);
            } else {
                indUsage1 = objRB.ABB_Industry_Usage_Level1__c != null ? objRB.ABB_Industry_Usage_Level1__c : VAR_EMPTY;
            }


            if (mapIndUsage2.containskey(objRB.ABB_Industry_Usage_Level2__c)) {
                indUsage2 = mapIndUsage2.get(objRB.ABB_Industry_Usage_Level2__c);
            } else {
                indUsage2 = objRB.ABB_Industry_Usage_Level2__c != null ? objRB.ABB_Industry_Usage_Level2__c : VAR_EMPTY;
            }

            if (mapIndUsage3.containskey(objRB.ABB_Industry_Usage_Level3__c)) {
                indUsage3 = mapIndUsage3.get(objRB.ABB_Industry_Usage_Level3__c);
            } else {
                indUsage3 = objRB.ABB_Industry_Usage_Level3__c != null ? objRB.ABB_Industry_Usage_Level3__c : VAR_EMPTY;
            }*/
            /****Added by Swedha for PickList Migration Changes****/
            /***Start of PickList Migration Changes***/
            if (mapChannelClassLevel1.containskey(objRB.Channel_Class_Level1_PickVal__c)) {
                channelClass1 = mapChannelClassLevel1.get(objRB.Channel_Class_Level1_PickVal__c);
            } else {
                channelClass1 = objRB.Channel_Class_Level1_PickVal__c != null ? objRB.Channel_Class_Level1_PickVal__c : VAR_EMPTY;
            }

            if (mapChannelClassLevel2.containskey(objRB.Channel_Class_Level2_Pickval__c)) {
                channelClass2 = mapChannelClassLevel2.get(objRB.Channel_Class_Level2_Pickval__c);
            } else {
                channelClass2 = objRB.Channel_Class_Level2_Pickval__c != null ? objRB.Channel_Class_Level2_Pickval__c : VAR_EMPTY;
            }

            if (mapApplication.containskey(objRB.Application_PickVal__c)) {
                application = mapApplication.get(objRB.Application_PickVal__c);
            } else {
                application = objRB.Application_PickVal__c != null ? objRB.Application_PickVal__c : VAR_EMPTY;
            }

            if (mapBusinessLine.containskey(objRB.Business_Line_PickVal__c)) {
                businessLine = mapBusinessLine.get(objRB.Business_Line_PickVal__c);
            } else {
                businessLine = objRB.Business_Line_PickVal__c != null ? objRB.Business_Line_PickVal__c : VAR_EMPTY;
            }
            if (mapABBDomain.containskey(objRB.ABB_Domain_PickVal__c)) {
                abbDomain = mapABBDomain.get(objRB.ABB_Domain_PickVal__c);
            } else {
                abbDomain = objRB.ABB_Domain_PickVal__c != null ? objRB.ABB_Domain_PickVal__c : VAR_EMPTY;
            }
            if (mapBU.containskey(objRB.BU_PickVal__c)) {
                buVal = mapBU.get(objRB.BU_PickVal__c);
            } else {
                buVal = objRB.BU_PickVal__c != null ? objRB.BU_PickVal__c : VAR_EMPTY;
            }
            if (mapIndUsage1.containskey(objRB.Industry_Usage_Level1_PickVal__c)) {
                indUsage1 = mapIndUsage1.get(objRB.Industry_Usage_Level1_PickVal__c);
            } else {
                indUsage1 = objRB.Industry_Usage_Level1_PickVal__c != null ? objRB.Industry_Usage_Level1_PickVal__c : VAR_EMPTY;
            }
            if (mapIndUsage2.containskey(objRB.Industry_Usage_Level2_PickVal__c)) {
                indUsage2 = mapIndUsage2.get(objRB.Industry_Usage_Level2_PickVal__c);
            } else {
                indUsage2 = objRB.Industry_Usage_Level2_PickVal__c != null ? objRB.Industry_Usage_Level2_PickVal__c : VAR_EMPTY;
            }
            if (mapIndUsage3.containskey(objRB.Industry_Usage_Level3_PickVal__c)) {
                indUsage3 = mapIndUsage3.get(objRB.Industry_Usage_Level3_PickVal__c);
            } else {
                indUsage3 = objRB.Industry_Usage_Level3_PickVal__c != null ? objRB.Industry_Usage_Level3_PickVal__c : VAR_EMPTY;
            }           
            /***End of PickList Migration Changes***/

            accountCustomerName = String.valueOf(objRB.Account_Customer__r.Name != null ? objRB.Account_Customer__r.Name : VAR_EMPTY);
            abbLocationName = String.valueOf(objRB.ABB_Location__r.Name != null ? objRB.ABB_Location__r.Name : VAR_EMPTY);
            offeringPGName = String.valueOf(objRB.Offering_Primary_PG__r.Name != null ? objRB.Offering_Primary_PG__r.Name : VAR_EMPTY);
            accEndUserName = String.valueOf(objRB.Account_End_User__r.Name != null ? objRB.Account_End_User__r.Name : VAR_EMPTY);
            endUserProjName = String.valueOf(objRB.End_User_Project__r.Name != null ? objRB.End_User_Project__r.Name : VAR_EMPTY);

            if (sourceType.equals('Opportunity')) {
                sourceObjectName = String.valueOf(objRB.Opportunity__r.Name != null ? objRB.Opportunity__r.Name : VAR_EMPTY);
                sourceObjectStatus = String.valueOf(objRB.Opportunity__r.StageName != null ? objRB.Opportunity__r.StageName : VAR_EMPTY);
                objRB.Application__c = application;
                objRB.BU__c = buVal;
                objRB.Business_Line__c = businessLine;
                objRB.ABB_Domain__c = abbDomain;
                objRB.Channel_Class_Level1__c = channelClass1;
                objRB.Channel_Class_Level2__c = channelClass2;
                objRB.ABB_Industry_Usage_Level1__c = indUsage1;
                objRB.ABB_Industry_Usage_Level2__c = indUsage2;
                objRB.ABB_Industry_Usage_Level3__c = indUsage3;             
                List < Apttus__APTS_Agreement__c > lstAgmnt = new List < Apttus__APTS_Agreement__c > ();
                if(objRB.Source_Agreement__c !=null){
                    lstAgmnt = [SELECT id, Name, Apttus__Contract_Start_Date__c, Apttus__Status_Category__c,
                        Apttus__Contract_End_Date__c, Payment_Schedule__c, Apttus__Related_Opportunity__c,Recordtype.Developername
                        FROM Apttus__APTS_Agreement__c where id=:objRB.Source_Agreement__c
                    ];
                }
                /* lstAgmnt = [SELECT id, Name, Apttus__Contract_Start_Date__c, Apttus__Status_Category__c,
                    Apttus__Contract_End_Date__c, Payment_Schedule__c, Apttus__Related_Opportunity__c
                    FROM Apttus__APTS_Agreement__c where Apttus__Related_Opportunity__c =: sourceId AND(Apttus__Status_Category__c = 'In Effect'
                        OR Apttus__Status_Category__c = 'Amended') AND (Recordtype.Developername =: VAR_FRAMEAGMT OR Recordtype.Developername =: VAR_DEALAGMT)
                ];

               if (lstAgmnt.IsEmpty()) {
                    //Get Frame Agreement (Quotation )
                    List < Apttus_Proposal__Proposal__c > lstQuote = [SELECT id, Apttus_QPComply__MasterAgreementId__c FROM Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c =: sourceId AND RecordType.Developername = 'APTS_Frame_Agreement'
                        AND APTS_Active_Version__c = TRUE AND Apttus_Proposal__Primary__c = TRUE
                    ];
                    if (lstQuote.size() > 0 && lstQuote[0].Apttus_QPComply__MasterAgreementId__c != null) {
                        //For CCP agreement
                        lstAgmnt = new List < Apttus__APTS_Agreement__c > ();
                        lstAgmnt = [SELECT id, Name, Apttus__Contract_Start_Date__c, Apttus__Status_Category__c,
                            Apttus__Contract_End_Date__c, Payment_Schedule__c, Apttus__Related_Opportunity__c
                            FROM Apttus__APTS_Agreement__c where id =: lstQuote[0].Apttus_QPComply__MasterAgreementId__c AND Apttus__Status_Category__c = 'In Effect'
                            AND Recordtype.Developername =: VAR_FRAMEAGMT
                        ];
                    }
                }

                lstAgmnt = RecurringBusinessOpportunityHelper.finaliseTheSourceAgreement(lstAgmnt); //  Req - 6464 
                Recurring_Business__c newRB = new Recurring_Business__c();
                newRB.Source_Agreement__c = lstAgmnt.size() > 0 ? lstAgmnt[0].id : null;
                newRB.id = objRB.id;
                try {
                    update newRB;
                } catch (Exception e) {
                    system.debug(e.getMessage());
                } */

                objRB = getRBDetails(recBuId);
                if (lstAgmnt.size() > 0) {
                    objRB.Start_Date__c = lstAgmnt[0].Apttus__Contract_Start_Date__c != null ? lstAgmnt[0].Apttus__Contract_Start_Date__c : null;
                    objRB.End_Date__c = lstAgmnt[0].Apttus__Contract_End_Date__c != null ? lstAgmnt[0].Apttus__Contract_End_Date__c : null;
                    SourceAgreementId = String.valueof(lstAgmnt[0].id);
                    SourceAgreementName = String.valueof(lstAgmnt[0].Name);
                }

            } else if (sourceType.equals('Account')) {
                sourceObjectName = String.valueOf(objRB.Account_Customer__r.Name != null ? objRB.Account_Customer__r.Name : VAR_EMPTY);
                sourceObjectStatus = '';
                objRB.Channel_Class_Level1__c = channelClass1;
                objRB.Channel_Class_Level2__c = channelClass2;
                objRB.Application__c = application;
                objRB.Business_Line__c = businessLine;
                objRB.ABB_Industry_Usage_Level1__c = indUsage1;
                objRB.ABB_Industry_Usage_Level2__c = indUsage2;
                objRB.ABB_Industry_Usage_Level3__c = indUsage3;
                objRB.BU__c = buVal;
                objRB.ABB_Domain__c = abbDomain;
                objRB.TotalRBValue__c = objRB.TotalRBValue__c != null ? objRB.TotalRBValue__c : 0;
                objRB.Frequency__c = objRB.Frequency__c != null ? objRB.Frequency__c : 'Monthly';

            } else if (sourceType.equals('CPBP')) {
                sourceObjectName = String.valueOf(objRB.ChannelPartner_BusinessPlan__r.Name != null ? objRB.ChannelPartner_BusinessPlan__r.Name : VAR_EMPTY);
                sourceObjectStatus = String.valueOf(objRB.ChannelPartner_BusinessPlan__r.Status__c != null ? objRB.ChannelPartner_BusinessPlan__r.Status__c : VAR_EMPTY);
                objRB.Application__c = application;
                objRB.BU__c = buVal;
                objRB.Business_Line__c = businessLine;
                objRB.ABB_Domain__c = abbDomain;
                objRB.Channel_Class_Level1__c = channelClass1;
                objRB.Channel_Class_Level2__c = channelClass2;
                objRB.ABB_Industry_Usage_Level1__c = indUsage1;
                objRB.ABB_Industry_Usage_Level2__c = indUsage2;
                objRB.ABB_Industry_Usage_Level3__c = indUsage3;
            }
            returnObj = new RecurringBusinessWrapperClasses.OnLoadWrapper(objRB, lstFulfillItems, abbLocationName, offeringPGName, accEndUserName, endUserProjName, sourceObjectName,
                accountCustomerName, rbCount, sourceObjectStatus, SourceAgreementId, SourceAgreementName,String.valueOf(objRB.Campaign__r.Name));
        } else {
            // query all the details from source and set in rb object and add it to the wrapper class.
            if (sourceType.equals('Opportunity')) {

                returnObj = RecurringBusinessOpportunityHelper.getNewRBDataFromSourceOpportunity(sourceId);

            } else if (sourceType.equals('Account')) {

                returnObj = RecurringBusinessAccountHelper.getNewRBDataFromSourceAccount(sourceId);

            } else if (sourceType.equals('CPBP')) {

                returnObj = RecurringBusinessCPBPHelper.getNewRBDataFromSourceCPBP(sourceId);

            }

        }
        return returnObj;
    }


    /**
    @author  Lavanya Krishnan
    @created 2018-04-01
    @Method Name:  getProductSplitFullFillData
    **/
    @AuraEnabled
    public static List < RecurringBusinessWrapperClasses.Sourcelineitems > getProductSplitFullFillData(String sourceId, String rbRecid, String sourceType) {
        List < RecurringBusinessWrapperClasses.Sourcelineitems > listRBlineitems = null;

        if (sourceType.equals('Opportunity')) {

            listRBlineitems = RecurringBusinessOpportunityHelper.getProductSplitFullFillData(sourceId, rbRecid);

        } else if (sourceType.equals('Account')) {

            listRBlineitems = RecurringBusinessAccountHelper.getProductSplitFullFillData(sourceId, rbRecid);

        } else if (sourceType.equals('CPBP')) {

            listRBlineitems = RecurringBusinessCPBPHelper.getProductSplitFullFillData(sourceId, rbRecid);

        }


        return listRBlineitems;

    }


    /**
    @author  Lavanya Krishnan
    @created 2018-04-01
    @Method Name:  getProductSplitPageLoad
    **/
    @AuraEnabled
    public static List < RecurringBusinessWrapperClasses.Sourcelineitems > getProductSplitPageLoad(String sourceId, String rbRecid, String sourceType) {
        List < RecurringBusinessWrapperClasses.Sourcelineitems > listRBlineitems = null;

        if (sourceType.equals('Opportunity')) {

            listRBlineitems = RecurringBusinessOpportunityHelper.getProductSplitPageLoad(sourceId, rbRecid);

        } else if (sourceType.equals('Account')) {

            listRBlineitems = RecurringBusinessAccountHelper.getProductSplitPageLoad(sourceId, rbRecid);

        } else if (sourceType.equals('CPBP')) {

            listRBlineitems = RecurringBusinessCPBPHelper.getProductSplitPageLoad(sourceId, rbRecid);

        }


        return listRBlineitems;

    }



    /**
     @author  Lavanya Krishnan
     @created 2018-04-03
     @Method Name:  processCreateRO
     **/
    @AuraEnabled
    public static List < RecurringBusinessWrapperClasses.FullFillItems > processCreateRO(String recBuId, String sourceId, String sourceType, String rbObj) {
        String isROCreatableResponse = '';  
        System.debug('###' + rbObj);          
        Recurring_Business__c rbObject = (Recurring_Business__c) JSON.deserialize(rbObj, Recurring_Business__c.class);
        List < RecurringBusinessWrapperClasses.FullFillItems > returnResp = new List < RecurringBusinessWrapperClasses.FullFillItems > ();
        if (sourceType.equals('Opportunity')) {

            if (updateRecurringBusinessObject(rbObject, recBuId)) {
                isROCreatableResponse = RecurringBusinessOpportunityHelper.checkIfROsCreatable(sourceId);
                if (isROCreatableResponse.equals(MSG_SUCCESS)) {
                    RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper scopeChangeResult = RecurringBusinessOpportunityHelper.checkForScopeAndFieldChange(recBuId, sourceId);
                    if (scopeChangeResult.hasScopeChanged) {               
                        returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, scopeChangeResult.message));
                    } else {
                        try {
                            returnResp = createRecurringOpportunity(recBuId, sourceType);
                        } catch (Exception e) {
                            returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, VAR_ERROR1 + ' : ' + e.getMessage()));
                        }
                    }
                } else {
                    returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, isROCreatableResponse));
                }
            }

        } else if (sourceType.equals('Account')) {
            rbObject = updateRBRecordsForPicklistFields(rbObject);
            if (updateRecurringBusinessObject(rbObject, recBuId)) {
                if (RecurringBusinessAccountHelper.getSourceAccountStatus(sourceId)) {
                RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper scopeChangeResult = RecurringBusinessAccountHelper.checkForScopeChange(recBuId, sourceId);
                   if (scopeChangeResult.hasScopeChanged) {                   
                        returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, scopeChangeResult.message));
                    } else {
                        try {
                            returnResp = createRecurringOpportunity(recBuId, sourceType);
                        } catch (Exception e) {
                            returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, VAR_ERROR1 + ' : ' + e.getMessage()));
                        }
                    }
                }
            }

        } else if (sourceType.equals('CPBP')) {
            rbObject = updateRBRecordsForPicklistFields(rbObject);
            RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper scopeChangeResult = RecurringBusinessCPBPHelper.checkForScopeChange(recBuId, sourceId);
           if (scopeChangeResult.hasScopeChanged) {          
                returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, scopeChangeResult.message));
            } else {
                if (RecurringBusinessCPBPHelper.checkIfCPBPIsActive(sourceId)) {
                    if (updateRecurringBusinessObject(rbObject, recBuId)) {
                        try {
                            returnResp = createRecurringOpportunity(recBuId, sourceType);
                        } catch (Exception e) {
                            returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, VAR_ERROR1 + ' : ' + e.getMessage()));
                        }
                    } else {
                        returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, VAR_ERROR4));
                    }
                } else {
                    returnResp.add(new RecurringBusinessWrapperClasses.FullFillItems(null, null, null, VAR_ERROR5));
                }


            }

        }

        return returnResp;

    }



    /**
    @author  Lavanya Krishnan
    @created 2018-04-03
    @Method Name:  processUpdateRO
    **/
    @AuraEnabled
    public static String processUpdateRO(String recBuId, String rbStatus, String sourceId, String sourceType, String rbObj, String rbRefItems) {
        String result = '';
     if(rbObj != null){     
        Recurring_Business__c rbObject = (Recurring_Business__c) JSON.deserialize(rbObj, Recurring_Business__c.class);      
        Boolean proceedWithROUpdation = false;
        String isROCreatableResponse = '';
        List < RB_Reference__c > rbReflst = null;
        List < RB_Reference__c > lstItems = (List < RB_Reference__c > ) JSON.deserialize(rbRefItems, List < RB_Reference__c > .class);
        if (sourceType.equals('Opportunity')) {
            if (rbStatus.equals('Draft')) {
            RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper scopeChangeResult =  RecurringBusinessOpportunityHelper.checkForScopeAndFieldChange(recBuId, sourceId);
            if(scopeChangeResult.hasScopeChanged) {         
                    proceedWithROUpdation = false;
                    result = scopeChangeResult.message;
                } else {
                    proceedWithROUpdation = true;
                }
            } else if (rbStatus.equals('In Progress')) {
                proceedWithROUpdation = true;
            }

            if (proceedWithROUpdation) {
                isROCreatableResponse = RecurringBusinessOpportunityHelper.checkIfROsCreatable(sourceId);
                if (isROCreatableResponse.equals(MSG_SUCCESS)) {
                    if(updateRecurringBusinessObject(rbObject ,recBuId)){
                    
                    lstItems = updateRBRefWithStatusAndROName(lstItems,rbObject);                   
                    rbReflst = updateRBReferenceAndSyncRO(lstItems);
                    if (rbReflst != null) {
                        if (RecurringBusinessHelper.updateRO(recBuId)) {
                            if (updateRBStatusBasedOnRO(recBuId, rbObject)) {
                                result = VAR_ROSUCCESS;
                            } else {
                                result = 'Recurring Opportunities have been synced and saved successfully \n But an Error occured during update of Recurring Business Status';
                            }

                        } else {
                            result = VAR_ERROR2;
                        }
                    }

                      }
                } else {
                    result = isROCreatableResponse;
                }
            }

        } else if (sourceType.equals('Account')) {
            rbObject = updateRBRecordsForPicklistFields(rbObject);
            if (rbStatus.equals('Draft')) {
            RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper scopeChangeResult =  RecurringBusinessAccountHelper.checkForScopeChange(recBuId, sourceId);
                if (scopeChangeResult.hasScopeChanged) {              
                    proceedWithROUpdation = false;
                    result = scopeChangeResult.message;
                } else {
                    proceedWithROUpdation = true;
                }
            } else if (rbStatus.equals('In Progress')) {
                proceedWithROUpdation = true;
            }

            if (proceedWithROUpdation) {
                if(updateRecurringBusinessObject(rbObject,recBuId)){
                lstItems = updateRBRefWithStatusAndROName(lstItems,rbObject);
                rbReflst = updateRBReferenceAndSyncRO(lstItems);
                if (rbReflst != null) {
                    if (RecurringBusinessHelper.updateRO(recBuId)) {
                        if (updateRBStatusBasedOnRO(recBuId, rbObject)) {
                            result = VAR_ROSUCCESS;
                        } else {
                            result = 'Recurring Opportunities have been synced and saved successfully \n But an Error occured during update of Recurring Business Status';
                        }
                    } else {
                        result = VAR_ERROR2;
                    }
                } else {
                    result = VAR_ERROR3;
                }
                  }
            }

        } else if (sourceType.equals('CPBP')) {
            rbObject = updateRBRecordsForPicklistFields(rbObject);
            if(updateRecurringBusinessObject(rbObject,recBuId)){
            lstItems = updateRBRefWithStatusAndROName(lstItems,rbObject);           
            rbReflst = updateRBReferenceAndSyncRO(lstItems);
            if (rbReflst != null) {
                if (RecurringBusinessHelper.updateRO(recBuId)) {
                    if (updateRBStatusBasedOnRO(recBuId, rbObject)) {
                        result = VAR_ROSUCCESS;
                    } else {
                        result = 'Recurring Opportunities have been synced and saved successfully \n But an Error occured during update of Recurring Business Status';
                    }
                } else {
                    result = VAR_ERROR2;
                }
            }
               }               
        }
    }
        if (result.equals(VAR_ROSUCCESS)) {
            syncRBAndROOwners(recBuId);
        }
        return result;
    }

    /**
     @author  Lavanya
     @created 2018-04-09
     @Method Name:  getRefreshedData
     **/
    @AuraEnabled
    public static List < RecurringBusinessWrapperClasses.RefreshWrapper > getRefreshedData(String sourceId, String recBuId, String sourceType) {
        List < RecurringBusinessWrapperClasses.RefreshWrapper > retValue = new List < RecurringBusinessWrapperClasses.RefreshWrapper > ();

        if (sourceType.equals('Opportunity')) {

            retValue = RecurringBusinessOpportunityHelper.getRefreshedData(sourceId, recBuId);

        } else if (sourceType.equals('Account')) {

            retValue = RecurringBusinessAccountHelper.getRefreshedData(sourceId, recBuId);

        } else if (sourceType.equals('CPBP')) {

            retValue = RecurringBusinessCPBPHelper.getRefreshedData(sourceId, recBuId);

        }
        return retValue;
    }


    @AuraEnabled
    public static Boolean checkForScopeChange(string rbId, String sourceId, String sourceType) {
        RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper scopeChangeResult = null;
        Boolean retVal = false;
        if (sourceType.equals('Opportunity')) {

            scopeChangeResult = RecurringBusinessOpportunityHelper.checkForScopeChange(rbId, sourceId);         

        } else if (sourceType.equals('Account')) {

            scopeChangeResult = RecurringBusinessAccountHelper.checkForScopeChange(rbId, sourceId);

        } else if (sourceType.equals('CPBP')) {

            scopeChangeResult = RecurringBusinessCPBPHelper.checkForScopeChange(rbId, sourceId);

        } 
        retVal= scopeChangeResult != null ? scopeChangeResult.hasScopeChanged : false;
        System.debug('checkforscopechange scopeChangeResult='+scopeChangeResult);
        return retVal;

    }


    /**
    @author  Lavanya Krishnan
    @created 2018-05-31
    @Method Name:  updateRBStatusBasedOnRO
    **/
    @AuraEnabled
    public static boolean updateRBStatusBasedOnRO(String recBuId, Recurring_Business__c rbObj) {
        Boolean retVal = false;
        //Recurring_Business__c rbObject = (Recurring_Business__c) JSON.deserialize(rbObj, Recurring_Business__c.class);
        Integer totalROCount = 0;
        Integer OpenROCount = 0;
        Integer WonROCount = 0;
        Integer CancelledROCount = 0;
        String rbStatusToUpdate = '';
        List < Opportunity > roList = RecurringBusinessHelper.getAllROsForRB(recBuId);
        totalROCount = roList.size();
        for (Opportunity o: roList) {
            if (o.StageName.equals('Negotiation')) {
                OpenROCount++;
            } else if (o.StageName.equals('Closed Lost (Cancelled)')) {
                CancelledROCount++;
            } else if (o.StageName.equals('Closed Won')) {
                WonROCount++;
            }
        }

        if (OpenROCount > 0) {
            rbStatusToUpdate = 'In Progress';
        } else if (CancelledROCount == totalROCount) {
            rbStatusToUpdate = 'Cancelled';
        } else if (WonROCount > 0 && OpenROCount > 0) {
            rbStatusToUpdate = 'In Progress';
        } else if (WonROCount > 0 && OpenROCount == 0) {
            rbStatusToUpdate = 'Closed';
        } else {
            rbStatusToUpdate = 'In Progress';
        }
        System.debug('OpenROCount $$$$$ =' + OpenROCount);
        System.debug('totalROCount $$$$$ =' + totalROCount);
        System.debug('CancelledROCount $$$$$ =' + CancelledROCount);
        System.debug('WonROCount $$$$$ =' + WonROCount);
        System.debug('rbStatusToUpdate $$$$$ =' + rbStatusToUpdate);
        rbObj.Status__c = rbStatusToUpdate;
        //String rbObjSerialised = JSON.serialize(rbObject);

        retVal = updateRecurringBusinessObject(rbObj, recBuId);

        return retVal;

    }

    /**
    @author  Lavanya Krishnan
    @created 2018-07-04
    @Method Name:  syncRBAndROOwners
    **/
    @future
    public static void syncRBAndROOwners(String rbId) {
        System.debug('Entered syncRBAndROOwners ; rbId: ' + rbId);
        /*
        1. Query the RB object with owner details
        2. Query All the Open ROs associated with this RB
        3. Check if the owner of the RB and Owner of the Open ROs are in sync 
        4. If not - sync them
        5. Update all the ROs
        */
        Recurring_Business__c rbObj = getRBDetails(rbId);
        List < Opportunity > openROList = RecurringBusinessHelper.getAllOpenROsForRB(rbId);
        List < Opportunity > openROListToUpdate = new List < Opportunity > ();
        for (Opportunity opp: openROList) {
            if (opp.OwnerId != rbObj.OwnerId) {
                opp.OwnerId = rbObj.OwnerId;
                openROListToUpdate.add(opp);
            }
        }
        System.debug('openROListToUpdate=' + openROListToUpdate);
        if (openROListToUpdate.size() > 0) {
            Database.update(openROListToUpdate);
        }
    }
    
     /**
    @author  Lavanya
    @created 2018-08-02
    @Method Name:  checkForMissingABBLocOnOppLineItems
    **/
    @AuraEnabled
    public static boolean checkForMissingABBLocOnOppLineItems(String sourceId) {            
        Boolean abbLocMissing = RecurringBusinessOpportunityHelper.checkForMissingABBLocOnOppLineItems(sourceId); 
        System.debug('abbLocMissing = '+abbLocMissing);       
        return abbLocMissing;
    }
    
     /**
    @author  Lavanya
    @created 2018-08-022
    @Method Name:  updateRBRefWithStatusAndROName
    **/
    @AuraEnabled
    public static List<RB_Reference__c> updateRBRefWithStatusAndROName(List<RB_Reference__c> lstItems,Recurring_Business__c rbObject) { 
        for (RB_Reference__c rbref: lstItems) {
            rbref.RO_Custom_Name__c = RecurringBusinessHelper.constructRBName(rbref.RO_Name__c,rbObject.Frequency__c,rbRef.EAD__c,rbObject.Name);
            //if (rbref.Status__c.equals('Draft')) {
            if (rbref.Fulfill__c.equals('No')) {
                rbref.Status__c = 'In Progress';
            }
        }
        return lstItems;
    }
   
     @AuraEnabled
    public static Recurring_Business__c updateRBRecordsForPicklistFields(Recurring_Business__c RBRec) {
        Map<String, Map<String, String>> valuesMapping = prepareValuesMapping();
        for(string field: DESTINATION_FIELDS.keySet()){
            if (isForMapping(RBRec, field, valuesMapping)) {
                String fieldValue = (String)RBRec.get(field);
                RBRec.put(getDestinationFieldName(field), valuesMapping.get(field).get(fieldValue.toLowerCase()));
            } else if (isNoneValue(RBRec, field)) {
                RBRec.put(getDestinationFieldName(field), null);
            } else {
                RBRec.put(getDestinationFieldName(field), RBRec.get(field));
            }
        }
        return RBRec;
    }
 
  
    @AuraEnabled
    public static Map<String, Map<String, String>> prepareValuesMapping() {
            Map<String, Map<String, String>> valuesMapping = new Map<String, Map<String, String>>();
            for (String fieldName : DESTINATION_FIELDS.keySet()) {
                Map<String, String> fieldMapping = lowerTheKeys(
                    RecurringBusinessHelper.fetchOpportunityPickListDescValueMap(fieldName, VAR_VALUE));
                valuesMapping.put(fieldName, fieldMapping);
            }
            return valuesMapping;
    }
 
    @AuraEnabled
    public static String getDestinationFieldName(String textFieldName) {
        return DESTINATION_FIELDS.get(textFieldName);
    }
   
    public static Boolean isForMapping(Recurring_Business__c record, String field,Map<String, Map<String, String>> valuesMapping) {
        return record.get(field) != null && 
            valuesMapping.get(field).containsKey(((String)record.get(field)).toLowerCase());
    }
    
    public static Boolean isNoneValue(Recurring_Business__c record, String field) {
        return (record.get(field) != null && record.get(field) == VAR_NONE);
    }
    
    public static Map<String, String> lowerTheKeys(Map<String, String> mapToLower) {
        Map<String, String> loweredMap = new Map<String, String>();
        for (String key : mapToLower.keySet()) {
            loweredMap.put(key.toLowerCase(), mapToLower.get(key));
        }
        return loweredMap;
    }
}