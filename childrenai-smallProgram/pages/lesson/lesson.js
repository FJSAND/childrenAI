const { COURSES } = require('../../utils/courses.js');

Page({
  data: {
    lesson: null,
    courseName: '',
    badgeClass: '',
    level: ''
  },

  onLoad(options) {
    const { level, index } = options;
    const course = COURSES[level];
    const lesson = course.lessons[parseInt(index)];

    this.setData({
      lesson: lesson,
      courseName: course.name,
      badgeClass: course.badge,
      level: level
    });

    wx.setNavigationBarTitle({ title: lesson.title });
  },

  copyPrompt() {
    wx.setClipboardData({
      data: this.data.lesson.prompt,
      success() {
        wx.showToast({ title: '已复制', icon: 'success' });
      }
    });
  },

  startPractice() {
    const app = getApp();
    const that = this;
    if (!app.globalData.apiKey) {
      wx.showModal({
        title: '🔑 设置 API Key',
        content: '',
        editable: true,
        placeholderText: '请粘贴 DeepSeek API Key',
        confirmText: '保存',
        cancelText: '取消',
        success(res) {
          if (res.confirm && res.content) {
            const key = res.content.trim();
            if (!key) {
              wx.showToast({ title: '请输入Key', icon: 'none' });
              return;
            }
            app.globalData.apiKey = key;
            wx.setStorageSync('deepseek_api_key', key);
            wx.showToast({ title: 'Key已保存', icon: 'success' });
            // 保存后自动进入练习
            app.globalData.currentLesson = that.data.lesson;
            wx.navigateTo({ url: '/pages/chat/chat' });
          }
        }
      });
      return;
    }
    app.globalData.currentLesson = this.data.lesson;
    wx.navigateTo({ url: '/pages/chat/chat' });
  }
});

