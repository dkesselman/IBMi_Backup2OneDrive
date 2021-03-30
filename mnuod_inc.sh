    TPUT(){ $e "\e[${1};${2}H";}                                             
   CLEAR(){ $e "\ec";}                                                                                                         
   CIVIS(){ $e "\e[?25l";}                                                                                                     
    DRAW(){ $e "\e%@\e(0";}                                                                                                    
   WRITE(){ $e "\e(B";}                                                                                                        
    MARK(){ $e "\e[7m";}                                                                                                       
  UNMARK(){ $e "\e[27m";}
                                                                                                                        
    LINE(){ $E ""; $E "\033(0rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr\033(B";}                      
                                                                                                                           
#***********************************************************************************#                                      
#                           Cloud Functions                                         #                                      
#***********************************************************************************#                                      
                                                                                                                          
BUCKETLS(){ read -p "Directory to list: " odpath ; $ODCMD list od:$odpath;LINE;}                                       
BUCKETPT(){ read -p "OneDrive target directory : " odpath ; read -p "File on IFS:" ifsfile; $ODCMD put $ifsfile od:$odpath ;LINE;}                          
BUCKETGT(){ read -p "OneDrive source file : " odobject; read -p "Target directory on IFS:" ifsfile; $ODCMD get od:$odobject $ifsfile ;LINE;}
BUCKETDL(){ read -p "OneDrive source file : " odobject; $ODCMD  delete od:$odobject ;LINE;}                                     
 ASKLIB1(){ read -p "Library name: " libname; read -p "OneDrive directory : " odpath; ifsfile=$IFSPATH/$libname.zip ;} 
 SAVLIST(){ system "CPYTOIMPF FROMFILE(BACKUPSAV/BKPLOG $libname ) TOSTMF('$IFSPATH/$libname.csv') MBROPT(*ADD) STMFCCSID(1208) RCDDLM(*CRLF) DTAFMT(*DLM) DATFMT(*YYMD)" ;} 
 CRTLIB1(){ mkdir -p $IFSPATH; system "CRTLIB BACKUPSAV" 2>&1 ;  }         
     B2C(){ $ODCMD  put $ifsfile "od:/"$odpath ;$ODCMD  put $ifslog "od:/"$odpath;}                                                                                                                                                       
BKPTOCLD(){ ASKLIB1;CRTLIB1;SAVLIB1;SAVLIST;ZIPLIB1; B2C;LINE;}            
SAVZIP2(){ $E 'Saving Library:' $libname ' - ' $dt;SAVLIB1;SAVLIST;ZIPLIB1;B2C;LINE;}
 UNZIP1(){ pigz -d -K -k -c $libname"_lst.zip" > $libname".csv"; }
