@AbapCatalog.sqlViewName: 'ZIMMEMPDATA_V2'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for emp data'
define view Z_I_MMEMP_DATA_V2 as select from zmm_emp {
    
    key emp_id as EmpId,
    emp_name as EmpName,
    emp_add as EmpAdd,
    emp_des as EmpDes

}
