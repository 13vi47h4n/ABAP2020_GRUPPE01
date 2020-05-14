CLASS yhska_init DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yhska_init IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA:itab_01 TYPE TABLE OF yhska_url.
    DATA:itab_02 TYPE TABLE OF yhska01_Tech.

*   read current timestamp
    GET TIME STAMP FIELD DATA(zv_tsl).

    itab_02 = VALUE #(
  ( id = '02D5290E594C1EDA93815057FD946624' name = 'SQL' )
  ( id = '02D5290E594C1EDA93815057FD946625' name = 'Java' )
  ).
*   fill internal travel table (itab)
    itab_01 = VALUE #(
  ( id = '02D5290E594C1EDA93815057FD946624' techid = '02D5290E594C1EDA93815057FD946624' sitename = 'W3Schools' url = 'https://www.w3schools.com/sql/' description = 'First Entry')
  ( id = '02D5290E594C1EDA93815C50CD7AE62A' techid = '02D5290E594C1EDA93815057FD946624' sitename = 'Sql-und-Xml' url = 'https://www.sql-und-xml.de/sql-tutorial/' description = 'Second Entry')
  ( id = '02D5290E594C1EDA93858EED2DA2EB0B' techid = '02D5290E594C1EDA93815057FD946624' sitename = 'Code-Academy' url = 'https://www.codecademy.com/learn/learn-sql' description = 'Third Entry')
  ( id = '02D5290E594C1EDA93858EED2DA2EB09' techid = '02D5290E594C1EDA93815057FD946625' sitename = 'DIY' url = 'Do it yourself' description = 'Fourth Entry')
  ( id = '02D5290E594C1EDA93858EED2DA2EB10' techid = '02D5290E594C1EDA93815057FD946625' sitename = 'LMGTFY' url = 'Let me google that for you' description = 'Fifth Entry')
  ).



*   delete existing entries in the database table
    DELETE FROM yhska_url.
    DELETE FROM yhska01_Tech.

*   insert the new table entries
    INSERT yhska_url FROM TABLE @itab_01.
    INSERT yhska01_Tech FROM TABLE @itab_02.

*   check the result
    SELECT * FROM yhska_url INTO TABLE @itab_01.
    out->write( sy-dbcnt ).
    out->write( 'data insert success').

  ENDMETHOD.
ENDCLASS.
