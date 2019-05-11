## VMWARE vSphere maintenance script

This script performs the following actions  
1. Pulls list of vSphere ESXi hosts  
2. Asks which ones you will run VM shutdowns on  
3. Level-sets VM start-up order  
4. Attempts graceful shutdown on all VMs on target ESXi host  

## Code examples
```
Stop-VM -vmhost
```
