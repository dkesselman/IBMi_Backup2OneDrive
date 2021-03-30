        E='echo -e';e='echo -en';trap "R;exit" 2                                
      ODCMD='onedrivecmd'                                   
  IFSPATH='/backup2od'      
   LIBLST=$IFSPATH'/liblist.lst'     
  FLISTHD='System-- Save Date/Time Object--- Type---- Attribute- Size (Bytes)---- Owner------ Description--------------' 
      ESC=$( $e "\e")
    num_procs=8
