       IDENTIFICATION              DIVISION.
      ******************************************************************
       PROGRAM-ID.                 prog.
      ******************************************************************
       DATA                        DIVISION.
      ******************************************************************
       WORKING-STORAGE             SECTION.
       01 V PIC X(10).

       01  TEST-DATA.
         03 FILLER  PIC X(10) VALUE "xxxxxxxxxx".
         03 FILLER  PIC X(10) VALUE "abcdefghij".
         03 FILLER  PIC X(10) VALUE "1234567890".
         03 FILLER  PIC X(10) VALUE "abc_______".
         03 FILLER  PIC X(10) VALUE "??????????".
         03 FILLER  PIC X(10) VALUE "{}^|!%#$()".
         03 FILLER  PIC X(10) VALUE "����������".
         03 FILLER  PIC X(10) VALUE "���{��aaaa".
         03 FILLER  PIC X(10) VALUE "�P�Q�R�S�T".
         03 FILLER  PIC X(10) VALUE "�v���O����".

       01  TEST-DATA-R   REDEFINES TEST-DATA.
         03  TEST-TBL    OCCURS  10.
           05  D             PIC X(10).

       01  IDX                     PIC  S9(02) .
       01 LOG-COUNT PIC 9999 VALUE 1.

       01 READ-DATA-TBL.
         03  READ-TBL    OCCURS  10.
           05  READ-DATA     PIC X(10).

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME                  PIC  X(30) VALUE SPACE.
       01  USERNAME                PIC  X(30) VALUE SPACE.
       01  PASSWD                  PIC  X(10) VALUE SPACE.
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.
      ******************************************************************
       PROCEDURE                   DIVISION.
      ******************************************************************
       MAIN-RTN.
           
       PERFORM SETUP-DB.

      *    SHOW RESULT
           EXEC SQL
               SELECT FIELD INTO :READ-TBL FROM TESTTABLE ORDER BY N
           END-EXEC.

           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 10
               DISPLAY READ-DATA(IDX)
           END-PERFORM.

       PERFORM CLEANUP-DB.

      *    END
           STOP RUN.

      ******************************************************************
       SETUP-DB.
      ******************************************************************

      *    SERVER
           MOVE  "<|DB_NAME|>@<|DB_HOST|>:<|DB_PORT|>"
             TO DBNAME.
           MOVE  "<|DB_USER|>"
             TO USERNAME.
           MOVE  "<|DB_PASSWORD|>"
             TO PASSWD.

           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME 
           END-EXEC.

           EXEC SQL
               DROP TABLE IF EXISTS TESTTABLE
           END-EXEC.

           EXEC SQL
                CREATE TABLE TESTTABLE
                (
                    N         NUMERIC(2,0) NOT NULL,
                    FIELD     CHAR(10)
                )
           END-EXEC.

      *    INSERT ROWS USING HOST VARIABLE
           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 10
              MOVE D(IDX)     TO  V
              EXEC SQL
                 INSERT INTO TESTTABLE VALUES (:IDX, :V)
              END-EXEC
           END-PERFORM.

      *    COMMIT
           EXEC SQL
               COMMIT WORK
           END-EXEC.

      ******************************************************************
       CLEANUP-DB.
      ******************************************************************
           EXEC SQL
               DROP TABLE IF EXISTS TESTTABLE
           END-EXEC.

           EXEC SQL
               DISCONNECT ALL
           END-EXEC.
