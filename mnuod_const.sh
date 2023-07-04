        E='echo -e';e='echo -en';trap "R;exit" 2             
    ODCMD='onedrivecmd'                                   
  IFSPATH='/backup2od'      
   LIBLST=$IFSPATH'/liblist.lst'     
  FLISTHD='System-- Save Date/Time Object--- Type---- Attribute- Size (Bytes)---- Owner------ Description--------------' 
      ESC=$( $e "\e")
num_procs=3     #Number of simultaneous backup tasks - This can help you reduce CPU usage and storage temporary space.
   pgzthr=8     #Number of PIGZ threads - Suggestion: 1 per physical processor thread in your system. IE: 1 P9 Core=8 Threads
  maxsize=250   # Informational by now
   prefix='IBMiA 
