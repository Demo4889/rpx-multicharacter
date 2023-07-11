var ShowingToast = false;
var ShowingDeleteModal = false;

window.addEventListener("message", (event) => {
    const action = event.data.action;
    switch (action) {
        case "OPEN":
            $("#multicharmenu").show();
            break;
        case "OPEN_CONFIRMDELETE":
            ShowingDeleteModal = true;
            $("#multicharmenu").hide();
            $("#confirmmenu").show();
            break;
        case "CLOSE":
            $("#multicharmenu").hide();
            break;
        default:
            return;
    }
});

// This enables the player to close the NUI with the escape key.
$(document).keyup(function(e) {
    if (e.keyCode == 27 && !ShowingDeleteModal) {
        $("#multicharmenu").hide();
        $.post(`https://${GetParentResourceName()}/CloseNUI`);
    }
});

$("#button").click(function() {
    // must began with Capital letter
    const Name = /^[A-Z][a-z]+/;
    var Age = parseInt($("#age").val());
    var Height = parseInt($("#height").val());
    var gender = $("input[name='radio']:checked").attr("id");
    switch(gender) {
        case "male":
            gender = "1"
            break;
        case "female":
            gender = "0"
            break;
    }



    if(!Name.test($("#firstname").val())) return Toast("Invalid First Name<br/>Name must have a capital character at the beginning, and be a realistic roleplay name.", 2500);
    if(!Name.test($("#lastname").val())) return Toast("Invalid Last Name<br/>Name must have a capital character at the beginning, and be a realistic roleplay name.", 2500);
    if(Age < 18 || Age > 80) return Toast("Invalid Age<br/>A valid age is between 18 and 80.", 2500);
    if(Height < 150 || Height > 190) return Toast("Invalid Height<br/>A valid height is between 150 and 190", 2500);


    if($("#firstname").val() != "" && $("#lastname").val() != "" && $("#age").val() != "" && $("#height").val() != "") {
        $("#multicharmenu").hide();
        $.post(`https://${GetParentResourceName()}/CloseNUI`, JSON.stringify({
            firstname:$("#firstname").val(),
            lastname:$("#lastname").val(),
            age:$("#age").val(),
            gender:gender,
            height:$("#height").val()
        }));
    }
});

$(".radioinput").click(function() {
    let gender = $("input[name='radio']:checked").attr("id");
    switch(gender) {
        case "male":
            gender = "1"
            break;
        case "female":
            gender = "0"
            break;
    }
    $.post(`https://${GetParentResourceName()}/ChangeGender`, JSON.stringify({gender: gender}));
});

$("#button2").click(function() {
    $("#multicharmenu").hide();
    $("#confirmmenu").hide();
    $.post(`https://${GetParentResourceName()}/CloseConfirm`, JSON.stringify({confirm: true}));
    ShowingDeleteModal = false;
});

$("#button3").click(function() {
    $("#multicharmenu").hide();
    $("#confirmmenu").hide();
    $.post(`https://${GetParentResourceName()}/CloseConfirm`, JSON.stringify({confirm: false}));
    ShowingDeleteModal = false;
});

$("#firstname").keypress(function (e) {
    var regex = new RegExp("^[a-zA-Z]+$");
    var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
    if (regex.test(str)) {
        return true;
    }
    e.preventDefault();
    return false;
});

$("#lastname").keypress(function (e) {
    var regex = new RegExp("^[a-zA-Z]+$");
    var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
    if (regex.test(str)) {
        return true;
    }
    e.preventDefault();
    return false;
});


Toast = function(text, time) {
    if(!ShowingToast) {
        ShowingToast = true;
        $("#toast").html("<p>" + text + "</p>");
        $("#toast").fadeIn(250, function () {
            setTimeout(function() {
                $("#toast").fadeOut(250, function () {
                    $("#toast").html("");
                    ShowingToast = false;
                });
            }, time);
        });
    }
}
