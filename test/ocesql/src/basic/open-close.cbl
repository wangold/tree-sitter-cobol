       IDENTIFICATION              DIVISION.
      ******************************************************************
       PROGRAM-ID.                 prog.
      ******************************************************************
       DATA                        DIVISION.
      ******************************************************************
       WORKING-STORAGE             SECTION.
       01 TEST-CASE-COUNT PIC 9999 VALUE 1.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME                  PIC  X(30) VALUE SPACE.
       01  USERNAME                PIC  X(30) VALUE SPACE.
       01  PASSWD                  PIC  X(10) VALUE SPACE.

       01  EMP-REC-VARS.
         03  EMP-NO                PIC S9(04) VALUE ZERO.
         03  EMP-NAME              PIC  X(20) .
         03  EMP-SALARY            PIC S9(04) VALUE ZERO.
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.
      ******************************************************************
       PROCEDURE                   DIVISION.
      ******************************************************************
       MAIN-RTN.
           
       PERFORM SETUP-DB.

       EXEC SQL
           DECLARE CURSOR1 CURSOR FOR SELECT * FROM EMP
       END-EXEC.

      * Test case 0001 *************************************************
       EXEC SQL
           OPEN CURSOR1
       END-EXEC.
       PERFORM DISPLAY-TEST-RESULT.
      ******************************************************************

      * Test case 0002 *************************************************
       EXEC SQL
           CLOSE CURSOR1
       END-EXEC.
       PERFORM DISPLAY-TEST-RESULT.
      ******************************************************************

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
               DROP TABLE IF EXISTS EMP
           END-EXEC.

           EXEC SQL
                CREATE TABLE EMP
                (
                    EMP_NO     NUMERIC(4,0) NOT NULL,
                    EMP_NAME   CHAR(20),
                    EMP_SALARY NUMERIC(4,0),
                    CONSTRAINT IEMP_0 PRIMARY KEY (EMP_NO)
                )
           END-EXEC.

      ******************************************************************
       CLEANUP-DB.
      ******************************************************************
           EXEC SQL
               DROP TABLE IF EXISTS EMP
           END-EXEC.

           EXEC SQL
               DISCONNECT ALL
           END-EXEC.

      ******************************************************************
       DISPLAY-TEST-RESULT.
      ******************************************************************
           IF  SQLCODE = ZERO
             THEN

               DISPLAY "<log> test case " TEST-CASE-COUNT ": success"
               ADD 1 TO TEST-CASE-COUNT

             ELSE
               DISPLAY "*** SQL ERROR ***"
               DISPLAY "SQLCODE: " SQLCODE " " NO ADVANCING
               EVALUATE SQLCODE
                  WHEN  +10
                     DISPLAY "Record not found"
                  WHEN  -01
                     DISPLAY "Connection falied"
                  WHEN  -20
                     DISPLAY "Internal error"
                  WHEN  -30
                     DISPLAY "PostgreSQL error"
                     DISPLAY "ERRCODE: "  SQLSTATE
                     DISPLAY SQLERRMC
                  *> TO RESTART TRANSACTION, DO ROLLBACK.
                     EXEC SQL
                         ROLLBACK
                     END-EXEC
                  WHEN  OTHER
                     DISPLAY "Undefined error"
                     DISPLAY "ERRCODE: "  SQLSTATE
                     DISPLAY SQLERRMC
               END-EVALUATE
               STOP RUN.
      ******************************************************************  
