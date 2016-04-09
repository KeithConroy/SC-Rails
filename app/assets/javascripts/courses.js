$(document).on('courses:loaded', function() {

  $("body").on('click', ".add-student-course", addStudentCourse);
  $("body").on('click', ".remove-student-course", removeStudentCourse);

  $('#course-search').on('keyup', courseSearch);

  $('.modify-course-search').on('keyup', modifyCourseSearch);
  $('.modify-course-search').focusout(hideResults);

});

var addStudentCourse = function(){
  event.preventDefault();

  var url = $(this).attr('href');
  var studentId = $(this).attr('data-student-id');
  this.closest("tr").remove();

  $.ajax({
    url: url,
    data: { student_id: studentId },
    type: 'post'
  }).done(function(data) {
    $('#course-show-students').find('.none-added').parent().hide()
    $('#course-show-students').append($(data));
  }).fail(function() {
    console.log('error');
  });
};

var removeStudentCourse = function(){
  event.preventDefault();

  var url = $(this).attr('href');
  var studentId = $(this).attr('data-student-id');

  $.ajax({
    url: url,
    data: { student_id: studentId },
    type: 'delete'
  }).done(function(data) {
    if(data.count === 0){
      $('#course-show-students').find('.none-added').parent().show()
    }
    var student = this.data.match( /\d+/g );
    $("a[data-student-id='"+student+"']").closest("tr").remove();
  }).fail(function() {
    console.log('error');
  });
};

var courseSearch = function(){
  var phrase = $(this).val().toLowerCase();
  if (phrase) {
    $.get('courses/search', { phrase: phrase }).success(function(payload) {
      $('#courses-index').html($(payload));
    });
  } else {
    $.get('courses').success(function(payload) {
      $('#courses-index').html($(payload));
    });
  }
};

var modifyCourseSearch = function(event){
  var phrase = $(this).val().toLowerCase();
  var courseId = $(this).attr('id');

  if(event.keyCode == 13){
    $('.search-results a:first').click();
  }

  if (phrase) {
    $.get(courseId + '/modify_search', { phrase: phrase }).success(function(payload) {
      $('.search-results table').html($(payload));
      $('.search-results tr:first').addClass('force-hover');
      showResults();
    });
  } else {
    $('.search-results table').empty();
    hideResults();
  }
};

var showResults = function() {
  $('.search-results').fadeIn(200);
};

var hideResults = function() {
  $('.search-results').fadeOut(200);
};