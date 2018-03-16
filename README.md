# Backup as a Service

tbd

## TODO

A LOT

* Use python or go instead of Bash
* Database Support
  * Select using label
  * rsh into container - stream dump via stdout/stdin
  * rsh into container - detect app
* Prune job
* oc create sa baas
* oc adm policy add-role-to-user edit -z baas

oc create secret generic baas --from-literal=AWS_SECRET_ACCESS_KEY=SECRET --from-literal=AWS_ACCESS_KEY_ID=SECRET --from-literal=RESTIC_PASSWORD=SECRET

