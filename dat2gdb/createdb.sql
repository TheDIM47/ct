CREATE DATABASE "d:\ibabc.gdb"
USER "SYSDBA" PASSWORD "masterkey"
PAGE_SIZE 4096
DEFAULT CHARACTER SET WIN1251;

/* CREATE SYSTEM INDEXES FOR IB5.X (from http://www.ibase.ru) */

CREATE INDEX RDB$D_DON  ON RDB$DEPENDENCIES     ( RDB$DEPENDED_ON_NAME );
CREATE INDEX RDB$D_DN   ON RDB$DEPENDENCIES     ( RDB$DEPENDENT_NAME );
CREATE INDEX RDB$D_DNON ON RDB$DEPENDENCIES     ( RDB$DEPENDENT_NAME, RDB$DEPENDED_ON_NAME );
CREATE INDEX RDB$LF_FS  ON RDB$LOG_FILES        ( RDB$FILE_SEQUENCE );
CREATE INDEX RDB$TR_ID  ON RDB$TRANSACTIONS     ( RDB$TRANSACTION_ID );
CREATE INDEX RDB$TM_TN  ON RDB$TRIGGER_MESSAGES ( RDB$TRIGGER_NAME );
CREATE INDEX RDB$T_FN   ON RDB$TYPES            ( RDB$FIELD_NAME );
CREATE INDEX RDB$UP_G   ON RDB$USER_PRIVILEGES  ( RDB$GRANTOR );
CREATE INDEX RDB$UP_U   ON RDB$USER_PRIVILEGES  ( RDB$USER );
CREATE INDEX RDB$UP_UG  ON RDB$USER_PRIVILEGES  ( RDB$USER, RDB$GRANTOR );
CREATE INDEX RDB$VR_VN  ON RDB$VIEW_RELATIONS   ( RDB$VIEW_NAME );

/* CREATE SUPER GENERATOR */

CREATE GENERATOR SUPER_GEN;
SET GENERATOR SUPER_GEN TO 0;

