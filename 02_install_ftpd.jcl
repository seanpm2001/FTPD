//RECVFTPD JOB (FTPD),
//            'FTPD XMI',
//            CLASS=A,
//            MSGCLASS=A,
//            REGION=8M,
//            MSGLEVEL=(1,1),
//            USER=IBMUSER,PASSWORD=SYS1
//FTDELETE EXEC PGM=IDCAMS,REGION=1024K
//SYSPRINT DD  SYSOUT=A
//SYSIN    DD  *
 DELETE SYSGEN.FTPD.LOADLIB NONVSAM SCRATCH PURGE
 DELETE SYS2.PROCLIB(FTPD)
 DELETE SYS2.LINKLIB(FTPD)
 DELETE SYS2.LINKLIB(FTPDXCTL)
 /* IF THERE WAS NO DATASET TO DELETE, RESET CC           */
 IF LASTCC = 8 THEN
   DO
       SET LASTCC = 0
       SET MAXCC = 0
   END
/*
//* RECV370 DDNAMEs:
//* ----------------
//*
//*     RECVLOG    RECV370 output messages (required)
//*
//*     RECVDBUG   Optional, specifies debugging options.
//*
//*     XMITIN     input XMIT file to be received (required)
//*
//*     SYSPRINT   IEBCOPY output messages (required for DSORG=PO
//*                input datasets on SYSUT1)
//*
//*     SYSUT1     Work dataset for IEBCOPY (not needed for sequential
//*                XMITs; required for partitioned XMITs)
//*
//*     SYSUT2     Output dataset - sequential or partitioned
//*
//*     SYSIN      IEBCOPY input dataset (required for DSORG=PO XMITs)
//*                A DUMMY dataset.
//*
//RECV370 EXEC PGM=RECV370
//STEPLIB  DD  DISP=SHR,DSN=SYSC.LINKLIB
//XMITIN   DD  UNIT=01C,DCB=(RECFM=FB,LRECL=80,BLKSIZE=80)
//RECVLOG  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  DUMMY
//* Work temp dataset
//SYSUT1   DD  DSN=&&SYSUT1,
//             UNIT=VIO,
//             SPACE=(CYL,(5,1)),
//             DISP=(NEW,DELETE,DELETE)
//* Output dataset
//SYSUT2   DD  DSN=SYSGEN.FTPD.LOADLIB,
//             UNIT=SYSALLDA,VOL=SER=PUB001,
//             SPACE=(CYL,(15,2,20),RLSE),
//             DISP=(NEW,CATLG,DELETE)
//*
//* Copy FTPD/FTPDXCTL to SYS2.LINKLIB
//*
//STEP2CPY EXEC PGM=IEBCOPY
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  DSN=SYSGEN.FTPD.LOADLIB,DISP=SHR
//SYSUT2   DD  DSN=SYS2.LINKLIB,DISP=SHR
//SYSIN    DD  *
  COPY INDD=((SYSUT1,R)),OUTDD=SYSUT2
/*
//*
//* Add FTPD to SYS2.PROCLIB
//*
//FTPDDEVC EXEC PGM=IEBGENER
//SYSUT1   DD DATA,DLM=@@
//FTPD   PROC PASVADR='127,0,0,1',SRVIP='any',SRVPORT=21021
//********************************************************************
//*
//* MVS3.8j RAKF Enabled FTP server PROC
//* To use: in Hercules console issue /s FTPD to start FTP server on
//*         on port 21021
//*
//********************************************************************
//FTPD   EXEC PGM=FTPDXCTL,TIME=1440,REGION=4096K,
// PARM='PASVADR=&PASVADR SRVIP=&SRVPORT SRVPORT=&SRVIP DD=AAINTRDR'
//AAINTRDR DD SYSOUT=(A,INTRDR),DCB=(RECFM=FB,LRECL=80,BLKSIZE=80)
//STDOUT   DD SYSOUT=*
@@
//SYSUT2   DD DISP=SHR,DSN=SYS2.PROCLIB(FTPD)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//*
//* Add VATLSTFF to SYS1.PARMLIB
//*
//FTPDDEVC EXEC PGM=IEBGENER
//SYSUT1   DD DATA,DLM=@@
MVSRES,0,2,3350    ,Y        SYSTEM RESIDENCE (PRIVATE)
MVS000,0,2,3350    ,Y        SYSTEM DATASETS (PRIVATE)
PUB000,1,2,3380    ,N        PUBLIC DATASETS (PRIVATE)
PUB001,1,2,3390    ,N        PUBLIC DATASETS (PRIVATE)
SYSCPK,1,2,3350    ,N        COMPILER/TOOLS (PRIVATE)
@@
//SYSUT2   DD DISP=SHR,DSN=SYS1.PARMLIB(VATLSTFF)
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY

