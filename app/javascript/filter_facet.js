function filterFacets(uuid) {
    var input = document.getElementById('input-' + uuid).value.toLowerCase();
    var list = document.getElementById('list-' + uuid).getElementsByTagName('li');

    for (var i = 0; i < list.length; i++) {
      var txt = list[i].textContent.toLowerCase();
      list[i].hidden = !txt.includes(input);
    }
}

window.filterFacets = filterFacets;
