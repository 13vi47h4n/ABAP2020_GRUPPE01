*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lhc_tutorial DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES tt_tutorial_update TYPE TABLE FOR UPDATE yhska_tutorial.

    METHODS validateTechnology         FOR VALIDATION Tutorial24~validateTechnology IMPORTING keys FOR Tutorial24.
    METHODS validateURL                FOR VALIDATION Tutorial24~validateURL IMPORTING keys FOR Tutorial24.



    METHODS ratingZero                 FOR MODIFY IMPORTING  keys    FOR ACTION Tutorial24~zeroStars     RESULT result.
    METHODS ratingOne                  FOR MODIFY IMPORTING  keys    FOR ACTION Tutorial24~oneStars     RESULT result.
    METHODS ratingTwo                  FOR MODIFY IMPORTING  keys    FOR ACTION Tutorial24~twoStars     RESULT result.
    METHODS ratingThree                FOR MODIFY IMPORTING  keys    FOR ACTION Tutorial24~threeStars     RESULT result.
    METHODS ratingFour                 FOR MODIFY IMPORTING  keys    FOR ACTION Tutorial24~fourStars     RESULT result.
    METHODS ratingFive                 FOR MODIFY IMPORTING  keys    FOR ACTION Tutorial24~fiveStars     RESULT result.
    METHODS get_features               FOR FEATURES IMPORTING keys REQUEST    requested_features FOR Tutorial24    RESULT result.

    METHODS CalculateTutorialID        FOR DETERMINATION Tutorial24~CalculateTutorialID IMPORTING keys FOR Tutorial24.


ENDCLASS.

CLASS lhc_tutorial IMPLEMENTATION.

  METHOD validateTechnology.


    READ ENTITY yhska_tutorial FROM VALUE #(
        FOR <root_key> IN keys ( %key     = <root_key>
                                 %control = VALUE #( name = if_abap_behv=>mk-on ) ) )
        RESULT DATA(lt_technologies).
    LOOP AT lt_technologies INTO DATA(ls_tech).
      SELECT SINGLE FROM yhska01_tech
      FIELDS id
*        FIELDS @abap_true
        WHERE name = @ls_tech-name
        INTO @DATA(ls_technologie).
*      INTO TABLE @DATA(lt_technologies_db).
*        INTO @DATA(lv_found).

*      IF NOT line_exists( lt_technologies_db[ id = ls_tech-id ] ). " AND lt_technologies_db IS NOT INITIAL.
*      IF lv_found NE abap_true.
      IF sy-subrc NE 0.
        APPEND VALUE #(  id = ls_tech-id ) TO failed.
        APPEND VALUE #(  id = ls_tech-id
                         %msg      = new_message( id       = 'YHSKA01_MSG'
                                                  number   = '001'
                                                  v1       = ls_tech-id
                                                  severity = if_abap_behv_message=>severity-error )
                         %element-id = if_abap_behv=>mk-on ) TO reported.

      ELSE.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateurl.
    DATA matcher TYPE REF TO cl_abap_matcher.

    READ ENTITY yhska_tutorial FROM VALUE #(
    FOR <root_key> IN keys ( %key     = <root_key>
                             %control = VALUE #( url = if_abap_behv=>mk-on ) ) )
    RESULT DATA(lt_url).

    " Raise msg for bad url
    LOOP AT lt_url INTO DATA(ls_urls).
      matcher = cl_abap_matcher=>create(
      pattern = `https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)`
      text    = ls_urls-url ).
      IF matcher->match( ) IS INITIAL. "and ( ls_urls-url not BETWEEN 1 and 100 ).
        APPEND VALUE #(  %key = ls_urls-%key
                            id = ls_urls-id ) TO failed.
        APPEND VALUE #( %key = ls_urls-%key
                  %msg  = new_message(
                    id   = 'YHSKA01_MSG' "Message Class
                    number = '002' "Number
                    severity = if_abap_behv_message=>severity-error )
                  %element-id = if_abap_behv=>mk-on ) TO reported.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

