Shader "Custom/Fractal" {
	Properties {
		_MainTex ("Color Gradient (horizontal)", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		
        _FractalWorldPos ("Fractal Position (world-space)", Vector) = (0,0,0,0)
		_FractalPower ("Fractal Power", Range(0.01,8.0)) = 3.0
		_FractalScale ("Fractal Scale", Float) = 2.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" } //TODO: Alpha cutout.
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows addshadow
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0


		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		sampler2D _MainTex;
		float3 _Color;
		
        float3 _FractalWorldPos;
		float _FractalPower;
		float _FractalScale;
		
		
		struct FractalData {
			//The distance to the fractal and
			//    the number of iterations it took to get there (from 0 to 1).
			float dist, iterationsT;
			//Some data based on the fractal algorithm. Can be used for coloring.
			float2 data;
		};
		FractalData getFractalInfoAt(float3 pos) {
			//Taken from my shader at www.shadertoy.com/view/llf3Wl
			const int nIterations = 4;
			const float bailout = 2.0;
			
			float3 z = pos;
			FractalData fractal;
			fractal.data = float2(0.0, 1.0);
			fractal.iterationsT = 0.0;
			for (int i = 0; i < nIterations; ++i) {
				fractal.data.x = length(z);
				fractal.iterationsT += 1.0;
				
				if (fractal.data.x > bailout) {
					break;
				}
				
				//Convert to polar coordinates.
				float theta = acos(z.z / fractal.data.x);
				float phi = atan2(z.y, z.x);
				
				fractal.data.y = 1.0 + (pow(fractal.data.x, _FractalPower - 1.0) *
										_FractalPower * fractal.data.y);
										
				//Scale and rotate the point.
				float zr = pow(fractal.data.x, _FractalPower);
				theta *= _FractalPower;
				phi *= _FractalPower;
				
				//Convert back to cartesian coordinates.
				z = zr * float3(sin(theta) * cos(phi),
								sin(phi) * sin(phi) * sin(theta),
								cos(theta));
				z += pos;
			}
			
			fractal.dist = 0.5 * log(fractal.data.x) * (fractal.data.x / fractal.data.y);
			fractal.iterationsT = nIterations / float(nIterations);
			return fractal;
		}
		float3 getFractalNormalAt(float3 pos) {
			const float2 epsilon = float2(0.0, 0.001);
			return normalize(float3(getFractalInfoAt(pos + epsilon.yxx).dist -
										getFractalInfoAt(pos - epsilon.yxx).dist,
									getFractalInfoAt(pos + epsilon.xyx).dist -
										getFractalInfoAt(pos - epsilon.xyx).dist,
									getFractalInfoAt(pos + epsilon.xxy).dist -
										getFractalInfoAt(pos - epsilon.xxy).dist));
		}
		
		struct RaycastResult {
			float3 hitPos;
			float moveDist;
			float didHit;
			float nIterations;
			FractalData fractal;
		};
		RaycastResult castRay(float3 rayStart, float3 rayDir) {
			RaycastResult result;
			result.hitPos = rayStart;
			result.didHit = 0.0;
			result.nIterations = 0.0;
			
			const int nIterations = 200;
			const float distanceEpsilon = 0.01;
			
			for (int i = 0; i < nIterations; ++i) {
				result.nIterations += 1.0;
				result.fractal = getFractalInfoAt(result.hitPos);
				
				if (result.fractal.dist < distanceEpsilon) {
					result.didHit = 1.0;
					break;
				}
				
				result.hitPos += result.fractal.dist * rayDir;
				result.moveDist += result.fractal.dist;
			}
			
			return result;
		}
		
		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			
			RaycastResult castResult = castRay((IN.worldPos - _FractalWorldPos) * _FractalScale,
											   normalize(IN.worldPos - _WorldSpaceCameraPos));
											   
			o.Alpha = castResult.didHit;
			
			if (castResult.didHit > 0.5) {
				//Choose a value ini the color ramp based on some aspect of the fractal.
				float colorT = castResult.fractal.data.x * 0.05;/// 10000.0;
				colorT = atan2(castResult.fractal.data.y * 0.01, castResult.fractal.data.x);
				
				o.Albedo = tex2D(_MainTex, float2(colorT, 0.0));
				o.Albedo.rgb *= _Color;
				//o.Albedo.xyz = colorT;
				o.Normal = getFractalNormalAt(castResult.hitPos);
			} else {
				discard;
			}
		}
		ENDCG
	}
	FallBack "Diffuse"
}
