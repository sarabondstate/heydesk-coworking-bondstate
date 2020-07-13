function generateUserPassword() {
    var password = generatePassword(8);
    $("#user_password").val(password);
    $("#user_password_confirmation").val(password);
}