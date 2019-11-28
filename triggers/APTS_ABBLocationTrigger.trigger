trigger APTS_ABBLocationTrigger on ABB_Location__c (before insert, before update,  before delete) {
    
    Boolean fullLogicDisabledFlag  = ObjectsSaveMode__c.getInstance().FullLogicDisabled__c;  //Added By Jaweed - Data Fix Enhancements Rel3.0
    
    if(!System.label.SYS_RunABBLocationTrigger.equalsIgnoreCase('NO') && !fullLogicDisabledFlag/* && !ClsTriggerFactory.isSkipABBLocationTrigger*/){                
        ClsTriggerFactory.createHandler(ABB_Location__c.sObjectType);     
    }
}