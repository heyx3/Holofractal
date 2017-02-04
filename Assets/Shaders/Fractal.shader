Shader "Custom/Fractal" {
	Properties {
		_MainTex ("Color Gradient (horizontal)", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		
        _FractalWorldPos ("Fractal Position (world-space)", Vector) = (0,0,0,0)
		_FractalPower ("Fractal Power", Range(0.01,8.0)) = 3.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" } //TODO: Alpha cutout.
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
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

		
		struct RaycastResult {
			float3 hitPos, hitNormal;
			float colorT;
			float didHit;
		};
		RaycastResult castRay(float3 rayStart, float3 rayDir) {
			RaycastResult result;
			result.hitPos = rayStart;
			result.hitNormal = float3(1.0, 0.0, 0.0);
			result.didHit = 1.0;
			result.colorT = 0.0;
			
			//TODO: Implement.
			
			return result;
		}
		
		void surf (Input IN, inout SurfaceOutputStandard o) {
			RaycastResult castResult = castRay(IN.worldPos,
											   normalize(IN.worldPos - _WorldSpaceCameraPos));
			o.Albedo = tex2D(_MainTex, float2(castResult.colorT, 0.0));
			o.Normal = castResult.hitNormal;
			o.Alpha = castResult.didHit;
			
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
