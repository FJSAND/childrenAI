// ===== 课程数据 =====
const COURSES = {
  low: {
    name: '低段（1-2年级）', subtitle: '文字指令启蒙篇 —— AI听我话',
    icon: '🌱', badge: 'badge-low',
    lessons: [
      { id: 'l1', title: '认识文字编程小伙伴', prompt: '你好，请做一下自我介绍吧！', goal: '学会打开AI工具，输入短句指令"你好"，查看AI回复', steps: ['打开AI对话窗口','输入"你好"','查看AI的回复','试着换一个问候语再试一次'], checklist: ['成功打开AI工具','输入指令并发送','阅读AI回复'] },
      { id: 'l2', title: '文字指令小魔法（1）', prompt: '画一只彩色小猫，可爱一点', goal: '用文字让AI画画，学会描述具体内容', steps: ['输入"画一只彩色小猫"','查看AI生成的结果','修改为"画一只蓝色的小狗"再试'], checklist: ['输入绘画指令','查看结果','修改指令重试'] },
      { id: 'l3', title: '文字指令小魔法（2）', prompt: '讲一个小兔子去冒险的故事，简短有趣', goal: '让AI讲故事，学会描述故事主题', steps: ['输入故事指令','听AI讲的故事','换一个动物角色再试'], checklist: ['输入故事指令','阅读故事','仿写新指令'] },
      { id: 'l4', title: '我的第一个文字指令', prompt: '（自由发挥：写一句你最想让AI帮你做的事）', goal: '独立写一句指令，让AI完成心愿', steps: ['想一想你想让AI做什么','写出你的指令','发送并记录结果'], checklist: ['独立思考','写出指令','记录结果'] },
      { id: 'l5', title: 'AI小管家（文字查知识）', prompt: '太阳为什么会发光？请用小朋友能听懂的话回答', goal: '学会用文字问AI知识问题', steps: ['输入你想知道的问题','阅读AI的回答','再问一个新问题'], checklist: ['提出问题','理解回答','追问新问题'] },
      { id: 'l6', title: '指令要清楚（短句优化）', prompt: '画一朵红色的玫瑰花，花瓣要很大，背景是绿色的草地', goal: '学会写更清楚、更详细的文字指令', steps: ['先输入"画花"看结果','再输入详细指令看结果','对比两次效果有什么不同'], checklist: ['对比模糊指令和精准指令','发现差异','学会加细节'] },
      { id: 'l7', title: '文字指挥AI做数学', prompt: '请帮我出5道10以内的加法题，并给出答案', goal: '用文字让AI帮忙做数学', steps: ['输入数学指令','检查AI给的答案对不对','换成减法再试'], checklist: ['发送数学指令','验证答案','尝试新指令'] },
      { id: 'l8', title: 'AI小画家（文字创作）', prompt: '用文字描述一幅画：一个小朋友在草地上踢足球，天空有彩虹', goal: '组合多个描述，完成创意作品', steps: ['写出完整的画面描述','发送给AI','修改让画面更丰富'], checklist: ['写完整描述','查看结果','优化指令'] },
      { id: 'l9', title: '安全用AI（文字礼仪）', prompt: '请告诉我小朋友使用AI应该注意哪些安全规则？', goal: '学会安全、文明使用AI', steps: ['问AI安全规则','记住重要规则','讨论哪些内容不能问AI'], checklist: ['了解安全规则','记住要点','知道什么不该问'] },
      { id: 'l10', title: '文字指令闯关', prompt: '请出3个文字指令小挑战，从简单到困难', goal: '按关卡要求写指令完成挑战', steps: ['完成第一关简单指令','完成第二关中等指令','挑战第三关困难指令'], checklist: ['完成3个关卡','每关都有结果','挑战成功'] },
      { id: 'l11', title: '我的指令日记', prompt: '帮我整理今天学到的3个最好用的AI指令', goal: '记录自己的文字指令作品', steps: ['回忆学过的指令','选出最好的3个','写成指令日记'], checklist: ['回忆指令','记录作品','分享给同学'] },
      { id: 'l12', title: '小组比拼：AI听谁的', prompt: '（小组挑战：看谁的指令让AI执行得最准确）', goal: '分组比赛，提升指令精准度', steps: ['分组讨论指令','各组发送指令','评比哪组效果最好'], checklist: ['参与小组讨论','发送指令','互评打分'] },
      { id: 'l13', title: '复习：指令小达人', prompt: '请帮我复习文字指令的3个技巧：要具体、要完整、要清楚', goal: '回顾短句指令写法，查漏补缺', steps: ['复习指令技巧','找出自己的不足','练习改进'], checklist: ['掌握3个技巧','发现不足','改进练习'] },
      { id: 'l14', title: '结业展示：我的指令作品', prompt: '请帮我做一个自我介绍，展示我这学期学会的AI指令技巧', goal: '展示自己的文字指令作品', steps: ['准备展示内容','向同学展示','获得评价'], checklist: ['准备作品','展示分享','收获评价'] },
      { id: 'l15', title: '拓展：家庭文字指令任务', prompt: '请给我3个可以在家里用AI帮爸爸妈妈的任务', goal: '回家用AI帮助家人', steps: ['获取家庭任务','选择一个完成','告诉爸妈你学会了什么'], checklist: ['获取任务','完成实践','分享成果'] },
    ]
  },
  mid: {
    name: '中段（3-4年级）', subtitle: '文字编程实战篇 —— 用文字做项目',
    icon: '🌿', badge: 'badge-mid',
    lessons: [
      { id: 'm1', title: '什么是文字编程', prompt: '请用小学生能听懂的话解释：什么是文字编程？和写代码有什么关系？', goal: '理解"写文字=编程序"的概念', steps: ['问AI什么是文字编程','理解文字和代码的关系','打开编程助手界面'], checklist: ['理解文字编程概念','知道指令和代码的关系','熟悉工具界面'] },
      { id: 'm2', title: '第一个文字编程作品（打招呼动画）', prompt: '做一个打招呼的动画网页，角色是黄色小猫，画面简洁可爱，有动画效果', goal: '输入完整文字指令，运行AI代码查看效果', steps: ['输入标准指令（照着抄，不写错）','发送指令，等待AI生成代码','点击"运行代码"查看效果','记录：正常运行 / 有点问题 / 运行失败'], checklist: ['成功打开编程工具','输入完整指令并发送','运行代码查看效果','观察动画效果'], isTask: true },
      { id: 'm3', title: '优化指令：让动画更好看', prompt: '做一个打招呼的动画网页，角色是黄色小猫，背景是蓝色天空，小猫会左右摆动，画面简洁可爱', goal: '修改文字指令，添加细节让作品更好', steps: ['在原来指令基础上添加"背景蓝色"','再添加"小猫动起来"','对比两次效果，学会优化'], checklist: ['修改指令','添加新要素','对比优化效果'] },
      { id: 'm4', title: '文字做数学小游戏', prompt: '做一个10以内加法口算小游戏网页，界面简单易懂，有计分功能，适合3-4年级学生玩', goal: '运行AI生成的数学小游戏', steps: ['输入范文指令，发送给AI','点击"运行代码"玩小游戏','自己玩3局，记录得分','把"加法"改成"减法"，重新生成'], checklist: ['输入指令','运行游戏','记录得分','修改指令重新生成'], isTask: true },
      { id: 'm5', title: '文字做故事动画', prompt: '做一个简单的故事动画网页：小兔子在森林里遇到小熊，他们成为朋友一起冒险。要有对话气泡，画面简洁可爱', goal: '写完整文字指令描述故事', steps: ['确定故事角色和场景','写出完整的故事指令','让AI生成代码并运行','修改故事情节'], checklist: ['设定角色场景','写完整指令','运行查看效果'] },
      { id: 'm6', title: '提示词技巧：要素要齐全', prompt: '（学习指令公式：谁 + 做什么 + 效果要求）', goal: '掌握"谁+做什么+效果"指令公式', steps: ['学习指令公式','用公式写一个指令','对比有公式和没公式的效果'], checklist: ['记住指令公式','独立写指令','对比效果'] },
      { id: 'm7', title: '文字编程做贺卡', prompt: '用HTML和CSS制作一个电子生日贺卡，要有漂亮的背景色、生日快乐的大字、闪烁的星星动画效果，代码简洁适合小学生', goal: '生成电子贺卡并修改', steps: ['输入贺卡指令','查看生成的贺卡代码','修改文字内容为自己想写的','添加更多装饰效果'], checklist: ['生成贺卡','修改内容','添加效果'] },
      { id: 'm8', title: 'AI纠错：指令错了怎么办', prompt: '做一个游戏（故意写模糊指令，看AI怎么回应）', goal: '学会从AI反馈中发现问题并修正', steps: ['故意写一个模糊指令','看AI的回应和提问','修正指令让AI理解','总结怎样写才不会出错'], checklist: ['尝试模糊指令','分析AI反馈','修正指令','总结经验'] },
      { id: 'm9', title: '文字做垃圾分类小助手', prompt: '制作一个垃圾分类查询小工具网页，输入垃圾名称就能返回分类结果，操作简单，界面干净可爱，适合小学生使用', goal: '完成一个实用的小工具项目', steps: ['输入指令，生成代码','点击运行，测试3种垃圾','记录分类结果','修改指令，加入更多功能'], checklist: ['生成代码','测试3种垃圾','记录结果','优化功能'], isTask: true },
      { id: 'm10', title: '小组合作：文字编程闯关', prompt: '（小组挑战：分组写指令完成编程任务）', goal: '分组合作完成编程闯关', steps: ['分组讨论策略','分工写指令','合并代码运行','评比效果'], checklist: ['参与讨论','写出指令','合作完成','互评打分'] },
      { id: 'm11', title: 'AI与语文：文字生成古诗', prompt: '写一首描写春天的五言绝句，通俗易懂，适合小学生背诵，并解释每句的意思', goal: '让AI创作古诗并赏析', steps: ['输入古诗指令','阅读AI写的古诗','让AI解释含义','试着修改主题重新生成'], checklist: ['生成古诗','理解含义','修改主题'] },
      { id: 'm12', title: 'AI与科学：文字查科普', prompt: '请用小学生能听懂的话解释：为什么天空是蓝色的？请分步骤说明', goal: '用精准指令查询科学知识', steps: ['提出科学问题','阅读AI的解释','整理成笔记','换一个问题继续'], checklist: ['提问','理解答案','做笔记'] },
      { id: 'm13', title: '复习：指令公式与调试', prompt: '请帮我总结文字编程的指令公式和调试技巧', goal: '巩固指令写法和调试步骤', steps: ['复习指令公式','练习调试技巧','完成综合练习'], checklist: ['掌握公式','学会调试','完成练习'] },
      { id: 'm14', title: '结业项目：我的文字编程小游戏', prompt: '做一个猜数字小游戏网页：电脑随机一个1-100的数，玩家来猜，提示大了或小了，猜对显示恭喜，界面友好可爱', goal: '独立设计指令，生成专属小游戏', steps: ['构思游戏创意','写出完整指令','生成并测试代码','展示给同学'], checklist: ['有创意','指令完整','代码能运行','展示成功'] },
      { id: 'm15', title: '拓展：优化自己的项目', prompt: '请帮我优化上一节课做的猜数字游戏，加入计分功能和难度选择', goal: '修改指令让作品更完善', steps: ['找出可以改进的地方','修改指令添加新功能','测试新版本','撰写项目说明'], checklist: ['找到改进点','添加功能','测试通过','写说明'] },
    ]
  },
  high: {
    name: '高段（5-6年级）', subtitle: '提示词工程进阶篇 —— AI项目设计师',
    icon: '🌳', badge: 'badge-high',
    lessons: [
      { id: 'h1', title: '提示词工程：文字编程的高级技巧', prompt: '请教我结构化指令的写法，包含：角色设定 + 任务描述 + 具体要求 + 输出格式，举个例子', goal: '学习结构化指令写法', steps: ['了解结构化指令4要素','看AI给出的示例','自己仿写一个结构化指令'], checklist: ['理解4要素','看懂示例','独立仿写'] },
      { id: 'h2', title: '结构化指令做校园打卡系统', prompt: '角色：你是一个少儿编程导师。任务：制作一个校园打卡小程序。要求：用HTML+JS实现，功能简单（输入姓名点击打卡显示时间），界面可爱适合小学生。输出：完整可运行的代码', goal: '用结构化指令开发实用项目', steps: ['按结构化格式输入指令','查看AI生成的完整代码','复制运行并测试','调试修改优化'], checklist: ['使用结构化指令','代码能运行','功能正常','界面美观'] },
      { id: 'h3', title: '优化提示词：提升AI作品质量', prompt: '对比这两个指令的效果：\n指令A：做个计算器\n指令B：角色：编程导师。任务：做一个四则运算计算器。要求：HTML+CSS+JS，界面简洁美观，按钮大一些适合触屏操作，有清除功能。输出：完整代码', goal: '学会对比和优化提示词', steps: ['先发送简单指令A','再发送精准指令B','对比两次结果','总结优化技巧'], checklist: ['对比两种指令','发现差异','总结规律'] },
      { id: 'h4', title: '文字编程做科普动画', prompt: '角色：少儿科普动画师。任务：用HTML+CSS+JS做一个太阳系行星运行的动画。要求：画面简洁，至少展示太阳和3颗行星的轨道运行，颜色区分不同行星，适合小学生观看。输出：完整可运行代码', goal: '设计完整指令生成动画代码', steps: ['确定动画主题和要素','按结构化格式写指令','运行查看动画效果','调整参数优化'], checklist: ['主题明确','指令完整','动画运行','效果优化'] },
      { id: 'h5', title: 'AI代码解读：看懂文字生成的代码', prompt: '请逐行解释上面生成的太阳系动画代码，用小学生能听懂的话，标注每段代码的作用', goal: '理解文字指令与代码的对应关系', steps: ['把之前生成的代码发给AI','让AI逐行解释','标注听懂的和没听懂的','提问不理解的部分'], checklist: ['发送代码','阅读解释','标注疑问','追问理解'] },
      { id: 'h6', title: '项目开发：环保主题小工具', prompt: '角色：环保教育编程师。任务：做一个碳排放计算器。要求：HTML+JS实现，输入用电度数/开车公里数，计算碳排放量，给出环保建议，界面绿色主题。输出：完整代码+使用说明', goal: '确定主题，写完整项目指令', steps: ['确定环保主题','写出完整结构化指令','生成代码并测试','优化功能和界面'], checklist: ['主题合适','指令结构化','代码运行','功能完善'] },
      { id: 'h7', title: '多轮对话编程：反复优化作品', prompt: '请在碳排放计算器的基础上，加入以下功能：1. 可以切换不同场景（家庭/学校/出行）2. 显示环保等级评分 3. 加入可爱的动画提示', goal: '通过多轮对话逐步完善项目', steps: ['发送优化指令','查看新增功能','继续提出改进意见','直到满意为止'], checklist: ['多轮对话','逐步优化','功能增加','作品完善'] },
      { id: 'h8', title: 'AI伦理：文字编程的边界', prompt: '请告诉我：小学生使用AI编程应该遵守哪些规则？哪些事情AI不应该帮我们做？', goal: '讨论AI使用规范', steps: ['了解AI使用规则','讨论AI的边界','制定班级AI使用公约'], checklist: ['了解规则','知道边界','形成公约'] },
      { id: 'h9', title: '信息安全：保护隐私不泄露', prompt: '请告诉我在使用AI时，哪些个人信息不能输入？怎样保护自己的隐私安全？', goal: '学会保护个人隐私', steps: ['了解隐私安全知识','列出不能告诉AI的信息','学会安全使用AI'], checklist: ['知道隐私红线','列出危险信息','掌握安全方法'] },
      { id: 'h10', title: '项目启动：我的创意AI作品', prompt: '我想做一个关于______（主题）的AI项目，请帮我制定项目计划，包括：项目目标、功能列表、技术方案、时间安排', goal: '分组确定项目主题，撰写计划书', steps: ['选定项目主题','与AI讨论项目计划','完善计划书','准备开发'], checklist: ['主题确定','计划完整','分工明确','准备就绪'] },
      { id: 'h11', title: '项目设计：结构化指令撰写', prompt: '角色：______。任务：______。要求：______。输出格式：______。（按这个模板完成你的项目核心指令）', goal: '按结构化模板完成核心指令', steps: ['填写角色设定','描述任务需求','明确要求细节','确定输出格式'], checklist: ['4要素齐全','描述清晰','要求具体','格式明确'] },
      { id: 'h12', title: '项目实操：AI生成与调试', prompt: '（发送你的项目指令，生成代码，开始调试）', goal: '运行指令，测试代码，修正bug', steps: ['发送项目指令','检查生成的代码','发现并修复问题','优化到满意为止'], checklist: ['代码生成','运行测试','bug修复','优化完成'] },
      { id: 'h13', title: '项目包装：制作演示文档', prompt: '请帮我写一份项目介绍文档，包括：项目名称、功能介绍、使用的指令思路、创新亮点、使用方法', goal: '写项目介绍，准备展示', steps: ['撰写项目介绍','整理指令思路','突出创新亮点','制作演示文档'], checklist: ['介绍完整','思路清晰','亮点突出','文档规范'] },
      { id: 'h14', title: '项目发布会：展示文字编程成果', prompt: '请帮我准备一段2分钟的项目展示演讲稿，重点介绍我是怎么用文字指令一步步完成项目的', goal: '分组演示作品，互评打分', steps: ['准备演讲稿','现场演示项目','讲解指令思路','接受评分'], checklist: ['演讲流利','演示成功','思路清楚','获得好评'] },
      { id: 'h15', title: '总结与展望：未来AI与文字编程', prompt: '请用小学生能理解的话，介绍未来AI技术的发展趋势，文字编程会怎样改变我们的生活？', goal: '撰写学习心得，展望未来', steps: ['了解AI发展趋势','讨论未来可能','撰写学习心得','分享感想'], checklist: ['了解趋势','展望未来','写心得','分享感想'] },
    ]
  }
};



