Shader "Mirror/MirrorSurfaceShader" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _NormalTex("Normal", 2D) = "bump"{}
        _NormalIntensity("Intensity", float) = 1

        _OcclusionTex("Occlusion", 2D) = "bump"{}
        _OcclusionIntensity("OcclusionIntensity", float) = 1

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _MetallicTex ("MetallicTex", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        UNITY_DECLARE_TEX2DARRAY(_ReflectionTex);
        int _Index;

        sampler2D _NormalTex;
        float _NormalIntensity;

        sampler2D _OcclusionTex;
        float _OcclusionIntensity;

        sampler2D _MetallicTex;

        struct Input {
            float2 uv_MainTex;
            float4 screenPos;
        };

        half _Glossiness;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v, out Input i) {

            UNITY_INITIALIZE_OUTPUT(Input, i);
            i.screenPos = ComputeScreenPos(v.vertex);
            // COMPUTE_EYEDEPTH(i.proj.z);
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            // reflectionColor
            fixed3 reflectionColor = UNITY_SAMPLE_TEX2DARRAY(_ReflectionTex, float3( IN.screenPos.xy / IN.screenPos.w, _Index));

            o.Albedo = lerp(c.rgb,reflectionColor.rgb,_Glossiness);
            // Metallic and smoothness come from slider variables
            fixed4 metallic = tex2D (_MetallicTex, IN.uv_MainTex);
            o.Metallic = metallic.r;
            o.Smoothness = metallic.a * _Glossiness;

            fixed3 n = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex)).rgb;
            n.x *= _NormalIntensity;
            n.y *= _NormalIntensity;
            o.Normal = n;

            o.Occlusion = tex2D (_OcclusionTex, IN.uv_MainTex).r * _OcclusionIntensity;

            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
