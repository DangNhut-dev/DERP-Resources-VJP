progressValue = 0
const timer = ms => new Promise(res => setTimeout(res, ms))

window.addEventListener('message', function(event) {
    let data = event.data

    if (data.action === "open") {
      SkillTypes = data.skilltypes

      $(`.stat-container`).html("")

      function createcircle(Name){
        if (SkillTypes[Name].Use == true){
          $(`.stat-container`).append(`
          <a href="#bottom">
              <button class="Circle" id="${Name}" onclick="Scroll(id)" onmouseenter="ChangeBackground(id)">
                  <div class="percent">
                      <svg>
                          <circle cx="70" cy="70" r="70"></circle>
                          <circle cx="70" cy="70" r="70"></circle>
                      </svg>
                  </div>
                  <h1>0</h1>
                  <h2>${SkillTypes[Name].Label}</h2>
              </button>
          </a>
        `)

        $(`#${Name} .percent svg circle:nth-child(2)`).css({
          "stroke-dashoffset": "440",
          "stroke-width": "27",
          "stroke": SkillTypes[Name].Color,
          "transition": "stroke-dashoffset 1s ease-in-out",
          "transition-delay": "0.3s",
          "transition-property": "stroke-dashoffset",
        })
        }
      }

      createcircle("Stamina")
      createcircle("Running")
      createcircle("Driving")
      createcircle("Strength")
      createcircle("Swimming")
      createcircle("Shooting")

      show(".section-main")
      Skills = data.skills

      async function load () {
        for (var k in SkillTypes) {
          if (SkillTypes[k].Use == true){
            await timer(10)
            automaticgrow(k, Skills[k])
          }
        }
      }

      load()
    }
    else if(data.action === "StartTimer"){
      time = data.time
      $(`.section-timer .main-container h1`).css("color", "rgb(24, 192, 238)")

      function Time(){
        setTimeout(function(){
          if (time != 0){
            time = time - 1 

            show(".section-timer")
            
            if (time < 10){
              $(`.section-timer .main-container h1`).css("color", "rgb(255, 0, 0)")
            }

            $(`.section-timer .main-container h1`).html(fancyTimeFormat(time))

            Time()
          }
          else{
            hide(".section-timer")
          }
        },1000)
      }
      Time()
    }
    else if(data.action === "StopTimer"){
      time = 0
      hide(".section-timer")
    }
    else if(data.action === "Notify"){
      let Skill = data.skillname
      SkillTypes = data.skilltypes
      for (var k in SkillTypes) {
        if (Skill === k && SkillTypes[k].Use == true){
          $(".section-notify .main-container h1").html("+1 "+SkillTypes[k].Label)
          $(".section-notify .main-container .background").css("background-color", SkillTypes[k].Color)
          show(".section-notify")
        }
      }

      setTimeout(function(){
        hide(".section-notify")
      }, data.duration)
    } 

})

function fancyTimeFormat(duration)
{   
    var hrs = ~~(duration / 3600);
    var mins = ~~((duration % 3600) / 60);
    var secs = ~~duration % 60;

    var ret = "";

    if (hrs > 0) {
        ret += "" + hrs + ":" + (mins < 10 ? "0" : "");
    }

    ret += "" + mins + ":" + (secs < 10 ? "0" : "");
    ret += "" + secs;
    return ret;
}

document.onkeyup = function() {
  if (event.key == 'Escape') {
    Close()
  }
}

function Close(){
  hide(".section-main")
  $.post('https://'+GetParentResourceName()+'/UseButton', JSON.stringify({action:"close"}))
  $(`.percent svg circle:nth-child(1)`).css("stroke-dashoffset", (440 - (440 * 0) / 100))
  $(`.percent svg circle:nth-child(2)`).css("stroke-dashoffset", (440 - (440 * 0) / 100))
}

function automaticgrow(skillname, max_value){
  $(`#${skillname} h1`).html(max_value)
  $(`#${skillname} .percent svg circle:nth-child(1)`).css("stroke-dashoffset", (440 - (440 * 100) / 100));
  $(`#${skillname} .percent svg circle:nth-child(2)`).css("stroke-dashoffset", (440 - (440 * max_value) / 100));
}

function show(element){
  $(element).css("display", "block")
  setTimeout(function(){
      $(element).css("opacity", "1")
  }, 10);
}

function hide(element){
  $(element).css("opacity", "0")
  setTimeout(function(){
    $(element).css("display", "none")
  }, 400)
}

function Scroll(id){
  if (id === "back"){
    clearInterval(progress)
    progressValue = 0
    $(`.section-main .background_color`).css("background-color", "transparent")
  }
  else{
    for (var k in SkillTypes) {
      if (id === k){
        var description = SkillTypes[k].Description
        SkillName = SkillTypes[k].Label
        $(`.bottom-container h2`).html(SkillName)
        $(`.bottom-container h3`).html(description)
      }
    }
    let max = $(`#${id} h1`).html()
    let color = $(`#${id} .percent circle:nth-child(2)`).css("stroke")
    $(`.bottom-container h1`).css("background-image", "linear-gradient(rgb(255, 255, 255), "+color+")")
    $(`.bottom-container h2`).css("color", color)
   
    setTimeout(function(){
      $(`.section-main .background_color`).css("background-color", color)
    },500)

    progress = setInterval(() => {
      if (progressValue == max) {
        clearInterval(progress)
      }
      $(`.bottom-container h1`).html(progressValue)
      progressValue++
    }, 20)
  }
}

function ChangeBackground(id){
  let color = $(`#${id} .percent circle:nth-child(2)`).css("stroke")
  $(`.section-main .background_color`).css("background-color", color)
  $('#'+id).on('mouseleave', function () {
    $(`.section-main .background_color`).css("background-color", "transparent")
  })
}
