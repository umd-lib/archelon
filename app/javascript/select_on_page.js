function selectOnPage(uuid) {
    let amount_currently_selected = document.querySelector('span[data-role=bookmark-counter]').firstChild.nodeValue
    let max_limit = document.getElementById(`button-${uuid}`).dataset.maxLimit
    let amount_selectable = max_limit - amount_currently_selected;

    if (Number(amount_currently_selected) >= Number(max_limit)) {
        alert(`You have reached the maximum limit of ${max_limit} bookmarks.`)
        return;
    }

    let select_boxes = document.querySelectorAll('input[type=checkbox]') // The checkboxes for each item

    if (amount_selectable < select_boxes.length) {
        select_boxes = Array.from(select_boxes).slice(0, amount_selectable)
    }

    console.log(`Selecting ${select_boxes.length} items.`)

    select_boxes.forEach((box) => {
        box.click();
    });

}

window.selectOnPage = selectOnPage;
