import fl.containers.ScrollPane;

worning.visible=false;
addTopic.visible = false; // 确保添加话题面板初始不可见

var topicsContainer:MovieClip = new MovieClip(); // 初始化话题容器
var scrollPane:ScrollPane = new ScrollPane(); // 获取滚动条实例
//scrollPane.width = 500;
//scrollPane.height = 900;
//scrollPane.x = -250;
//scrollPane.y = -520;
scrollPane.verticalScrollPolicy = "auto"; // 自动显示垂直滚动条
scrollPane.horizontalScrollPolicy = "off"; // 禁用水平滚动条
scrollPane.verticalLineScrollSize = 100;
scrollPane.scrollDrag = true;
scrollPane.setSize(1520, 700); // 设置滚动容器的大小
scrollPane.move(-750, -420); // 设置滚动容器的位置
scrollPane.source = topicsContainer; // 设置滚动容器的内容源为话题容器
addChildAt(scrollPane, 3);

loadTopicsFromGlobalArray();    // 从全局数组加载话题数据

qd_btn.addEventListener(MouseEvent.CLICK,qdEvent);  // 单击确定按钮，关闭话题管理器
function qdEvent(e:MouseEvent):void
{
	MovieClip(root).menu_btn.visible=true;
	MovieClip(root).refresh_btn.visible=true;
	MovieClip(root).pause_btn.visible=true;
    if(MovieClip(root).bubbleManager.isPaused){
        MovieClip(root).onPause(e);	// 恢复暂停
    }
    this.visible=false;
}

addTopic_btn.addEventListener(MouseEvent.CLICK, showAddTopicPanel);
function showAddTopicPanel(e:MouseEvent):void
{
    addTopic.visible=true;
    addTopic.gotoAndStop(1);
    addTopic.topic.type="input";
    addTopic.topic.text="";
    addTopic.note.text="";
    stage.focus = addTopic.topic; // 正确设置焦点到文本字段
}

// 添加话题确认按钮点击事件
addTopic.qd_btn.addEventListener(MouseEvent.CLICK,confirmAddTopic);
function confirmAddTopic(e:MouseEvent):void
{
    if(addTopic.currentFrame == 1){    // 话题管理器第一帧
        addTopic.topic.text = addTopic.topic.text.replace(/^\s+|\s+$/g, "");   //剔除首尾空格
        var topicText:String = addTopic.topic.text;
        //var a:String="   abcdefg   ";
        //a=a.replace(/([  ]{1})/g, "");    //[  ]内是一个中文空格和一个英文空格，{1}表示匹配一个或多个，/g表示连续匹配。整条语句的功能时去掉内容的所有空格
        //trace(a);
        if(topicText == ""){    // 话题为空时,显示警告
            worning.visible=true;
            worning.gotoAndStop(1);
            return;
        }
        //话题已存在时，显示警告
        for(var i:int=0; i<MovieClip(root).topicsData.length; i++){
            if(topicText == MovieClip(root).topicsData[i].keyword){
                worning.visible=true;
                worning.gotoAndStop(2);
                return;
            }
        }
        // 存储话题数据
        var topicData:Object = {
            keyword: topicText,
            note: addTopic.note.text,
            mc: createTopicMC(topicText) // 创建topic元件实例
        };
        MovieClip(root).topicsData.push(topicData); // 存入全局数组
        // 添加到容器并排列
        topicsContainer.addChild(topicData.mc);
        arrangeTopics();
        // 添加新气泡
        MovieClip(root).bubbleManager.addBubble(topicText, addTopic.note.text, 0.6 + Math.random() * 0.3);
        MovieClip(root).bubbleManager.getBubbleByKeyword(topicText).addEventListener(MouseEvent.CLICK, MovieClip(root).onBubbleClick); // 添加气泡点击监听器
        addTopic.visible=false;

        // 存储话题数据到本地存储
        var so:SharedObject = SharedObject.getLocal("topicsData");
        so.data.topicsData = MovieClip(root).topicsData;
        so.flush(); // 刷新保存
        return;
    }
    if(addTopic.currentFrame == 2){    // 话题管理器第二帧
        var index:int = -1;
        for(var j:int=0; j<MovieClip(root).topicsData.length; j++) { // 将循环变量i改为j避免重复声明
            if(MovieClip(root).topicsData[j].keyword == addTopic.topic.text) {
                index = j;
                break;
            }
        } // 替换findIndex为手动遍历查找索引
	    if(index !== -1) {
		    MovieClip(root).topicsData[index].note = addTopic.note.text; // 保存编辑后的note
		    // 更新气泡管理器中的备注
		    MovieClip(root).bubbleManager.updateBubbleNote(addTopic.topic.text, addTopic.note.text);
	    }
        addTopic.visible=false;
        return;
    }
}

