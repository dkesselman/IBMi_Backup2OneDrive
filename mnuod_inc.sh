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
 ASKLIB1(){ read -p "Library name: " libname; read -p "OneDrive target directory : " odpath; ifsfile=$IFSPATH/$libname.zip ;}           
 CRTLIB1(){ mkdir -p $IFSPATH; system "CRTLIB BACKUPSAV" ;}                                                                                          
 SAVLIB1(){ rm /QSYS.LIB/BACKUPSAV.LIB/$libname.FILE ;system "CRTSAVF BACKUPSAV/$libname"; system "SAVLIB LIB($libname) DEV(*SAVF) SAVF(BACKUPSAV/$libname) SAVACT(*LIB) SAVACTWAIT(60) "; }    
 ZIPLIB1(){ cd /QSYS.LIB/BACKUPSAV.LIB/;rm $IFSPATH/$libname.zip ;pigz -v -K -c $libname.FILE > /$IFSPATH/$libname.zip ; }  
     B2C(){ $ODCMD  put $ifsfile "od:/"$odpath ;}
BKPTOCLD(){ ASKLIB1;CRTLIB1;SAVLIB1;ZIPLIB1; B2C;LINE;}                                                                                            
SAVSECDTA(){ rm /QSYS.LIB/BACKUPSAV.LIB/SAVSECDTA.FILE;system "CRTSAVF BACKUPSAV/SAVSECDTA"; system "SAVSECDTA DEV(*SAVF) SAVF(BACKUPSAV/SAVSECDTA)"; libname="SAVSECDTA";ifsfile=$IFSPATH/$libname.zip ; ZIPLIB1;B2C; }   
  SAVZIP2(){ SAVLIB1;ZIPLIB1;$e $odpath;B2C ;}
BKPTOCLD2(){ 
CRTLIB1;
#Depuro biblioteca de salvado y directorio del IFS
rm /QSYS.LIB/BACKUPSAV.LIB/*.FILE
rm $IFSPATH/*.zip
#Listo bibliotecas excluyendo las Q*, SYS* y ASN
cd /QSYS.LIB;ls |grep '\.LIB' |cut -f1 -d"." |grep -Fv -e 'Q' -e 'SYS' -e '#' -e 'ASN' -e 'BACKUPSAV'  > $LIBLST;

dt=$(date '+%Y%m%d-%H%M%S');
dt2=$(date '+%Y%m%d');
LOGNAME=$IFSPATH'/BAK'$dt'.log';                                                                                                                                                      
odpath='BKP'$dt2'/';

echo 'SAVING DATA TO :' $odpath

# Save Security Data

echo 'Saving Security Data: ' $odpath
echo 'Saving Security Data: ' $odpath  > $LOGNAME    
  
SAVSECDTA;                 

# Save library 1 by 1
i=0;
liblst=$(cat $LIBLST);
for libname in $liblst
do
        i=$((i+1));
        ifsfile=$IFSPATH/$libname.zip ;
	SAVZIP2 >> $LOGNAME 
        rm /QSYS.LIB/BACKUPSAV.LIB/$libname.FILE 
done
LINE;
$e $i "Libraries backed up to " $odpath; 
} 
#***********************************************************************************#                             
                                                                                                    
      R(){ CLEAR ;stty sane;$e "\ec\e[37;44m\e[J";};                                          
    HEAD(){ DRAW                                                                      
           TPUT 4 0                                                         
           for each in $(seq 1 13);do                                                                                                  
           $E "   x                                          x"                                                                     
           done                                                                                                                     
           WRITE;MARK;TPUT 4 5                                                                                                                
           $E "OneDrive BACKUP MENU                      ";UNMARK;}                                                                              
           i=0; CLEAR; CIVIS;NULL=/dev/null                                                                                                     
   FOOT(){ MARK;TPUT 16 5                                                                                                                        
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
     M6(){ TPUT 13 11; $e "ABOUT                         ";}                                                                                     
     M7(){ TPUT 14 11; $e "EXIT                          ";}                                                                                  
      LM=7                                                                                                                                      
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

