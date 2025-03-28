class ATShader extends hxsl.Shader {

	static var SRC = {
        @:import h3d.shader.BaseMesh;

		@input var props : {
			var uv : Vec2;
		};

		@const @param var useSourceUVs : Bool = true;
		@const @param var blendBetweenFrames : Bool = true;


		@param var texture : Sampler2D;
		// var pixelColor : Vec4;

		var animatedUV : Vec2;
		var animatedUV2 : Vec2;

		// @global var global : {
		// 	var time : Float;
		// };
		@perInstance @param var startFrame : Float = 0.0;
		@param var speed : Float;
		@param var frameDivision : Vec2;
		@param var totalFrames : Float;
		@perInstance @param var startTime : Float;
		@const var loop : Bool;

		@private var blendFactor : Float;

		var textureColor : Vec4;
		var calculatedUV : Vec2;


		function vertex() {
			var frame = (global.time - startTime) * speed + float(int(startFrame));
			blendFactor = frame.fract();
			frame = floor(frame);
			if( loop ) frame %= totalFrames else frame = min(frame, totalFrames - 1);
			var nextFrame = if( loop ) (frame + 1) % totalFrames else min(frame + 1, totalFrames - 1);

			var delta = vec2( frame % frameDivision.x, float(int(frame / frameDivision.x)) );
			animatedUV = (delta) / frameDivision;
			var delta = vec2( nextFrame % frameDivision.x, float(int(nextFrame / frameDivision.x)) );
			animatedUV2 = (delta) / frameDivision;
		}

		function __init__fragment() {
			textureColor = mix( texture.get((useSourceUVs ? props.uv : calculatedUV) / frameDivision + animatedUV) , texture.get((useSourceUVs ? props.uv : calculatedUV) / frameDivision + animatedUV2), blendBetweenFrames ? blendFactor : 0.0);
		}

		function fragment() {
			pixelColor *= textureColor;
		}

	};


	public function new( texture, frameDivisionX : Int, frameDivisionY : Int, totalFrames = -1, ?speed = 1.) {
		super();
		this.texture = texture;
		if( totalFrames < 0 ) totalFrames = frameDivisionX * frameDivisionY;
		this.frameDivision.set(frameDivisionX,frameDivisionY);
		this.totalFrames = totalFrames;
		this.speed = speed;
		this.loop = true;
	}

}