       IDENTIFICATION              DIVISION.
      ******************************************************************
       PROGRAM-ID.                 prog.
       DATA                        DIVISION.
       WORKING-STORAGE             SECTION.
       01 EMP-NO-MAX PIC S9(04).
       01 EMP-NO-MIN PIC S9(04).

       01 EMP-NO-MAX-U PIC 9(04).
       01 EMP-NO-MIN-U PIC 9(04).

       01 EMP-NAME-X PIC X(20).

       01  D-EMP-REC.
           05  D-EMP-NO            PIC  9(04).
           05  FILLER              PIC  X.
           05  D-EMP-NAME          PIC  X(20).
           05  FILLER              PIC  X.
           05  D-EMP-SALARY        PIC  --,--9.

       01  TEST-DATA.
         03 FILLER       PIC X(28) VALUE "0001HOKKAI TARO         0400".
         03 FILLER       PIC X(28) VALUE "0002AOMORI JIRO         0350".
         03 FILLER       PIC X(28) VALUE "0003AKITA SABURO        0300".
         03 FILLER       PIC X(28) VALUE "0004IWATE SHIRO         025p".
         03 FILLER       PIC X(28) VALUE "0005MIYAGI GORO         020p".
         03 FILLER       PIC X(28) VALUE "0006FUKUSHIMA RIKURO    0150".
         03 FILLER       PIC X(28) VALUE "0007TOCHIGI SHICHIRO    010p".
         03 FILLER       PIC X(28) VALUE "0008IBARAKI HACHIRO     0050".
         03 FILLER       PIC X(28) VALUE "0009GUMMA KURO          020p".
         03 FILLER       PIC X(28) VALUE "0010SAITAMA JURO        0350".
       01  TEST-DATA-R   REDEFINES TEST-DATA.
         03  TEST-TBL    OCCURS  10.
           05  TEST-NO             PIC S9(04).
           05  TEST-NAME           PIC  X(20) .
           05  TEST-SALARY         PIC S9(04).
       01  IDX                     PIC  9(02).
       01  SYS-TIME                PIC  9(08).
 
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
           MOVE  "<|DB_NAME|>@<|DB_HOST|>:<|DB_PORT|>"
             TO DBNAME.
           MOVE  "<|DB_USER|>"
             TO USERNAME.
           MOVE  "<|DB_PASSWORD|>"
             TO PASSWD.

           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME 
           END-EXEC.
           IF  SQLCODE NOT = ZERO PERFORM ERROR-RTN STOP RUN.
           
      *    DROP TABLE
           EXEC SQL
               DROP TABLE IF EXISTS EMP
           END-EXEC.
           IF  SQLCODE NOT = ZERO PERFORM ERROR-RTN.
           
      *    CREATE TABLE 
           EXEC SQL
                CREATE TABLE EMP
                (
                    EMP_NO     NUMERIC(4,0) NOT NULL,
                    EMP_NAME   CHAR(20),
                   EMP_SALARY NUMERIC(4,0),
                    CONSTRAINT IEMP_0 PRIMARY KEY (EMP_NO)
                )
           END-EXEC.
           IF  SQLCODE NOT = ZERO PERFORM ERROR-RTN STOP RUN.

      *    INSERT ROWS USING HOST VARIABLE
           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 10
              MOVE TEST-NO(IDX)     TO  EMP-NO
              MOVE TEST-NAME(IDX)   TO  EMP-NAME
              MOVE TEST-SALARY(IDX) TO  EMP-SALARY
              EXEC SQL
                 INSERT INTO EMP VALUES
                        (:EMP-NO,:EMP-NAME,:EMP-SALARY)
              END-EXEC
              IF  SQLCODE NOT = ZERO 
                  PERFORM ERROR-RTN
                  EXIT PERFORM
              END-IF
           END-PERFORM.

      *    COMMIT
           EXEC SQL COMMIT WORK END-EXEC.

           MOVE 5 TO EMP-NO-MIN.
           MOVE 9 TO EMP-NO-MAX.
           EXEC SQL 
               DECLARE C1 CURSOR FOR
               SELECT EMP_NO, EMP_NAME, EMP_SALARY 
                      FROM EMP
                      WHERE EMP_NO >= :EMP-NO-MIN
                        AND EMP_NO <= :EMP-NO-MAX
                      ORDER BY EMP_NO
           END-EXEC.
           EXEC SQL
               OPEN C1
           END-EXEC.
           
           EXEC SQL 
               FETCH C1 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
           END-EXEC.
           PERFORM UNTIL SQLCODE NOT = ZERO 
              MOVE  EMP-NO        TO    D-EMP-NO
              MOVE  EMP-NAME      TO    D-EMP-NAME
              MOVE  EMP-SALARY    TO    D-EMP-SALARY
              DISPLAY D-EMP-REC
              EXEC SQL 
                  FETCH C1 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
              END-EXEC
      *       ADD 1 TO LOOP-COUNTER
           END-PERFORM.

           EXEC SQL 
               CLOSE C1 
           END-EXEC. 
           DISPLAY "--".

           MOVE 5 TO EMP-NO-MIN-U.
           MOVE 9 TO EMP-NO-MAX-U.
           EXEC SQL 
               DECLARE C2 CURSOR FOR
               SELECT EMP_NO, EMP_NAME, EMP_SALARY 
                      FROM EMP
                      WHERE EMP_NO >= :EMP-NO-MIN-U
                        AND EMP_NO <= :EMP-NO-MAX-U
                      ORDER BY EMP_NO
           END-EXEC.
           EXEC SQL
               OPEN C2
           END-EXEC.
           
           EXEC SQL 
               FETCH C2 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
           END-EXEC.
           PERFORM UNTIL SQLCODE NOT = ZERO 
              MOVE  EMP-NO        TO    D-EMP-NO
              MOVE  EMP-NAME      TO    D-EMP-NAME
              MOVE  EMP-SALARY    TO    D-EMP-SALARY
              DISPLAY D-EMP-REC
              EXEC SQL 
                  FETCH C2 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
              END-EXEC
      *       ADD 1 TO LOOP-COUNTER
           END-PERFORM.
           
           EXEC SQL 
               CLOSE C2 
           END-EXEC. 
           DISPLAY "--".

           MOVE "MIYAGI GORO" TO EMP-NAME-X.
           EXEC SQL 
               DECLARE C3 CURSOR FOR
               SELECT EMP_NO, EMP_NAME, EMP_SALARY 
                      FROM EMP
                      WHERE EMP_NAME = :EMP-NAME-X
                      ORDER BY EMP_NO
           END-EXEC.
           EXEC SQL
               OPEN C3
           END-EXEC.
           
           EXEC SQL 
               FETCH C3 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
           END-EXEC.
           PERFORM UNTIL SQLCODE NOT = ZERO 
              MOVE  EMP-NO        TO    D-EMP-NO
              MOVE  EMP-NAME      TO    D-EMP-NAME
              MOVE  EMP-SALARY    TO    D-EMP-SALARY
              DISPLAY D-EMP-REC
              EXEC SQL 
                  FETCH C3 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
              END-EXEC
      *       ADD 1 TO LOOP-COUNTER
           END-PERFORM.
           
           EXEC SQL 
               CLOSE C3
           END-EXEC.
           DISPLAY "--".

           MOVE "MIYAGI GORO" TO EMP-NAME-X.
           MOVE 5 TO EMP-NO-MIN-U.
           MOVE 9 TO EMP-NO-MAX-U.
           EXEC SQL 
               DECLARE C4 CURSOR FOR
               SELECT EMP_NO, EMP_NAME, EMP_SALARY 
                      FROM EMP
                      WHERE EMP_NAME != :EMP-NAME-X
                        AND EMP_NO >= :EMP-NO-MIN-U
                        AND EMP_NO <= :EMP-NO-MAX-U
                      ORDER BY EMP_NO
           END-EXEC.
           EXEC SQL
               OPEN C4
           END-EXEC.
           
           EXEC SQL 
               FETCH C4 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
           END-EXEC.
           PERFORM UNTIL SQLCODE NOT = ZERO 
              MOVE  EMP-NO        TO    D-EMP-NO
              MOVE  EMP-NAME      TO    D-EMP-NAME
              MOVE  EMP-SALARY    TO    D-EMP-SALARY
              DISPLAY D-EMP-REC
              EXEC SQL 
                  FETCH C4 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
              END-EXEC
      *       ADD 1 TO LOOP-COUNTER
           END-PERFORM.
           
           EXEC SQL 
               CLOSE C4
           END-EXEC.
           DISPLAY "--".

           MOVE 5 TO EMP-NO.
           EXEC SQL 
               DECLARE C5 CURSOR FOR
               SELECT EMP_NO, EMP_NAME, EMP_SALARY 
                      FROM EMP
                      GROUP BY EMP_NO
                      HAVING EMP_NO = :EMP-NO
                      ORDER BY EMP_NO
           END-EXEC.
           EXEC SQL
               OPEN C5
           END-EXEC.
           
           EXEC SQL 
               FETCH C5 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
           END-EXEC.
           PERFORM UNTIL SQLCODE NOT = ZERO 
              MOVE  EMP-NO        TO    D-EMP-NO
              MOVE  EMP-NAME      TO    D-EMP-NAME
              MOVE  EMP-SALARY    TO    D-EMP-SALARY
              DISPLAY D-EMP-REC
              EXEC SQL 
                  FETCH C5 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
              END-EXEC
      *       ADD 1 TO LOOP-COUNTER
           END-PERFORM.

           EXEC SQL 
               CLOSE C5
           END-EXEC.
           DISPLAY "--".

           MOVE 5 TO EMP-NO-MIN-U.
           MOVE 9 TO EMP-NO-MAX-U.
           EXEC SQL 
               DECLARE C6 CURSOR FOR
               SELECT EMP_NO, EMP_NAME, EMP_SALARY 
                      FROM EMP
                      WHERE EMP_NO >= :EMP-NO-MIN-U
                      GROUP BY EMP_NO
                      HAVING EMP_NO <= :EMP-NO-MAX-U
                      ORDER BY EMP_NO
           END-EXEC.
           EXEC SQL
               OPEN C6
           END-EXEC.
           
           EXEC SQL 
               FETCH C6 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
           END-EXEC.
           PERFORM UNTIL SQLCODE NOT = ZERO 
              MOVE  EMP-NO        TO    D-EMP-NO
              MOVE  EMP-NAME      TO    D-EMP-NAME
              MOVE  EMP-SALARY    TO    D-EMP-SALARY
              DISPLAY D-EMP-REC
              EXEC SQL 
                  FETCH C6 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
              END-EXEC
      *       ADD 1 TO LOOP-COUNTER
           END-PERFORM.

           EXEC SQL 
               CLOSE C6
           END-EXEC.
           
      *    DISCONNECT
           EXEC SQL
               DISCONNECT ALL
           END-EXEC.
           
           STOP RUN.

      ******************************************************************
       ERROR-RTN.
      ******************************************************************
           DISPLAY "*** SQL ERROR ***".
           DISPLAY "SQLCODE: " SQLCODE " " NO ADVANCING.
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
           END-EVALUATE.
      ******************************************************************
