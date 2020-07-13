// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require multi-select
//= require turbolinks
//= require cocoon
//= require popper
//= require bootstrap
//= require cookies_eu
//= require_tree .

function generatePassword(length) {
    var charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
        retVal = "";
    for (var i = 0, n = charset.length; i < length; ++i) {
        retVal += charset.charAt(Math.floor(Math.random() * n));
    }
    return retVal;
}

$(document).on("click", ".enable-change-subscription-lnk", function () {
    var plan_id = $(this).attr('plan_id');
    $(".plan_id").val( plan_id );
    //var new_plan = $(this).parents('.card-holder').find('.plan-title').html();
    $('.enable-change-subscription').modal('show');
});




document.addEventListener("turbolinks:load", function() {

    var spinnerActive = false 
    /** 
    * Toggles the saving spinner for sorting 
     */ 
    const toggleSpinner = function() { 
        const spinner = document.querySelector(".spinner") 
        spinnerActive = !spinnerActive 
        spinner.classList.toggle("active", spinnerActive) 
 
    } 
    /** 
    * Updates the data-old-position attribute for <tr>s 
    */ 
    const updateOldPositions = function() { 
        var elements = $("#sortable > tr[data-object-id]");
        console.log(elements)
        index = 0;
        elements.each(function () { 
           this.dataset.oldPosition = index;
           index ++ ;
        });
        
    } 
    $(function() {
        $( "#sortable" ).sortable({

            update: function( event, ui ) {
              toggleSpinner() 
              requestBody = { 
                ids: Array.prototype.map.call($("#sortable > tr[data-object-id]"), function(elm) { return parseInt(elm.dataset.objectId) }) 
              } 
              $.post( "/horses/update_positions",requestBody).done(function( data ) {
                updateOldPositions();
                toggleSpinner();
              });;
            }
        });
        $( "#sortable" ).disableSelection();
      } );

    function refresh_tags() {
        if($('#tag_type_select')[0]==undefined)
            return;
        tags = window.TAGS[$('#tag_type_select').val()];
        tag_select = $('.tagMultipleSelect');
        tag_select.children().remove();
        $.each(tags, function(index, tag) {
            var option = $('<option></option>')
                .attr('value', tag.id)
                .text(tag.tag_name);
            if(window.TAGS_SELECTED.indexOf(tag.id)!==-1)
                option.attr('selected', 'selected');
            tag_select.append(option);
        });
        tag_select.multiSelect('refresh');
    }

    $('#tag_type_select').on('change', refresh_tags);

    $.each($('.multipleSelect'), function(i, obj){
        $(this).multiSelect({
            selectableHeader: '<label class="label">' + $(this).data('1st-placeholder') + '</label>',
            selectionHeader: '<label class="label">' + $(this).data('2nd-placeholder') + '</label>'
        });
    });

    $.each($('.multipleSelectWithFilter'), function(i, obj) {
        $(this).multiSelect({
            selectableHeader: "<input type='text' class='search-input' autocomplete='off' placeholder='" + $(this).data('1st-placeholder') + "'>",
            selectionHeader: "<input type='text' class='search-input' autocomplete='off' placeholder='" + $(this).data('2nd-placeholder') + "'>",
            afterInit: function (ms) {
                var that = this,
                    $selectableSearch = that.$selectableUl.prev(),
                    $selectionSearch = that.$selectionUl.prev(),
                    selectableSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selectable:not(.ms-selected)',
                    selectionSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selection.ms-selected';

                that.qs1 = $selectableSearch.quicksearch(selectableSearchString)
                    .on('keydown', function (e) {
                        if (e.which === 40) {
                            that.$selectableUl.focus();
                            return false;
                        }
                    });

                that.qs2 = $selectionSearch.quicksearch(selectionSearchString)
                    .on('keydown', function (e) {
                        if (e.which == 40) {
                            that.$selectionUl.focus();
                            return false;
                        }
                    });
            },
            afterSelect: function () {
                this.qs1.cache();
                this.qs2.cache();
            },
            afterDeselect: function () {
                this.qs1.cache();
                this.qs2.cache();
            }
        });
    });


    // Refresh tags on page load
    refresh_tags();
});//= require cookies_eu
