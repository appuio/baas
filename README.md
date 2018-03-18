# Backup as a Service

tbd

## TODO

A LOT

* Database Support
  * Select using label
  * rsh into container - detect app
  * rsh into container - stream dump via stdout/stdin
* https://github.com/Sirupsen/logrus
* Subcommands:
  * restic backup
  * generate app specific job
  * init
    * generate cronjob
    * oc create sa baas
    * oc adm policy add-role-to-user edit -z baas
    * oc create secret generic baas --from-literal=AWS_SECRET_ACCESS_KEY=SECRET --from-literal=AWS_ACCESS_KEY_ID=SECRET --from-literal=RESTIC_PASSWORD=SECRET
* Use go openshift client