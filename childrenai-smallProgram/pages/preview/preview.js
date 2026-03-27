Page({
  data: {
    htmlCode: '',
    rawCode: ''
  },

  onLoad() {
    const app = getApp();
    const code = app.globalData._previewCode;
    if (!code) {
      wx.showToast({ title: '没有代码可预览', icon: 'none' });
      return;
    }
    this.setData({ htmlCode: code, rawCode: code });
  },

  copyCode() {
    wx.setClipboardData({
      data: this.data.rawCode,
      success() {
        wx.showToast({ title: '代码已复制 ✅', icon: 'none' });
      }
    });
  }
});

