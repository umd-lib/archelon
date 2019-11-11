// Copyright 2011-2018, The Trustees of Indiana University and Northwestern
//   University.  Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
// 
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software distributed
//   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied. See the License for the
//   specific language governing permissions and limitations under the License.
// ---  END LICENSE_HEADER BLOCK  ---

updateSelectAll = () => {
  $("#bookmarks_selectall").prop("checked", $("input.toggle_bookmark:not(:checked)").size() == 0)
}

updateSelectAllResults = () => {
  sel_link = $("#select-all-results")
  max_sel = sel_link.data('max-selection-count')
  current_sel = $('[data-role=bookmark-counter]').text()
  sel_link.unbind( "click" )
  if(current_sel < max_sel) {
    sel_link.removeAttr('disabled')
    total_res = sel_link.data('total-results')
    sel_count = $('[data-role=bookmark-counter]').text()
    if(total_res > (max_sel - sel_count)) {
      // Display a JS confirm box when only part of the results can be selected
      sel_link.on("click", (e) => {
        proceed = confirm("Max selection limit is " + max_sel + "! " +
                          "Only first " + (max_sel - sel_count) + " result(s) will be selected!\n\n" +
                          "Do you want to proceed?")
        if(!proceed) {
          e.preventDefault()
          return false
        }
      })
    }
  }
  else {
    // Disable link click event, if it has "disabled" property
    sel_link.attr('disabled', 'disabled')
    sel_link.on("click", (e) => {
      event.preventDefault()
      return false
    })
  }
}

createTempInputElementsDiv = (items, mode) => {
  div = $('<div/>')
  div.append('<input type="hidden" name="mode" value="' + mode + '" />')
  ids = items.each((index, item) => {
    div.append('<input type="hidden" name="document_ids[]" value="' + item.id.substring(16) + '"/>')
  });
  return div;
}

updateMultipleSelection = (items, mode) => {
  $("#bookmarks_selectall").attr("disabled", "disabled")
  items.attr("disabled", "disabled")
  form = $('#select-all')
  temp_inputs_div = createTempInputElementsDiv(items, mode)
  form.append(temp_inputs_div)
  form_data = form.serialize()
  temp_inputs_div.remove()

  $.ajax({
      url: form.attr("action"),
      dataType: 'json',
      type: form.attr("method").toUpperCase(),
      data: form_data,
      error: (e) => {
        alert('Request to select all items failed!')
        $("#bookmarks_selectall").removeAttr("disabled")
        items.removeAttr("disabled")
      },
      success: (data, status, xhr) => {
        if (xhr.status != 0) {
          checked = mode == "select"
          $("#bookmarks_selectall").prop("checked", checked)
          items.prop("checked", checked)
          items.parent().toggleClass("checked", checked)
          items.closest("form").find("input[name=_method]").val(checked ? "delete" : "put");
          $('[data-role="bookmark-counter"]').text(data.bookmarks.count)
        } else {
          alert('Request to select all items failed!')
        }
        $("#bookmarks_selectall").removeAttr("disabled")
        items.removeAttr("disabled")
      }
  });
}

addSelectAllHandler = () => {
  $("#bookmarks_selectall").on("click", (e) => {
    if($("#bookmarks_selectall").prop("checked") === true) {
      updateMultipleSelection($("input.toggle_bookmark:not(:checked)"), "select")
    } else {
      updateMultipleSelection($("input.toggle_bookmark:checked"), "unselect")
    }
  })
}

disiableSelectAll = () => {
  $("#bookmarks_selectall").attr("disabled", "disabled")
}

enableSelectAll = () => {
  $("#bookmarks_selectall").removeAttr("disabled")
}

disableUnchecked = () => {
   $("input.toggle_bookmark:not(:checked)").attr("disabled", "disabled")
}

enableUnchecked = () => {
   $("input.toggle_bookmark:not(:checked)").removeAttr("disabled")
}

enableDisableCheckboxes = () => {
  count = +($('[data-role="bookmark-counter"]').text())
  max = $("#select-all-results").data('max-selection-count')
  unchecked_count = $("input.toggle_bookmark:not(:checked)").length;
  if (unchecked_count>0) {
    if(count >= max) {
      disiableSelectAll()
      disableUnchecked()
    } else {
      enableUnchecked()
      if((count + unchecked_count) > max) disiableSelectAll()
      else enableSelectAll()
    }
  }
}

$(document).on("turbolinks:load", () => {
  addSelectAllHandler()
  updateSelectAll()
  updateSelectAllResults()
  enableDisableCheckboxes()
  return
})

$(document).ajaxStop(()=> {
  updateSelectAll()
  updateSelectAllResults()
  enableDisableCheckboxes()
  return
})
