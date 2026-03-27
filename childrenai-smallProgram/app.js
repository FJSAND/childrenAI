App({
  globalData: {
    apiKey: '',
    currentLevel: 'low',
    currentLesson: null
  },
  onLaunch() {
    const apiKey = wx.getStorageSync('deepseek_api_key') || '';
    this.globalData.apiKey = apiKey;
  }
});

