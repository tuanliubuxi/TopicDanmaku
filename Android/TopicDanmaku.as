import flash.display.MovieClip;
import flash.events.MouseEvent;
import fl.transitions.Tween;	//缓动类库
import fl.transitions.easing.*;	//缓动效果库
import components.BubbleManager;	//气泡管理器
import flash.net.SharedObject;	// 导入本地存储类

var bgMod:int=0;		//背景状态

instruction.visible=false;		//隐藏说明页面
topicsManager.visible=false;		//隐藏话题管理器
noteBox.visible=false;			//隐藏备注框

// 全局话题数据数组（存储{keyword:String, note:String, mc:MovieClip}对象）
var topicsData:Array = [];

// ------------------- 气泡弹幕初始化代码 -------------------
var bubbleManager:BubbleManager = new BubbleManager();
function managerInit():void
{
	bubbleManager.x = 0; // 覆盖整个屏幕
	bubbleManager.y = 0;
	addChildAt(bubbleManager,4); // 添加到显示列表

	// 设置气泡初始参数（可通过侧边栏配置后续修改）
	bubbleManager.setBubbleSpeed(2.0); // 速度（像素/帧）
	//bubbleManager.setBubbleSize(60); // 气泡尺寸（像素）
	//bubbleManager.setBubbleDensity(8); // 同时显示的气泡数量

	// 从话题数据数组初始化气泡
	topicsData.forEach(function(topic:Object, index:int, array:Array):void {
        var randomAlpha:Number = 0.6 + Math.random() * 0.3; // 随机透明度（0.6-0.9）
        var bubble:Bubble = bubbleManager.addBubble(topic.keyword,topic.note,randomAlpha);
        bubble.addEventListener(MouseEvent.CLICK, onBubbleClick); // 添加气泡点击监听
    });
}

// 从本地存储加载话题数据
var so:SharedObject = SharedObject.getLocal("topicsData");
if (so.data.topicsData) {
    topicsData = so.data.topicsData as Array; // 显式转换为Array类型
}
if(so.data.topicsData.length == 0)
{
	//首次运行时添加默认数据
	pushData(topicsData,"点我一下看看","这是我的备注内容");
	pushData(topicsData,"#右滑进入菜单栏#","点击界面左上角的菜单栏按钮也可以打开菜单");
	pushData(topicsData,"#双击背景切换暗色模式#","再次双击可以切换回去");
	pushData(topicsData,"#点开“菜单栏——话题管理”，#","可以查看并编辑该话题对应的备注内容");
	pushData(topicsData,"#点一下右上角的“⏸”按钮试试#","所有气泡都暂停了哦");
	pushData(topicsData,"#点击“菜单栏——话题管理——添加话题”，可以添加话题，备注选填","同一个话题只能添加一次哦");
	pushData(topicsData,"#点击以下右上角的刷新按钮试试#","你会看到所有气泡的大小和颜色，还有飘动速度都发生了变化！");
	pushData(topicsData,"#菜单栏里的使用说明有更多详细信息#","有项目地址跟QQ交流群哦");
}

//初始化气泡
managerInit();
// 启动气泡动画（初始不暂停）
bubbleManager.resumeBubbles();
// ------------------- 以上为气泡弹幕初始化代码 -------------------

// 气泡点击处理函数
function onBubbleClick(e:MouseEvent):void {
    var clickedBubble:Bubble = e.currentTarget as Bubble;
	MovieClip(root).menu_btn.visible=false;
	MovieClip(root).refresh_btn.visible=false;
	MovieClip(root).pause_btn.visible=false;
	if(!bubbleManager.isPaused){	//如果未暂停
		onPause(e); // 暂停所有气泡
	}
    noteBox.visible = true; // 显示备注框
	noteBox.noteView.text = clickedBubble.note; // 设置备注内容
}

//topicData数组添加数据函数
function pushData(topicsData:Array,keyword:String,note:String):void
{
    // 将数据存入全局数组
    var topic:Object = {keyword:keyword, note:note};
	//如果该话题不存在则添加
    for (var i:int = 0; i < topicsData.length; i++) {
        if (topicsData[i].keyword === keyword) {
            return; // 话题已存在，不添加
        }
    }
    topicsData.push(topic); // 将新话题添加到全局数组
}

//给菜单按钮添加单击监听事件
menu_btn.addEventListener(MouseEvent.CLICK, menu_io);
function menu_io(e:MouseEvent):void
{
    var targetX:Number = sidebar.x == 0 ? -sidebar.main_bac.width : 0;
    new Tween(sidebar, "x", Strong.easeOut, sidebar.x, targetX, 0.5, true);
}

//双击背景切换主题
bg.doubleClickEnabled = true;
bg.addEventListener(MouseEvent.DOUBLE_CLICK,switchColor);
function switchColor(e:MouseEvent):void        //夜间模式切换
{
	bgMod = bgMod ? 0:1;
	var targetX:Number = bgMod == 1 ? 25 : -25;
	new Tween(sidebar.switch_btn.io, "x", Strong.easeOut, sidebar.switch_btn.io.x, targetX, 0.5, true);
	bg.gotoAndPlay(String(bgMod));        //弹幕区背景切换
	sidebar.main_bac.gotoAndPlay(String(bgMod));        //菜单栏背景切换
	edgeStyle.gotoAndPlay(String(bgMod));        //边界背景切换
	sidebar.switch_btn.bac.gotoAndPlay(String(bgMod));        //切换按钮底色切换
}

// 滑动手势处理
var startX:Number;
sidebar.transparent_bac.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
sidebar.transparent_bac.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
function handleMouseMove(e:MouseEvent):void
{
	var deltaX:Number=mouseX-startX;
	var targetX:Number = deltaX > 0 ? 0 : -sidebar.main_bac.width;
    new Tween(sidebar, "x", Strong.easeOut, sidebar.x, targetX, 0.5, true);
}
function handleMouseDown(e:MouseEvent):void
{
	startX = mouseX;
    sidebar.transparent_bac.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
}
function handleMouseUp(e:MouseEvent):void
{
	sidebar.transparent_bac.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
    var deltaX:Number = mouseX - startX;
	var targetX:Number = deltaX > 0 ? 0 : -sidebar.main_bac.width;
    new Tween(sidebar, "x", Strong.easeOut, sidebar.x, targetX, 0.5, true);
}

refresh_btn.addEventListener(MouseEvent.CLICK,onRefresh);	//刷新按钮
function onRefresh(e:MouseEvent):void
{
    if(topicsData.length === 0) return; // 无话题数据时不执行
    if(pause_btn.currentFrame==2)	//如果暂停
	{
		onPause(e);
	}
	// 触发气泡管理器刷新逻辑
	bubbleManager.reFresh();
}

pause_btn.addEventListener(MouseEvent.CLICK, onPause);	//暂停按钮
var isPause:Boolean = false;	// 暂停状态
function onPause(e:MouseEvent):void
{
    if(topicsData.length === 0) return; // 无话题数据时不执行
    pause_btn.gotoAndPlay(isPause? 1:2);	//切换暂停按钮状态
	isPause = !isPause;	// 切换暂停状态
	if (isPause)	// 暂停
	{
		bubbleManager.pauseBubbles();	// 暂停气泡
	} 
	else  	// 恢复
	{
		bubbleManager.resumeBubbles();	// 恢复
	}
}