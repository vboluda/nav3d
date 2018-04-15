package org.vbvb.flex3d
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.charts.chartClasses.IChartElement;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.messaging.AbstractConsumer;
	import mx.styles.StyleManager;
	
	import org.vbvb.flex3d.thumbnail.D3dEvent;
	import org.vbvb.flex3d.thumbnail.ThumbnaiItemRenderer;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Image;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;

	[Event(D3dEvent.BRING_BACK,org.vbvb.flex3d.thumbnail.D3dEvent)]
	[Event(D3dEvent.BRING_FRONT,org.vbvb.flex3d.thumbnail.D3dEvent)]
	public class Container3d extends Group
	{
		[Bindable]
		private var _contained:UIComponent;
		private var panel3d:Panel3D;
		private var _thumbnail:BitmapData=null;
		
		[Bindable]
		private var staticImage:Image=new Image();
		
		
		
		[Embed (source="close.png" )]
		public static const closeRes:Class;
		
//		private var borderc:BorderContainer=new BorderContainer();
		
		private var close:Image=new Image();
		
		
		public function Container3d(c:UIComponent,apanel3d:Panel3D)
		{
			layout=new BasicLayout();
			panel3d=apanel3d;
			close.source=closeRes;
			close.width=25;
			close.height=25;
			close.x=c.width/2-close.width-5;
			close.y=5;
			close.addEventListener(MouseEvent.MOUSE_MOVE,onMove);
			close.addEventListener(MouseEvent.CLICK,onClick);
			close.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			contained=c;
			this.addElement(c);
			contained.addEventListener(MouseEvent.CLICK,click);
			contained.removeEventListener(MouseEvent.CLICK,bringToBack);
//			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOutContainer);
			x=c.x+(c.width/2);
			width=c.width;
			y=c.y;
			height=c.height;
			contained.x=c.x-(c.width/2);
			calculateThumnail();
		}
		
		private function onMove(e=null){
			close.alpha=0.3;
		}
		
		private function onMouseOut(e=null){
			close.alpha=1;
		}
		
		private function onClick(e=null){
			bringToBack();
		}
		
		private function click(event:MouseEvent=null){
			if(panel3d.dragFlag) return;
			if((panel3d.selectedPanel==null) || (panel3d.selectedPanel!=this)){
				event.stopImmediatePropagation();
			}
			if(panel3d.selectedPanel!=null) return;
			panel3d.selectedPanel=this;
			bringToFront(panel3d.px,contained.y,0);
		}
		
		private var _angle:Number;

		public function get angle():Number
		{
			return _angle;
		}

		public function set angle(value:Number):void
		{
			_angle = value;
		}
		
		private var _initialAngle:Number;
		
		protected var oldx:Number=x;
		protected var oldy:Number=y;
		protected var oldz:Number=z;
		
		protected var oldrx:Number=rotationX;
		protected var oldry:Number=rotationY;
		protected var oldrz:Number=rotationZ;
		
		var toFrontSMP:SimpleMotionPath=new SimpleMotionPath("variable");
		var toFront:Animate=new Animate();
	
		public function bringToFront(ax:Number=0,ay:Number=0,az:Number=0){
			toggleToContainer();
			oldx=x;
			oldy=y;
			oldz=z;
			oldrx=rotationX;
			oldry=rotationY;
			oldrz=rotationZ;
			landax=(ax-x)/(az-z);
			landary=(0-rotationY)/(az-z);
			toFrontSMP.valueFrom=this.variable;
			toFrontSMP.valueTo=az;
			toFront.motionPaths=new Vector.<MotionPath>();
			toFront.motionPaths.push(toFrontSMP);
			toFront.addEventListener(EffectEvent.EFFECT_END,endFront);
			toFront.play([this]);
		}
		
		private function endFront(e){
			toFront.removeEventListener(EffectEvent.EFFECT_END,endFront);
//			contained.addEventListener(MouseEvent.CLICK,bringToBack);
			contained.removeEventListener(MouseEvent.CLICK,bringToFront);
			this.addElement(close);
			panel3d.selectedPanel=this;
			dispatchEvent(new D3dEvent(D3dEvent.BRING_FRONT,this));
			var event:D3dEvent=new D3dEvent(D3dEvent.BRING_FRONT,this);
			event.xPosition=x+this.contained.x;
			event.yPosition=y;
			contained.dispatchEvent(event);
		}
		
		private function ToggleToImage(){
//			contained.visible=false;
//			staticImage.visible=true;
			if(containsElement(contained)){
				removeElement(contained);
			}
			if(!contains(staticImage)){
				addElement(staticImage);
			}
		}
		
		private function toggleToContainer(){
//			contained.visible=true;
//			staticImage.visible=false;
			if(containsElement(staticImage)){
				removeElement(staticImage);
			}
			if(!contains(contained)){
				addElement(contained);
			}
		}
		
		public function bringToBack(e=null){
			calculateThumnail();
			this.removeElement(close);
			toFront.addEventListener(EffectEvent.EFFECT_END,endBack);
//			contained.removeEventListener(MouseEvent.CLICK,bringToBack);
			toFront.play([this],true);
		}
		
		private function endBack(e){
			toFront.removeEventListener(EffectEvent.EFFECT_END,endBack);
			contained.addEventListener(MouseEvent.CLICK,click);
			contained.removeEventListener(MouseEvent.CLICK,bringToBack);
			panel3d.selectedPanel=null;
			panel3d.collectionChange();
			var newEvent:D3dEvent=new D3dEvent(D3dEvent.BRING_BACK,this);
//			calculateThumnail();
			ToggleToImage();
			dispatchEvent(newEvent);
		}
		
		public function get variable():Number{
			return z;
		}
		private var landax:Number=0;
		private var landary:Number=0;
		
		public function set variable(v:Number):void{
			z=v;
			x=panel3d.px+z*landax;
			rotationY=z*landary;
			panel3d.removeElement(this);
			panel3d.addElement(this);
		}
		
		
		private function calculateThumnail():void{
			trace("Calculating thumbnail ");
			thumbnail=new BitmapData(contained.width,contained.height);
			thumbnail.draw(contained);
			staticImage.x=contained.x;
			staticImage.y=contained.y;
			staticImage.width=contained.width;
			staticImage.height=contained.height;
			staticImage.source=thumbnail;
			//staticImage.source=close.source;
			this.removeElement(contained);
			this.addElement(staticImage);
			//ToggleToImage();
			staticImage.addEventListener(MouseEvent.CLICK,click);
		}

		public function get contained():UIComponent
		{
			return _contained;
		}

		public function set contained(value:UIComponent):void
		{
			_contained = value;
		}

		[Bindable]
		public function get thumbnail():BitmapData
		{
			return _thumbnail;
		}

		public function set thumbnail(value:BitmapData):void
		{
			_thumbnail = value;
		}

		public function get initialAngle():Number
		{
			return _initialAngle;
		}

		public function set initialAngle(value:Number):void
		{
			_initialAngle = value;
		}


	}
}