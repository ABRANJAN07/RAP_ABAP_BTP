CLASS lhc_EmpView DEFINITION INHERITING FROM cl_abap_behavior_handler.
  public section.


  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR EmpView RESULT result.

    METHODS is_update_allowed
      RETURNING
        value(update_allowed) type abap_boolean.
*        value(r_result) TYPE abap_bool.

ENDCLASS.

CLASS lhc_EmpView IMPLEMENTATION.

  METHOD get_global_authorizations.

  ENDMETHOD.


  METHOD is_update_allowed.
*   Autorization object code here
*   Do not use in production environment. Simulating Auth object code
*    AUTHORITY-CHECK OBJECT 'ZEMP_DEMO' ID 'ACTVT' FIELD cs_action.
*        IF sy-subrc <> 0.
*            update_allowed = abap_false.
*            rv_message = 'Not authorized'.
*        else.
*            update_allowed = abap_true.
*        ENDIF.
  ENDMETHOD.

ENDCLASS.