********************************************************************************
*
* Implements the dynamic feature handling
*
********************************************************************************
  METHOD get_features.

    "%control-<fieldname> specifies which fields are read from the entities

    READ ENTITY yhska_tutorial FROM VALUE #( FOR keyval IN keys
                                                      (  %key                    = keyval-%key
                                                         %control-id      = if_abap_behv=>mk-on
                                                         %control-rating = if_abap_behv=>mk-on
                                                        ) )
                                RESULT DATA(lt_tutorial_result).


    result = VALUE #( FOR ls_tutorial IN lt_tutorial_result
                       ( %key                           = ls_tutorial-%key
                         %features-%action-zeroStars = COND #( WHEN ls_tutorial-rating = 0 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                         %features-%action-oneStars = COND #( WHEN ls_tutorial-rating = 1 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                         %features-%action-twoStars = COND #( WHEN ls_tutorial-rating = 2 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                         %features-%action-threeStars = COND #( WHEN ls_tutorial-rating = 3 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                         %features-%action-fourStars = COND #( WHEN ls_tutorial-rating = 4 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                         %features-%action-fiveStars = COND #( WHEN ls_tutorial-rating = 5 THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                      ) ).

  ENDMETHOD.



  METHOD calculatetutorialid.
    SELECT FROM yhska_tutorial
        FIELDS MAX( id ) INTO @DATA(lv_max_tutorial_id).

    LOOP AT keys INTO DATA(ls_key).
      lv_max_tutorial_id = lv_max_tutorial_id + 1.
      MODIFY ENTITIES OF yhska_tutorial  IN LOCAL MODE
        ENTITY Tutorial24
          UPDATE SET FIELDS WITH VALUE #( ( id     = lv_max_tutorial_id
          ) )
          REPORTED DATA(ls_reported).
      APPEND LINES OF ls_reported-tutorial24 TO reported-tutorial24.
    ENDLOOP.

  ENDMETHOD.