#***********************************************************************************#        
LSTCLDBKP(){
ASKLIB1;
cd $IFSPATH
odobject=$odpath"/"$libname"_lst.zip";
echo $odobject;
$ODCMD get od:$odobject $IFSPATH"/"; 
UNZIP1;
#------------------------------------------
CLEAR;WRITE;MARK;TPUT 6 0 
$E $FLISTHD; 
awk -F "," '{print($3,$12,$13,$15,$16,$17,$18,$22)}' $libname".csv" | tr -d '"';
#------------------------------------------
}
#***********************************************************************************#                                                                                                                                                     
 SAVLIB1(){ 
rm /QSYS.LIB/BACKUPSAV.LIB/$libname.FILE 2>&1 ;
system "RMVM FILE(BACKUPSAV/BKPLOG) MBR($libname)" 2>&1;
system "CRTSAVF BACKUPSAV/$libname"; 
system "SAVLIB LIB($libname) DEV(*SAVF) SAVF(BACKUPSAV/$libname) SAVACT(*LIB) SAVACTWAIT(60) OUTPUT(*OUTFILE) OUTFILE(BACKUPSAV/BKPLOG) OUTMBR($libname)"; 
}
#***********************************************************************************#        
 ZIPLIB1(){ 
cd /QSYS.LIB/BACKUPSAV.LIB/;
rm $IFSPATH/$libname.zip 2>&1 ; 
pigz -K -c $libname".FILE" > "/"$IFSPATH"/"$libname".zip";
rm $libname".FILE";
ifslog=$IFSPATH/$libname"_lst.zip";
cd $IFSPATH; 
pwd
pigz -K -c $libname".csv" > $ifslog;
rm $libname".csv";
}  
#***********************************************************************************#        
SAVSECDTA(){ 
rm /QSYS.LIB/BACKUPSAV.LIB/SAVSECDTA.FILE 2>&1 ;
system "CRTSAVF BACKUPSAV/SAVSECDTA"; 
system "SAVSECDTA DEV(*SAVF) SAVF(BACKUPSAV/SAVSECDTA) OUTPUT(*OUTFILE) OUTFILE(BACKUPSAV/BKPLOG) OUTMBR(SAVSECDTA)"; 
libname="SAVSECDTA";
ifsfile=$IFSPATH"/"$libname".zip";
SAVLIST;
ZIPLIB1;
B2C; 
}   
#***********************************************************************************#                                                                                                                                                     
BKPTOCLD2(){
CRTLIB1; 
#Purge BACKUPSAV library and IFS path
rm /QSYS.LIB/BACKUPSAV.LIB/*.FILE 2>&1
rm $IFSPATH/*.zip 2>&1
rm $IFSPATH/*.csv 2>&1

#List libraries excluding Q*, SYS* & ASN
cd /QSYS.LIB;ls |grep '\.LIB' |cut -f1 -d"." |grep -Fv -e 'Q' -e 'SYS' -e '#' -e 'ASN' -e 'BACKUPSAV'  > $LIBLST;

#Add some libraries to the list
$E "QGPL"    >> $LIBLST;    
$E "QS36F"   >> $LIBLST;    
$E "QUSRSYS" >> $LIBLST;    

dt=$(date '+%Y%m%d-%H%M%S');
dt2=$(date '+%Y%m%d');
LOGNAME=$IFSPATH'/BAK'$dt'.log';                                                                                                                                                      
odpath='BKP'$dt2'/';

$E 'SAVING DATA TO :' $odpath

$E 'Starting Backup: BKP' $dt2 ' - ' $dt > $LOGNAME    

# Save Security Data

$E 'Saving Security Data: ' $odpath  >> $LOGNAME    
 
SAVSECDTA;                 

# Save library 1 by 1
i=0;
num_jobs="\j"
liblst=$(cat $LIBLST);
for libname in $liblst
do
        i=$((i+1));
        ifsfile=$IFSPATH/$libname.zip ;
        dt=$(date '+%Y%m%d-%H%M%S');
	SAVZIP2 >> $LOGNAME & 
        while (( ${num_jobs@P} >= num_procs )) 
        do
            wait -n
        done
done

wait

LINE;
$e $i "Libraries backed up to " $odpath;
 
dt=$(date '+%Y%m%d-%H%M%S');
echo 'Backup ending: BKP' $dt2 ' - ' $dt > $LOGNAME                                                                                                                                                                                     
} 
#***********************************************************************************#                             
                                                                                                    
      R(){ CLEAR ;stty sane;$e "\ec\e[96m\e[J";};                                          
    HEAD(){ DRAW                                                                      
           TPUT 4 0                                                         
           for each in $(seq 1 14);do                                                                                          
           $E "   x                                          x"                                                                
           done                                                                                                                
           WRITE;MARK;TPUT 4 5                                                                                                  
           $E "OneDrive BACKUP MENU                      ";UNMARK;}                                                            
           i=0; CLEAR; CIVIS;NULL=/dev/null                                                                                
   FOOT(){ MARK;TPUT 17 5                                                                                                 
           printf "ENTER - SELECT,NEXT                       ";UNMARK;}                                                    
  ARROW(){ read -s -n3 key 2>/dev/null >&2                                                                                
           if [[ $key = $ESC[A ]];then echo up;fi                                                           
           if [[ $key = $ESC[B ]];then echo dn;fi;}                                                                             
     M0(){ TPUT  7 11; $e "List content on OneDrive      ";}                                                               
     M1(){ TPUT  8 11; $e "Upload file to OneDrive       ";}                                                               
     M2(){ TPUT  9 11; $e "Get file from OneDrive        ";}                                                              
     M3(){ TPUT 10 11; $e "Delete file from OneDrive     ";}                                                              
     M4(){ TPUT 11 11; $e "Save Library to OneDrive      ";}                                                                    
     M5(){ TPUT 12 11; $e "Save ALL Libraries to OneDrive";}                                                               
     M6(){ TPUT 13 11; $e "List library saved on Cloud   ";}
     M7(){ TPUT 14 11; $e "ABOUT                         ";}                                                              
     M8(){ TPUT 15 11; $e "EXIT                          ";}                                                             
      LM=8;                                                                                                                 
   MENU(){ for each in $(seq 0 $LM);do M${each};done;}                                                                     
   POS(){ if [[ $cur == up ]];then ((i--));fi                                                                              
           if [[ $cur == dn ]];then ((i++));fi                                                                             
           if [[ $i -lt 0   ]];then i=$LM;fi                                                                               
           if [[ $i -gt $LM ]];then i=0;fi;}                                                                                    
REFRESH(){ after=$((i+1)); before=$((i-1))                                                                                 
           if [[ $before -lt 0  ]];then before=$LM;fi                                                                     
           if [[ $after -gt $LM ]];then after=0;fi                                                                        
           if [[ $j -lt $i      ]];then UNMARK;M$before;else UNMARK;M$after;fi                                                  
           if [[ $after -eq 0 ]] || [ $before -eq $LM ];then                                                                    
           UNMARK; M$before; M$after;fi;j=$i;UNMARK;M$before;M$after;}                           
   INIT(){ R;HEAD;FOOT;MENU;}                                                                                              
     SC(){ REFRESH;MARK;$S;$b;cur=`ARROW`;}                                                                                   
     ES(){ MARK;$e "    ENTER = main menu    ";$b;read;INIT;};INIT          

