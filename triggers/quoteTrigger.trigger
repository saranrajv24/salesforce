/******************************************************  
 * Release - R5 
 *  
 * @author  - Shankar Anand (Accenture)
 * @created - 2016-2-05
 * @version - 1.0
 * @Description - Req#2504
 * - Created
 *@ModifiedBy: mihir Shah
*@ModifiedDate: 17/10/2016
*@ChangeDescription: Added !APTS_CPQCommonUtil.isValidCCPUser() check so its only  trigger for Non-CCP user. Jira-#3157 
**************************************************************
@ModifiedBy : Ajithkumar Kothandaramasamy
@Modified Date: 08 March 2018
@ChangeDescription: Removed the condition !(APTS_CPQCommonUtil.isValidCPQUser) from the condition and moved the logic to ClsTriggerQuoteHandler
                    as part of Req#5748.
***************************************************************************                                        
@ModifiedBy : Venkat and Renuka
@Modified Date:06/07/2018
@ChangeDescription:R3-QFA-Req#6160 APTS_ProposalTrigger merged to Quote Trigger,To stop the execution of QFA/TQ methods during DML operations. 
*************************************************************
@ModifiedBy : Venkat
@Modified Date:21/08/2018
@ChangeDescription:R3-QFA-Req#6160 Added triggercontext checks for each stream
**************************************************************/
trigger quoteTrigger on Apttus_Proposal__Proposal__c (before insert, before update, before delete, after insert, after update, after delete) {
 Boolean fullLogicDisabledFlag  = ObjectsSaveMode__c.getInstance().FullLogicDisabled__c;//Added for Disabling the trigger during deployment activities
     System.debug('****');
     if(!fullLogicDisabledFlag)
     {
          System.debug('####');

    /*QFA R3 Req#6160 APTS_ProposalTrigger merged to Quote Trigger 
    * Added by Venkat 
    * To stop the execution of QFA/TQ methods during DML operations. 
    */
    if(APTS_ProcessorControl.isByPassTriggerOnDML || APTS_ProcessorControl.skipProposalTrigger)
    {
        system.debug('Trigger Bypassed:::'+APTS_ProcessorControl.isByPassTriggerOnDML);
        ClsTriggerQuoteHandler.Skiptriggerflag = true;
    }

    System.debug('Outside QuoteTrigger calling');
    If(!System.label.SYS_RunQuoteTrigger.equalsIgnoreCase(System.label.System_CL0002)/* && ClsTriggerFactory.isSkipQuoteTrigger*/)
    { // System_CL0002 -> 'NO'
         System.debug('QuoteTrigger calling');
         /*QFA R3 Req#6160 APTS_ProposalTrigger merged to Quote Trigger Added by Venkat*/
         ClsWrappers.TriggerContext trgCtx1 = new ClsWrappers.TriggerContext(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
         ClsWrappers.TriggerContext QFAcheck = APTS_CPQCommonUtil.isQFAFlow(trgCtx1);
        ClsWrappers.TriggerContext TQcheck = APTS_CPQCommonUtil.isTQFlow(trgCtx1);
        ClsWrappers.TriggerContext CQPnTQcheck = APTS_CPQCommonUtil.isTQnCQPFlow(trgCtx1);
        //Change Ends for QFA R3 Req#6160
         ClsTriggerFactory.createHandler(Apttus_Proposal__Proposal__c.sObjectType);
    }

    }
}