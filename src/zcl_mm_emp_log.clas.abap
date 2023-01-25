CLASS zcl_mm_emp_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mm_emp_log IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    TRY.

        " Create a new Application Log
        DATA(l_log) = cl_bali_log=>create( ).

        " Add a header to the log
        l_log->set_header( header = cl_bali_header_setter=>create( object = 'ZDEMO_LOG_OB'
                                                                   subobject = ''
                                                                   external_id = 'External ID' ) ).

        " Add a message as item to the log
        DATA(l_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_error
                                                          id = 'PO'
                                                          number = '000' ).

        l_log->add_item( item = l_message ).


        " Add a free text to the log
        DATA(l_free_text) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_error
                                                              text = 'Some Error Text' ).

        l_log->add_item( item = l_free_text ).


        " Add an exception to the log
        DATA: i TYPE i.
        TRY.
            i = 1 / 0.
          CATCH cx_sy_zerodivide INTO DATA(l_ref).
        ENDTRY.

        DATA(l_exception) = cl_bali_exception_setter=>create( severity = if_bali_constants=>c_severity_error
                                                              exception = l_ref ).
        l_log->add_item( item = l_exception ).

        " Save the log into the database
        cl_bali_log_db=>get_instance( )->save_log( log = l_log ).


        "Reading application log from database starts

        " Create a filter which selects all logs of the current user from the last hour
        DATA(l_filter) = cl_bali_log_filter=>create( ).
        l_filter->set_create_info( user = sy-uname ).

        DATA(l_timestamp_now) = utclong_current( ).
        DATA(l_timestamp_minus_1_hour) = utclong_add( val = l_timestamp_now
                                                      hours = '1-' ).
        l_filter->set_time_interval( start_time = l_timestamp_minus_1_hour
                                     end_time = l_timestamp_now ).

        " Read all Application Logs from the database which fit to the filter
        DATA(log_table) = cl_bali_log_db=>get_instance( )->load_logs_via_filter( filter = l_filter ).

        LOOP AT log_table INTO DATA(l_log2).

          " Output log handle
          out->write( |Handle: { l_log->get_handle( ) }| ).

          " Get log header and output attributes of the header
          DATA(l_header) = l_log->get_header( ).
          out->write( |{ l_header->object } { l_header->subobject } { l_header->external_id } { l_header->log_user }| ).

          " Get all items and output some data which exist in all item categories
          DATA(l_item_table) = l_log->get_all_items( ).

          LOOP AT l_item_table INTO DATA(l_item_entry).
            out->write( |{ l_item_entry-log_item_number } { l_item_entry-item->get_message_text( ) }| ).

            " Output attributes which are specific for messages and exceptions
            IF l_item_entry-item->category = if_bali_constants=>c_category_message.
              DATA(l_message_ref) = CAST if_bali_message_getter( l_item_entry-item ).
              out->write( |{ l_message_ref->id } { l_message_ref->number }| ).
            ELSEIF l_item_entry-item->category = if_bali_constants=>c_category_exception.
              DATA(l_exception_ref) = CAST if_bali_exception_getter( l_item_entry-item ).
              out->write( |{ l_exception_ref->exception_class } { l_exception_ref->exception_id_name }| ).
            ENDIF.
          endloop.

        endloop.


        CATCH cx_bali_runtime INTO DATA(l_runtime_exception).
        out->write( l_runtime_exception->get_text(  ) ).

    endtry.

  ENDMETHOD.

ENDCLASS.
