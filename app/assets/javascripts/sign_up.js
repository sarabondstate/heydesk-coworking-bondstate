document.addEventListener("turbolinks:load", function() {

    $("#trainer_country").change(function(){

        product = window.PRODUCTS[$(this).val()];
        if(product === undefined){
            product = window.PRODUCTS[''];
        }

       // $("#sign_up_price").text(product.price);
       // $("#sign_up_vat").text(product.vat);
       // $("#sign_up_full_price").text(product.full);

        //$("#modal-window").modal("show");
    });

});