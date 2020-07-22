// Handles AJAX response from "update" method in app/controllers/resource_controller.rb
$(document).on('turbolinks:load', function() {

  const errorDiv = document.querySelector("#error_explanation");
  if (errorDiv) {
    errorDiv.innerHTML = "";
  }

  const resourceFormSubmit = document.querySelector("#resource_form_submit");

  function enableSubmitButton() {
    if (resourceFormSubmit) {
      resourceFormSubmit.disabled = false;
      resourceFormSubmit.value = "Submit"
    }
  }

  function disableSubmitButton() {
    if (resourceFormSubmit) {
      resourceFormSubmit.disabled = true;
      resourceFormSubmit.value = "Submitting...";
    }
  }

  // Ensure submit button is enabled on form load
  enableSubmitButton();


  const resourceForm = document.querySelector("#resource_edit_form");
  if (resourceForm) {
    resourceForm.addEventListener("submit", (event) => {
      disableSubmitButton()
    });
  }

  const element = document.querySelector("#resource_edit_form");
  if (element) {
    element.addEventListener("ajax:success", (event) => {
      const [data, _status, xhr] = event.detail;

      enableSubmitButton();
      // ajax.success occurs even if a validation error occurrs, so
      // check for any errors

      let errorDisplay = data.error_display;
      if (errorDisplay) {
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
      enableSubmitButton();
      const [data, _status, xhr] = event.detail;
      errors = data.errors
      let alertText = errors.join("\n");
      alert(alertText);
    });
  }
});
