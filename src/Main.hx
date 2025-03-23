import h3d.scene.Object;
import h3d.prim.ModelCache;
import h3d.scene.Mesh;
import h3d.prim.Cube;
import hxd.Key in K;

class WorldMesh extends h3d.scene.World {
	override function initChunkSoil(c:h3d.scene.World.WorldChunk) {
		var cube = new h3d.prim.Cube(chunkSize, chunkSize, 0);
		cube.addNormals();
		cube.addUVs();
		var soil = new h3d.scene.Mesh(cube, c.root);
		soil.x = c.x;
		soil.y = c.y;
		soil.material.texture = h3d.mat.Texture.fromColor(0x408020);
		soil.material.shadows = true;
	}
}

class Main extends hxd.App {

	var world : h3d.scene.World;
	var shadow :h3d.pass.DefaultShadowMap;
	var tf : h2d.Text;

    var s:Mesh;
    var s2:Object;

    var fui : h2d.Flow;

	override function init() {

		world = new WorldMesh(16, s3d);
		var t = world.loadModel(hxd.Res.tree);
		var r = world.loadModel(hxd.Res.rock);

        final prim = new Cube(4, 5, 6, true);
        prim.addNormals();
        prim.addUVs();
        s = new Mesh(prim, null, s3d);

        final cache = new ModelCache();
        s2 = cache.loadModel(hxd.Res.rock);
        s2.setScale(5);
        s3d.addChild(s2);

		for( i in 0...1000 )
			world.add(Std.random(2) == 0 ? t : r, Math.random() * 128, Math.random() * 128, 0, 1.2 + hxd.Math.srand(0.4), hxd.Math.srand(Math.PI));

        // world.add(s, 0, 0, 0, 5);

		world.done();

		//
		new h3d.scene.fwd.DirLight(new h3d.Vector( 0.3, -0.4, -0.9), s3d);
		cast(s3d.lightSystem,h3d.scene.fwd.LightSystem).ambientLight.setColor(0x909090);

		s3d.camera.target.set(72, 72, 0);
		s3d.camera.pos.set(120, 120, 40);

		shadow = s3d.renderer.getPass(h3d.pass.DefaultShadowMap);
		shadow.size = 2048;
		shadow.power = 200;
		shadow.blur.radius = 0.0;
		shadow.bias *= 0.1;
		shadow.color.set(0.7, 0.7, 0.7);

		//
		var parts = new h3d.parts.GpuParticles(world);
		var g = parts.addGroup();
		g.size = 0.2;
		g.gravity = 1;
		g.life = 10;
		g.nparts = 10000;
		g.emitMode = CameraBounds;
		parts.volumeBounds = h3d.col.Bounds.fromValues( -20, -20, 15, 40, 40, 40);

		s3d.camera.zNear = 1;
		s3d.camera.zFar = 100;
		new h3d.scene.CameraController(s3d).loadFromCamera();

		tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);

		fui = new h2d.Flow(s2d);
		fui.layout = Vertical;
		fui.verticalSpacing = 5;
		fui.padding = 10;

        // requires `dom` be commented out in h2d.Flow
        addSlider("ax", function() return ax, function(x) { ax = x; }, 0, 6);
        addSlider("ay", function() return ay, function(x) { ay = x; }, 0, 6);
        addSlider("az", function() return az, function(x) { az = x; }, 0, 1000);
        addSlider("angle", function() return angle, function(x) { angle = x; }, 0, Math.PI * 2);
	}

    var ax:Float = 0.0;
    var ay:Float = 0.0;
    var az:Float = 0.0;
    var angle:Float = 0.0;

    var q:Float = 0.0;
    // var e:Float = 0.0;

	override function update(dt:Float) {
        if (K.isDown('A'.code)) s.x -= 1;
        if (K.isDown('D'.code)) s.x += 1;
        if (K.isDown('W'.code)) s.y -= 1;
        if (K.isDown('S'.code)) s.y += 1;
        if (K.isDown('Q'.code)) q += 0.1;
        if (K.isDown('E'.code)) q -= 0.1;

        s.setRotation(0, 0, q);

        // trace(ax, ay, az, angle, e, q);

		tf.text = ""+engine.drawCalls;
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}

	function addSlider( label : String, get : Void -> Float, set : Float -> Void, min : Float = 0., max : Float = 1. ) {
		var f = new h2d.Flow(fui);

		f.horizontalSpacing = 5;

		var tf = new h2d.Text(getFont(), f);
		tf.text = label;
		tf.maxWidth = 70;
		tf.textAlign = Right;

		var sli = new h2d.Slider(100, 10, f);
		sli.minValue = min;
		sli.maxValue = max;
		sli.value = get();

		var tf = new h2d.TextInput(getFont(), f);
		tf.text = "" + hxd.Math.fmt(sli.value);
		sli.onChange = function() {
			set(sli.value);
			tf.text = "" + hxd.Math.fmt(sli.value);
			f.needReflow = true;
		};
		tf.onChange = function() {
			var v = Std.parseFloat(tf.text);
			if( Math.isNaN(v) ) return;
			sli.value = v;
			set(v);
		};
		return sli;
	}
	function getFont() {
		return hxd.res.DefaultFont.get();
	}
}
