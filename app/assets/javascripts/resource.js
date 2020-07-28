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

  function displayErrors(errorHtml, errors) {
    // Clear all error fields
    errorClass = "validation_error";
    let fields = document.getElementsByClassName(errorClass);
    while (fields.length > 0) {
      fields[0].classList.remove(errorClass);
    }

    errorDiv.innerHTML = errorHtml;
    errors.forEach( error => {
      let field_name = error['name'];
      if (field_name) {
        let fields = document.getElementsByName(field_name);
        fields.forEach(field => {
          field.classList.add(errorClass);
        });
      }
    });
    window.scrollTo(0, 0);
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

      let errors = data.errors;
      let errorHtml = data.error_display;
      if (errorHtml) {
        displayErrors(errorHtml, errors)
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

      enableSubmitButton();

      let errorDisplay = data.error_display;
      if (errorDisplay) {
        displayErrors(errorDisplay)
        return;
      }
    });
  }
});
