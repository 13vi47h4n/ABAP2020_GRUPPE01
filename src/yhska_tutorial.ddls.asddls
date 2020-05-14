@AbapCatalog.sqlViewName: 'YHSKA_TUT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'table of tutorial urls'
define root view YHSKA_TUTORIAL
  as select from yhska_url as Tutorials

  association [1..1] to yhska01_tech as _TECH on $projection.techid = _TECH.id
{
      //join yhska01_tech on yhska01_tech.id = yhska_url.techid {


  key id,
  techid,
      _TECH.name,
      url,
      sitename,
      description,
      rating,
      created_by,
      created_at,
      last_changed_by,
      last_changed_at
}
