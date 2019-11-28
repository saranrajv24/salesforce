/****************************
@ModifiedBy: Dinesh Kumar S
@ModifiedDate: 22/08/2017
@Release: R6-EP-CPQ
@Requirement ID : 1675
@Method : getSAPRequestJSON()
@ChangeDescription: As part of R6-EP-CPQ Requirement #1675,  Fields "Market","Industry Usage" and "Channel Class" need to be send to SAP while Creating MSPA in SAP
*******************************************************************
*@ModifiedBy: Renuka G
*@ModifiedDate: 12/02/2018
*@Release: R2-EP-CPQ REQ#5795 - US#1409
*@Modified Method: getSAPRequestJSON() (Modified)
*@ChangeDescription:R2-EP-CPQ REQ#5795 - US#1409, Primary Partner Local Channel code to be sent to SAP for China in Customergroup field.
*******************************************************************
@ModifiedBy: Venkata Ramanan G
@ModifiedDate: 16-02-2018
@Release : EP-CPQ R2 - Req# 5788
@ChangeDescription: Created mapping for the Pricing Date field in the getSAPRequestJSON() to send to SAP.
*******************************************************************
@ModifiedBy:Dinesh & Leena
@ModifiedDate: 06-06-2018
@Release : QFA-R3-MR1_REQ#6142
@Modified Method: getSAPRequestJSON()
@ChangeDescription: As part of R3-MR1_REQ6142- GUID and Account Legal Name must be sent to SAP.
*******************************************************************/
/*******************************************************************
@ModifiedBy:Viswanathan G
@ModifiedDate: 27-06-2019
@Release : MRQ_QFA_BR# 4174
@Modified Method: getSAPRequestJSON()
@ChangeDescription: Product Group  mapped to hierarchy level2 code and hierarchy level 3 code  in MSPA request and response to SAP based on the hierarchy level of the products.
*******************************************************************/

