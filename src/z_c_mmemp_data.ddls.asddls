@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'root view for EMP data'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity Z_C_MMEMP_DATA provider contract transactional_query
    as projection on Z_I_MMEMP_DATA as EmpView 
{
    @EndUserText.label: 'Emp Id'
    key EmpId,
    @EndUserText.label: 'Emp Name'
    @Search.defaultSearchElement: true
    EmpName,
    @EndUserText.label: 'Emp Addr'
    EmpAdd,
    @EndUserText.label: 'Emp Des'
    EmpDes,
    @EndUserText.label: 'Emp Stat'
    EmpStat
}
