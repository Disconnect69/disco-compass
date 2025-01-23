$(document).ready(function(){
  window.addEventListener('message', function(event){
    var item = event.data;
    if (item.open === 2) {
     // console.log(3)
     // update(item.info);

      if (item.direction) {
        $(".direction").find(".image").attr('style', 'transform: translate3d(' + item.direction + 'px, 0px, 0px)');
        return;
      }
      $(".wrap").removeClass("lower");
      $(".street-txt").empty();
      $(".street-txt").append(item.street)
    }

    if (item.open === 4) {
      $(".wrap").addClass("lower");
      $(".street-txt").empty();
      $(".direction").find(".image").attr('style', 'transform: translate3d(' + item.direction + 'px, 0px, 0px)');
    }

    if (item.open === 3) {
      $(".full-screen").fadeOut(100);
    }
    if (item.open === 1) {
      //console.log(1)
      $(".full-screen").fadeIn(100);
    }
  });
});