// ===== 状态管理 =====
let currentLevel = 'low';
let currentLesson = null;
let chatHistory = [];
let apiKey = localStorage.getItem('deepseek_api_key') || '';

// ===== 初始化 =====
document.addEventListener('DOMContentLoaded', () => {
  renderLessonList();
  if (apiKey) document.getElementById('apiKeyInput').value = '••••••••';
  // 默认显示欢迎页
  showMobileView('content');
});

// ===== API Key 管理 =====
function toggleApiConfig() {
  document.getElementById('apiConfigPanel').classList.toggle('hidden');
}

function saveApiKey() {
  const key = document.getElementById('apiKeyInput').value.trim();
  if (key && !key.startsWith('••')) {
    apiKey = key;
    localStorage.setItem('deepseek_api_key', key);
    document.getElementById('apiKeyInput').value = '••••••••';
    toggleApiConfig();
    addSystemMessage('✅ API Key 已保存！');
  }
}

// ===== 年级切换 =====
function switchLevel(level) {
  currentLevel = level;
  currentLesson = null;
  document.querySelectorAll('.level-tab').forEach(t => t.classList.remove('active'));
  document.querySelector(`.level-tab[data-level="${level}"]`).classList.add('active');
  renderLessonList();
  // 显示欢迎页
  document.getElementById('welcomePage').classList.remove('hidden');
  document.getElementById('lessonDetail').classList.add('hidden');
}

