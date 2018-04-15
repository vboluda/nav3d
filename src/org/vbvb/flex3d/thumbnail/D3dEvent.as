package org.vbvb.flex3d.thumbnail
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	import org.vbvb.flex3d.Container3d;
	
	public class D3dEvent extends MouseEvent
	{
		public static var THUMBNAIL_CLICK_EVENT:String="thumbnailClickEvent";
		public static var BRING_BACK:String="bringBack";
		public static var BRING_FRONT:String="bringFront";
		
		public function D3dEvent(type:String, 
									   thumbnailContainer:Container3d,
									   closedContainer:Container3d=null,
									   bubbles:Boolean=true, 
									   cancelable:Boolean=false, 
									   localX:Number=Number.NaN, 
									   localY:Number=Number.NaN, 
									   relatedObject:InteractiveObject=null, 
									   ctrlKey:Boolean=false, 
									   altKey:Boolean=false,
									   shiftKey:Boolean=false, 
									   buttonDown:Boolean=false, 
									   delta:int=0,
									   xPosition:Number=0,
									   yPosition:Number=0)
		{
			super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			this._thumbnailContainer=thumbnailContainer;
			this._xPosition=xPosition;
			this._yPosition=yPosition;
		}
		
		
		private var _thumbnailContainer:Container3d=null;
		
		public function get thumbnailContainer():Container3d
		{
			return _thumbnailContainer;
		}

		public function set thumbnailContainer(value:Container3d):void
		{
			_thumbnailContainer = value;
		}
		
		private var _closedContainer:Container3d=null;

		public function get closedContainer():Container3d
		{
			return _closedContainer;
		}

		public function set closedContainer(value:Container3d):void
		{
			_closedContainer = value;
		}
		
		private var _xPosition:Number=0;

		public function get xPosition():Number
		{
			return _xPosition;
		}

		public function set xPosition(value:Number):void
		{
			_xPosition = value;
		}

		private var _yPosition:Number=0;

		public function get yPosition():Number
		{
			return _yPosition;
		}

		public function set yPosition(value:Number):void
		{
			_yPosition = value;
		}


	}
}