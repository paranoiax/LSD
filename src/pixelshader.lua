time = 0

pixelEffectSupported = love.graphics.isSupported("pixeleffect")

pixeleffect = love.graphics.newPixelEffect[[
extern number time;

// noise effect intensity value (0 = no effect, 1 = full effect)
extern number nIntensity;

// scanlines effect intensity value (0 = no effect, 1 = full effect)
extern number sIntensity;

// scanlines effect count value (0 = no effect, 4096 = full effect)
extern number sCount;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
{
	vec4 cTextureScreen = Texel( tex, tc);
	
	number x = tc.x * tc.y * time * 1000.0;
	x = mod( x, 13.0 ) * mod( x, 123.0 );
	number dx = mod( x, 0.01 );
	
	vec3 cResult = cTextureScreen.rgb + cTextureScreen.rgb * clamp( 0.1 + dx * 100.0, 0.0, 1.0 );
	
	vec2 sc = vec2( sin( tc.y * sCount ), cos( tc.y * sCount ) );
	
	cResult += cTextureScreen.rgb * vec3( sc.x, sc.y, sc.x ) * sIntensity;
	
	cResult = cTextureScreen.rgb + clamp( nIntensity, 0.0,1.0 ) * ( cResult - cTextureScreen.rgb );
	
	// cResult = vec3( cResult.r * 0.3 + cResult.g * 0.59 + cResult.b * 0.11 ); //grayscale
	return vec4( cResult, cTextureScreen.a );
	
}]]

pixeleffect:send("sIntensity", 0.025)
pixeleffect:send("sCount", 512)