// ===== 渲染课程列表 =====
function renderLessonList() {
  const list = document.getElementById('lessonList');
  const lessons = COURSES[currentLevel].lessons;
  list.innerHTML = lessons.map((l, i) => `
    <div class="lesson-item ${currentLesson?.id === l.id ? 'active' : ''}" onclick="selectLesson('${l.id}')">
      <span class="lesson-num">${i + 1}</span>
      <span class="lesson-title">${l.title}</span>
    </div>
  `).join('');
}

// ===== 选择课程 =====
function selectLesson(lessonId) {
  const course = COURSES[currentLevel];
  currentLesson = course.lessons.find(l => l.id === lessonId);
  if (!currentLesson) return;

  renderLessonList();
  renderLessonDetail(course);
  showMobileView('content');
}

// ===== 渲染课程详情 =====
function renderLessonDetail(course) {
  document.getElementById('welcomePage').classList.add('hidden');
  document.getElementById('lessonDetail').classList.remove('hidden');

  const badge = document.getElementById('lessonBadge');
  badge.textContent = course.name;
  badge.className = `lesson-badge ${course.badge}`;
  document.getElementById('lessonTitle').textContent = currentLesson.title;

  let html = '';
  // 目标
  html += `<h3>🎯 学习目标</h3><div class="task-step">${currentLesson.goal}</div>`;
  // 示例提示词
  html += `<h3>💡 参考指令</h3>
    <div class="sample-prompt"><button class="copy-btn" onclick="copyPrompt(this)">📋 复制</button>${escapeHtml(currentLesson.prompt)}</div>`;
  // 操作步骤
  html += `<h3>📝 操作步骤</h3>`;
  currentLesson.steps.forEach((s, i) => {
    html += `<div class="task-step"><strong>步骤${i + 1}：</strong>${s}</div>`;
  });
  // 评价清单
  html += `<h3>✅ 自评清单</h3><ul class="checklist">`;
  currentLesson.checklist.forEach(c => { html += `<li>${c}</li>`; });
  html += `</ul>`;

  document.getElementById('lessonBody').innerHTML = html;
}

