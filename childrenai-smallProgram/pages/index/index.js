const { COURSES } = require('../../utils/courses.js');

Page({
  data: {
    currentLevel: 'low',
    courseData: COURSES['low']
  },

  onLoad() {
    const app = getApp();
    const level = app.globalData.currentLevel || 'low';
    this.setData({
      currentLevel: level,
      courseData: COURSES[level]
    });
  },

  switchLevel(e) {
    const level = e.currentTarget.dataset.level;
    const app = getApp();
    app.globalData.currentLevel = level;
    this.setData({
      currentLevel: level,
      courseData: COURSES[level]
    });
  },

  goToLesson(e) {
    const id = e.currentTarget.dataset.id;
    const index = e.currentTarget.dataset.index;
    const app = getApp();
    const lesson = this.data.courseData.lessons[index];
    app.globalData.currentLesson = lesson;

    wx.navigateTo({
      url: `/pages/lesson/lesson?level=${this.data.currentLevel}&index=${index}`
    });
  }
});

