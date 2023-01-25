CLASS lhc_room DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CLASS-DATA:
      mt_root_to_create TYPE STANDARD TABLE OF zroom_emp WITH NON-UNIQUE DEFAULT KEY,
      mt_root_to_update TYPE STANDARD TABLE OF zroom_emp WITH NON-UNIQUE DEFAULT KEY,
      mt_root_to_delete TYPE STANDARD TABLE OF zroom_emp WITH NON-UNIQUE DEFAULT KEY.


  PRIVATE SECTION.

    TYPES:
      ty_action(2)     TYPE c,
      tt_message       TYPE TABLE OF symsg,
      tt_room_failed   TYPE TABLE FOR FAILED z_i_room_emp,
      tt_room_reported TYPE TABLE FOR REPORTED z_i_room_emp.
    CONSTANTS:
      BEGIN OF cs_action,
        create TYPE ty_action VALUE '01',
        update TYPE ty_action VALUE '02',
        delete TYPE ty_action VALUE '03',
      END OF cs_action.

    METHODS create FOR MODIFY
      IMPORTING roots_to_create FOR CREATE room.

    METHODS update FOR MODIFY
      IMPORTING roots_to_update FOR UPDATE room.

    METHODS delete FOR MODIFY
      IMPORTING roots_to_delete FOR DELETE room.

    METHODS read FOR READ
      IMPORTING roots_to_read FOR READ room RESULT et_room.

    METHODS lock FOR LOCK
      IMPORTING roots_to_lock FOR LOCK room.

    methods validate
        IMPORTING
          iv_action         TYPE ty_action
          is_room           TYPE zroom_emp
        RETURNING
          VALUE(rv_message) TYPE string.

ENDCLASS.

CLASS lhc_room IMPLEMENTATION.

  METHOD create.
    LOOP AT roots_to_create INTO DATA(ls_root_to_create).
      DATA(lv_message) = validate( iv_action = cs_action-create is_room = CORRESPONDING zroom_emp( ls_root_to_create ) ).
      IF lv_message IS INITIAL.
        ls_root_to_create-lastchangedbyuser = sy-uname.
        GET TIME STAMP FIELD ls_root_to_create-lastchangeddatetime.
        INSERT CORRESPONDING #( ls_root_to_create ) INTO TABLE mapped-room.
        INSERT CORRESPONDING #( ls_root_to_create ) INTO TABLE mt_root_to_create.
      ELSE.
        APPEND VALUE #( %cid = ls_root_to_create-%cid id = ls_root_to_create-id %fail = VALUE #( cause = if_abap_behv=>cause-unspecific ) ) TO failed-room.
        APPEND VALUE #( %cid = ls_root_to_create-%cid id = ls_root_to_create-id %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = lv_message ) ) TO reported-room.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT roots_to_update INTO DATA(ls_root_to_update).
      SELECT SINGLE FROM zroom_emp FIELDS * WHERE id = @ls_root_to_update-id INTO @DATA(ls_room).

      DATA(lt_control_components) = VALUE string_table(
          ( `id` )
          ( `seats` )
          ( `location` )
          ( `hasbeamer` )
          ( `hasvideo` )
          ( `userrating` )
          ( `lastchangedbydatetime` )
          ( `lastchangedbyuser` ) ).

      LOOP AT lt_control_components INTO DATA(lv_component_name).
        ASSIGN COMPONENT lv_component_name OF STRUCTURE ls_root_to_update-%control TO FIELD-SYMBOL(<lv_control_value>).
        CHECK <lv_control_value> = cl_abap_behavior_handler=>flag_changed.
        ASSIGN COMPONENT lv_component_name OF STRUCTURE ls_root_to_update TO FIELD-SYMBOL(<lv_new_value>).
        ASSIGN COMPONENT lv_component_name OF STRUCTURE ls_room TO FIELD-SYMBOL(<lv_old_value>).
        <lv_old_value> = <lv_new_value>.
      ENDLOOP.

      DATA(lv_message) = validate( iv_action = cs_action-update is_room = ls_room ).
      IF lv_message IS INITIAL.
        ls_root_to_update-lastchangedbyuser = sy-uname.
        GET TIME STAMP FIELD ls_root_to_update-lastchangeddatetime.
        INSERT ls_room INTO TABLE mt_root_to_update.
      ELSE.
        APPEND VALUE #( %cid = ls_root_to_update-%cid_ref id = ls_root_to_update-id %fail = VALUE #( cause = if_abap_behv=>cause-unspecific ) ) TO failed-room.
        APPEND VALUE #( %cid = ls_root_to_update-%cid_ref id = ls_root_to_update-id %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = lv_message ) ) TO reported-room.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT roots_to_delete INTO DATA(ls_root_to_delete).
      SELECT SINGLE FROM zroom_emp FIELDS * WHERE id = @ls_root_to_delete-id INTO @DATA(ls_room).
      DATA(lv_message) = validate( iv_action = cs_action-delete is_room = ls_room ).
      IF lv_message IS INITIAL.
        INSERT CORRESPONDING #( ls_root_to_delete ) INTO TABLE mt_root_to_delete.
      ELSE.
        APPEND VALUE #( %cid = ls_root_to_delete-%cid_ref id = ls_root_to_delete-id %fail = VALUE #( cause = if_abap_behv=>cause-unspecific ) ) TO failed-room.
        APPEND VALUE #( %cid = ls_root_to_delete-%cid_ref id = ls_root_to_delete-id %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = lv_message ) ) TO reported-room.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT roots_to_read INTO DATA(ls_root_to_read).
      SELECT SINGLE FROM z_i_room_emp FIELDS * WHERE id = @ls_root_to_read-id INTO @DATA(ls_room).
      INSERT ls_room INTO TABLE et_room.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    LOOP AT roots_to_lock INTO DATA(ls_root_to_lock).
      TRY.
          cl_abap_lock_object_factory=>get_instance( iv_name = 'EZLOCKROOM')->enqueue(
            it_table_mode = VALUE if_abap_lock_object=>tt_table_mode( ( table_name = 'ZROOM_EMP' ) )
            it_parameter  = VALUE if_abap_lock_object=>tt_parameter( ( name = 'ID' value = REF #( ls_root_to_lock-id ) ) ) ).
        CATCH cx_abap_foreign_lock INTO DATA(lx_lock).
          APPEND VALUE #( id = ls_root_to_lock-id %fail = VALUE #( cause = if_abap_behv=>cause-locked ) ) TO failed-room.
          APPEND VALUE #( id = ls_root_to_lock-id %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = lx_lock->get_text( ) ) ) TO reported-room.
        CATCH cx_abap_lock_failure.
          ASSERT 1 = 0.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.

*     AUTHORITY-CHECK OBJECT 'Z_LOCAOEMP' ID 'ACTVT' FIELD iv_action ID 'Z_LOCAFEMP' FIELD is_room-location.
*        IF sy-subrc <> 0.
*          rv_message = 'Not authorized'.
*        ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_ROOM_EMP DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_ROOM_EMP IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    INSERT zroom_emp FROM TABLE @lhc_room=>mt_root_to_create.
    UPDATE zroom_emp FROM TABLE @lhc_room=>mt_root_to_update.
    DELETE zroom_emp FROM TABLE @lhc_room=>mt_root_to_delete.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
