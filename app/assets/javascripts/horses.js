$("#modal-window").html("<%= escape_javascript(render 'project/new_release') %>");

$(document).ajaxComplete(function( event, xhr, settings ) {
    var modal = $("#modal-window");
    if ( settings.url.includes("/horses/horse_info/") || settings.url.includes("/horses/single_import_preview/")) {
        modal.html(xhr.responseText);
        modal.modal("show");
    }
});

document.addEventListener("turbolinks:load", function() {

    $("#check_all").click(function(){

        $("#multi_horse_import input[type='checkbox']").each(function(){
            $(this).prop('checked', 'checked');
        });

        toggle_submit_state();
        return false;

    });

    $("#uncheck_all").click(function(){

        $("#multi_horse_import input[type='checkbox']").each(function(){
            $(this).removeProp('checked').removeAttr('disabled');
        });

        toggle_submit_state();
        return false;

    });

    function toggle_submit_state(){
        var submit_button = $("#multi_horse_import_button");
        var max_horses = get_max_horses_count();
        selected_horses_length = get_checked_count();
        if(max_horses == -3)//unlimited max plan 
        {
          $("#check_all").removeClass("isDisabled")
          $("#uncheck_all").removeClass("isDisabled")
          $("#multi_horse_import input[type='checkbox']").removeAttr('disabled', '');
          if(selected_horses_length){
            submit_button.removeAttr('disabled', '');
          }
          else{
            submit_button.attr('disabled', '');
          }
        }
        else if(max_horses == -1 || max_horses == -2)//no plan seleced - inactive stable
        {
          $("#check_all").addClass("isDisabled")
          $("#uncheck_all").addClass("isDisabled")
          submit_button.attr('disabled', '');
          $("#multi_horse_import input[type='checkbox']").attr('disabled', '');
        }
        else{
            if(selected_horses_length > 0){
                if (selected_horses_length > max_horses) {
                    submit_button.attr('disabled', '');
                }
               else if(selected_horses_length == max_horses) {
                    $("#multi_horse_import input[type='checkbox']:not(:checked)").attr("disabled","disabled");
                    $("#check_all").addClass("isDisabled");
                    submit_button.removeAttr('disabled');
                }
                else
                {
                  submit_button.removeAttr('disabled');
                  $("#check_all").removeClass("isDisabled");
                  $("#multi_horse_import input[type='checkbox']:not(:checked)").removeAttr('disabled');
                }
            }
            else{
              if(max_horses == 0){
                $("#multi_horse_import input[type='checkbox']:not(:checked)").attr("disabled","disabled");
              }
              submit_button.attr('disabled', '');
            }
            if($("#multi_horse_import input[type='checkbox']").length > max_horses){
              $("#check_all").addClass("isDisabled")
            }
        }
    }

    $("#multi_horse_import input[type='checkbox']").change(function(){
      toggle_submit_state();
    });

    $("#multi_horse_import_button").click(function(){

        var count = get_checked_count();
        var single_text = $("#single_text");
        var multi_text = $("#multi_text");

        if (count === 1){
            multi_text.hide();
            single_text.show();
        }else{
            multi_text.find('span').text(count);
            single_text.hide();
            multi_text.show();
        }

        $("#confirm-window").modal("show");
        return false;
    });

    function get_checked_count(){
        return $("#multi_horse_import input[type='checkbox']:checked").length
    }

    function get_max_horses_count(){
        return $("#max_horses").val()
    }

    toggle_submit_state();

});

$('#hidden-cancel').hide();