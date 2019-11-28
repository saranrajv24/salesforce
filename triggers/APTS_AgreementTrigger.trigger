/*************************************************************
@Name: APTS_AgreementTrigger
@Author: Nishi Kushwaha
@CreateDate: 05/09/2015
@Description: Trigger on Agreement Object.
@UsedBy: NA
******************************************************************
@ModifiedBy: Hardik Shah
@ModifiedDate: 02/09/2015
@ChangeDescription: OnAfterUpdate Method Call, OnAfterDelete Method Call
**** PS: @ModifiedBy and @ChangeDescription can be repeated multiple time, based on number of changes made to the original process.
******************************************************************
@ModifiedBy: Nakul Singh(Accenture)
@ModifiedDate: 22/11/2016
@R4.1 CPQ
@ChangeDescription: Add the Quote team to the related Agreements MSPA Team.
******************************************************************/

trigger APTS_AgreementTrigger on Apttus__APTS_Agreement__c (before insert, after insert, before update, after update, before delete, after delete) {
        if (!System.label.SYS_DataMigUserName.equalsIgnoreCase(UserInfo.getUserName())){
        System.debug('Bypassing trigger on DML: ' + APTS_ProcessorControl.isByPassTriggerOnDML);   
    //If DML happend from Approval Request - dont fire Proposal Trigger
    if(APTS_ProcessorControl.isByPassTriggerOnDML || APTS_ProcessorControl.skipAgreementTrigger){
        //system.debug('Trigger Bypassed:::'+APTS_ProcessorControl.isByPassTriggerOnDML);
        //APTS_ProcessorControl.isByPassTriggerOnDML = false; //Commented to resolve CPU Time out issue in Finalize Cart
        return;
    }

    APTS_AgreementTriggerHandler agreementTriggerHandler = new APTS_AgreementTriggerHandler();

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        agreementTriggerHandler.onBeforeInsert(Trigger.new);
    }

     /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        agreementTriggerHandler.onAfterInsert(Trigger.new);
    }

    /* Before Update */
    if(Trigger.isUpdate && Trigger.isBefore){
        System.debug('APTS_RecursiveTriggerHandler flag: ' + APTS_RecursiveTriggerHandler.setFlag); 
        if(APTS_RecursiveTriggerHandler.setFlag){ // Added for Too Many SOQL: 101 issue by v.a.sangeetha 3/3/17
        agreementTriggerHandler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
          //APTS_RecursiveTriggerHandler.setFlag = FALSE;// Added for Too Many SOQL: 101 issue by v.a.sangeetha 3/3/17
          } // Added for Too Many SOQL: 101 issue by v.a.sangeetha 3/3/17
    }

          if(Trigger.isUpdate && Trigger.isAfter){           
            agreementTriggerHandler.OnAfterUpdateActual(Trigger.oldMap, Trigger.newMap);          
            // Updating Email Notification Fields
            // keeping this method outside 'if' loop since this method required to run secondtime 
            //APTS_AgreementTriggerHelper.updateEmailNotificationfields(Trigger.newMap.values(),Trigger.oldMap);            
        }

    /* After Delete */
    if(Trigger.isDelete && Trigger.isAfter){
        agreementTriggerHandler.onAfterDelete(Trigger.oldMap);
    }

        //R4.1 CPQ - To add the Quote Team to the related Agreements MSPA Team.
        if(Trigger.isAfter && Trigger.isInsert){
            if(Trigger.Size == 1){
                for(Sobject So : Trigger.new){
                Apttus__APTS_Agreement__c agrt = (Apttus__APTS_Agreement__c)So;//Added for the Defect#9170 on 24/04/2017 by Renuka.
                    if( !agrt.Apttus__Workflow_Trigger_Created_From_Clone__c || (agrt.Apttus__Workflow_Trigger_Created_From_Clone__c && !agrt.isclone())){
            UpdateQuoteORMSPATeamHandler createMspaHandler = new UpdateQuoteORMSPATeamHandler();
            createMspaHandler.createMSPATeamWithQuoteTeam(Trigger.new);
                    }
                }
            }
            //createMspaHandler.createMSPATeamWithAgreeSalesRep(Trigger.new, Trigger.oldMap);
        }
    }
}