// ===== 复制提示词 =====
function copyPrompt(btn) {
  const text = btn.parentElement.textContent.replace('📋 复制', '').trim();
  navigator.clipboard.writeText(text).then(() => {
    btn.textContent = '✅ 已复制';
    setTimeout(() => btn.textContent = '📋 复制', 1500);
  });
}

// ===== 开始AI练习 =====
function startPractice() {
  if (!apiKey) {
    toggleApiConfig();
    addSystemMessage('⚠️ 请先设置 DeepSeek API Key');
    return;
  }
  showMobileView('chat');
  document.getElementById('chatHint').classList.add('hidden');
  // 自动发送参考指令
  if (currentLesson) {
    addSystemMessage(`📚 当前课程：${currentLesson.title}`);
    addSystemMessage(`💡 参考指令已填入输入框，你可以直接发送或修改后发送`);
    document.getElementById('chatInput').value = currentLesson.prompt;
    document.getElementById('chatInput').focus();
  }
}

// ===== 发送消息 =====
async function sendMessage() {
  const input = document.getElementById('chatInput');
  const text = input.value.trim();
  if (!text) return;

  if (!apiKey) {
    toggleApiConfig();
    addSystemMessage('⚠️ 请先设置 DeepSeek API Key');
    return;
  }

  // 显示用户消息
  addMessage('user', text);
  input.value = '';
  input.style.height = 'auto';

  // 构建系统提示
  const codeRule = `
【重要代码规则】当学生的指令需要生成代码时：
- 必须生成完整的、可直接在浏览器中运行的 HTML 文件（包含<!DOCTYPE html>、<html>、<head>、<body>标签）
- 样式用<style>标签写在<head>里，脚本用<script>标签写在<body>底部
- 不要生成Python、Java等需要额外环境的代码，统一用 HTML+CSS+JavaScript
- 如果需要画图/动画，用 Canvas API 或 CSS 动画实现
- 如果需要游戏/交互，用 JavaScript DOM 操作实现
- 代码块用 \`\`\`html 标记，确保是完整可运行的HTML页面
- 生成的页面要色彩丰富、有趣，适合小学生`;

  const systemPrompt = currentLesson
    ? `你是一个友善的AI编程助教，正在教小学生"${currentLesson.title}"。
当前课程目标：${currentLesson.goal}。
请用简单、有趣、鼓励性的语言回答。回答要适合小学生阅读，控制在合理长度内。用emoji让回答更生动。
${codeRule}`
    : `你是一个友善的AI编程助教，面对的是小学生。请用简单、有趣、鼓励性的语言回答。
回答适合小学生阅读，用emoji让回答更生动。
${codeRule}`;

  chatHistory.push({ role: 'user', content: text });

  // 显示加载中
  const loadingId = addMessage('ai', '<span class="typing-dots">AI正在思考</span>');

  const sendBtn = document.getElementById('sendBtn');
  sendBtn.disabled = true;
  sendBtn.textContent = '思考中...';
  document.getElementById('chatStatus').textContent = '思考中';
  document.getElementById('chatStatus').style.background = '#fef3c7';
  document.getElementById('chatStatus').style.color = '#92400e';

  try {
    const response = await fetch('https://api.deepseek.com/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model: 'deepseek-chat',
        messages: [
          { role: 'system', content: systemPrompt },
          ...chatHistory.slice(-10)
        ],
        temperature: 0.7,
        max_tokens: 4096,
        stream: true
      })
    });

    if (!response.ok) {
      const err = await response.json().catch(() => ({}));
      throw new Error(err.error?.message || `请求失败 (${response.status})`);
    }

    // 流式读取
    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullReply = '';
    let buffer = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop(); // 保留未完成的行

      for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed || !trimmed.startsWith('data: ')) continue;
        const jsonStr = trimmed.slice(6);
        if (jsonStr === '[DONE]') continue;

        try {
          const chunk = JSON.parse(jsonStr);
          const delta = chunk.choices?.[0]?.delta?.content || '';
          if (delta) {
            fullReply += delta;
            updateMessage(loadingId, formatMarkdown(fullReply, true) + '<span class="typing-cursor">▍</span>');
          }
        } catch (e) { /* 跳过解析错误 */ }
      }
    }

    if (!fullReply) fullReply = '抱歉，AI没有返回内容。';
    chatHistory.push({ role: 'assistant', content: fullReply });
    updateMessage(loadingId, formatMarkdown(fullReply, false));
  } catch (err) {
    updateMessage(loadingId, `❌ 出错了：${err.message}<br><small>请检查API Key是否正确，或稍后重试</small>`);
  } finally {
    sendBtn.disabled = false;
    sendBtn.textContent = '发送 ✨';
    document.getElementById('chatStatus').textContent = '就绪';
    document.getElementById('chatStatus').style.background = '';
    document.getElementById('chatStatus').style.color = '';
  }
}

