package
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	[SWF(width="500",height="300",frameRate="30")]
	public class Box2DTutorial extends Sprite
	{
		//屏幕像素单位转换成物理世界的距离单位
		private const PIXEL_TO_METER:Number = 30;
		
		//物理世界
		private var world:Box2D.Dynamics.b2World;
		private var debugDraw : b2DebugDraw;
		private var _ballList : Vector.<b2Body>;
		
		
		public function Box2DTutorial()
		{
			_ballList = new Vector.<b2Body>();
			drawBackground();
			createWorld();
			createWall();
			createBall();
			createDebugDraw();
//			this.addEventListener(MouseEvent.CLICK,onClick);
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function onClick(e : MouseEvent):void
		{
			var ballBodyDef : b2BodyDef = new b2BodyDef();
			ballBodyDef.type = b2Body.b2_dynamicBody;
			ballBodyDef.userData = creatSpriteBall();
			var bollShape : b2CircleShape = new b2CircleShape(20 / PIXEL_TO_METER);
			var ballFix : b2FixtureDef = new b2FixtureDef();
			ballFix.shape = bollShape;
			ballFix.density = 2.0;
			ballFix.restitution = 0.5;
			ballBodyDef.position.Set(50/PIXEL_TO_METER,50/PIXEL_TO_METER);
			
//			var ballBody : b2Body = new b2Body(ballBodyDef,world);
			var ballBody : b2Body = world.CreateBody(ballBodyDef);
			ballBody.CreateFixture(ballFix);
			
			_ballList.push(ballBody);
		}
		
		private function createWorld():void
		{
			//重力向量
			var gravity:b2Vec2 = new b2Vec2(0,9.0);
			//是否休眠
			var doSleep:Boolean = true;
			world = new b2World(gravity,doSleep);
			//false时初始刚体不受重力影响，除非受力
			world.SetWarmStarting(true);
		}
		
		private function createWall():void
		{
			//1.需要创建的墙刚体
			var leftWall:b2Body;
			//2.刚体定义
			var leftWallBodyDef:b2BodyDef = new b2BodyDef();
			//刚体类型和位置
			leftWallBodyDef.type = b2Body.b2_staticBody;
			//注意刚体的注册中心都是在物体的中心位置
			leftWallBodyDef.position.Set(10/PIXEL_TO_METER, stage.stageHeight/2/PIXEL_TO_METER);
			//工厂模式创建刚体
			leftWall = world.CreateBody(leftWallBodyDef);
			
			//3.刚体修饰物定义
			var leftWallFixtureDef:b2FixtureDef = new b2FixtureDef();
			//密度
			leftWallFixtureDef.density = 1.0;
			//摩擦粗糙程度
			leftWallFixtureDef.friction = 0.3;
			//力度返回程度（弹性）
			leftWallFixtureDef.restitution = 1.0;
			
			//4.创建墙形状
			var leftWallShape:b2PolygonShape = new b2PolygonShape();
			//此处参数为宽和高度的一半值
			leftWallShape.SetAsBox(10/PIXEL_TO_METER, stage.stageHeight/2/PIXEL_TO_METER);
			
			//将形状添加到刚体修饰物
			leftWallFixtureDef.shape = leftWallShape;
			
			leftWall.CreateFixture(leftWallFixtureDef);
			
			//下面创建其他三面墙，共用leftwall的几个变量
			leftWallBodyDef.position.Set((stage.stageWidth-10)/PIXEL_TO_METER, stage.stageHeight/2/PIXEL_TO_METER);
			var rightWall:b2Body = world.CreateBody(leftWallBodyDef);
			rightWall.CreateFixture(leftWallFixtureDef);
			
			leftWallBodyDef.position.Set( stage.stageWidth/2/PIXEL_TO_METER, (stage.stageHeight-10)/PIXEL_TO_METER);
			var bottomWall:b2Body = world.CreateBody(leftWallBodyDef);
			leftWallShape.SetAsBox(stage.stageWidth/2/PIXEL_TO_METER, 10/PIXEL_TO_METER);
			bottomWall.CreateFixture(leftWallFixtureDef);
			
			
			leftWallBodyDef.position.Set( stage.stageWidth/2/PIXEL_TO_METER, 10/PIXEL_TO_METER);
			var topWall:b2Body = world.CreateBody(leftWallBodyDef);
			topWall.CreateFixture(leftWallFixtureDef);
		}
		
		private function createBall():void
		{
			for(var i:int = 0; i < 1; i++)
			{
				var ballDef:b2BodyDef = new b2BodyDef();
				ballDef.type = b2Body.b2_dynamicBody;
				ballDef.userData = creatSpriteBall();
				
				var circleShape:b2CircleShape  = new b2CircleShape((20)/PIXEL_TO_METER);
				var ballFixtureDef:b2FixtureDef = new b2FixtureDef();
				ballFixtureDef.shape = circleShape;
				ballFixtureDef.density = 2.0;
				ballFixtureDef.restitution = 0.5;
				ballFixtureDef.friction = 1;
				ballDef.position.Set(stage.stageWidth/2/PIXEL_TO_METER,20/PIXEL_TO_METER);
				var ball:b2Body = world.CreateBody(ballDef);
				ball.CreateFixture(ballFixtureDef);
				if(_ballList)
				{
					_ballList.push(ball);
				}
			}
		}
		
		private  function creatSpriteBall():Sprite
		{
			var sprite : Sprite = new Sprite();
			sprite.graphics.beginFill(0xFFFF00,1);
			sprite.graphics.drawCircle(0,0,20);
			sprite.graphics.endFill();
			this.addChild(sprite);
			return sprite;
		}
		
		private function createDebugDraw():void
		{
			//创建一个sprite，可以将测试几何物体放入其中
			var debugSprite:Sprite = new Sprite();
			addChild(debugSprite);
			debugDraw = new b2DebugDraw();
			debugDraw.SetSprite(debugSprite);
			//设置边框厚度
			debugDraw.SetLineThickness(1.0);
			//边框透明度
			debugDraw.SetAlpha(1.0);
			//填充透明度
			debugDraw.SetFillAlpha(0.5);
			//设置显示对象
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit);
			//物理世界缩放
			debugDraw.SetDrawScale(PIXEL_TO_METER);
			world.SetDebugDraw(debugDraw);
		}
		
		private function handleEnterFrame(evt:Event):void
		{
			var timeStep:Number = 1/30;
			var velocityInterations:int = 10;
			var positionIterations:int = 10;
			
			world.Step(timeStep,velocityInterations,positionIterations);
			//在2.1版本清除力，以提高效率
			world.ClearForces();
			//绘制
			world.DrawDebugData();
			if(_ballList)
			{
				trace(_ballList[0].GetDefinition().position.y * PIXEL_TO_METER);
				_ballList[0].GetUserData().x = _ballList[0].GetPosition().x * PIXEL_TO_METER;
				_ballList[0].GetUserData().y = _ballList[0].GetPosition().y * PIXEL_TO_METER;
			}
		}
		
		private function drawBackground():void
		{
			var bg:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.translate(100,100);
			bg.graphics.beginGradientFill(GradientType.RADIAL,[0xffffff,0xffaa00],[0.3,0.2],[0,255],matrix);
			bg.graphics.drawRect(0,0,stage.stageWidth,stage.stage.stageHeight);
			bg.graphics.endFill();
			addChild(bg);
		}
	}
}