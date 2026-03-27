Page({
  data: {
    messages: [],
    inputText: '',
    isThinking: false,
    scrollToId: '',
    apiKeySaved: false,
    currentLessonTitle: '',
    msgCounter: 0
  },

  onShow() {
    const app = getApp();
    const lesson = app.globalData.currentLesson;
    if (lesson && lesson.title !== this.data.currentLessonTitle) {
      this.setData({ currentLessonTitle: lesson.title });
      if (lesson.prompt) {
        this.setData({ inputText: lesson.prompt });
        this.addSystemMsg('📚 当前课程：' + lesson.title);
        this.addSystemMsg('💡 参考指令已填入，你可以直接发送或修改');
      }
    }
    // 检查 API Key
    if (!app.globalData.apiKey) {
      this.setData({ apiKeySaved: false });
    } else {
      this.setData({ apiKeySaved: true });
    }
  },

  chatHistory: [],

  onInput(e) {
    this.setData({ inputText: e.detail.value });
  },

  addSystemMsg(text) {
    const id = this.data.msgCounter + 1;
    const msgs = this.data.messages.concat([{ id, role: 'system', content: text }]);
    this.setData({ messages: msgs, msgCounter: id, scrollToId: 'msg-' + id });
  },

  addMsg(role, content) {
    const id = this.data.msgCounter + 1;
    const msgs = this.data.messages.concat([{ id, role, content }]);
    this.setData({ messages: msgs, msgCounter: id, scrollToId: 'msg-' + id });
    return id;
  },

  // 流式缓冲
  _streamBuffer: '',
  _aiMsgId: 0,

  sendMessage() {
    const text = this.data.inputText.trim();
    if (!text) return;

    const app = getApp();
    if (!app.globalData.apiKey) {
      this.showApiConfig();
      return;
    }

    this.addMsg('user', text);
    this.setData({ inputText: '', isThinking: true });
    this.chatHistory.push({ role: 'user', content: text });

    const lesson = app.globalData.currentLesson;
    const isCodeLesson = lesson && (lesson.isTask || /做|制作|动画|游戏|网页|工具|贺卡|计算/.test(lesson.title));

    let systemPrompt;
    const baseRule = '\n【重要规则】1.不要输出任何思考过程、分析过程、推理步骤，直接给出最终结果。2.代码必须用```html代码块包裹，代码前后可以有简短说明（1-2句话），但不要长篇解释。3.不要使用<think>标签。';
    if (isCodeLesson) {
      systemPrompt = '你是少儿编程AI助教。当前课程："' + lesson.title + '"，目标：' + lesson.goal + '。用户要求做网页/动画/游戏/工具时，直接生成完整可运行的HTML代码（含CSS+JS），用```html代码块包裹。代码简洁有趣，界面可爱色彩丰富。' + baseRule;
    } else if (lesson) {
      systemPrompt = '你是少儿编程AI助教，正在教小学生"' + lesson.title + '"。目标：' + lesson.goal + '。用简单有趣的语言回答，用emoji。如需展示代码效果，生成完整HTML代码用```html代码块包裹。' + baseRule;
    } else {
      systemPrompt = '你是少儿编程AI助教，面对小学生。用简单有趣的语言回答。如果用户要求做网页/动画/游戏/工具，直接生成完整可运行HTML代码（含CSS+JS），用```html代码块包裹。代码简洁有趣，界面可爱。' + baseRule;
    }

    this._streamBuffer = '';
    const aiId = this.addMsg('ai', '');
    this._aiMsgId = aiId;

    const that = this;
    const requestTask = wx.request({
      url: 'https://api.deepseek.com/chat/completions',
      method: 'POST',
      enableChunkedTransfer: true,
      header: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + app.globalData.apiKey
      },
      data: {
        model: 'deepseek-chat',
        stream: true,
        messages: [
          { role: 'system', content: systemPrompt },
          ...that.chatHistory.slice(-10)
        ],
        temperature: 0.7,
        max_tokens: 4096
      },
      success(res) {
        // 回退：如果流式没生效，success 拿到完整响应
        if (!that._streamBuffer && res.statusCode === 200) {
          // 非流式响应（res.data 可能是对象或字符串）
          let data = res.data;
          if (typeof data === 'string') {
            // 流式拼接的纯文本，尝试提取最后一个完整 JSON
            const lines = data.split('\n');
            let fullContent = '';
            for (let i = 0; i < lines.length; i++) {
              const line = lines[i].trim();
              if (!line || !line.startsWith('data: ')) continue;
              const jsonStr = line.slice(6);
              if (jsonStr === '[DONE]') continue;
              try {
                const parsed = JSON.parse(jsonStr);
                const delta = parsed.choices && parsed.choices[0] && parsed.choices[0].delta;
                if (delta && delta.content) fullContent += delta.content;
              } catch (e) {}
            }
            if (fullContent) {
              that._streamBuffer = fullContent;
              that.chatHistory.push({ role: 'assistant', content: fullContent });
              that._updateAiMsg(fullContent);
            }
          } else if (data && data.choices) {
            // 非流式 JSON 响应
            const reply = data.choices[0].message.content;
            that._streamBuffer = reply;
            that.chatHistory.push({ role: 'assistant', content: reply });
            that._updateAiMsg(reply);
          }
        }
      },
      fail(err) {
        that._updateAiMsg('❌ 网络错误，请检查网络连接');
      },
      complete() {
        if (that._streamBuffer) {
          // 确保历史记录已保存（流式情况）
          const lastHist = that.chatHistory[that.chatHistory.length - 1];
          if (!lastHist || lastHist.role !== 'assistant') {
            that.chatHistory.push({ role: 'assistant', content: that._streamBuffer });
          }
        } else {
          that._updateAiMsg('❌ 未收到回复，请重试');
        }
        that.setData({ isThinking: false, scrollToId: 'msg-bottom' });
      }
    });

    // 监听流式分块
    if (requestTask && requestTask.onChunkReceived) {
      requestTask.onChunkReceived(function(res) {
        const text = that._decodeUTF8(res.data);
        const lines = text.split('\n');
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i].trim();
          if (!line || !line.startsWith('data: ')) continue;
          const jsonStr = line.slice(6);
          if (jsonStr === '[DONE]') continue;
          try {
            const parsed = JSON.parse(jsonStr);
            const delta = parsed.choices && parsed.choices[0] && parsed.choices[0].delta;
            if (delta && delta.content) {
              that._streamBuffer += delta.content;
              that._updateAiMsg(that._streamBuffer);
            }
          } catch (e) { /* 忽略不完整的 JSON 片段 */ }
        }
      });
    }
  },

  _parseContent(content) {
    // 将内容拆分为 text 和 code 段
    const segments = [];
    const regex = /```(\w*)\n([\s\S]*?)```/g;
    let lastIndex = 0;
    let match;
    while ((match = regex.exec(content)) !== null) {
      if (match.index > lastIndex) {
        const txt = content.slice(lastIndex, match.index).trim();
        if (txt) segments.push({ type: 'text', content: txt });
      }
      segments.push({ type: 'code', lang: match[1] || 'code', content: match[2] });
      lastIndex = match.index + match[0].length;
    }
    // 尾部文本
    if (lastIndex < content.length) {
      const txt = content.slice(lastIndex).trim();
      if (txt) segments.push({ type: 'text', content: txt });
    }
    if (segments.length === 0) segments.push({ type: 'text', content: content });
    return segments;
  },

  _updateAiMsg(content) {
    const msgs = this.data.messages.slice();
    for (let i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].id === this._aiMsgId) {
        msgs[i].content = content;
        msgs[i].segments = this._parseContent(content);
        break;
      }
    }
    this.setData({ messages: msgs, scrollToId: 'msg-bottom' });
  },

  copyCode(e) {
    const code = e.currentTarget.dataset.code;
    wx.setClipboardData({
      data: code,
      success() { wx.showToast({ title: '代码已复制 ✅', icon: 'none' }); }
    });
  },

  runCode(e) {
    const code = e.currentTarget.dataset.code;
    const app = getApp();
    app.globalData._previewCode = code;
    wx.navigateTo({ url: '/pages/preview/preview' });
  },

  _decodeUTF8(buffer) {
    // 优先用 TextDecoder（基础库 2.19.2+）
    if (typeof TextDecoder !== 'undefined') {
      return new TextDecoder('utf-8').decode(buffer);
    }
    // 手动 UTF-8 解码
    const bytes = new Uint8Array(buffer);
    let str = '';
    let i = 0;
    while (i < bytes.length) {
      const b = bytes[i];
      if (b < 0x80) {
        str += String.fromCharCode(b);
        i++;
      } else if ((b & 0xE0) === 0xC0) {
        str += String.fromCharCode(((b & 0x1F) << 6) | (bytes[i+1] & 0x3F));
        i += 2;
      } else if ((b & 0xF0) === 0xE0) {
        str += String.fromCharCode(((b & 0x0F) << 12) | ((bytes[i+1] & 0x3F) << 6) | (bytes[i+2] & 0x3F));
        i += 3;
      } else if ((b & 0xF8) === 0xF0) {
        const cp = ((b & 0x07) << 18) | ((bytes[i+1] & 0x3F) << 12) | ((bytes[i+2] & 0x3F) << 6) | (bytes[i+3] & 0x3F);
        // 转代理对
        str += String.fromCharCode(0xD800 + ((cp - 0x10000) >> 10), 0xDC00 + ((cp - 0x10000) & 0x3FF));
        i += 4;
      } else {
        i++;
      }
    }
    return str;
  },

  clearChat() {
    this.chatHistory = [];
    this.setData({ messages: [], msgCounter: 0, currentLessonTitle: '' });
    const app = getApp();
    app.globalData.currentLesson = null;
    wx.showToast({ title: '已清空', icon: 'success' });
  },

  showApiConfig() {
    const app = getApp();
    const that = this;
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
          that.setData({ apiKeySaved: true });
          that.addSystemMsg('✅ API Key 已保存！');
        }
      }
    });
  }
});

