// Handles AJAX response from "update" method in app/controllers/resource_controller.rb
$(document).on('turbolinks:load', function() {
  const element = document.querySelector("#resource_edit_form");
  element.addEventListener("ajax:success", (event) => {
    const [data, _status, xhr] = event.detail;
    let messages = data.messages;
    let alertText = messages.join("\n");
    alert(alertText);
  });
  element.addEventListener("ajax:error", () => {
    const [data, _status, xhr] = event.detail;
    errors = data.errors
    let alertText = errors.join("\n");
    alert(alertText);
  });
});
