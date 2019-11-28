/**
      
 * Release - R5 
 *  
 * @author  - Vasanthi (Accenture)
 * @created - 2016-1-05
 * @version - 1.0
 * @Description - To sync Quote Team Member with Opportunity Team Member as per Req#2503
 * - Created
 */
trigger quoteTeamMemberTrigger on Quote_Team_Member__c (before insert, before update, before delete, after insert, after update) {
Boolean fullLogicDisabledFlag  = ObjectsSaveMode__c.getInstance().FullLogicDisabled__c;  //- Bypassing for Data Fix Enhancements - STS R3.0       
If(!System.label.SYS_RunQuoteTeamMemberTrigger.equalsIgnoreCase(System.label.System_CL0002) && ClsTriggerFactory.isSkipQuoteTeamMemberTrigger && !fullLogicDisabledFlag){ // System_CL0002 --> 'NO'                                                
    ClsTriggerFactory.createHandler(Quote_Team_Member__c.sObjectType);
    }
}