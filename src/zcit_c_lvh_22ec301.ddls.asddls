@EndUserText.label: 'Projection View for Leave Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true  // <--- CRITICAL: Add this line here
define root view entity ZCIT_C_LVH_22EC301
  provider contract transactional_query
  as projection on ZCIT_I_LVH_22EC301
{
  key ReqId,
  EmployeeId,
  EmployeeName,
  OverallStatus,
  CreatedAt,
  _LeaveItems : redirected to composition child ZCIT_C_LVI_22EC301
}
