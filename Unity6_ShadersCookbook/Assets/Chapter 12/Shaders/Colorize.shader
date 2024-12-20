Shader "Cookbook Shaders/Chapter 12/Colorize"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DesatValue ("Desaturate", Range(0,1)) = 0.5
        _MyColor ("My Color", Color) = (1,1,1,1) 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            // Include URP core libraries for lighting and shading
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" // TransformObjectToHClip
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl" // Luminance
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "MyHLSLInclude.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION; // position
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DesatValue;

            v2f vert (appdata v)
            {
                v2f o;
                
                // Calculate world position and normal
                o.vertex = TransformObjectToHClip(v.vertex.xyz); 
                o.uv = v.uv;

                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);

                // Calculate the luminance for desaturation
                float luminance = Luminance(col.rgb);
                col.rgb = lerp(col.rgb, luminance.xxx, _DesatValue);

                // Fetch main light direction and color using URP functions
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float3 lightColor = mainLight.color;
                float3 customDiffuse = LightingHalfLambert(normalize(i.worldNormal), lightDir, lightColor, col.rgb, 1.0);

                // Apply custom lighting to the base color
                col.rgb *= customDiffuse;
                 
                return col;
            }
            ENDHLSL
        }
    }
}
