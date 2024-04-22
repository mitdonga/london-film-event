//= require arctic_admin/base

//= require activeadmin_addons/all


$(document).ready(function(){function a(a){var c=$("#client_admin_select"),n=$("#client_admin_select").val();c.empty(),$.each(a,function(a,n){c.append($("<option>").text(n.name).attr("value",n.id))}),null!=a.find(a=>a.id==n)?c.val(n):c.prop("selectedIndex",-1)}var c=$("#company_select").val();c?$.ajax({url:"/account_block/accounts/all_company_users",data:{company_id:c},dataType:"json",success:function(c){a(c.data)}}):$("#client_admin_select").empty(),$("#company_select").change(function(){var c=$(this).val();c?$.ajax({url:"/account_block/accounts/all_company_users",data:{company_id:c},dataType:"json",success:function(c){a(c.data)}}):$("#client_admin_select").empty()})});

$(document).ready(function() {
  // Function to open the popup
  function openPopup() {
    document.getElementById('modalDialog').style.display = 'block';
  }
  // Function to close the popup
  function closePopup() {
    document.getElementById('modalDialog').style.display = 'none';
  }

  // Function to handle form submission
  // function submitForm(formData) {
  //   fetch('/your_controller/action', {
  //     method: 'POST',
  //     body: formData
  //   })
  //   .then(response => {
  //     // Handle response as needed
  //     if (response.ok) {
  //       closePopup();
  //       // Optionally, update UI or show success message
  //     } else {
  //       // Handle error response
  //     }
  //   })
  //   .catch(error => {
  //     // Handle fetch error
  //   });
  // }

  // Bind click event to open the popup when the button is clicked
  document.querySelector('#create_bespoke_service_btn').addEventListener('click', function() {
    openPopup();
  });

  document.querySelector('#close_btn').addEventListener('click', function() {
    closePopup();
  });

  // // Bind form submission event
  // document.getElementById('popup-form').addEventListener('submit', function(event) {
  //   event.preventDefault(); // Prevent default form submission
  //   const formData = new FormData(event.target); // Get form data
  //   submitForm(formData); // Call function to submit form data
  // });

  // // Bind click event to close the popup when clicking outside the popup or on a close button
  // document.addEventListener('click', function(event) {
  //   if (!event.target.closest('#popup-container') && !event.target.closest('.open-popup-button')) {
  //     closePopup();
  //   }
  // });
});