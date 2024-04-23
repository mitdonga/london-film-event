//= require arctic_admin/base
//= require activeadmin_addons/all

$(document).ready(function(){function a(a){var c=$("#client_admin_select"),n=$("#client_admin_select").val();c.empty(),$.each(a,function(a,n){c.append($("<option>").text(n.name).attr("value",n.id))}),null!=a.find(a=>a.id==n)?c.val(n):c.prop("selectedIndex",-1)}var c=$("#company_select").val();c?$.ajax({url:"/account_block/accounts/all_company_users",data:{company_id:c},dataType:"json",success:function(c){a(c.data)}}):$("#client_admin_select").empty(),$("#company_select").change(function(){var c=$(this).val();c?$.ajax({url:"/account_block/accounts/all_company_users",data:{company_id:c},dataType:"json",success:function(c){a(c.data)}}):$("#client_admin_select").empty()})});

$(document).ready(function() {
  $('#create_bespoke_service_from').on('submit', function(event) {
    event.preventDefault();
    var formData = $(this).serialize();
    $.ajax({
      url: $(this).attr('action'),
      method: 'POST',
      data: formData,
      dataType: 'json', 
      success: function(response) {
        console.log("success response", response);
        $("#model-error").html("")
        $('#modalDialog').hide()
        window.location.href = `/admin/bespoke_services/${response.service_id}`
      },
      error: function(xhr, status, error) {
        var res = JSON.parse(xhr.responseText)
        console.log(res);
        $("#model-error").html(res.error)
      }
    });
  })

  $('#create_bespoke_service_btn').on('click', function() {
    $('#modalDialog').show();
  })

  $('#close_btn').on('click', function() {
    $('#modalDialog').hide();
  })
});