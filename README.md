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

Production environment
======================
*Folder structure*
/root/bahmni-environment -> Running deployment scripts

/root/release-backups -> Create subfolders in this directory for backing up previous build, configs etc. The folder can be named as r<release-number>.ddmmyyyy. Eg: r4.0.06062014

/root/tmp - for creating temporary files for current deployment related activities. Assume that it can be deleted by anyone without asking.

/root/jss-config -> Running jss specific scripts

/root/jss-reports -> Deploying reports on slave 

/backup -> The backup scripts in bahmni-environment create db backups in this folder. During release if you create db backups, please delete other backups older than month or so.

*Key steps*

1) On Slave
- Stop tomcat, nagios

2) On master
- Stop tomcat, openerp, nrpe
- Backup mysql and pgsql databases ./scripts/backup-all-dbs.sh
- Backup folder - /packages/build, .OpenMRS, tomcat/webapps, httpd conf
- Download or copy build

3) On master
- deploy-jss

4) On Slave
- deploy-module.sh bahmni-jasperreports

5) On Slave
- Start tomcat, nagios

6) On master
- Start tomcat, openerp, nrpe
- Tag the bahmni-environment with release date

*Testing in PreProd*
- For deleting cache -> rm -rf /var/cache/mod_proxy/*