// 创建topic元件实例
function createTopicMC(keyword:String):MovieClip
{
    var topicMC:topic = new topic(); // 从库中创建元件
    // 处理文本截断（超过6字显示...）
    topicMC.topic_lable.text = keyword.length > 6 ? keyword.substr(0,6) + "..." : keyword;
    // 删除按钮点击事件
    topicMC.del_btn.addEventListener(MouseEvent.CLICK, onDelBtnClick);
    function onDelBtnClick(e:MouseEvent):void {
        var targetMC:MovieClip = e.currentTarget.parent;
        // 从数组中移除数据
        var index:int = -1;
        for(var i:int=0; i<MovieClip(root).topicsData.length; i++){
            if(MovieClip(root).topicsData[i].mc == targetMC){
                index = i;
                break;
            }
        }
        if(index != -1){
            var removedKeyword:String = MovieClip(root).topicsData[index].keyword; // 保存要删除的keyword
            MovieClip(root).topicsData.splice(index, 1);    // 从数组中移除数据
            // 获取并移除气泡点击监听器
            var bubble:Bubble = MovieClip(root).bubbleManager.getBubbleByKeyword(removedKeyword);
            if(bubble) {
                bubble.removeEventListener(MouseEvent.CLICK, MovieClip(root).onBubbleClick);
            }
            // 从气泡管理器删除对应气泡
            MovieClip(root).bubbleManager.removeBubbleByKeyword(removedKeyword);
            // 从容器中移除元件
            if(topicsContainer.contains(targetMC)){
                topicMC.del_btn.removeEventListener(MouseEvent.CLICK, onDelBtnClick); // 使用命名函数移除监听器
                topicMC.lable_btn.removeEventListener(MouseEvent.CLICK, editNote); // 移除事件监听器，避免内存泄漏
                topicsContainer.removeChild(targetMC);
            }
            arrangeTopics(); // 重新排列
            // 更新本地存储数据
            var so:SharedObject = SharedObject.getLocal("topicsData");
            so.data.topicsData = MovieClip(root).topicsData;
            so.flush(); // 刷新保存
        }
    }
    topicMC.lable_btn.addEventListener(MouseEvent.CLICK,editNote);
    function editNote(e:MouseEvent):void{
    	addTopic.visible=true;
        addTopic.gotoAndStop(2);
        addTopic.topic.type="dynamic";
        addTopic.topic.text = keyword;
        //根据keyword获取对应note
        var index:int = -1;
        for(var i:int=0; i<MovieClip(root).topicsData.length; i++) {
            if(MovieClip(root).topicsData[i].keyword == keyword) {
                index = i;
                break;
            }
        } // 替换findIndex为手动遍历查找索引
        if(index !== -1) {
            addTopic.note.text = MovieClip(root).topicsData[index].note;
        } else {
            addTopic.note.text = "";
        } // 添加索引有效性检查，避免数组越界
        stage.focus = addTopic.note;
    }
    return topicMC;
}

// 重新排列话题元件（从上到下）
function arrangeTopics():void
{
    var yPos:Number = 0;
    for(var i:int=0; i<topicsContainer.numChildren; i++){
        var mc:MovieClip = MovieClip(topicsContainer.getChildAt(i)); // 显式转换为MovieClip类型
        mc.y = yPos;
        yPos += mc.height; // 间隔0像素
    }
    //topicsContainer.height = yPos; // 设置容器高度为总高度
    scrollPane.update();
}

// 从全局数组加载话题到容器
function loadTopicsFromGlobalArray():void {
    // 清空现有容器（可选，根据需求决定是否保留原有内容）
    // topicsContainer.removeAllChildren();
    
    //如果没有话题数据，直接返回
    if(!MovieClip(root).topicsData) {
        return;
    }
    // 遍历全局话题数组
    for(var i:int=0; i<MovieClip(root).topicsData.length; i++) {
        var topic:Object = MovieClip(root).topicsData[i];
        // 重新创建topic元件实例（解决反序列化后mc丢失问题）
        var topicMC:MovieClip = createTopicMC(topic.keyword);
        topic.mc = topicMC; // 绑定mc属性
        // 添加到容器
        if(topicsContainer) {
            topicsContainer.addChild(topicMC);
        }
    }
    // 重新排列话题
    arrangeTopics();
}