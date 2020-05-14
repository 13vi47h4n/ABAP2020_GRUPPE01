@EndUserText.label: 'Coding Tutorials 24'
@AccessControl.authorizationCheck: #CHECK

//@UI: {
// headerInfo: { typeName: 'Tutorial', typeNamePlural: 'Tutorials', title: { type: #STANDARD, value: 'TutorialID' } } }

@Search.searchable: true
define root view entity YHSKA_C_TUTORIALS
  as projection on YHSKA_TUTORIAL
{
      @UI.facet: [ { id:              'Tutorial',
                       purpose:         #STANDARD,
                       type:            #IDENTIFICATION_REFERENCE,
                       label:           'Details',
                       position:        10 } ]

      @UI.hidden: true
      key id       as TutID,
      
//      @UI.hidden: true
//      key client     as clnt,

      @UI: {
           lineItem:       [ { position: 30, importance: #HIGH } ],
           identification: [ { position: 30, label: 'Technology'  } ] }
      @Search.defaultSearchElement: true
      name     as Technology,

      @UI: {
          lineItem:       [ { position: 40, importance: #HIGH } ],
          identification: [ { position: 40, label: 'Tutorial by'  } ] }
      @Search.defaultSearchElement: true
      sitename as Sitename,

      @UI.identification: [ { position: 50, label: 'URL' } ]
      url      as URL,

 
      @UI.lineItem: [ { position:60 , importance: #MEDIUM ,type: #AS_DATAPOINT } ]
      @UI.dataPoint: { title:'Product Rating', description: 'Rating Indicator', visualization: #RATING }
      //@UI.identification: [ { position: 60, label: 'Rating' } ]
      rating   as Rating,
      
      @UI.identification: [ { position: 70, label: 'Description' } ]
      description as Description,
      
      @UI.identification: [ { position: 80, label: 'Created at' } ]
      created_at as Created,
      
      @UI.identification: [ { position: 85, label: 'Created by' } ]
      created_by as createdBy,
      
      @UI.identification: [ { position: 90, label: 'Last Changed at' } ]
      last_changed_at as LastChanged,
      
      @UI.identification: [ { position: 95, label: 'Last Changed by' } ]
      last_changed_by as LastChangedBy
      
}