// ===== 聊天辅助函数 =====
let msgCounter = 0;

function addMessage(role, content) {
  const id = `msg-${++msgCounter}`;
  const container = document.getElementById('chatMessages');
  const div = document.createElement('div');
  div.className = `chat-msg ${role}`;
  div.id = id;
  div.innerHTML = content;
  container.appendChild(div);
  container.scrollTop = container.scrollHeight;
  return id;
}

function updateMessage(id, content) {
  const el = document.getElementById(id);
  if (el) { el.innerHTML = content; }
  const container = document.getElementById('chatMessages');
  container.scrollTop = container.scrollHeight;
}

function addSystemMessage(text) {
  addMessage('system', text);
}

function clearChat() {
  document.getElementById('chatMessages').innerHTML = '';
  chatHistory = [];
  document.getElementById('chatHint').classList.remove('hidden');
  addSystemMessage('🗑️ 对话已清空');
}

// ===== 键盘事件 =====
function handleKeyDown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
}

// ===== 移动端视图切换 =====
function showMobileView(view) {
  const sidebar = document.getElementById('sidebar');
  const content = document.getElementById('contentArea');
  const chat = document.getElementById('chatPanel');

  [sidebar, content, chat].forEach(el => el.classList.remove('show'));
  document.querySelectorAll('.mobile-tab').forEach(t => t.classList.remove('active'));

  if (view === 'sidebar') { sidebar.classList.add('show'); document.querySelectorAll('.mobile-tab')[0].classList.add('active'); }
  else if (view === 'content') { content.classList.add('show'); document.querySelectorAll('.mobile-tab')[1].classList.add('active'); }
  else if (view === 'chat') { chat.classList.add('show'); document.querySelectorAll('.mobile-tab')[2].classList.add('active'); }
}

