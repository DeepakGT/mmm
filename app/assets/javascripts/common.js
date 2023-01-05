const resetModal = () => {
  $(".modal").on("show.bs.modal", function(){
    $(this).find('input[type=text]').val('')
    $(this).find('.error').html('')
  });
}

const initDatatables = () => {
  $('.datatable.with-default-setting').dataTable();
  $('.datatable.with-currency-filter').each((i, table)=>{
    let oTable = $(table).dataTable({
      "dom": "<'row custom-filters-wrapper'<'currency-filter offset-md-7 col-md-2'>f>rtip"
    });
    initCurrencyFilterOnDatatable(oTable);
  })
}

const initCurrencyFilterOnDatatable = (oTable) => {
  $('.dataTables_filter').addClass('col-md-3')
  $('div.currency-filter').html("<label>Currency:<br/><select><option value='usdt'>USDT</option><option value='trx'>TRX</option></select></label>")

  var currentSeletedVal = $('.currency-filter select').val();
  applyCurrencyFilterOnDatatable(oTable, currentSeletedVal)
  bindEventOnCurrencyFilterChange(oTable);
}

const bindEventOnCurrencyFilterChange = (oTable) => {
  $(document).on('change', '.currency-filter select', function () {
    selectVal = $(this).val()
    $('.currency-filter select').val(selectVal)
    applyCurrencyFilterOnDatatable(oTable, selectVal)
  } );
}

const applyCurrencyFilterOnDatatable = (oTable, val) => {
  var currencyColumnIndex = 0
  if(oTable.hasClass('history')) {
    currencyColumnIndex = 1
  } else if(oTable.hasClass('growth')){
    currencyColumnIndex = 2
  }
  oTable.fnFilter( val, currencyColumnIndex );
}

const handleAjaxEvents = () => {
  $('form').on('ajax:beforeSend', function(){
    $('#loader').removeClass('d-none')
  })
  $('form').on('ajax:success', function(){
    $('#loader').addClass('d-none')
  })
}

keepDropdownOpen = () => {
  $("ul.dropdown-menu").on("click", "[data-keepOpenOnClick]", function(e) {
    e.stopPropagation();
  });
}

initGoogleTranslater = () => {
  new google.translate.TranslateElement(
    'googleTranslater'
  );
}

$(document).on('ready turbolinks:load', function() {
  initDatatables();
  resetModal();
  handleAjaxEvents();
  keepDropdownOpen();
})
