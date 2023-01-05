makePaymentListPaginationAjaxify = function() {
  $('#paymentListContainer .pagination a').attr('data-remote', 'true')
}

makepayInListPaginationAjaxify = function() {
  $('#payInCardsContainer .pagination a').attr('data-remote', 'true')
}

initClipboard = () => {
  var clipboard = new Clipboard('.clipboard-btn');
}

confirmBeforepayInOrderPlace = () => {
  $('#commitmentForm').submit(function() {
    var decision = confirm("Are you sure?");
    return decision; //you can just return decision because it will be true or false
  });
}

bindUserSelectionSelectBox = () => {
  $('#childrenFilters select').on('change', function() {
    let url = '/users/dashboard?';
    $('#childrenFilters select').each((i, ele)=>{
      url = url + ele.dataset.filter + '=' + ele.value + '&';
    });
    $.ajax({
      url: url,
      dataType: "script"
    })
  })
}

updateValidMaxMinAmount = () => {
  var currency = $('#commitmentAmountPaymentModal #currency').find(":selected").text();
  var minAmount = 0;
  var maxAmount = 0;
  if(currency == null) {
    minAmount = 0;
    maxAmount = 0;
  } else if(currency.toLowerCase() === 'usdt') {
    minAmount = $('#commitmentAmountPaymentModal #minimumValidUsdtAmount').html();
    maxAmount = $('#commitmentAmountPaymentModal #maximumValidUsdtAmount').html();
  } else if(currency.toLowerCase() === 'trx') {
    minAmount = $('#commitmentAmountPaymentModal #minimumValidTrxAmount').html();
    maxAmount = $('#commitmentAmountPaymentModal #maximumValidTrxAmount').html();
  }
  $('#commitmentAmountPaymentModal .valid-minimum-amount-hint').html(minAmount);
  $('#commitmentAmountPaymentModal .amount-field').attr('min', minAmount);
  $('#commitmentAmountPaymentModal .valid-maximum-amount-hint').html(maxAmount);
  $('#commitmentAmountPaymentModal .amount-field').attr('max', maxAmount);
}

bindCurrencySelectFieldOnChange = () => {
  $('#commitmentAmountPaymentModal #currency').change(() => {
    updateValidMaxMinAmount();
  })
}

$(document).on('ready turbolinks:load', function() {
  makePaymentListPaginationAjaxify();
  makepayInListPaginationAjaxify();
  initClipboard();
  confirmBeforepayInOrderPlace();
  bindUserSelectionSelectBox();
  updateValidMaxMinAmount();
  bindCurrencySelectFieldOnChange();
});
