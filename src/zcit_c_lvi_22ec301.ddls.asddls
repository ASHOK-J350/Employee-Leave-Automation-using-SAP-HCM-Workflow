@EndUserText.label: 'Projection View for Leave Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZCIT_C_LVI_22EC301
  as projection on ZCIT_I_LVI_22EC301
{
  key ItemId,
      ReqId,
      LeaveType,
      StartDate,
      EndDate,
      
      /* Associations */
      _LeaveHeader : redirected to parent ZCIT_C_LVH_22EC301
}
