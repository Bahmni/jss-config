### JSS Hospital specific configuration and data for Bahmni

Deploy
- under server (apache) www directory
- alias root (jss-config) to bahmni_config


*Dev commands:*
* `./scripts/vagrant-link.sh` to link jss_config to vagrants /var/www/bahmni_config
* `./scripts/vagrant-database.sh` to run liquibase migrations in vagrant 

 Configurations -
 ==============================================================
 1) Clinical app.json: example -  (Details in comments)

```javascript

 "config" : {
    "otherInvestigationsMap": {
        "Radiology": "Radiology Order",
        "Endoscopy": "Endoscopy Order"
    },
    "conceptSetUI": {   // all configs for conceptSet added here
        "XCodedConcept": {  // name of the concept
            "autocomplete": true,  // if set to true, it will show autocomplete instead of dropdown for coded concept answers.
            "showAbnormalIndicator": true   //If set to true, will show a checkbox for capturing abnormal observation.
        },
        "Text Complaints": {    //name of the concept
            "freeTextAutocomplete": {   //if present, will show a textbox, with autocomplete for concept name.
                "conceptSetName": "Vitals",  // autocomplete will search for concepts which are membersOf this conceptSet (Optional)
                "codedConceptName": "Complaints"     // autocomplete will search for concepts which are answersTo this codedConcept (Optional)
            }
        }
    }
}

```
 2) Registration app.json: example -  (Details in comments)

```javascript

"config" : {
  "autoCompleteFields":["familyName", "caste"],
  "defaultIdentifierPrefix": "GAN",
  "searchByIdForwardUrl": "/patient/{{patientUuid}}?visitType=OPD",
  "conceptSetUI": {
      "temparature": {
          "showAbnormalIndicator": true
      }
  },
  "registrationConceptSet":"",
  "showMiddleName": false,
  "registrationCardPrintLayout": "/bahmni_config/openmrs/apps/registration/registrationCardLayout/print.html",
  "localNameSearch": true,                       // registration search displays parameter for search by local name
  "localNameLabel": "मरीज़ का नाम",                // label to be diplyed for local name search input
  "localNamePlaceholder": "मरीज़ का नाम",          // placeholder to be diplyed for local name search input
  "localNameAttributes": ["givenNameLocal", "familyNameLocal"]  //patient attributes to be search against for local name search
}

```
