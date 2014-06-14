/root/bahmni-environment -> Running deployment scripts

/root/release-backups -> Create subfolders in this directory for backing up previous build, configs etc. The folder can be named as r<release-number>.ddmmyyyy. Eg: r4.0.06062014

/root/tmp - for creating temporary files for current deployment related activities. Assume that it can be deleted by anyone without asking.

/root/jss-config -> Running jss specific scripts

/root/jss-reports -> Deploying reports on slave 

/backup -> The backup scripts in bahmni-environment create db backups in this folder. During release if you create db backups, please delete other backups older than month or so.
