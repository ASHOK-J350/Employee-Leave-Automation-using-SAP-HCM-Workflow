@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Item View'
define view entity ZCIT_I_LVI_22EC301
  as select from zcit_lvi_22ec301
  association to parent ZCIT_I_LVH_22EC301 as _LeaveHeader on $projection.ReqId = _LeaveHeader.ReqId
{
  key item_id    as ItemId,
      req_id     as ReqId,
      leave_type as LeaveType,
      start_date as StartDate,
      end_date   as EndDate,
      
      _LeaveHeader // Expose parent association
}
