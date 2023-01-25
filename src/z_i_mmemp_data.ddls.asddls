@AbapCatalog.sqlViewName: 'ZMMEMP_DATA_V1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for emp data'
define root view Z_I_MMEMP_DATA as select from zmm_emp {
    
    key emp_id as EmpId,
    emp_name as EmpName,
    emp_add as EmpAdd,
    emp_des as EmpDes,
    user_name as EmpUs,
    status as EmpStat

}
