// Handles AJAX response from "update" method in app/controllers/resource_controller.rb
$(document).on('turbolinks:load', function() {
  const element = document.querySelector("#resource_edit_form");
  if (element) {
    element.addEventListener("ajax:success", (event) => {
      const [data, _status, xhr] = event.detail;

      // ajax.success occurs even if a validation error occurrs, so
      // check for any errors

      let errorDisplay = data.error_display;
      if (errorDisplay) {
        errorDiv = document.querySelector("#error_explanation");
        errorDiv.innerHTML = errorDisplay;
        window.scrollTo(0, 0);
        return;
      }

      let messages = data.messages;
      if (messages) {
        let alertText = messages.join("\n");
        alert(alertText);
      }
    });
    element.addEventListener("ajax:error", () => {
      const [data, _status, xhr] = event.detail;
      errors = data.errors
      let alertText = errors.join("\n");
      alert(alertText);
    });
  }
  errorDiv.innerHTML = "";
});