public with sharing class APTS_ABB_LP_SAP_Integration_Util {
    
    public static String errorMsg{get; private set;}   
    public static String errorCode{get; private set;} // Added by Swedha for INC5801956  
    public static String access_token{get; private set;}
    private static final String SAS_TOKEN_HEADER = 'SharedAccessSignature';
    private static final String SAS_TOKEN_PARAM_SR ='sr';
    private static final String SAS_TOKEN_PARAM_SIG ='sig';
    private static final String SAS_TOKEN_PARAM_SE = 'se';
    private static final String SAS_TOKEN_PARAM_SKN = 'skn';
    private static final String AND_SYMBOL = '&';
    
    public static String sapBaseAdd{get; private set;}
    public static String sapKeyName{get; private set;}
    public static String sapKey{get; private set;}
    public static String sapBauCode{get; private set;}
    public static String sapErpResCulture{get; private set;}
    public static String sapEndPoint{get; private set;}
    public static String sapHeaderKey{get; private set;}
    public static Integer callTimeout{get; private set;}
    public static string muleClient_id{get; private set;}
    public static string muleClient_secret{get; private set;}
    
    static{
        //@Added by Parth : To support France . Italy specific MSPA Creation/Blocking
        //user country
        String userCountry = APTS_ApttusIntegrationUtility.getLoggedInUserCountry();
        //read static values that are neded for authetication from custom settings
        APTS_SAP_Integration_Tokens__c mspaCreationDataset = APTS_ApttusIntegrationUtility.getSAPIntegrationTokenCustomSetting(APTS_ApttusIntegrationUtility.CUSTOM_SETTING_MSPA_PRICING_TOKEN_NAME, UserCountry);
        system.debug('###### SAPIntegration'+MSPACreationDataset);
        
        sapBaseAdd = MSPACreationDataset.APTS_Base_Address__c;////get base address from custom setting
        sapKeyName = MSPACreationDataset.APTS_Key_Name__c;////get key name
        sapKey = MSPACreationDataset.APTS_Key__c;////get key
        sapBauCode = MSPACreationDataset.APTS_Bau_Code__c;////get Baucode
        sapErpResCulture = MSPACreationDataset.APTS_ERP_Response_Culture__c;////get response culture
        sapEndPoint = MSPACreationDataset.APTS_End_Point__c;//get end point
        sapHeaderKey = MSPACreationDataset.APTS_Http_Header_Key__c;//get http header key value
        //get client_id header value
        muleClient_id= MSPACreationDataset.Client_id__c;
        //get Client_secret for header value
        muleClient_secret= MSPACreationDataset.Client_Secret__c; 
        callTimeout = MSPACreationDataset.APTS_SAP_Call_Timeout_Millis__c != null ? Integer.valueOf(MSPACreationDataset.APTS_SAP_Call_Timeout_Millis__c) : 120000;
    }
    
    
   /* public static Boolean GetSecureOauthTokenAzure(){
        
        Boolean isSuccess = false;
        
        //String oAuthToken, oAuthKeyName, oAuthPass, oAuthAdd, oAuthEndPoint, oAuthHeaderPoint, oAuthHeaderKey, 
        //read static values from custom settings
        APTS_SAP_Integration_Tokens__c SAPoAuthDataset = APTS_SAP_Integration_Tokens__c.getValues('SAP oAuth Tokens');
        
        //get erp gateway key from custom setting
        String authToken = SAPoAuthDataset.APTS_oAuth_Token__c;
        
        //get key name
        string keyname = SAPoAuthDataset.APTS_Key_Name__c;
        
        //get password
        string password = SAPoAuthDataset.APTS_Key__c;
        
        //get base address
        string authenticationaddress = SAPoAuthDataset.APTS_Base_Address__c;
        
        //get end point
        string endpoint = SAPoAuthDataset.APTS_End_Point__c;
        
        //get http header key value
        string headerkey = SAPoAuthDataset.APTS_Http_Header_Key__c;
        
        //generate oAuth token here
        String Token = EncodingUtil.base64Encode(Blob.valueof(authToken));
        
        string oAuthToken = 'Basic '+Token;
        
        Integer timeout = SAPoAuthDataset.APTS_SAP_Call_Timeout_Millis__c != null ? Integer.valueOf(SAPoAuthDataset.APTS_SAP_Call_Timeout_Millis__c) : 120000;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        req.setEndpoint(endpoint);
        
        req.setMethod('POST');
        
        //pass authentication token to SAP
        req.setHeader(headerkey, oAuthToken);
        
        req.setHeader('Content-Type', 'application/json');
        
        //set the body with required parameters
        req.setBody('{"scope":"'+authenticationaddress+'","grant_type":"password","username":"'+keyname+'","password":"'+password+'"}');
        
        req.setTimeout(timeout);
        
        try{
            
            res = http.send(req);
            
            //system.debug('****responsebody azure'+res1.getbody()+':::'+req1.getbody());
            
            //check if authentication is success and deserialize the jason body to get access token
            if(res.getStatusCode() == 200){
                
                //deserialize json body to get access token
                APTS_ABB_LP_SAP_Tokens.oAuthIntegrationToken  jsonvalues = (APTS_ABB_LP_SAP_Tokens.oAuthIntegrationToken)JSON.deserialize(res.getbody(), APTS_ABB_LP_SAP_Tokens.oAuthIntegrationToken.class);
                APTS_ABB_LP_SAP_Integration_Util.access_token = 'OAuthJwt '+jsonvalues.access_token;
                isSuccess = true;
                
            }else {
                //return errormsg;
                APTS_ABB_LP_SAP_Integration_Util.errorMsg = 'Response code: '+res.getStatusCode() + '\n' + 'Response Status: '+res.getStatus();
            }   
            
        }catch (Exception exp) {
            //System.debug('#### General Callout error: '+ ex.getMessage());
            APTS_ABB_LP_SAP_Integration_Util.errorMsg = 'Error Type: '+ exp.getTypeName() + '\n Error: '+ exp.getMessage() + '\n'+ 'Cause: '+exp.getCause() + '\n' + 'Line Number: '+ exp.getLineNumber() + '\n StackTrace: '+ exp.getStackTraceString();
        }   
        
        return isSuccess;
        
    } */
    
     /*
       @ Method to get sas token
       @ Param: resource url,key name,key
     **/
    public static string getSasToken() {   
        //set expiry here
        String expiry = string.valueof(system.now().getTime() /1000);
        //encode resource url and append expiry
        String stringToSign = EncodingUtil.urlEncode(sapBaseAdd, APTS_Constants.ENCODING_UTF_8) + APTS_Constants.NEW_LINE  + expiry;
        //get hmac code and encode it
        String signature = EncodingUtil.base64Encode(crypto.generateMac(APTS_Constants.ENCRYPTION_ALGO_HMACSHA256,
                                                    blob.valueof(stringtosign), blob.valueof(sapKey)));
                                                    
        //form the sas key in the format of (SharedAccessSignature sig=<signature-string>&se=<expiry>&skn=<keyName>&sr=<URL-encoded-resourceURI>)
        String sasToken = SAS_TOKEN_HEADER + APTS_Constants.SPACE_STRING  + SAS_TOKEN_PARAM_SR + APTS_Constants.APTS_SYMBOL_EQUAL + EncodingUtil.urlEncode(sapBaseAdd, APTS_Constants.ENCODING_UTF_8) +
                        AND_SYMBOL + SAS_TOKEN_PARAM_SIG + APTS_Constants.APTS_SYMBOL_EQUAL + EncodingUtil.urlEncode(signature, APTS_Constants.ENCODING_UTF_8) +
                        AND_SYMBOL + SAS_TOKEN_PARAM_SE + APTS_Constants.APTS_SYMBOL_EQUAL + expiry +
                        AND_SYMBOL + SAS_TOKEN_PARAM_SKN + APTS_Constants.APTS_SYMBOL_EQUAL + sapKeyName;
       
        system.debug('***sas token'+sasToken);
        return sasToken;
    }
    /*
    @ModifiedBy: Dinesh Kumar S
    @ModifiedDate: 10/13/2017
    @Release: R6-EP-CPQ
    @Requirement ID : 1675
    @Method : scalingdecimal()
    @ChangeDescription: As part of R6-EP-CPQ Requirement #1675,  Scalling the discount value to 2 digit
    */
    private static string scalingdecimal(Decimal discountValue){
        string discount = string.valueof(discountValue.setScale(2, RoundingMode.HALF_UP));
        return discount;
    }
    /*
    @ModifiedBy: Renuka G
    @ModifiedDate: 12/02/2018
    @Release: R2-EP-CPQ REQ#5795 - US#1409
    @ChangeDescription:R2-EP-CPQ REQ#5795 - US#1409, Primary Partner Local Channel code description to be sent to SAP for China .
    */
    public static String getSAPRequestJSON(Apttus__APTS_Agreement__c agrmt, String blockParam){
        
        
        //Start: Jinal (As per Jignesh's suggestion)
        //read static values that are neded for authetication from custom settings
        APTS_SAP_Integration_Tokens__c mspaCreationDataset = APTS_ApttusIntegrationUtility.getSAPIntegrationTokenCustomSetting(APTS_ApttusIntegrationUtility.CUSTOM_SETTING_MSPA_PRICING_TOKEN_NAME, agrmt.APTS_Locale__c);
        system.debug('###### SAPIntegration'+MSPACreationDataset);
        
        //sapBaseAdd = MSPACreationDataset.APTS_Base_Address__c;////get base address from custom setting
        sapKeyName = MSPACreationDataset.APTS_Key_Name__c;////get key name
        sapKey = MSPACreationDataset.APTS_Key__c;////get key
        sapBauCode = MSPACreationDataset.APTS_Bau_Code__c;////get Baucode
        sapErpResCulture = MSPACreationDataset.APTS_ERP_Response_Culture__c;////get response culture
        sapEndPoint = MSPACreationDataset.APTS_End_Point__c;//get end point
        sapHeaderKey = MSPACreationDataset.APTS_Http_Header_Key__c;//get http header key value
        callTimeout = MSPACreationDataset.APTS_SAP_Call_Timeout_Millis__c != null ? Integer.valueOf(MSPACreationDataset.APTS_SAP_Call_Timeout_Millis__c) : 120000;
        //End
       
        //R3.2 Changes - create consolidated MSPA request - The request to create MSPA in SAP should not have duplicate products in items. In case of duplicate product in Cart, need to consolidate Quantity.
        Map<String, APTS_ABB_LP_SAP_Tokens.AgreementLineItems> mapAgreementLineItems = new Map<String, APTS_ABB_LP_SAP_Tokens.AgreementLineItems>();
        APTS_ABB_LP_SAP_Tokens.SAPRequestAuthHeader globalPar = new APTS_ABB_LP_SAP_Tokens.SAPRequestAuthHeader();
        List<APTS_ABB_LP_SAP_Tokens.AgreementLineItems> agrmtlinestopass = new list<APTS_ABB_LP_SAP_Tokens.AgreementLineItems>();
        
        
        //End
        globalPar.BauCode = sapBauCode;
        globalPar.Currency1 = agrmt.Apttus_CMConfig__PriceListId__r.currencyISOcode;
        globalPar.CustomerCode = agrmt.APTS_SAP_Customer_ID__c;// '0010009006';//set customer Id
        //R2 EP REQ - 5788 - Price Date Mapping to sent to SAP - Defect # 17864- Corrected the format to send it to SAP as per mulesoft's configuration.
        if(agrmt.Apttus_CMConfig__PricingDate__c != null && agrmt.Apttus_CMConfig__PricingDate__c.Date() != agrmt.CreatedDate.Date())
        {
        Datetime pricingdate = agrmt.Apttus_CMConfig__PricingDate__c;
        globalPar.PriceDate = APTS_Constants.APTS_DATE +pricingdate.getTime()+ APTS_Constants.APTS_SYMBOL_BRACKET_SLASH;//convert dates into json format//agrmt.Apttus_CMConfig__PricingDate__c.format();
        }
        globalPar.AuthToken = access_token;
        System.debug('***axay: '+access_token);
        
        //CR 6110
        APTS_Country_Defaults__c countryDefault = APTS_Country_Defaults__c.getValues(agrmt.APTS_Country__c);
        Map<String, String> mapDiscTypeToDealCalcType = new Map<String,String>{APTS_Constants.APTS_S => APTS_Constants.APTS_A, APTS_Constants.APTS_N => APTS_Constants.APTS_B, APTS_Constants.APTS_A => APTS_Constants.APTS_A};
        Map<String, String> mapDiscTypeToDealValue = new Map<String,String>{APTS_Constants.APTS_S => APTS_Constants.LINE_ITEM_FIELD_DISCOUNT_PERCENTAGE, APTS_Constants.APTS_N => APTS_Constants.LINE_ITEM_FIELD_Unit_Net_Price , APTS_Constants.APTS_A => APTS_Constants.LINE_ITEM_FIELD_DISCOUNT_PERCENTAGE};
        //end of 6110
        
        //reqBody.globalParams = globalPar;
        for(Apttus__AgreementLineItem__c ali : agrmt.Apttus__AgreementLineItems__r){
            if(ali.Apttus__ProductId__c == null) {continue;} //In case of Miscelanious Product, skip the line item 
            //R3.2 Changes - create consolidated MSPA request
            String prodCode = ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c ? ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c : ali.APTS_Product_Code__c;
            
            if(mapAgreementLineItems.containsKey(prodCode)){
                
                APTS_ABB_LP_SAP_Tokens.AgreementLineItems agrmtlineitem = mapAgreementLineItems.get(prodCode);
                Decimal qty = (String.isEmpty(agrmtlineitem.ScaleQuantity) ? 0 : Decimal.valueOf(agrmtlineitem.ScaleQuantity)) + ali.Apttus__Quantity__c.setScale(2);
                agrmtlineitem.ScaleQuantity = String.valueOf(qty);
                mapAgreementLineItems.put(prodCode, agrmtlineitem);
                continue;
            }
            //end of R3.2
                    
            //assign the MSPA line item field to JSON field values to be passesd to SAP
            APTS_ABB_LP_SAP_Tokens.AgreementLineItems agrmtlineitem = new APTS_ABB_LP_SAP_Tokens.AgreementLineItems();
            
            //agrmtlineitem.ItemNumber = String.valueOf(ali.Apttus_CMConfig__LineNumber__c);
            agrmtlineitem.ItemNumber = String.valueOf(ali.APTS_Line_Number_Custom__c);
            agrmtlineitem.DealCode = ali.Apttus__AgreementId__r.APTS_SAP_Reference_No__c;
            
            //setting default value for following fields which are not required for spain
            //since SAP expects some value for these fields we are sending default values as per json request
            //Scenario: MSPA line items were not created in SAP due to ignoring this data, hence populating all of these values to some defaults
            agrmtlineitem.OrderQty = APTS_Constants.APTS_NUMBER_0;
            agrmtlineitem.OrderVal = APTS_Constants.APTS_NUMBER_0;
            agrmtlineitem.PricingUnit = ali.APTS_Unit_of_Price__c; //Parth: R4 CR - needs to be mapped with APTS_Unit_of_Price__c of agreement line item
            agrmtlineitem.PricingUom = ali.APTS_Price_Unit_of_Measure__c;
            agrmtlineitem.MinOrdVal = APTS_Constants.APTS_NUMBER_0;
            agrmtlineitem.MinOrdQty = APTS_Constants.APTS_NUMBER_0;
            agrmtlineitem.MaxOrdVal = APTS_Constants.APTS_NUMBER_0;
            agrmtlineitem.MaxOrdQty = APTS_Constants.APTS_NUMBER_0;
            agrmtlineitem.Maxconval = APTS_Constants.APTS_NUMBER_0;
            agrmtlineitem.ConditionPricingUnit = APTS_Constants.APTS_NUMBER_0;
            //end
            
            //send DealType="S" for substitute discount, "N" for NET_DISCOUNT and "A" for Additional discount
            //send Deal Value=Discount% for Substiture Discount, Net Price Override for NET_DISCOUNT
            if(APTS_Constants.SUB_DISCOUNT.equals(ali.APTS_Discount_Type__c) ){
                
                agrmtlineitem.DealType = APTS_Constants.APTS_S;
                agrmtlineitem.DealValue = scalingdecimal(ali.APTS_Discount_Percentage__c);
                agrmtlineitem.DealCalculationType = APTS_Constants.APTS_A;
                
                
            }else if(APTS_Constants.NET_DISCOUNT.equals(ali.APTS_Discount_Type__c) ){
                
                agrmtlineitem.DealType = APTS_Constants.APTS_N;
                agrmtlineitem.DealValue = scalingdecimal(ali.APTS_Net_Price_Override__c);
                agrmtlineitem.DealCalculationType = APTS_Constants.APTS_B;                
            }else if(APTS_Constants.ADD_DISCOUNT.equals(ali.APTS_Discount_Type__c) ){
                
                agrmtlineitem.DealType = APTS_Constants.APTS_A;
                agrmtlineitem.DealValue = scalingdecimal(ali.APTS_Discount_Percentage__c);
                agrmtlineitem.DealCalculationType = APTS_Constants.APTS_A;            
            } else{ }
            if(String.isBlank(agrmtlineitem.DealValue) ) {
                agrmtlineitem.DealValue = APTS_Constants.APTS_NUMBER_0; //default value should be set to 0 in order to prevent error in Local SAP while MSPA creation.
            }
            
            
            //CR 6110
            if(countryDefault != null){//agrmt.APTS_Country__c == 'Spain' && -> removing country since earlier we have done this for spain only
                
                String defaultDiscountType = ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c ? countryDefault.APTS_DefaultHierarchyDiscSAP__c : countryDefault.APTS_DefaultProductDiscSAP__c;
                defaultDiscountType = defaultDiscountType != null ? defaultDiscountType : agrmtlineitem.DealType;
                agrmtlineitem.DealType =  defaultDiscountType;
                agrmtlineitem.DealValue = scalingdecimal(Decimal.valueOf(string.valueof(ali.get(mapDiscTypeToDealValue.get(defaultDiscountType)))));//String.valueOf(ali.APTS_Net_Price_Override__c);
                agrmtlineitem.DealCalculationType = mapDiscTypeToDealCalcType.get(defaultDiscountType);                
            }
            
            //sales organisation will be ABB always
            agrmtlineitem.SalesOrganization = agrmt.APTS_LP_Sales_Organization__c;
            if(agrmt.APTS_Country__c != APTS_Constants.COUNTRY_ITALY) {
                agrmtlineitem.DistributionChannel = agrmt.APTS_Distribution_Channel__r.APTS_Code__c; 
            }
            //set quantity
            agrmtlineitem.ScaleQuantity = String.valueOf(ali.Apttus__Quantity__c.setScale(2));
            agrmtlineitem.DealCurrency = ali.currencyISOcode;
            
            
            //pass productCode
            agrmtlineitem.ProductCode = ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c ? APTS_Constants.EMPTY_STRING  : ali.APTS_Product_Code__c;
            if(APTS_Constants.COUNTRY_SPAIN.equals(agrmt.APTS_Country__c) ) {
                 agrmtlineitem.ProductHierarchy = ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c;//ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c ? ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c : '';
            } else if(APTS_Constants.COUNTRY_ITALY.equals(agrmt.APTS_Country__c) ) {
                agrmtlineitem.Custom01 = ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c;//ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c ? ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c : '';
            } else if(APTS_Constants.COUNTRY_FRANCE.equals(agrmt.APTS_Country__c) ) {
                if(ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c.contains(APTS_Constants.APTS_NUMBER_15)){
                    agrmtlineitem.ProductHierarchy = ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c;//ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c ? ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c : '';
                }else{
                agrmtlineitem.ProductGroup = ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c;//ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c ? ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c : '';
                } 
            }else if(APTS_Constants.COUNTRY_CHINA.equals(agrmt.APTS_Country__c) ) {
                agrmtlineitem.ProductGroup = ali.Apttus__ProductId__r.APTS_Hierarchy_Level_2_Code__c;
                agrmtlineitem.ProductHierarchy = ali.Apttus__ProductId__r.APTS_Hierarchy_Level__c == APTS_Constants.HIERARCHY_LEVEL_3 ? ali.Apttus__ProductId__r.APTS_Hierarchy_Level_3_Code__c : APTS_Constants.EMPTY_STRING; //MRQ_QFA_4174-MSPA Request to SAP. added by viswa
            }else {
                   //do nothing;
            }
            
          /*  if(ali.Apttus__ProductId__r.APTS_LP_Is_Hierarchy__c){
                agrmtlineitem.ProductHierarchy = ali.Apttus__ProductId__r.APTS_LP_Product_Hierarchy__c;
            }
           */
            
            agrmtlinestopass.add(agrmtlineitem);
            mapAgreementLineItems.put(prodCode, agrmtlineitem);
            
            
        }
        
        //Parth : R4 - France Scale Type
        List<APTS_ABB_LP_SAP_Tokens.AgreementLineItems> duplicateProductCodeAgrmtlinesForFrance = new list<APTS_ABB_LP_SAP_Tokens.AgreementLineItems>();
        if(!String.isBlank(agrmt.APTS_Country__c) && agrmt.APTS_Country__c.equalsIgnoreCase(APTS_Constants.COUNTRY_FRANCE)) {
            String agrmntId = String.valueOf(agrmt.Id).substring(0, 15);
            List<APTS_Product_Item_Scale_Data__c> scaleTypeInfoList = [Select Id, APTS_Agreement_Id__c, APTS_Parent_Configurator_Cart_Summary_ID__c, 
                    APTS_Discount_Type__c, APTS_Discount_Value__c, APTS_Product_Code__c, APTS_Quantity__c, APTS_Scale_Types__c
                    FROM APTS_Product_Item_Scale_Data__c WHERE APTS_Agreement_Id__c = :agrmntId and APTS_Scale_Types__c !=: APTS_Constants.SCALE_EXACT LIMIT 49999]; // FIX FOR INC:4468221
            if(!scaleTypeInfoList.isEmpty()) {
                Set<String> productCodeSet = new Set<String>();
                for(APTS_Product_Item_Scale_Data__c scaleTypeObj : scaleTypeInfoList) {
                    if(!mapAgreementLineItems.isEmpty() && mapAgreementLineItems.get(scaleTypeObj.APTS_Product_Code__c) != null) {
                        //first time update existing agreementLineItem record
                        //APTS_ABB_LP_SAP_Tokens.AgreementLineItems agrmtlineitem = new APTS_ABB_LP_SAP_Tokens.AgreementLineItems();
                        APTS_ABB_LP_SAP_Tokens.AgreementLineItems agrmtlineitem = mapAgreementLineItems.get(scaleTypeObj.APTS_Product_Code__c);
                        System.debug('***existing agrmtlineitem : ' + agrmtlineitem);
                        APTS_ABB_LP_SAP_Tokens.AgreementLineItems cloneAgrmtlineitem = agrmtlineitem.clone();
                        //BraketType (Scale Type)
                        if(scaleTypeObj.APTS_Scale_Types__c == APTS_Constants.SCALE_EXACT) {
                            cloneAgrmtlineitem.BraketType = null;
                        } else if(scaleTypeObj.APTS_Scale_Types__c == APTS_Constants.SCALE_FROM) {
                            cloneAgrmtlineitem.BraketType = APTS_Constants.APTS_A; 
                        } else if(scaleTypeObj.APTS_Scale_Types__c == APTS_Constants.SCALE_TO) {
                            cloneAgrmtlineitem.BraketType = APTS_Constants.APTS_B;
                        } else{ }
                        //Quantity
                        Decimal qty = (scaleTypeObj.APTS_Quantity__c != null) ? scaleTypeObj.APTS_Quantity__c : 0;
                        cloneAgrmtlineitem.ScaleQuantity = String.valueOf(qty);
                        //Discount Type
                        if(!String.isBlank(scaleTypeObj.APTS_Discount_Type__c)) {
                            Decimal discountValue = (scaleTypeObj.APTS_Discount_Value__c != null) ? scaleTypeObj.APTS_Discount_Value__c : 0;
                            
                            if(scaleTypeObj.APTS_Discount_Type__c == APTS_Constants.NET_DISCOUNT) {
                                cloneAgrmtlineitem.DealType = APTS_Constants.APTS_N;
                                cloneAgrmtlineitem.DealValue = scalingdecimal(discountValue);
                                cloneAgrmtlineitem.DealCalculationType = APTS_Constants.APTS_B;                
                            } else if(scaleTypeObj.APTS_Discount_Type__c == APTS_Constants.SUB_DISCOUNT) {
                                cloneAgrmtlineitem.DealType = APTS_Constants.APTS_S;
                                cloneAgrmtlineitem.DealValue = scalingdecimal(discountValue);
                                cloneAgrmtlineitem.DealCalculationType = APTS_Constants.APTS_A;
                            } else{ }
                            
                        }
                        System.debug('***cloneAgrmtlineitem : ' + cloneAgrmtlineitem);
                        duplicateProductCodeAgrmtlinesForFrance.add(cloneAgrmtlineitem);
                        productCodeSet.add(agrmtlineitem.ProductCode);
                    } 
                }
                //once the agreement lines are created as per the scale types, remove the redundent agreement line with same product code from mapAgreementLineItems Map.
                if(!productCodeSet.isEmpty()) {
                    for(String prodCode : productCodeSet) {
                        System.debug('***existing agrmtlineitem removed : ' + mapAgreementLineItems.get(prodCode));
                        mapAgreementLineItems.remove(prodCode);
                    }  
                }
                
            }
            
        }
        
        //AgreementHeader
        APTS_ABB_LP_SAP_Tokens.AgreementHeader mspa = new APTS_ABB_LP_SAP_Tokens.AgreementHeader();
        //MSPA.
        
        if(blockParam != null && APTS_Constants.VALUE_TRUE.equals(blockParam.toLowerCase()) ){
            //for MSPA blocking, block=true
            MSPA.Block = APTS_Constants.NUM_ONE ;
            MSPA.Action = APTS_Constants.APTS_B;
        }else{
            //for MSPA creation block=false  
            MSPA.Block = APTS_Constants.APTS_NUMBER_0;
            MSPA.Action = APTS_Constants.APTS_I;
        }
        
        //Added by Jignesh from Old version of copy
       String sDealTypeForHeader=APTS_Constants.EMPTY_STRING;        
        for(APTS_IntegrationMappingParameters__c parameter : APTS_IntegrationMappingParameters__c.getAll().values()){
            
            if(parameter.APTS_TargetObject__c.equals(APTS_Constants.AGREEMENT_SOBJECTTYPE)  && 
                parameter.APTS_ParameterName__c == 'DealType' && agrmt.APTS_Country__c == parameter.APTS_Country__c){
                    
                    sDealTypeForHeader = parameter.APTS_ParameterValue__c;
            }
        }

        
        MSPA.MaxOrdVal= scalingdecimal(agrmt.APTS_Max_Order_Amount__c); ////set max order value
        MSPA.MinOrdVal = APTS_Constants.APTS_NUMBER_0;//min order value will be 0
        MSPA.SalesMan = agrmt.APTS_LP_Sales_Person__r.name;
        if(agrmt.APTS_Country__c.equalsIgnoreCase(APTS_Constants.COUNTRY_CHINA) ) {
            MSPA.SalesOffice = agrmt.APTS_Sales_Office__r.PickList_Code__c != null ? agrmt.APTS_Sales_Office__r.PickList_Code__c.left(4) : null;//read from sales office of MSPA - read first 4 chars for china.
        }else {
            MSPA.SalesOffice = agrmt.APTS_Sales_Office__r.PickList_Code__c != null ? agrmt.APTS_Sales_Office__r.PickList_Code__c.left(3) : null;//read from sales office of MSPA - read first 3 chars.
        }
        MSPA.SalesOrganization = agrmt.APTS_LP_Sales_Organization__c;//sales organisation will be ABB always
        MSPA.Currency2 = agrmt.Apttus_CMConfig__PriceListId__r.currencyISOcode;
        MSPA.OPP_ID = agrmt.Apttus__Related_Opportunity__r.Opportunity_Number__c;
        MSPA.OPP_NAME = agrmt.Apttus__Related_Opportunity__r.Name;
        MSPA.IND_CUST_ID = agrmt.APTS_LP_Account_End_User__r.GUID__c != null ? agrmt.APTS_LP_Account_End_User__r.GUID__c : agrmt.APTS_LP_Account_End_User__r.id;
        MSPA.IND_CUST_NAME  = agrmt.APTS_LP_Account_End_User__r.Name_Local__c;
        MSPA.END_CUSTOMER_ID = agrmt.APTS_Account_End_User__r.GUID__c != null ? agrmt.APTS_Account_End_User__r.GUID__c : agrmt.APTS_Account_End_User__r.id; // R3_MR1 - Req. 6142 : Account EndUser's GUID or ID
        MSPA.END_CUSTOMER = agrmt.APTS_Account_End_User__r.Name_Local__c; // R3_MR1 - Req. 6142 : Account EndUser's Local Name
        if(APTS_Constants.COUNTRY_CHINA.equals(agrmt.APTS_Country__c) ){
            MSPA.IND_USG_W_OPP_ID = (agrmt.Apttus__Related_Opportunity__r.ABB_Industry_Usage_Level3__c != null) ? agrmt.Apttus__Related_Opportunity__r.ABB_Industry_Usage_Level3__c : 
                                  (agrmt.Apttus__Related_Opportunity__r.ABB_Industry_Usage_Level2__c != null) ? agrmt.Apttus__Related_Opportunity__r.ABB_Industry_Usage_Level2__c : agrmt.Apttus__Related_Opportunity__r.ABB_Industry_Usage_Level1__c;
         }
        //#changes starts here Req.1675 - three new fields need to be send to SAP local system 
        if(countryDefault.SAP_Industrial_Usage__c){
            MSPA.IND_USAGE_CODE = (agrmt.APTS_Industry_Usage_Level_3__c != null) ? agrmt.APTS_Industry_Usage_Level_3__c : 
                                  (agrmt.APTS_Industry_Usage_Level_2__c != null) ? agrmt.APTS_Industry_Usage_Level_2__c : agrmt.APTS_Industry_Usage_Level_1__c;
        }
        if(countryDefault.SAP_Class_Channel__c){
            MSPA.CHANNEL_CLASS = (agrmt.APTS_Channel_Class_Level2__c != null) ?  agrmt.APTS_Channel_Class_Level2__c : agrmt.APTS_Channel_Class_Level1__c;
        }
        if(countryDefault.SAP_Market__c){
            MSPA.MARKET = agrmt.Market__r.APTS_Code__c;
        }
        //#changes Ends here Req.1675 - three new fields need to be send to SAP local system 
        if(agrmt.APTS_Country__c != APTS_Constants.COUNTRY_ITALY) {
            MSPA.DistributionChannel = agrmt.APTS_Distribution_Channel__r.APTS_Code__c;
        }
        Datetime startdate = agrmt.Apttus__Contract_Start_Date__c;//MSPA start date
        Datetime enddate = agrmt.Apttus__Contract_End_Date__c;//MSPA end date
        MSPA.ValidFrom = APTS_Constants.APTS_DATE +startdate.getTime()+ APTS_Constants.APTS_SYMBOL_BRACKET_SLASH;//convert dates into json format
        MSPA.ValidtO = APTS_Constants.APTS_DATE+enddate.getTime()+APTS_Constants.APTS_SYMBOL_BRACKET_SLASH; 
        MSPA.CustomerGroup = agrmt.APTS_Local_Channel__r.APTS_Code__c;
        //R2 EP REQ - 5795- Primary Partner Local Channel code Mapping to sent to SAP for China.
        if(countrydefault.SAP_PrimaryPartner_LocalChannel_CodeDesc__c) {
            MSPA.CustomerGroup = agrmt.Primary_Partner_Local_Channel__r.APTS_Code__c;
        }
        
        MAP<string, SAP_Reference_MSPA_SubType__c> mspadealTypemap = SAP_Reference_MSPA_SubType__c.getALL();
        if(MSPAdealTypemap.containskey(agrmt.Apttus__Subtype__c)){
            MSPA.DealType = MSPAdealTypemap.get(agrmt.Apttus__Subtype__c).MSPA_DealType__c;
        }
        MSPA.DealValue = scalingdecimal(agrmt.APTS_Total_Agreement_Value__c);
        if(!String.isBlank(MSPA.DealValue)) {
            MSPA.DealValue = APTS_Constants.APTS_NUMBER_0; //default value should be set to 0 in order to prevent error in Local SAP while MSPA creation.
        }
        MSPA.DealCode = agrmt.APTS_SAP_Reference_No__c;
        MSPA.ResidualAmount = APTS_Constants.APTS_NUMBER_0;//this field is not needed for spain but it cannot be null, hence passing 0 value
        //R4 Integration Fields : Parth 
        MSPA.Incoterms1 = (agrmt.APTS_Incoterms__c != null) ? agrmt.APTS_Incoterms__r.APTS_Code__c : APTS_Constants.EMPTY_STRING  ;
        MSPA.Incoterms2 = (!String.isBlank(agrmt.APTS_Incoterm2__c)) ? agrmt.APTS_Incoterm2__c : APTS_Constants.EMPTY_STRING ;
        MSPA.PaymentTerms = (agrmt.APTS_Payment_Terms__c != null) ? agrmt.APTS_Payment_Terms__r.APTS_Code__c : APTS_Constants.EMPTY_STRING ;
        
        //MSPA.SalesDealItems = agrmtlinestopass;
        //R3.2 - Consolidated MSPA Request - commented above line and added below line
        MSPA.SalesDealItems = mapAgreementLineItems.values();
        //end of R3.2
        //Parth : R4 : France - Scale Types
        if(!duplicateProductCodeAgrmtlinesForFrance.isEmpty()) {
            MSPA.SalesDealItems.addAll(duplicateProductCodeAgrmtlinesForFrance);
        }        
        APTS_ABB_LP_SAP_Tokens.MSPASAPRequestWrapper mspaReq = new APTS_ABB_LP_SAP_Tokens.MSPASAPRequestWrapper();
        mspaReq.globalParams = globalPar;
        mspaReq.createSalesDealRequest = MSPA;
        //mspaReq - is the main object that will be passed to the SAP
        String jsonbody = JSON.serialize(mspaReq);
        jsonbody = jsonbody.replace(APTS_Constants.APTS_CURRENCY1, APTS_Constants.APTS_CURRENCY);
        jsonbody = jsonbody.replace(APTS_Constants.APTS_CURRENCY2, APTS_Constants.APTS_CURRENCY);
        return jsonbody;
    }
}