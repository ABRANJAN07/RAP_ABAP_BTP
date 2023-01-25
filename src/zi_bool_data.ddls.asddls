@AbapCatalog.sqlViewName: 'ZVBOOL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface CDS view for bool data'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view ZI_BOOL_DATA as select from ztboolean {
    
    @Search.defaultSearchElement: true
    @EndUserText.label: 'Senstive'
    key type as Type,
    value as Value
    
}