// ===== 工具函数 =====
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// 存储代码块，用于运行
let codeBlocks = [];

function formatMarkdown(text, isStreaming) {
  // 先重置代码块存储（避免流式过程中重复追加）
  if (!isStreaming) codeBlocks = [];

  // 1) 已闭合的代码块 —— HTML代码块加"运行代码"按钮
  text = text.replace(/```(\w*)\n([\s\S]*?)```/g, (_, lang, code) => {
    const trimmed = code.trim();
    const isRunnable = (lang === 'html' || lang === 'htm' || trimmed.match(/^\s*<!DOCTYPE|^\s*<html|^\s*<body|^\s*<div|^\s*<canvas/i));
    if (isRunnable) {
      if (isStreaming) {
        // 流式中：只显示代码，不加按钮（避免重复添加）
        return `<div class="code-block-wrap"><pre><code>${escapeHtml(trimmed)}</code></pre><div class="btn-run-code" style="opacity:.5;pointer-events:none">⏳ 代码生成中...</div></div>`;
      }
      const idx = codeBlocks.length;
      codeBlocks.push(trimmed);
      return `<div class="code-block-wrap">
        <pre><code>${escapeHtml(trimmed)}</code></pre>
        <button class="btn-run-code" onclick="runCode(${idx})">▶ 运行代码看效果</button>
      </div>`;
    }
    return `<pre><code>${escapeHtml(trimmed)}</code></pre>`;
  });

  // 2) 未闭合的代码块（流式传输中，还没收到结尾的```）
  text = text.replace(/```(\w*)\n([\s\S]*)$/g, (_, lang, code) => {
    const trimmed = code.trim();
    return `<div class="code-block-wrap"><pre><code>${escapeHtml(trimmed)}</code></pre><div class="btn-run-code" style="opacity:.5;pointer-events:none">⏳ 代码生成中...</div></div>`;
  });

  // 行内代码（避免匹配到代码块的反引号）
  text = text.replace(/`([^`\n]+)`/g, '<code>$1</code>');
  // 粗体
  text = text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  // 斜体
  text = text.replace(/\*(.+?)\*/g, '<em>$1</em>');
  // 换行
  text = text.replace(/\n/g, '<br>');
  return text;
}

// 在弹窗iframe中运行代码
function runCode(index) {
  const code = codeBlocks[index];
  if (!code) return;
  const modal = document.getElementById('codePreviewModal');
  const iframe = document.getElementById('codePreviewFrame');
  modal.classList.add('show');
  // 写入iframe
  const doc = iframe.contentDocument || iframe.contentWindow.document;
  doc.open();
  doc.write(code);
  doc.close();
}

function closeCodePreview() {
  const modal = document.getElementById('codePreviewModal');
  const iframe = document.getElementById('codePreviewFrame');
  modal.classList.remove('show');
  // 清空iframe
  const doc = iframe.contentDocument || iframe.contentWindow.document;
  doc.open();
  doc.write('');
  doc.close();
}
