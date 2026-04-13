" --- 1. The Handler Class (Interaction Phase) ---
CLASS lhc_LeaveHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    TYPES: tt_header_db TYPE TABLE OF zcit_lvh_22ec301,
           tt_item_db   TYPE TABLE OF zcit_lvi_22ec301.

    " Global buffers to hold data until the Save phase
    CLASS-DATA: mt_buffer_hdr TYPE tt_header_db,
                mt_buffer_itm TYPE tt_item_db.

  PRIVATE SECTION.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE LeaveHeader.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE LeaveHeader.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE LeaveHeader.
    METHODS read FOR READ
      IMPORTING keys FOR READ LeaveHeader RESULT result.
    METHODS cba_Leaveitems FOR MODIFY
      IMPORTING entities_cba FOR CREATE LeaveHeader\_LeaveItems.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR LeaveHeader RESULT result.
ENDCLASS.

CLASS lhc_LeaveHeader IMPLEMENTATION.
  METHOD create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<header>).
      DATA(ls_header) = VALUE zcit_lvh_22ec301(
        employee_id    = <header>-EmployeeId
        employee_name  = <header>-EmployeeName
        overall_status = 'N' ).

      TRY.
          ls_header-req_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.

      " Stage data in the Buffer. NO INSERT STATEMENTS HERE.
      APPEND ls_header TO mt_buffer_hdr.
      INSERT VALUE #( %cid = <header>-%cid reqid = ls_header-req_id ) INTO TABLE mapped-leaveheader.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Leaveitems.
    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<cba>).
      LOOP AT <cba>-%target ASSIGNING FIELD-SYMBOL(<item>).
        DATA(ls_item) = VALUE zcit_lvi_22ec301(
          leave_type = <item>-LeaveType
          start_date = <item>-StartDate
          end_date   = <item>-EndDate
          req_id     = <cba>-ReqId ).

        TRY.
            ls_item-item_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.

        " Stage data in the Buffer. NO INSERT STATEMENTS HERE.
        APPEND ls_item TO mt_buffer_itm.
        INSERT VALUE #( %cid = <item>-%cid itemid = ls_item-item_id ) INTO TABLE mapped-leaveitem.
      ENDLOOP.

      " Required empty loop for strict mode consistency
      LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<cba_key>).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zcit_lvh_22ec301 FOR ALL ENTRIES IN @keys
      WHERE req_id = @keys-ReqId INTO TABLE @DATA(lt_db).
    result = CORRESPONDING #( lt_db MAPPING ReqId = req_id EmployeeId = employee_id
                                            EmployeeName = employee_name OverallStatus = overall_status ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      APPEND VALUE #(
        %tky = <key>-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) TO result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

" --- 2. The Saver Class (Save Phase) ---
CLASS lsc_ZCIT_I_LVH_22EC301 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save          REDEFINITION.
    METHODS cleanup       REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_I_LVH_22EC301 IMPLEMENTATION.
  METHOD save.
    " This is the ONLY legal place for database updates in Unmanaged
    IF lhc_LeaveHeader=>mt_buffer_hdr IS NOT INITIAL.
      INSERT zcit_lvh_22ec301 FROM TABLE @lhc_LeaveHeader=>mt_buffer_hdr.
    ENDIF.
    IF lhc_LeaveHeader=>mt_buffer_itm IS NOT INITIAL.
      INSERT zcit_lvi_22ec301 FROM TABLE @lhc_LeaveHeader=>mt_buffer_itm.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    " Clear buffers to prevent duplicate inserts on subsequent clicks
    CLEAR: lhc_LeaveHeader=>mt_buffer_hdr, lhc_LeaveHeader=>mt_buffer_itm.
  ENDMETHOD.
ENDCLASS.
