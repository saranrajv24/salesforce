/**
 *
 @author  Lavanya Krishnan
 @created 2018-03-27
 @version 1.0
 **/
global class RecurringBusinessCPBPHelper{

    public static final String VAR_EMPTY = '';
    public static final String VAR_YES = 'Yes';
    public static final String VAR_NO = 'No'; 
    public static final String VAR_HYPHON = ' - ';
    public static final String VAR_RBRECORDTYPE_NAME = 'Recurring Opportunity';
    public static final string VAR_NEGOTIATION = 'Negotiation';
    public static final String VAR_VALUE = 'Value';
    public static final String VAR_QUANTITY = 'Quantity';
    public static final String VAR_BUYING = 'Buying';
    public static final String VAR_INPROGRESS = 'In Progress';
    public static final string VAR_TOTALPRICE1 = 'totalPrice';
    public static final String VAR_UNKNOWNACCPOLAND = 'Unknown Account - PL';
    public static final String VAR_RB = 'RB - ';
    public static final String VAR_RO = 'RO';
    public static final String VAR_MONTHLY = 'Monthly';
    public static final String VAR_QUARTERLY = 'Quarterly';
    public static final String VAR_YEARLY = 'Yearly';
    public static final String VAR_INSERTRO = 'INSERT_RO';
    public static final String VAR_UPDATERO = 'UPDATE_RO';
    public static final String VAR_DELETERO = 'DELETE_RO';
    public static final string VAR_CANCELRB = 'CANCELRB';
    public static final string VAR_REOPENRB = 'REOPENRB';
    public static final String VAR_ZERO = '0';
    public static final String VAR_NONE = '-None-';
    public static final String VAR_DRAFT = 'Draft';
    public static final String VAR_INAPPROVAL = 'In Approval';
    public static final String VAR_ACTIVE = 'Active';
    public static final String VAR_CLOSEDWON = 'Closed Won';
    public static final String VAR_LOSTCANCELLED = 'Closed Lost (Cancelled)';
    public static final String VAR_CANCELLED = 'Cancelled';
    public static final String VAR_MAILBODY1 = 'This is to notify you that the Cancelling of Recurring Opportunity :';
    public static final String VAR_MAILBODY_SUCCESSFUL = ' was successful';
    public static final String VAR_MAILBODY_UNSUCCESSFUL = ' was unsuccessful';
    public static final String VAR_MAILBODY_SUBJECT = 'Recurring Opportunity Cancellation Status';
    public static final String VAR_SELECT = '--Select--';
    public static final String VAR_WON = 'Closed Won';


  /**
    @author  Rajesh
    @created 2017-26-20
    @Method Name:  getProductSplitFullFillData
    **/
    @AuraEnabled
    public static List<RecurringBusinessWrapperClasses.Sourcelineitems> getProductSplitFullFillData(String sourceId,String rbRecid) {        
        List<RecurringBusinessWrapperClasses.Sourcelineitems> listRBlineitems = new List<RecurringBusinessWrapperClasses.Sourcelineitems>();
        if(rbRecid == VAR_EMPTY){
            listRBlineitems = getProductsData(sourceId);
        }else{       
        List<RB_Reference__c> rbRefs = [SELECT id, EAD__c, RO_Name__c, Products_1__c, Status__c,Products_2__c, RB_ID__c, Total_Value__c,Fulfill__c FROM RB_Reference__c WHERE RB_ID__c =: rbRecid ORDER BY RO_Name__c ASC LIMIT 50000];
        
        List<RecurringBusinessWrapperClasses.Sourcelineitems> srcLineItems = getProductsData(sourceId);
        List<RecurringBusinessWrapperClasses.RoLineItems> listlines = new List<RecurringBusinessWrapperClasses.RoLineItems>();
        Map<String,List<RecurringBusinessWrapperClasses.RoLineItems>> mapROProds = new Map<String,List<RecurringBusinessWrapperClasses.RoLineItems>>();
        List<RecurringBusinessWrapperClasses.RoLineItems> toAdd = new List<RecurringBusinessWrapperClasses.RoLineItems>();
        Map<String,String> fullfilledROs = new Map<String,String>();
        Map<String,String> cancelledROs = new Map<String,String>();
        for(RB_Reference__c objRR : rbRefs){
            listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_1__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
            if(objRR.Products_2__c != null){
                listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_2__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
            }
            mapROProds.put(objRR.RO_Name__c,listlines);
            fullfilledROs.put(objRR.RO_Name__c,objRR.Fulfill__c);
            cancelledROs.put(objRR.RO_Name__c,objRR.Status__c);  
        }
        Boolean isFullfill = false;
        for(String s : fullfilledROs.keyset()){
            if(fullfilledROs.get(s) == VAR_YES){
                isFullfill = true;
                break;
            }
        }


        Map<String,String> productExistsinRO = new Map<String,String>();
        List<String> productNotinRO = new List<String>();
        Map<String,RecurringBusinessWrapperClasses.Sourcelineitems> prodDetails = new Map<String,RecurringBusinessWrapperClasses.Sourcelineitems>();
        for(RecurringBusinessWrapperClasses.Sourcelineitems sr : srcLineItems){
            productExistsinRO.put(sr.Productid,null);
            prodDetails.put(sr.Productid,sr);
        }
        system.debug('###'+mapROProds);
        system.debug('###'+fullfilledROs);
        system.debug('###'+productExistsinRO);
        Map<String,List<RecurringBusinessWrapperClasses.RoLineItems>> mapRBLines = new Map<String,List<RecurringBusinessWrapperClasses.RoLineItems>>();
        
        for(RecurringBusinessWrapperClasses.RoLineItems objRef : listlines){
            if(!mapRBLines.containsKey(objRef.Productid)){
                mapRBLines.put(objRef.Productid, new list<RecurringBusinessWrapperClasses.RoLineItems>{objRef});
            }    
            else{
                mapRBLines.get(objRef.Productid).add(objRef);
            }
            if(productExistsinRO.containsKey(objRef.Productid)){
                productExistsinRO.put(objRef.Productid,VAR_YES);
            }
        }
        system.debug('###'+productExistsinRO);
        system.debug(mapRBLines);
        String[] newlinefulfill;
        for(String objProdid : mapRBLines.keyset()){
            String prodid = VAR_EMPTY;
            String prodname = VAR_EMPTY;
            Decimal quantity = 0;
            Decimal unitprice = 0;
            Decimal totalprice = 0;
            Integer htotal = 0;
            String[] fulfill = new List<String>();
            newlinefulfill = new List<String>();
            String roname = VAR_EMPTY;
            String source = VAR_EMPTY;
            Boolean solidFreeze = false;
            Decimal[] tbonus = new List<Decimal>();
            String[] cancelStatus = new List<String>();
            Boolean selected =false;
            for(RecurringBusinessWrapperClasses.RoLineItems objline : mapRBLines.get(objProdid)){
                prodid = objline.Productid;
                //if(productExistsinRO.get(prodid)=='yes'){
                        prodid = objline.Productid;
                        prodname = objline.Productname;
                        quantity = objline.Quantity;
                        unitprice = objline.UnitPrice;
                        totalprice = objline.Totalprice;
                        tbonus.add(objline.ROvalue);    
                        htotal = htotal + Integer.valueof(objline.ROvalue);
                        fulfill.add(fullfilledROs.get(objline.ROname));
                        newlinefulfill.add(fullfilledROs.get(objline.ROname));
                       // fulfill = fullfilledROs.get(objline.ROname);
                        roname = objline.ROname;
                        source = productExistsinRO.containsKey(prodid)? VAR_YES : VAR_NO;
                        solidFreeze = productExistsinRO.containsKey(prodid)? true : false;
                        selected = productExistsinRO.containsKey(prodid)? true : false;
                        cancelStatus.add(cancelledROs.get(objline.ROname));
                        //if(isFullfill && source == VAR_NO){
                            listRBlineitems.add(new RecurringBusinessWrapperClasses.Sourcelineitems(prodid,prodname,UnitPrice,quantity,0,totalprice,htotal,tbonus,fulfill,roname,source,cancelStatus,selected,solidFreeze,null,false));//RB-6458
                       /* }else if(isFullfill && source == VAR_YES){
                             listRBlineitems.add(new RecurringBusinessWrapperClasses.Sourcelineitems(prodid,prodname,UnitPrice,quantity,0,totalprice,htotal,tbonus,fulfill,roname,source,cancelStatus,selected,'',null,false));//RB-6458
                        }else if(!isFullfill && source == VAR_YES){
                             listRBlineitems.add(new RecurringBusinessWrapperClasses.Sourcelineitems(prodid,prodname,UnitPrice,quantity,0,totalprice,htotal,tbonus,fulfill,roname,source,cancelStatus,selected,'',null,false));//RB-6458
                        }*/
               // }   
                
            }
            
        system.debug(listRBlineitems);
        }
        Boolean selected = true;
        for(String roIds : productExistsinRO.keyset()){
            if(productExistsinRO.containsKey(roIds)){
                String check = productExistsinRO.get(roIds);
                system.debug(check+'check');
                
                if(check == 'Yes'){
                    selected = false;
                    break;
                }
                
            }
        }
         if(selected == true){
            for(String roIds : productExistsinRO.keyset()){
                String prodid = VAR_EMPTY;
                String prodname = VAR_EMPTY;
                Decimal quantity = 0;
                Decimal unitprice = 0;
                Decimal totalprice = 0;
                Integer htotal = 0;
                String[] fulfill =new List<String>();
                String roname=VAR_EMPTY;
                String source = VAR_EMPTY;
                Decimal[] tbonus = new List<Decimal>();
                String[] cancelStatus = new List<String>();
                Integer count = 0;
                Integer newCount = 0;
                
                if(productExistsinRO.containsKey(roIds)){
                String check = productExistsinRO.get(roIds);
                    if(check == null){
                        prodid = roIds;
                        prodname = prodDetails.get(roIds).Productname;
                        quantity = prodDetails.get(roIds).Quantity;
                        unitprice = prodDetails.get(roIds).UnitPrice;
                        totalprice = prodDetails.get(roIds).Totalprice;   
                        htotal = htotal; 
                        if(newlinefulfill!= null && !newlinefulfill.isEmpty()){
                        fulfill.addall(newlinefulfill);
                        }else{
                        fulfill.add(VAR_EMPTY);    
                        }
                        roname= VAR_EMPTY;
                        source = productExistsinRO.get(roIds);
                        
                        system.debug('cond4'+'prodid:'+prodid+'prodname:'+prodname+'unitprice:'+UnitPrice+'quantity:'+quantity+0+'totalprice:'+totalprice+'htotal:'+htotal+'bonus:'+tbonus+'fulfill:'+fulfill+'roname:'+roname+'source:'+source+'cancel:'+cancelStatus+'sel:'+selected);
                        listRBlineitems.add(new RecurringBusinessWrapperClasses.Sourcelineitems(prodid,prodname,UnitPrice,quantity,0,totalprice,htotal,tbonus,fulfill,roname,source,cancelStatus,selected,false,null,false));//RB-6458
                                  
                    }
                }
            }   
        }else{
            for(String roIds : productExistsinRO.keyset()){
                String prodid = VAR_EMPTY;
                String prodname = VAR_EMPTY;
                Decimal quantity = 0;
                Decimal unitprice = 0;
                Decimal totalprice = 0;
                Integer htotal = 0;
                String[] fulfill =new List<String>();
                String roname=VAR_EMPTY;
                String source = VAR_EMPTY;
                Decimal[] tbonus = new List<Decimal>();
                String[] cancelStatus = new List<String>();
                Integer count = 0;
                Integer newCount = 0;
                
                if(productExistsinRO.containsKey(roIds)){
                String check = productExistsinRO.get(roIds);
                    if(check == null){
                        prodid = roIds;
                        prodname = prodDetails.get(roIds).Productname;
                        quantity = prodDetails.get(roIds).Quantity;
                        unitprice = prodDetails.get(roIds).UnitPrice;
                        totalprice = prodDetails.get(roIds).Totalprice;   
                        htotal = htotal; 
                        if(newlinefulfill!= null && !newlinefulfill.isEmpty()){
                        fulfill.addall(newlinefulfill);
                        }else{
                        fulfill.add('');    
                        }
                        roname= '';
                        source = productExistsinRO.get(roIds);
                        
                        system.debug('cond4'+'prodid:'+prodid+'prodname:'+prodname+'unitprice:'+UnitPrice+'quantity:'+quantity+0+'totalprice:'+totalprice+'htotal:'+htotal+'bonus:'+tbonus+'fulfill:'+fulfill+'roname:'+roname+'source:'+source+'cancel:'+cancelStatus+'sel:'+selected);
                        listRBlineitems.add(new RecurringBusinessWrapperClasses.Sourcelineitems(prodid,prodname,UnitPrice,quantity,0,totalprice,htotal,tbonus,fulfill,roname,source,cancelStatus,selected,false,null,false));//RB-6458
                                  
                    }
                }
            }
        }
        
        system.debug('###'+listRBlineitems);
        }
        return listRBlineitems;
    }
    
      @AuraEnabled
    public static List<RecurringBusinessWrapperClasses.Sourcelineitems> getProductSplitPageLoad(String sourceId,String rbRecid) {
        List<RecurringBusinessWrapperClasses.Sourcelineitems> listRBlineitems = new List<RecurringBusinessWrapperClasses.Sourcelineitems>();
        List<RecurringBusinessWrapperClasses.RoLineItems> listlines = new List<RecurringBusinessWrapperClasses.RoLineItems>();
        Integer roSize = 0;
        Map<Id,Map<String,Decimal>> mapROwithProd = new Map<Id,Map<String,Decimal>>();
        Map<String,List<RecurringBusinessWrapperClasses.RoLineItems>> mapRBLines = new Map<String,List<RecurringBusinessWrapperClasses.RoLineItems>>();
        Map<String,String> fullfilledROs = new Map<String,String>();
        Map<String,String> cancelledROs = new Map<String,String>();
        List<RecurringBusinessWrapperClasses.Sourcelineitems> srcLineItems = getProductsData(sourceId);
        Map<String,String> productExistsinRO = new Map<String,String>();
        for(RecurringBusinessWrapperClasses.Sourcelineitems sr : srcLineItems){
            productExistsinRO.put(sr.Productid,null);
        }
        if(rbRecid == VAR_EMPTY){
            listRBlineitems = getProductsData(sourceId);
        }else{
            List<RB_Reference__c> rbRefs = [SELECT id, EAD__c, RO_Name__c, Products_1__c, Status__c,Products_2__c, RB_ID__c, Total_Value__c,Fulfill__c FROM RB_Reference__c WHERE RB_ID__c =: rbRecid ORDER BY RO_Name__c ASC ];
            for(RB_Reference__c objRR : rbRefs){
                listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_1__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
                if(objRR.Products_2__c != null){
                    listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_2__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
                }
                roSize++;
                fullfilledROs.put(objRR.RO_Name__c,objRR.Fulfill__c);
                cancelledROs.put(objRR.RO_Name__c,objRR.Status__c); 
            }
            Boolean isFullfill = false;
            String roNameStat = '';
            for(String s : fullfilledROs.keyset()){
                if(fullfilledROs.get(s) ==VAR_YES){
                    isFullfill = true;
                    roNameStat = s;
                    system.debug('**##**'+roNameStat);
                }
            }
            for(RecurringBusinessWrapperClasses.RoLineItems objRef : listlines){
                if(!mapROwithProd.containsKey(objRef.Productid)){
                    mapROwithProd.put(objRef.Productid, new Map<String,Decimal>{objRef.ROname => objRef.ROvalue});
                }    
                else{
                    mapROwithProd.get(objRef.Productid).put(objRef.ROname,objRef.ROvalue);
                }
                if(!mapRBLines.containsKey(objRef.Productid)){
                    mapRBLines.put(objRef.Productid, new list<RecurringBusinessWrapperClasses.RoLineItems>{objRef});
                }    
                else{
                    mapRBLines.get(objRef.Productid).add(objRef);
                }
                if(productExistsinRO.containsKey(objRef.Productid)){
                if(objRef.Selected==true){
                    productExistsinRO.put(objRef.Productid,VAR_YES);
                }else{
                    productExistsinRO.put(objRef.Productid,VAR_NO);
                }
                }
            }
            for(String objProdid : mapRBLines.keyset()){
                String prodid = VAR_EMPTY;
                String prodname = VAR_EMPTY;
                Decimal quantity = 0;
                Decimal unitprice = 0;
                Decimal totalprice = 0;
                Integer htotal = 0;
                String[] fulfill = new List<String>();
                //newlinefulfill = new List<String>();
                String roname = VAR_EMPTY;
                String source = VAR_EMPTY;
                Decimal[] tbonus = new List<Decimal>();
                Map<String,Decimal> mapRO = mapROwithProd.get(objProdid);
                for(Integer i = 1;i<=roSize;i++){
                    if(mapRO.containsKey('RO'+i)){
                        tbonus.add(mapRO.get('RO'+i));
                    }else{
                        tbonus.add(0);
                    }
                }
                String[] cancelStatus = new List<String>();
                Boolean selected =false;
                Boolean sFreeze = false;
                for(RecurringBusinessWrapperClasses.RoLineItems objline : mapRBLines.get(objProdid)){
                    prodid = objline.Productid;
                    prodname = objline.Productname;
                    quantity = objline.Quantity;
                    unitprice = objline.UnitPrice;
                    totalprice = objline.Totalprice;
                    //tbonus.add(objline.ROvalue);    
                    htotal = htotal + Integer.valueof(objline.ROvalue);
                    fulfill.add(fullfilledROs.get(objline.ROname));
                    //newlinefulfill.add(fullfilledROs.get(objline.ROname));
                    roname = roNameStat;
                    source = productExistsinRO.containsKey(prodid)? VAR_YES : VAR_NO;
                    //selected = objline.Selected;//selected = productExistsinRO.containsKey(prodid)? true : false;
                    selected =  (productExistsinRO!=null && !productExistsinRO.isEmpty() && productExistsinRO.containsKey(prodid)) ? (productExistsinRO.get(prodid).equals(VAR_YES)? true : false) : objline.Selected;
                    sFreeze = objline.SolidFreeze;//productExistsinRO.containsKey(prodid)? false : true;
                    cancelStatus.add(cancelledROs.get(objline.ROname));
                    listRBlineitems.add(new RecurringBusinessWrapperClasses.Sourcelineitems(prodid,prodname,UnitPrice,quantity,0,totalprice,htotal,tbonus,fulfill,roname,source,cancelStatus,selected,sFreeze,null,false));//RB-6458
                }
            }
                        
        }
        system.debug(listRBlineitems);
        return listRBlineitems;
    }
    
    
        /**
    @author  Rajesh
    @created 2017-03-08
    @Method Name:  getProductsData
    **/
    @AuraEnabled
    public static List<RecurringBusinessWrapperClasses.Sourcelineitems> getProductsData(String sourceId) {
       
        List<RecurringBusinessWrapperClasses.Sourcelineitems> lstSourcelines = new List<RecurringBusinessWrapperClasses.Sourcelineitems>();                   
        Map<Id, List<Joint_Business_Plan_Product_Lines__c>> mapproducts = new Map<Id, List<Joint_Business_Plan_Product_Lines__c>>();       
          for(Joint_Business_Plan_Product_Lines__c objline : [Select Product__c, Product__r.Name, Current_Year_Currency__c from Joint_Business_Plan_Product_Lines__c where Joint_Business_Plan__c =:sourceId and Current_Year_Currency__c >0 and Current_Year_Currency__c <> null LIMIT 50000]){
            if(!mapproducts.containsKey(objline.Product__c)){ 
                mapproducts.put(objline.Product__c,new List<Joint_Business_Plan_Product_Lines__c>{objline});
            }else {
               mapproducts.get(objline.Product__c).add(objline);
            }
        }
        for(Id objprod : mapproducts.keyset()){
            Decimal varUnitprice = 0;
            Decimal varQuantity = 0;
            Decimal varSubTotal = 0;
            Decimal varTotalprice = 0;
            Id prodid = null;
            String prodname = VAR_EMPTY;
            List<Decimal> bonus = new List<Decimal>();
            List<String> fullfill = new List<String>();
            List<String> cancelStatus = new List<String>();
            for(Joint_Business_Plan_Product_Lines__c objprodline : mapproducts.get(objprod)){
                if(objprodline.Current_Year_Currency__c <> null){
                    varTotalprice = varTotalprice + objprodline.Current_Year_Currency__c;
                }
                prodid = objprodline.Product__c;
                prodname = objprodline.Product__r.Name;
            }
            lstSourcelines.add(new RecurringBusinessWrapperClasses.Sourcelineitems(prodid, prodname, varUnitprice, varQuantity, varSubTotal, varTotalprice, null, bonus ,fullfill,VAR_ZERO,VAR_ZERO,cancelStatus,true,false,null,false));//RB-6458
        }
        
        return lstSourcelines;
    }
    
     /**
    @author  Rajesh
    @created 2017-26-20
    @Method Name:  getRefreshedData
    **/
    @AuraEnabled
    public static List<RecurringBusinessWrapperClasses.RefreshWrapper> getRefreshedData(String sourceId, String recBuId) {
        List<RecurringBusinessWrapperClasses.RefreshWrapper> retValue = new List<RecurringBusinessWrapperClasses.RefreshWrapper>();
        List<Recurring_Business__c> lstRBcount = [Select id from Recurring_Business__c where Parent__c =: sourceId];
        List<Joint_Business_Plan_Product_Lines__c> cpbpLineitems  = [SELECT Current_Year_Currency__c FROM Joint_Business_Plan_Product_Lines__c where Current_Year_Currency__c <> null and                                                           Joint_Business_Plan__c =:sourceId];
        Decimal oppLineItemTotalPrice = 0;
        List<Joint_Business_Plan__c> objcpbp = [SELECT Name, Start_Date__c, Status__c, End_Date__c, Account__c,Account__r.Name,CurrencyIsoCode FROM Joint_Business_Plan__c where id =:sourceId LIMIT 1];
      
        for(Joint_Business_Plan_Product_Lines__c result : cpbpLineitems){
            if(result.Current_Year_Currency__c <> null){
                oppLineItemTotalPrice = oppLineItemTotalPrice + result.Current_Year_Currency__c;
            }
        }  

        if(recBuId != VAR_EMPTY){
            List<Recurring_Business__c> lstRB = [SELECT Id, ABB_Domain__c,ABB_Industry_Usage_Level1__c,ABB_Industry_Usage_Level2__c,ABB_Industry_Usage_Level3__c,
                                                ABB_Location__c,ABB_Location__r.name,Account_Customer__c,Account_End_User__c,Account_End_User__r.name,All_Target_vs_All_Commit__c,Application__c,
                                                Award_Date__c,Business_Line__c,BU__c,Channel_Class_Level1__c,Channel_Class_Level2__c,
                                                CurrencyIsoCode,Opportunity__r.Name,Account_Customer__r.Name,
                                                End_Date__c,End_User_Project__c,End_User_Project__r.name,Frequency__c,Offering_Primary_PG__c,Name,Opportunity__c,
                                                Parent__c,Periods__c,Quantity__c,Start_Date__c,Reason_For_Cancellation__c,
                                                Status__c,TotalRBValue__c,Type__c,Value__c,Source_Agreement__c, Source_Agreement__r.Name,Source_Agreement__r.Apttus__Contract_Start_Date__c,
                                                Source_Agreement__r.Apttus__Contract_End_Date__c,Schedule_Period__c,Scheduler_Day__c,Scheduler_Month__c,Scheduler_Repeat_On__c,Application_PickVal__c,
                                                BU_PickVal__c,Business_Line_PickVal__c,ABB_Domain_PickVal__c,Channel_Class_Level1_PickVal__c,Channel_Class_Level2_Pickval__c,Industry_Usage_Level1_PickVal__c,
                                                Industry_Usage_Level2_PickVal__c,Industry_Usage_Level3_PickVal__c FROM Recurring_Business__c where Id=:recBuId LIMIT 1];
         
            List<Recurring_Business__c> newRBLst = [SELECT Id,Source_Agreement__c, Source_Agreement__r.Name,Source_Agreement__r.Apttus__Contract_Start_Date__c,Source_Agreement__r.Apttus__Contract_End_Date__c FROM Recurring_Business__c where Id =:recBuId];

            if(lstRB!=null && lstRB.size()>0){
            Joint_Business_Plan__c cpbp=null;
                retValue.add(new RecurringBusinessWrapperClasses.RefreshWrapper(cpbp,lstRB[0],true,null,Integer.valueOf(oppLineItemTotalPrice))); 
            }
        }else{
            if(objcpbp!=null && objcpbp.size()>0){
                retValue.add(new RecurringBusinessWrapperClasses.RefreshWrapper(objcpbp[0],null,false,null,Integer.valueOf(oppLineItemTotalPrice))); 
            }
        }
        return retValue;
    }
    
    
   
      @AuraEnabled
    public static RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper checkForScopeChange(string rbId, String cpbpId){
        Boolean scopeChange = false;
        //get line items from source
        List<RecurringBusinessWrapperClasses.Sourcelineitems> srcLineItems = getProductsData(cpbpId);
        //get split json from rb
        List<RB_Reference__c> rbRefs = [SELECT id, EAD__c, RO_Name__c, Products_1__c, Status__c,Products_2__c, RB_ID__c, Total_Value__c,Fulfill__c FROM RB_Reference__c WHERE RB_ID__c =: rbId];
        List<RecurringBusinessWrapperClasses.RoLineItems> listlines = new List<RecurringBusinessWrapperClasses.RoLineItems>();
        for(RB_Reference__c objRR : rbRefs){
            listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_1__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
            if(objRR.Products_2__c != null){
                listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_2__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
            }    
        }
        Set<Id> productInSplit = new Set<Id>();
        Set<Id> productInSource = new Set<Id>();
        Set<Id> productInSplitSolidFreezed = new Set<Id>();
        Map<Id,Decimal> mapProdInSplitQuant = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProdInSplitPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProdInSrcQuant = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProdInSrcPrice = new Map<Id,Decimal>();
        for(RecurringBusinessWrapperClasses.RoLineItems objRef : listlines){
            productInSplit.add(objRef.Productid); //store the product from split to this collection
            mapProdInSplitQuant.put(objRef.Productid,objRef.Quantity);
            mapProdInSplitPrice.put(objRef.Productid,objRef.Totalprice);
            if(objRef.SolidFreeze == true){
            productInSplitSolidFreezed.add(objRef.Productid);
            }
        }
        for(RecurringBusinessWrapperClasses.Sourcelineitems src : srcLineItems){
            productInSource.add(src.Productid); //store the product from source to this collection
            mapProdInSrcQuant.put(src.Productid,src.Quantity);
            mapProdInSrcPrice.put(src.Productid,src.TotalPrice);
        }
        Set<Id> prodNotInSplit = new Set<Id>();
        Set<Id> prodNotInSource = new Set<Id>();
        
        //Newly added
        for(Id srcProds : productInSource){
            if(!productInSplit.contains(srcProds)){
                prodNotInSplit.add(srcProds);
            }
        }
        //Deleted
        Boolean quantityChange = false;
        Boolean valueChange = false;
        for(Id splitProds : productInSplit){
            if(!productInSource.contains(splitProds)){
                 if(!productInSplitSolidFreezed.contains(splitProds)){
                prodNotInSource.add(splitProds);
            }  
            }
            //Quantity change check
            system.debug(splitProds+''+mapProdInSplitQuant.get(splitProds));
            system.debug(splitProds+''+mapProdInSrcQuant.get(splitProds));
            if(mapProdInSplitQuant.get(splitProds) != null && mapProdInSrcQuant.get(splitProds) != null){
                if(mapProdInSplitQuant.get(splitProds) != mapProdInSrcQuant.get(splitProds)){
                    quantityChange = true;
                    break;
                }
            }
            //Value change check
            system.debug(splitProds+''+mapProdInSplitPrice.get(splitProds));
            system.debug(splitProds+''+mapProdInSrcPrice.get(splitProds));
            if(mapProdInSplitQuant.get(splitProds) != null && mapProdInSrcQuant.get(splitProds) != null){
                if(mapProdInSplitPrice.get(splitProds) != mapProdInSrcPrice.get(splitProds)){
                    valueChange = true;
                    break;
                }
            }
        }
        system.debug(prodNotInSplit);
        system.debug(prodNotInSource);
        system.debug(quantityChange);
        system.debug(valueChange);
        if(prodNotInSplit.size()> 0 || prodNotInSource.size() > 0 || quantityChange || valueChange){
            scopeChange = true;
        }
        
        List<String> fieldsChanged = new List<String>();
        fieldsChanged = RecurringBusinessHelper.getListOfFieldsChanged(quantityChange, valueChange, false,  (prodNotInSplit.size() > 0), (prodNotInSource.size() > 0), false );
        
        RecurringBusinessWrapperClasses.ScopeChangeWithMessageWrapper retVal = null;
        retVal = RecurringBusinessHelper.getScopeChangeResponseWrapper(scopeChange, fieldsChanged);
        
        System.debug('retVal scopeChangewrapperwithmsg = '+retVal);
        system.debug(scopeChange);
        return retVal;
    }
    
    public static Map<Id, List<Joint_Business_Plan_Product_Lines__c>> mappingChangedLineItems(Set<Id> rbId, Set<Id> oppId){
        Boolean scopeChange = false;
        Id cpbpId;
        Id recId;
        for(Id id : oppId){
            cpbpId = id;
        }
        for(Id id : rbId){
            recId = id;
        }
        //get line items from source
        List<RecurringBusinessWrapperClasses.Sourcelineitems> srcLineItems = getProductsData(cpbpId);
        //get split json from rb
        List<RB_Reference__c> rbRefs = [SELECT id, EAD__c, RO_Name__c, Products_1__c, Status__c,Products_2__c, RB_ID__c, Total_Value__c,Fulfill__c FROM RB_Reference__c WHERE RB_ID__c =: recId];
        List<RecurringBusinessWrapperClasses.RoLineItems> listlines = new List<RecurringBusinessWrapperClasses.RoLineItems>();
        for(RB_Reference__c objRR : rbRefs){
            listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_1__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
            if(objRR.Products_2__c != null){
                listlines.addall((List<RecurringBusinessWrapperClasses.RoLineItems>)JSON.deserialize(objRR.Products_2__c,List<RecurringBusinessWrapperClasses.RoLineItems>.class));
            }    
        }
        Set<Id> productInSplit = new Set<Id>();
        Set<Id> productInSource = new Set<Id>();
        Map<Id,Decimal> mapProdInSplitQuant = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProdInSplitPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProdInSrcQuant = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProdInSrcPrice = new Map<Id,Decimal>();
        for(RecurringBusinessWrapperClasses.RoLineItems objRef : listlines){
            productInSplit.add(objRef.Productid); //store the product from split to this collection
            mapProdInSplitQuant.put(objRef.Productid,objRef.Quantity);
            mapProdInSplitPrice.put(objRef.Productid,objRef.Totalprice);
        }
        for(RecurringBusinessWrapperClasses.Sourcelineitems src : srcLineItems){
            productInSource.add(src.Productid); //store the product from source to this collection
            mapProdInSrcQuant.put(src.Productid,src.Quantity);
            mapProdInSrcPrice.put(src.Productid,src.TotalPrice);
        }
        Set<Id> prodNotInSplit = new Set<Id>();
        Set<Id> prodNotInSource = new Set<Id>();
        Set<Id> productIdtoAdd = new Set<Id>();
        //Newly added
        for(Id srcProds : productInSource){
            if(!productInSplit.contains(srcProds)){
                prodNotInSplit.add(srcProds);
                productIdtoAdd.add(srcProds);
            }
        }
        //Deleted
        Boolean quantityChange = false;
        Boolean valueChange = false;
        
        for(Id splitProds : productInSplit){
            //Quantity change check
            system.debug(splitProds+''+mapProdInSplitQuant.get(splitProds));
            system.debug(splitProds+''+mapProdInSrcQuant.get(splitProds));
            if(mapProdInSplitQuant.get(splitProds) != null && mapProdInSrcQuant.get(splitProds) != null){
                if(mapProdInSplitQuant.get(splitProds) != mapProdInSrcQuant.get(splitProds)){
                    productIdtoAdd.add(splitProds);
                }
            }
            //Value change check
            system.debug(splitProds+''+mapProdInSplitPrice.get(splitProds));
            system.debug(splitProds+''+mapProdInSrcPrice.get(splitProds));
            if(mapProdInSplitQuant.get(splitProds) != null && mapProdInSrcQuant.get(splitProds) != null){
                if(mapProdInSplitPrice.get(splitProds) != mapProdInSrcPrice.get(splitProds)){
                    productIdtoAdd.add(splitProds);
                }
            }
        }
        system.debug(productIdtoAdd);
        
        Map<Id, List<Joint_Business_Plan_Product_Lines__c>> mapLineItemQtyValueChange = new Map<Id, List<Joint_Business_Plan_Product_Lines__c>>();
        List<Joint_Business_Plan_Product_Lines__c> oppLineItemList = [Select Product__c,Joint_Business_Plan__c, Product__r.Name, Current_Year_Currency__c from Joint_Business_Plan_Product_Lines__c where Joint_Business_Plan__c =:cpbpId and Product__c IN:productIdtoAdd and Current_Year_Currency__c >0 and Current_Year_Currency__c <> null LIMIT 50000];
        
        for(Joint_Business_Plan_Product_Lines__c oli : oppLineItemList){
            List<Joint_Business_Plan_Product_Lines__c> opptemplist = new List<Joint_Business_Plan_Product_Lines__c>();
            if(mapLineItemQtyValueChange.containskey(oli.Joint_Business_Plan__c))
            {
               
                boolean flag= false;
                Map<String,boolean> prdFlagMap = new Map<String,boolean>();
                opptemplist = mapLineItemQtyValueChange.get(oli.Joint_Business_Plan__c);                
                 for(Joint_Business_Plan_Product_Lines__c prd : opptemplist){
                    if(prd.Product__c.equals(oli.Product__c)){
                        prdFlagMap.put(oli.Product__c,true);
                            prd.Current_Year_Currency__c += oli.Current_Year_Currency__c;
                    }else{                                  
                        flag = true;
                    }
                 }
                if(!prdFlagMap.containskey(oli.Product__c)){
                        opptemplist.add(oli);
                }              
                mapLineItemQtyValueChange.put(oli.Joint_Business_Plan__c,opptemplist);
                
                opptemplist.add(oli);
                mapLineItemQtyValueChange.put(oli.Joint_Business_Plan__c,opptemplist);
            }  
            else
            {
                opptemplist.add(oli);
                mapLineItemQtyValueChange.put(oli.Joint_Business_Plan__c,opptemplist);
            }   
        }
        //mapLineItemQtyValueChange.put(opportunityId,oppLineItemList);
        
        
        for(Id splitProds : productInSplit){
            if(!productInSource.contains(splitProds)){
                prodNotInSource.add(splitProds);
            }
            //Quantity change check
            system.debug(splitProds+''+mapProdInSplitQuant.get(splitProds));
            system.debug(splitProds+''+mapProdInSrcQuant.get(splitProds));
            if(mapProdInSplitQuant.get(splitProds) != null && mapProdInSrcQuant.get(splitProds) != null){
                if(mapProdInSplitQuant.get(splitProds) != mapProdInSrcQuant.get(splitProds)){
                    quantityChange = true;
                    break;
                }
            }
            //Value change check
            system.debug(splitProds+''+mapProdInSplitPrice.get(splitProds));
            system.debug(splitProds+''+mapProdInSrcPrice.get(splitProds));
            if(mapProdInSplitQuant.get(splitProds) != null && mapProdInSrcQuant.get(splitProds) != null){
                if(mapProdInSplitPrice.get(splitProds) != mapProdInSrcPrice.get(splitProds)){
                    valueChange = true;
                    break;
                }
            }
        }
        system.debug(prodNotInSplit);
        system.debug(prodNotInSource);
        system.debug(quantityChange);
        system.debug(valueChange);
        if(prodNotInSplit.size()> 0 || prodNotInSource.size() > 0 || quantityChange || valueChange){
            scopeChange = true;
        }
        system.debug(mapLineItemQtyValueChange);
        return mapLineItemQtyValueChange;
    }
   
   
    /**
    @author  Lavanya Krishnan
    @created 2018-03-30
    @Description : Get source specific data - CPBP 
    @Method Name:  getNewRBDataFromSourceCPBP
    **/
    @AuraEnabled
    public static RecurringBusinessWrapperClasses.OnLoadWrapper getNewRBDataFromSourceCPBP(String sourceId) {
    
    Recurring_Business__c objRB = new Recurring_Business__c();
    RecurringBusinessWrapperClasses.OnLoadWrapper  returnObj = null;
    String abbLocationName = VAR_EMPTY;
    String offeringPGName = VAR_EMPTY;
    String accEndUserName = VAR_EMPTY;
    String endUserProjName = VAR_EMPTY;
    String sourceObjectName = VAR_EMPTY;
    String accountCustomerName = VAR_EMPTY; 
    String sourceObjectStatus = VAR_EMPTY;
    Decimal rbCount = 0;   
    String SourceAgreementId = VAR_EMPTY;
    String SourceAgreementName = VAR_EMPTY;
    List<Recurring_Business__c> lstRBcount = [Select id from Recurring_Business__c where Parent__c =: sourceId];
    List<Joint_Business_Plan_Product_Lines__c> cpbpLineitems  = [SELECT Current_Year_Currency__c FROM Joint_Business_Plan_Product_Lines__c where Current_Year_Currency__c != null and                                                           Joint_Business_Plan__c =:sourceId];  
            Decimal oppLineItemTotalPrice = 0;
            for(Joint_Business_Plan_Product_Lines__c result : cpbpLineitems){
                if(result.Current_Year_Currency__c <> null){
                    oppLineItemTotalPrice = oppLineItemTotalPrice + result.Current_Year_Currency__c;
                }
            }
            
            List<Joint_Business_Plan__c> objcpbp = [SELECT Name, Start_Date__c, Status__c, End_Date__c, Account__c,Account__r.Name,CurrencyIsoCode FROM Joint_Business_Plan__c where id =:sourceId LIMIT 1];
            List<Account> lstAccount = [Select id,name from Account where name =: VAR_UNKNOWNACCPOLAND LIMIT 1];
            if(objcpbp!=null && objcpbp.size()>0){
            String startdate = VAR_EMPTY;
            if(objcpbp[0].Start_Date__c!=null){
                startdate = String.valueof(objcpbp[0].Start_Date__c);
            }else{
                startdate = VAR_EMPTY;
            }            
            String enddate = VAR_EMPTY;
            if(objcpbp[0].End_Date__c!=null){
                enddate = String.valueof(objcpbp[0].End_Date__c);
            }else{
                enddate = VAR_EMPTY;
            } 
            String accCustName = null;
                if(!lstAccount.IsEmpty()){                  
                    accCustName = lstAccount[0].Name;
                }
            Date finalenddate = null;
                if(objcpbp[0].Start_Date__c != null){                   
                    Date strtdate = objcpbp[0].Start_Date__c;
                    finalenddate = date.newInstance(strtdate.year(), 12, 31);
                }
            objRB.Name = 'RB' + lstRBcount.size()+1 + ' - ' + ( objcpbp[0].Name!=null? objcpbp[0].Name : VAR_EMPTY );
            objRB.Value__c = oppLineItemTotalPrice;
           // objRB.Account_Customer_Name__c = objcpbp[0].Account__r.Name!=null? objcpbp[0].Account__r.Name : VAR_EMPTY; // add a string in the wrapper
            objRB.Start_Date__c =objcpbp[0].Start_Date__c!= null ? objcpbp[0].Start_Date__c: null;
            objRB.Frequency__c = 'Monthly';
            objRB.Status__c = 'Draft';
            objRB.Award_Date__c = objcpbp[0].Start_Date__c!= null ? objcpbp[0].Start_Date__c: null;
            //objRB.AvailableRBValue__c = oppLineItemTotalPrice;
            objRB.CurrencyIsoCode = String.valueOf(objcpbp[0].CurrencyIsoCode!=null?  objcpbp[0].CurrencyIsoCode : VAR_EMPTY );
            objRB.Channel_Class_Level1__c = '';
            objRB.Channel_Class_Level2__c = '';
            objRB.BU__c = '';
            objRB.Application__c = '';
            objRB.ABB_Domain__c = '';
            objRB.Business_Line__c = '';
            objRB.Offering_Primary_PG__c = null;
            objRB.ABB_Location__c = null;
            objRB.Account_End_User__c = !lstAccount.IsEmpty() ? lstAccount[0].Id : null ;
            //objRB.Account_End_User__c = accCustName; 
            objRB.End_User_Project__c = null;
            objRB.ABB_Industry_Usage_Level1__c = '';
            objRB.ABB_Industry_Usage_Level2__c = '';
            objRB.ABB_Industry_Usage_Level3__c = '';
            objRB.All_Target_vs_All_Commit__c = '';
            objRB.Account_Customer__c = objcpbp[0].Account__c;
            objRB.Periods__c = '';
            objRB.End_Date__c = finalenddate ;
            objRB.TotalRBValue__c = 0;
            objRB.Schedule_Period__c = 'Specific Days';
            objRB.Scheduler_Day__c = objcpbp[0].Start_Date__c!= null ? String.valueof(objcpbp[0].Start_Date__c): null;
            objRB.Scheduler_Month__c = '';
            objRB.Scheduler_Repeat_On__c = '';
            objRB.Target__c = false;
            objRB.Commit__c = false;
            objRB.ChannelPartner_BusinessPlan__c = objcpbp[0].id;
            
            rbCount=lstRBcount.size()+1;
            accountCustomerName= String.valueOf(objcpbp[0].Account__r.Name!=null? objcpbp[0].Account__r.Name : VAR_EMPTY);
            sourceObjectName = String.valueOf(objcpbp[0].Name!=null?  objcpbp[0].Name: VAR_EMPTY  );
            
            List<RecurringBusinessWrapperClasses.FullFillItems> lstFulfillItems = null;
            returnObj = new RecurringBusinessWrapperClasses.OnLoadWrapper (objRB,lstFulfillItems,abbLocationName, offeringPGName, accEndUserName, endUserProjName, sourceObjectName,
            accountCustomerName, rbCount, sourceObjectStatus,SourceAgreementId ,SourceAgreementName , '');
        }
        return returnObj ;
    
    
    }
    
    
    /**
    @author  Lavanya Krishnan
    @created 2018-05-31
    @Description : Get source status data - CPBP 
    @Method Name:  checkIfCPBPIsActive
    **/
    @AuraEnabled
    public static boolean checkIfCPBPIsActive(String sourceId) {
        boolean retValue = false;
        List<Joint_Business_Plan__c> objcpbp = [SELECT Name, Start_Date__c, Status__c, End_Date__c, Account__c,Account__r.Name,CurrencyIsoCode FROM Joint_Business_Plan__c where id =:sourceId LIMIT 1];
            if(!objcpbp.isEmpty()){
                if(objcpbp[0].Status__c == 'Active'){
                    retValue=true;
                }
            }
        return retValue;    
    }
    
}