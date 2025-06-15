var keyword:String;	// 关键词
var note:String;	// 备注
var speed:Number;	// 速度

function init(keyword:String, color:uint, textColor:uint, alpha:Number, size:Number):void
{
		this.keyword = keyword;
		setSize(keyword, color, textColor, alpha, size); // 调用整合后的setSize方法
}

function setSize(keyword:String, color:uint, textColor:uint, alpha:Number, size:Number):void
{
		// 清理旧子对象（解决对象池复用导致的文本重叠）
		while(numChildren > 0) removeChildAt(0);
		this.graphics.clear();	// 清除之前的绘制
		var scale:Number = size / 50; // 基于初始size=50的缩放因子

		var textField:Txt = new Txt();
		textField.txt.text = keyword;
		textField.txt.autoSize = TextFieldAutoSize.NONE; // 禁用自动调整，避免覆盖手动尺寸

		// 动态计算原始宽度（保持内边距逻辑）
		var baseWidth:Number = textField.txt.textWidth + 20; // 基础宽度
		var baseHeight:Number = textField.txt.textHeight + 10; // 基础高度

		// 应用缩放后的尺寸（直接作为文本框实际尺寸）
		var bubbleWidth:Number = baseWidth * scale;
		var bubbleHeight:Number = baseHeight * scale;

		// 调整文本框大小与气泡完全一致（禁用autoSize后手动设置尺寸）
		textField.txt.width = bubbleWidth;
		textField.txt.height = bubbleHeight;
		textField.txt.setTextFormat(new TextFormat(null, 50*scale, textColor)); // 使用高对比度文字颜色，并确保字体大小与气泡适配
		
		// 绘制圆角矩形
		this.graphics.beginFill(color, alpha);
		this.graphics.drawRoundRect(-bubbleWidth / 2, -bubbleHeight / 2, bubbleWidth, bubbleHeight, 30*scale);
		this.graphics.endFill();

		// 保持文本在中心位置
		textField.txt.x = 0;
		textField.txt.y = 0;
		textField.x = -bubbleWidth / 2;
		textField.y = -bubbleHeight / 2;
        addChild(textField);
}