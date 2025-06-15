package components {
	import flash.display.Sprite;
	import flash.events.Event;

	public class BubbleManager extends Sprite {
		private var bubbles:Array; // 存储所有气泡的数组
		private var bubblePool:Array; // 气泡对象池
		public var isPaused:Boolean = false; // 动画是否暂停标志

		private var bubbleSpeed:Number = 2.0;
		private var bubbleSize:Number = 50;
		private var bubbleDensity:int = 10;	// 气泡密度

		public function BubbleManager() {
			bubbles = [];
			bubblePool = [];

			// 等待 stage 初始化
			if (stage) {
				initialize();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}

		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initialize();
		}

		private function initialize():void {
			// 确保 stage 已初始化后再添加事件监听器
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function addBubble(keyword:String,note:String, alpha:Number):Bubble {
			// 生成柔和的随机背景色（HSL模式：色相随机，饱和度0.7，亮度0.5）
			var hue:Number = Math.random() * 360;	// 随机色相
			var saturation:Number = 0.7;	// 随机饱和度
			var lightness:Number = 0.5;	// 随机亮度
			var color:uint = hslToRgb(hue, saturation, lightness);	// 计算HSL颜色
			// 计算高对比度文字颜色（根据背景亮度选择黑/白）
			var textColor:uint = getContrastColor(color);	// 计算高对比度文字颜色
			// 从对象池中获取一个气泡对象
			var bubble:Bubble = bubblePool.length > 0 ? bubblePool.pop() : new Bubble();

			var randomScale:Number = Math.random() * 1.5 + 0.5; // 随机缩放因子（0.5-2.0）
			var size:Number = bubbleSize * randomScale; // 计算随机size
			bubble.init(keyword, color, textColor, alpha, size); // 传递背景色、文字色、透明度和尺寸参数
			bubble.speed = Math.random() * bubbleSpeed + 0.2; // 随机初始速度（0.5-2.0）
			bubble.note = note;
			bubbles.push(bubble);
			initPosition(bubble);	// 初始化气泡位置
			addChild(bubble);

			// 为气泡添加动画
			bubble.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			return bubble;
		}

		public function setBubbleSpeed(speed:Number):void {	// 设置气泡速度速度
			bubbleSpeed = speed;
		}

		public function setBubbleSize(size:Number):void {	// 设置气泡的大小
			bubbleSize = size;
			for each (var bubble:Bubble in bubbles) {
				// 传递气泡的keyword、color、alpha及新size调用setSize
				bubble.setSize(bubble.keyword, bubble.color, bubble.textColor, bubble.alpha, size);
			}			
		}

		/** 将HSL颜色转换为RGB的uint值 */
		private function hslToRgb(h:Number, s:Number, l:Number):uint {
			var r:Number, g:Number, b:Number;
			if (s == 0) {
				r = g = b = l;
			} else {
				var hue2rgb = function(p:Number, q:Number, t:Number):Number {
					if (t < 0) t += 1;
					if (t > 1) t -= 1;
					if (t < 1/6) return p + (q - p) * 6 * t;
					if (t < 1/2) return q;
					if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
					return p;
				};
				var q:Number = l < 0.5 ? l * (1 + s) : l + s - l * s;
				var p:Number = 2 * l - q;
				r = hue2rgb(p, q, h / 360 + 1/3);
				g = hue2rgb(p, q, h / 360);
				b = hue2rgb(p, q, h / 360 - 1/3);
			}
			return ((Math.round(r * 255) << 16) | (Math.round(g * 255) << 8) | Math.round(b * 255));
		}

		/** 根据背景色亮度返回高对比度文字颜色（黑或白） */
		private function getContrastColor(bgColor:uint):uint {
			var r:Number = (bgColor >> 16) & 0xFF;
			var g:Number = (bgColor >> 8) & 0xFF;
			var b:Number = bgColor & 0xFF;
			var luminance:Number = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
			return luminance > 0.5 ? 0x000000 : 0xFFFFFF;
		}

		/** 根据关键词删除对应气泡 */
		public function removeBubbleByKeyword(keyword:String):void {
			var toRemove:Array = [];
			for each (var bubble:Bubble in bubbles) {
				if (bubble.keyword == keyword) {
					toRemove.push(bubble);
				}
			}
			// 移除匹配的气泡
			for each (var b:Bubble in toRemove) {
				b.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				bubblePool.push(b);	// 放回对象池
				removeChild(b);
				bubbles.splice(bubbles.indexOf(b), 1);
			}
		}

		public function setBubbleDensity(spacing:Number):void {	// 设置气泡密度
			if (bubbles.length < 2) return; // 气泡数不足2时不调整

			// 保存当前间距（密度值）
			bubbleDensity = spacing;

			// 计算气泡水平排列的总可用宽度（屏幕宽度减去单个气泡宽度）
			var totalAvailableWidth:Number = stage.stageWidth - bubbles[0].width;
			// 计算每个气泡的目标x坐标（均匀分布）
			for (var i:int = 0; i < bubbles.length; i++) {
				var bubble:Bubble = bubbles[i];
				// 间距=spacing，气泡从左到右排列，起始位置为屏幕左侧外（保持原有移动逻辑）
				bubble.x = -bubble.width + (i * (bubble.width + spacing));
				// 保持y坐标随机，避免垂直重叠
				bubble.y = Math.random() * (1280 - bubble.height);
			}
		}

		private function onEnterFrame(event:Event):void {
			if (isPaused) return;

			for each (var bubble:Bubble in bubbles) {
				// 气泡水平移动
				bubble.x += bubble.speed;

				// 超出屏幕右侧时重置位置
				if (bubble.x - bubble.width > stage.stageWidth) {
					initPosition(bubble);
				}
			}
		}

		public function pauseBubbles():void {	// 暂停气泡动画
			isPaused = true;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function resumeBubbles():void {	// 恢复气泡动画
			isPaused = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function getBubbleByKeyword(keyword:String):Bubble {	// 通过关键词获取气泡实例
			for each (var bubble:Bubble in bubbles) {
				if(bubble.keyword == keyword) {
					return bubble;
				}
			}
			return null;
		}

		public function updateBubbleNote(keyword:String, newNote:String):void {	// 更新气泡备注
			for each (var bubble:Bubble in bubbles) {
				if(bubble.keyword == keyword) {
					bubble.note = newNote;
				}
			}
		}

		public function reFresh():void {	// 刷新气泡属性
			for each (var bubble:Bubble in bubbles) {
				// 重新生成颜色
				var hue:Number = Math.random() * 360;
				var color:uint = hslToRgb(hue, 0.7, 0.5);
				var textColor:uint = getContrastColor(color);
				// 重新生成速度
				bubble.speed = Math.random() * bubbleSpeed + 0.2;
				// 更新气泡显示
				bubble.setSize(bubble.keyword, color, textColor, bubble.alpha, bubbleSize * (Math.random() * 1.5 + 0.5));
				initPosition(bubble);
			}
		}

		public function clearBubbles():void {	// 清除所有气泡
			for each (var bubble:Bubble in bubbles) {
				bubble.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				bubblePool.push(bubble);	// 放回对象池
				removeChild(bubble);
			}
			bubbles = [];
		}

		private function initPosition(bubble:Bubble):void {
			// 计算气泡的初始位置，确保不超出屏幕
			bubble.x = -(bubble.width/2); // 初始位置，从屏幕左侧外
			bubble.y = Math.random() * (1300 - 220 - bubble.height) + 110 + bubble.height/2; // 随机y位置
		}
	}
}