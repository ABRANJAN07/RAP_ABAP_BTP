CLASS zcl_mm_emp_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
  Interfaces if_oo_adt_classrun.

  methods
  upload_emp_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mm_emp_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    upload_emp_data(  ).
  ENDMETHOD.

  METHOD upload_emp_data.
    Data: lt_type_emp TYPE STANDARD TABLE OF zmm_emp.
     lt_type_emp = Value #( ( emp_id = 1
     emp_name = 'Abhijeet'
     emp_add = 'Delhi'
     emp_des = 'AANALYST')
     ( emp_id = 2
     emp_name = 'Himadri'
     emp_add = 'Banglore'
     emp_des = 'Con')
     ).
    INSERT zmm_emp from TABLE @lt_type_emp.
  ENDMETHOD.

ENDCLASS.
