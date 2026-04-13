@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Header View'
@Metadata.allowExtensions: true
define root view entity ZCIT_I_LVH_22EC301
  as select from zcit_lvh_22ec301
  composition [0..*] of ZCIT_I_LVI_22EC301 as _LeaveItems
{
  key req_id         as ReqId,
      employee_id    as EmployeeId,
      employee_name  as EmployeeName,
      overall_status as OverallStatus,
      created_at     as CreatedAt,
      
      _LeaveItems // Expose association
}