********************************************************************************
*
* Implements tutorial action (in our case: for setting rating to new value)
*
********************************************************************************
  METHOD ratingOne.
    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF yhska_tutorial IN LOCAL MODE
           ENTITY Tutorial24
              UPDATE FROM VALUE #( FOR key IN keys ( id = key-id
                                                     rating = 1
                                                     %control-rating = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    " Read changed data for action result
    READ ENTITIES OF yhska_tutorial IN LOCAL MODE
         ENTITY Tutorial24
         FROM VALUE #( FOR key IN keys (  id = key-id
                                          %control = VALUE #(
                                            id              = if_abap_behv=>mk-on
                                            techid          = if_abap_behv=>mk-on
                                            name            = if_abap_behv=>mk-on
                                            url             = if_abap_behv=>mk-on
                                            description     = if_abap_behv=>mk-on
                                            rating          = if_abap_behv=>mk-on
                                            created_by      = if_abap_behv=>mk-on
                                            created_at      = if_abap_behv=>mk-on
                                            last_changed_by = if_abap_behv=>mk-on
                                            last_changed_at = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_tutorial).

    result = VALUE #( FOR tutorial IN lt_tutorial ( id = tutorial-id
                                                %param    = tutorial
                                              ) ).

  ENDMETHOD.

  METHOD ratingZero.
    MODIFY ENTITIES OF yhska_tutorial IN LOCAL MODE
           ENTITY Tutorial24
              UPDATE FROM VALUE #( FOR key IN keys ( id = key-id
                                                     rating = 0
                                                     %control-rating = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    READ ENTITIES OF yhska_tutorial IN LOCAL MODE
         ENTITY Tutorial24
         FROM VALUE #( FOR key IN keys (  id = key-id
                                          %control = VALUE #(
                                            id              = if_abap_behv=>mk-on
                                            techid          = if_abap_behv=>mk-on
                                            name            = if_abap_behv=>mk-on
                                            url             = if_abap_behv=>mk-on
                                            description     = if_abap_behv=>mk-on
                                            rating          = if_abap_behv=>mk-on
                                            created_by      = if_abap_behv=>mk-on
                                            created_at      = if_abap_behv=>mk-on
                                            last_changed_by = if_abap_behv=>mk-on
                                            last_changed_at = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_tutorial).
    result = VALUE #( FOR tutorial IN lt_tutorial ( id = tutorial-id
                                                %param    = tutorial
                                              ) ).

  ENDMETHOD.

  METHOD ratingTwo.
    MODIFY ENTITIES OF yhska_tutorial IN LOCAL MODE
           ENTITY Tutorial24
              UPDATE FROM VALUE #( FOR key IN keys ( id = key-id
                                                     rating = 2
                                                     %control-rating = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    READ ENTITIES OF yhska_tutorial IN LOCAL MODE
         ENTITY Tutorial24
         FROM VALUE #( FOR key IN keys (  id = key-id
                                          %control = VALUE #(
                                            id              = if_abap_behv=>mk-on
                                            techid          = if_abap_behv=>mk-on
                                            name            = if_abap_behv=>mk-on
                                            url             = if_abap_behv=>mk-on
                                            description     = if_abap_behv=>mk-on
                                            rating          = if_abap_behv=>mk-on
                                            created_by      = if_abap_behv=>mk-on
                                            created_at      = if_abap_behv=>mk-on
                                            last_changed_by = if_abap_behv=>mk-on
                                            last_changed_at = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_tutorial).
    result = VALUE #( FOR tutorial IN lt_tutorial ( id = tutorial-id
                                                %param    = tutorial
                                              ) ).

  ENDMETHOD.

  METHOD ratingThree.
    MODIFY ENTITIES OF yhska_tutorial IN LOCAL MODE
           ENTITY Tutorial24
              UPDATE FROM VALUE #( FOR key IN keys ( id = key-id
                                                     rating = 3
                                                     %control-rating = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    READ ENTITIES OF yhska_tutorial IN LOCAL MODE
         ENTITY Tutorial24
         FROM VALUE #( FOR key IN keys (  id = key-id
                                          %control = VALUE #(
                                            id              = if_abap_behv=>mk-on
                                            techid          = if_abap_behv=>mk-on
                                            name            = if_abap_behv=>mk-on
                                            url             = if_abap_behv=>mk-on
                                            description     = if_abap_behv=>mk-on
                                            rating          = if_abap_behv=>mk-on
                                            created_by      = if_abap_behv=>mk-on
                                            created_at      = if_abap_behv=>mk-on
                                            last_changed_by = if_abap_behv=>mk-on
                                            last_changed_at = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_tutorial).
    result = VALUE #( FOR tutorial IN lt_tutorial ( id = tutorial-id
                                                %param    = tutorial
                                              ) ).

  ENDMETHOD.

  METHOD ratingFour.
    MODIFY ENTITIES OF yhska_tutorial IN LOCAL MODE
           ENTITY Tutorial24
              UPDATE FROM VALUE #( FOR key IN keys ( id = key-id
                                                     rating = 4
                                                     %control-rating = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    READ ENTITIES OF yhska_tutorial IN LOCAL MODE
         ENTITY Tutorial24
         FROM VALUE #( FOR key IN keys (  id = key-id
                                          %control = VALUE #(
                                            id              = if_abap_behv=>mk-on
                                            techid          = if_abap_behv=>mk-on
                                            name            = if_abap_behv=>mk-on
                                            url             = if_abap_behv=>mk-on
                                            description     = if_abap_behv=>mk-on
                                            rating          = if_abap_behv=>mk-on
                                            created_by      = if_abap_behv=>mk-on
                                            created_at      = if_abap_behv=>mk-on
                                            last_changed_by = if_abap_behv=>mk-on
                                            last_changed_at = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_tutorial).
    result = VALUE #( FOR tutorial IN lt_tutorial ( id = tutorial-id
                                                %param    = tutorial
                                              ) ).

  ENDMETHOD.

  METHOD ratingFive.
    MODIFY ENTITIES OF yhska_tutorial IN LOCAL MODE
           ENTITY Tutorial24
              UPDATE FROM VALUE #( FOR key IN keys ( id = key-id
                                                     rating = 5
                                                     %control-rating = if_abap_behv=>mk-on ) )
           FAILED   failed
           REPORTED reported.

    READ ENTITIES OF yhska_tutorial IN LOCAL MODE
         ENTITY Tutorial24
         FROM VALUE #( FOR key IN keys (  id = key-id
                                          %control = VALUE #(
                                            id              = if_abap_behv=>mk-on
                                            techid          = if_abap_behv=>mk-on
                                            name            = if_abap_behv=>mk-on
                                            url             = if_abap_behv=>mk-on
                                            description     = if_abap_behv=>mk-on
                                            rating          = if_abap_behv=>mk-on
                                            created_by      = if_abap_behv=>mk-on
                                            created_at      = if_abap_behv=>mk-on
                                            last_changed_by = if_abap_behv=>mk-on
                                            last_changed_at = if_abap_behv=>mk-on
                                          ) ) )
         RESULT DATA(lt_tutorial).
    result = VALUE #( FOR tutorial IN lt_tutorial ( id = tutorial-id
                                                %param    = tutorial
                                              ) ).

  ENDMETHOD.

ENDCLASS.
