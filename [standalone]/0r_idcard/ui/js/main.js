$(function(){
    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.action === "toggle") {
            if (item.value === true) {
                let cardData = item.cardData;
                let cardTypes = item.cardTypes;

                let cardType = cardTypes[cardData.cardType];
                let grade = cardType.grades[cardData.jobGrade];
                let text = grade.text;

                $(".text-10, .text-12, .text-14, .text-16, .text-18, .text-20").css("color", grade.textColor);

                let signatureColor = grade.textColor.substring(1).toLowerCase();
            
                $(".card-title .subtitle").text(text);
                $(".card-bg img").attr("src", `assets/${cardData.cardType + "_" + cardData.face + "_" + grade.cardType}.png`);
                $("#signature img").attr("src", `assets/signature_${signatureColor}.png`);
                $("#card-image").attr("src", `assets/${cardData.cardType + "_icon.png"}`);
                $("#badge").attr("src", `assets/${cardData.cardType + "_badge.png"}`);
                $(".city-flag img").attr("src", `assets/flags/${cardData.nationality + ".png"}`);

                $("#lastname").text(cardData.name.lastname);
                $("#firstname").text(cardData.name.firstname);
                $("#sex").text(cardData.sex);
                $("#license").text(cardData.license);
                $("#birthdate").text(cardData.birthDate);
                $(".player-mugshot img").attr("src", cardData.headshot);

                $(".card-front").show();
            } else {
                $(".card-front").hide();
                $(".card-back").hide();
            }
        }

        if (item.action === "convert_base64") {
            toDataUrl(item.img, function(base64) {
                $.post(`https://${GetParentResourceName()}/base64`, JSON.stringify({
                    base64: base64,
                    handle: item.handle,
                    id: item.id
                }));
            });
        }
    });

    $(".card-front").mouseenter(function() {
        $(".card-back").show();
        $(this).hide()
    });

    $(".card-back").mouseleave(function() {
        $(".card-front").show();
        $(this).hide()
    });

    document.onkeyup = function(data) {
        if (data.which == 27) {
            $.post(`https://${GetParentResourceName()}/close`);
        }else if (data.which == 8) {
            $.post(`https://${GetParentResourceName()}/close`);
        }
    };
})

function toDataUrl(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onload = function() {
        var reader = new FileReader();
        reader.onloadend = function() {
            callback(reader.result);
        }
        reader.readAsDataURL(xhr.response);
    };
    xhr.open("GET", url);
    xhr.responseType = "blob";
    xhr.send();
}