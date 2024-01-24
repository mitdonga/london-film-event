//= require arctic_admin/base
//= require activeadmin/quill_editor/quill
//= require activeadmin/quill_editor_input
//= require activeadmin_addons/all
//= require activeadmin/froala_editor/froala_editor.pkgd.min
//= require activeadmin/froala_editor_input

$(document).ready(function(){function a(a){var c=$("#client_admin_select"),n=$("#client_admin_select").val();c.empty(),$.each(a,function(a,n){c.append($("<option>").text(n.name).attr("value",n.id))}),null!=a.find(a=>a.id==n)?c.val(n):c.prop("selectedIndex",-1)}var c=$("#company_select").val();c?$.ajax({url:"/account_block/accounts/all_company_users",data:{company_id:c},dataType:"json",success:function(c){a(c.data)}}):$("#client_admin_select").empty(),$("#company_select").change(function(){var c=$(this).val();c?$.ajax({url:"/account_block/accounts/all_company_users",data:{company_id:c},dataType:"json",success:function(c){a(c.data)}}):$("#client_admin_select").empty()})});

document.addEventListener('DOMContentLoaded', function() {
  function updateStatusDescriptionField() {
    const status = $('#inquiry_status').val();
    const statusDescriptionField = $('#inquiry_status_description');

    if (status === 'hold' || status === 'rejected') {
      statusDescriptionField.prop('disabled', false);
    } else {
      statusDescriptionField.prop('disabled', true);
    }
  }

  updateStatusDescriptionField();

  $(document).on('change', '#inquiry_status', function() {
    updateStatusDescriptionField();
  });
});
