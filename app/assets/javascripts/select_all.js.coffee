# Copyright 2011-2018, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
# 
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

updateSelectAll = -> $("#bookmarks_selectall").prop "checked", $("input.toggle_bookmark:not(:checked)").size() is 0

updateSelectAllResults = ->
  sel_link = $("#select-all-results")
  max_sel = sel_link.data('max-selection-count')
  current_sel = $('[data-role=bookmark-counter]').text()
  sel_link.unbind( "click" )
  if current_sel < max_sel
    sel_link.removeAttr('disabled')
    total_res = sel_link.data('total-results')
    sel_count = $('[data-role=bookmark-counter]').text()
    if total_res > (max_sel - sel_count)
      # Display a JS confirm box when only part of the results can be selected
      sel_link.on "click", (e) ->
        proceed = confirm("Max selection limit is " + max_sel + "! " +
                          "Only first " + (max_sel - sel_count) + " result(s) will be selected!\n\n" +
                          "Do you want to proceed?")
        if !proceed
          event.preventDefault()
          return false
  else
    # Disable link click event, if it has "disabled" property
    sel_link.attr('disabled', 'disabled')
    sel_link.on "click", (e) ->
        event.preventDefault()
        return false

$(document).on "turbolinks:load", ->
  updateSelectAll()
  updateSelectAllResults()
  return

$(document).ajaxStop ->
  updateSelectAll()
  updateSelectAllResults()
  return

$(document).on "turbolinks:load", ->
  $("#bookmarks_selectall").on "change", (e) ->
    if @checked
      $("label.toggle_bookmark:not(.checked) input.toggle_bookmark").prop("indeterminate", true);
      $("label.toggle_bookmark:not(.checked) input.toggle_bookmark").click()
    else
      $("label.toggle_bookmark:not(.checked) input.toggle_bookmark").prop("indeterminate", true);
      $("label.toggle_bookmark.checked input.toggle_bookmark").click()

  
  
  return
